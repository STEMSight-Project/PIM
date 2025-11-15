#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Live inference demo (GPU-optimized) — POSE-ONLY (33 landmarks) — compatible with
PoseTCN **Multi-View** checkpoints from your trainer (early/late/hybrid fusion,
Temporal MHA pooling, optional view attention).

Key points:
- Hands removed entirely (pose-only 33 per view)
- Single camera input; when a multi-view model is loaded, we **tile** the same
  view across V (matches your trainer interface)
- Supports heads/dropout/fusion settings saved in the checkpoint args
- GPU tweaks: TF32 enable, BF16/FP16 autocast
"""

import argparse, time
from collections import deque, Counter
from typing import Optional, Tuple
from datetime import datetime
import uuid

import numpy as np
import cv2
import torch
import torch.nn as nn
import mediapipe as mp

# Database imports (optional - will check if available)
try:
    import sys
    from pathlib import Path
    parent_dir = Path(__file__).resolve().parent.parent
    sys.path.insert(0, str(parent_dir))
    from core.common import supabase, logger
    DATABASE_AVAILABLE = True
except ImportError:
    DATABASE_AVAILABLE = False
    supabase = None
    logger = None

# ---------------- Constants ----------------
ALL_CLASSES = ["normal","decorticate","dystonia","chorea","myoclonus",
               "decerebrate","fencer posture","ballistic","tremor","versive head"]
NUM_POSE = 33
L_SHOULDER, R_SHOULDER, L_HIP, R_HIP = 11, 12, 23, 24

# ---------------- Normalization ----------------
def normalize_pose(seq: np.ndarray) -> np.ndarray:
    """
    Center by hips (fallback shoulders), scale by robust median of pose-only distances.
    Matches train.py normalize_single_view() exactly.
    seq: (T, 33, 3)
    """
    pose = seq[:, :NUM_POSE, :]
    hips_ok = (np.any(pose[:, L_HIP] != 0, axis=1) & np.any(pose[:, R_HIP] != 0, axis=1))
    ctr = np.where(hips_ok[:, None],
                   0.5 * (pose[:, L_HIP] + pose[:, R_HIP]),
                   0.5 * (pose[:, L_SHOULDER] + pose[:, R_SHOULDER]))
    seq = seq - ctr[:, None, :]

    def safe_pair(a, b):
        va, vb = pose[:, a], pose[:, b]
        valid = (np.any(va != 0, axis=1) & np.any(vb != 0, axis=1))
        d = np.full(len(va), np.nan, np.float32)
        if valid.any():
            d[valid] = np.linalg.norm(va[valid] - vb[valid], axis=1).astype(np.float32)
        return d

    vals = np.concatenate([safe_pair(L_SHOULDER, R_SHOULDER),
                           safe_pair(L_HIP, R_HIP),
                           safe_pair(L_SHOULDER, L_HIP)])
    vals = vals[np.isfinite(vals)]
    scale = float(np.median(vals)) if vals.size else 1.0
    if (not np.isfinite(scale)) or scale < 1e-3:
        scale = 1.0
    return np.nan_to_num(np.clip(seq / scale, -10.0, 10.0), nan=0.0).astype(np.float32)

# ---------------- Building blocks (match trainer) ----------------
class SE1d(nn.Module):
    def __init__(self, ch: int, reduction: int = 8):
        super().__init__()
        hidden = max(1, ch // reduction)
        self.fc1 = nn.Conv1d(ch, hidden, kernel_size=1, bias=True)
        self.fc2 = nn.Conv1d(hidden, ch, kernel_size=1, bias=True)
        self.act = nn.SiLU(); self.gate = nn.Sigmoid()
    def forward(self, x):
        s = x.mean(dim=2, keepdim=True)
        s = self.act(self.fc1(s))
        s = self.gate(self.fc2(s))
        return x * s

class DSResBlock(nn.Module):
    def __init__(self, channels: int, dilation: int = 1, drop: float = 0.1):
        super().__init__()
        self.dw = nn.Conv1d(channels, channels, kernel_size=3, padding=dilation,
                            dilation=dilation, groups=channels, bias=False)
        self.bn1 = nn.BatchNorm1d(channels)
        self.pw = nn.Conv1d(channels, channels, kernel_size=1, bias=False)
        self.bn2 = nn.BatchNorm1d(channels)
        self.act = nn.SiLU()
        self.drop = nn.Dropout(drop)
        self.se = SE1d(channels, reduction=8)
    def forward(self, x):
        out = self.dw(x)
        out = self.bn1(out); out = self.act(out)
        out = self.pw(out);  out = self.bn2(out)
        out = self.se(out);  out = self.drop(out)
        return self.act(out + x)

class TemporalMHAPool(nn.Module):
    """DS-Res outputs (B,C,T) -> (B,2C) via [CLS]-query attention + GAP."""
    def __init__(self, channels: int, heads: int = 4, dropout: float = 0.0):
        super().__init__()
        assert channels % heads == 0, "channels must be divisible by heads for MHA"
        self.cls = nn.Parameter(torch.randn(1, 1, channels) * 0.02)
        self.mha = nn.MultiheadAttention(embed_dim=channels, num_heads=heads, dropout=dropout, batch_first=True)
        self.norm = nn.LayerNorm(2 * channels)
    def forward(self, h_bct: torch.Tensor) -> torch.Tensor:
        x = h_bct.transpose(1, 2)   # (B,T,C)
        B = x.size(0)
        q = self.cls.expand(B, -1, -1)  # (B,1,C)
        tok, _ = self.mha(q, x, x, need_weights=False)
        cls = tok.squeeze(1)                            # (B,C)
        gap = x.mean(1)                                 # (B,C)
        return self.norm(torch.cat([cls, gap], dim=1))  # (B,2C)

class Backbone1D(nn.Module):
    def __init__(self, in_features: int, width: int, drop: float, dilations, t_heads: int = 4, attn_dropout: float = 0.0):
        super().__init__()
        self.stem = nn.Sequential(
            nn.Conv1d(in_features, width, kernel_size=1, bias=False),
            nn.BatchNorm1d(width),
            nn.SiLU(),
        )
        self.blocks = nn.ModuleList([DSResBlock(width, d, drop=drop) for d in (dilations or [1,2,4,8,16,32])])
        self.temporal_pool = TemporalMHAPool(width, heads=t_heads, dropout=attn_dropout)
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        h = self.stem(x.transpose(1, 2))
        for blk in self.blocks: h = blk(h)
        return self.temporal_pool(h)

class MultiHeadViewAttention(nn.Module):
    def __init__(self, embed_dim: int, heads: int = 4, dropout: float = 0.0):
        super().__init__()
        assert embed_dim % heads == 0, "embed_dim must be divisible by heads"
        self.cls = nn.Parameter(torch.randn(1, 1, embed_dim) * 0.02)
        self.mha = nn.MultiheadAttention(embed_dim=embed_dim, num_heads=heads, dropout=dropout, batch_first=True)
        self.norm = nn.LayerNorm(embed_dim)
    def forward(self, z: torch.Tensor) -> torch.Tensor:
        B = z.size(0)
        tokens = torch.cat([self.cls.expand(B, -1, -1), z], dim=1)
        out, _ = self.mha(tokens, tokens, tokens, need_weights=False)
        fused = out[:, 0, :]
        return self.norm(fused)

class PoseTCNMultiView(nn.Module):
    """Multi-view classifier with early/late/hybrid fusion and optional view attention."""
    def __init__(self, num_classes: int, num_views: int, width: int = 256, drop: float = 0.1,
                 dilations=None, fusion: str = "hybrid", view_fusion: str = "mean",
                 hybrid_alpha: float = 0.5, in_per_view: int = NUM_POSE*3,
                 t_heads: int = 4, view_heads: int = 4, attn_dropout: float = 0.0,
                 use_view_attn: bool = False):
        super().__init__()
        self.num_views = num_views
        self.in_per_view = in_per_view
        self.fusion = fusion
        self.view_fusion = ("attn" if use_view_attn else view_fusion)
        self.hybrid_alpha = float(hybrid_alpha)

        self.backbone_early = Backbone1D(in_features=in_per_view * num_views,
                                         width=width, drop=drop, dilations=dilations,
                                         t_heads=t_heads, attn_dropout=attn_dropout)
        self.head_early = nn.Linear(2*width, num_classes)

        self.backbone_late = Backbone1D(in_features=in_per_view,
                                        width=width, drop=drop, dilations=dilations,
                                        t_heads=t_heads, attn_dropout=attn_dropout)
        self.head_late = nn.Linear(2*width, num_classes)

        self.view_attn = MultiHeadViewAttention(2*width, heads=view_heads, dropout=attn_dropout) \
                          if self.view_fusion == "attn" else None

    def _split_views(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B,T,F_total) where F_total = V * in_per_view; reshape to (B,V,T,in_per_view)
        B, T, F = x.shape
        V = self.num_views
        L3 = self.in_per_view
        assert F == V * L3, f"Feature dim {F} != num_views*in_per_view {V}*{L3}"
        L = L3 // 3
        xv = x.view(B, T, L, 3, V).permute(0, 1, 4, 2, 3).contiguous().view(B, T, V, L3)
        return xv  # (B,T,V,in_per_view)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        le = ll = None
        if self.fusion in ("early", "hybrid"):
            le = self.head_early(self.backbone_early(x))
        if self.fusion in ("late", "hybrid"):
            xv = self._split_views(x)  # (B,T,V,in_per_view)
            B, T, V, Fv = xv.shape
            z = self.backbone_late(xv.view(B * V, T, Fv)).view(B, V, -1)  # (B,V,2W)
            if self.view_attn is None: z = z.mean(1)                      # (B,2W)
            else:                      z = self.view_attn(z)              # (B,2W)
            ll = self.head_late(z)
        if self.fusion == "early": return le
        if self.fusion == "late":  return ll
        return self.hybrid_alpha * le + (1.0 - self.hybrid_alpha) * ll

class PoseTCNSingleView(nn.Module):
    """Single-view pose classifier - matches train_single_view.py architecture."""
    def __init__(self, num_classes: int, width: int = 384, drop: float = 0.1,
                 dilations=None, in_features: int = NUM_POSE*3,
                 t_heads: int = 4, attn_dropout: float = 0.0):
        super().__init__()
        self.in_features = in_features
        self.num_classes = num_classes
        
        self.backbone = Backbone1D(in_features=in_features, width=width, drop=drop,
                                   dilations=dilations, t_heads=t_heads, attn_dropout=attn_dropout)
        self.head = nn.Linear(2 * width, num_classes)
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B,T,F) where F = in_features (99 for pose-only)
        return self.head(self.backbone(x))

# ---------------- Checkpoint loader ----------------

def _maybe_parse_dilations(cfg):
    if not isinstance(cfg, dict) or "dilations" not in cfg: return None
    try:
        v = cfg["dilations"]
        if isinstance(v, str):
            out = [int(x.strip()) for x in v.split(",") if x.strip()]
            return out or None
        if isinstance(v, (list, tuple)):
            return [int(x) for x in v]
    except Exception:
        return None


def _infer_num_views_and_in_per_view(state, cfg) -> Tuple[int,int]:
    """Infer (num_views, in_per_view=3*33) from early stem in_channels when present."""
    in_ch = None
    for k in ("backbone_early.stem.0.weight", "stem.0.weight", "backbone_late.stem.0.weight"):
        if k in state:
            in_ch = int(state[k].shape[1]); break
    if in_ch is None:
        in_ch = int(cfg.get("input_dim", NUM_POSE*3))
    prefer_V = int(cfg.get("max_views", 1) or 1)
    in_per_view = NUM_POSE * 3
    # Try to determine V from in_ch = V * in_per_view
    for V in (prefer_V, 3, 2, 1, 4, 5):
        if V > 0 and in_ch % (in_per_view * V) == 0:
            return V, in_per_view
    # Fallback single view
    return 1, in_per_view


def load_ckpt(path: str, device: torch.device):
    ckpt = torch.load(path, map_location="cpu")
    classes = ckpt.get("classes", ALL_CLASSES)
    cfg = ckpt.get("args", {}) or {}
    state = ckpt["model_state_dict"]
    
    # Get temperature calibration if available
    temperature = float(ckpt.get("best_temperature", 1.0) or 1.0)
    if not np.isfinite(temperature) or temperature <= 0:
        temperature = 1.0
    print(f"Loading checkpoint: {path}")
    print(f"  Classes: {classes}")
    print(f"  Temperature: {temperature:.4f}")

    # Detect if it's a MultiView checkpoint (your trainer naming)
    has_early = any(k.startswith("backbone_early.") for k in state)
    has_late  = any(k.startswith("backbone_late.")  for k in state)
    has_view_attn = any(k.startswith("view_attn.")  for k in state)

    width = int(cfg.get("width", 256))
    drop = float(cfg.get("dropout", 0.1))
    dilations = _maybe_parse_dilations(cfg) or [1,2,4,8,16,32]
    fusion = str(cfg.get("fusion", "hybrid"))
    view_fusion = str(cfg.get("view_fusion", "mean"))
    hybrid_alpha = float(cfg.get("hybrid_alpha", 0.5))
    t_heads = int(cfg.get("t_heads", 4))
    view_heads = int(cfg.get("view_heads", 4))
    attn_dropout = float(cfg.get("attn_dropout", 0.0))

    if has_early and has_late:
        num_views, in_per_view = _infer_num_views_and_in_per_view(state, cfg)
        model = PoseTCNMultiView(
            num_classes=len(classes), num_views=num_views, width=width, drop=drop,
            dilations=dilations, fusion=fusion, view_fusion=view_fusion,
            hybrid_alpha=hybrid_alpha, in_per_view=in_per_view,
            t_heads=t_heads, view_heads=view_heads, attn_dropout=attn_dropout,
            use_view_attn=has_view_attn or (view_fusion=="attn")
        )
        model.load_state_dict(state, strict=True)
        model.to(device).eval()
        
        # Note: For live demo with single camera, we tile the view to match expected input shape
        print(f"Model expects {num_views} views. Single camera will be tiled.")
        
        model_type = f"mv-{fusion}-{view_fusion}"
        expects_hands = False  # pose-only
        return model, classes, num_views, in_per_view//3, model_type, expects_hands, temperature

    # Otherwise, assume single-view PoseTCN (pose-only)
    # Check if it's the new single-view architecture (has backbone.stem, backbone.temporal_pool)
    has_backbone_stem = any(k.startswith("backbone.stem.") for k in state)
    has_temporal_pool = any(k.startswith("backbone.temporal_pool.") for k in state)
    
    if has_backbone_stem and has_temporal_pool:
        # New single-view architecture from train_single_view.py
        print("Detected single-view model (train_single_view.py architecture)")
        model = PoseTCNSingleView(
            num_classes=len(classes), width=width, drop=drop, dilations=dilations,
            in_features=NUM_POSE * 3, t_heads=t_heads, attn_dropout=attn_dropout
        )
        model.load_state_dict(state, strict=True)
        model.to(device).eval()
        model_type = "single-view-mha"
        expects_hands = False
        return model, classes, 1, NUM_POSE, model_type, expects_hands, temperature
    
    # Legacy single-path PoseTCN (old architecture with simple attention)
    input_dim = 3 * NUM_POSE
    print("Detected legacy single-path model")
    class PoseTCN(nn.Module):
        def __init__(self, input_dim: int, num_classes: int, width: int = 256, drop: float = 0.1, dilations=None):
            super().__init__()
            self.stem = nn.Sequential(
                nn.Conv1d(input_dim, width, kernel_size=1, bias=False),
                nn.BatchNorm1d(width),
                nn.SiLU(),
            )
            self.blocks = nn.ModuleList([DSResBlock(width, d, drop=drop) for d in (dilations or [1,2,4,8,16,32])])
            self.attn = nn.Conv1d(width, 1, kernel_size=1)
            self.norm = nn.LayerNorm(2*width)
            self.head = nn.Linear(2*width, num_classes)
        def forward(self, x):
            if x.dim() == 4:
                B,T,L,C = x.shape
                x = x.reshape(B, T, L*C)
            x = x.transpose(1, 2)
            h = self.stem(x)
            for blk in self.blocks:
                h = blk(h)
            w = torch.softmax(self.attn(h), dim=2)
            z_attn = (h * w).sum(dim=2)
            z_gap = h.mean(dim=2)
            z = torch.cat([z_attn, z_gap], dim=1)
            z = self.norm(z)
            return self.head(z)

    model = PoseTCN(input_dim=input_dim, num_classes=len(classes), width=width, drop=drop, dilations=dilations)
    model.load_state_dict(state, strict=True)
    model.to(device).eval()
    model_type = "posetcn"
    expects_hands = False
    return model, classes, 1, NUM_POSE, model_type, expects_hands, temperature

# ---------------- MediaPipe pose ----------------
mp_pose = mp.solutions.pose

def extract_pose(frame_bgr, pose, short=256) -> Optional[np.ndarray]:
    h, w = frame_bgr.shape[:2]
    scale = short / max(h, w)
    if scale < 1.0:
        frame_bgr = cv2.resize(frame_bgr, (int(w*scale), int(h*scale)), interpolation=cv2.INTER_AREA)
    rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
    res = pose.process(rgb)
    if not res.pose_landmarks: return None
    lm = res.pose_landmarks.landmark
    return np.array([[p.x, p.y, p.z] for p in lm], dtype=np.float32)

# ---------------- Smoother ----------------
class PredSmoother:
    def __init__(self, k=15):
        self.q_pred = deque(maxlen=k); self.q_conf = deque(maxlen=k)
    def push(self, p: int, c: float): self.q_pred.append(p); self.q_conf.append(c)
    def value(self):
        if not self.q_pred: return None, 0.0
        top = Counter(self.q_pred).most_common(1)[0][0]
        return top, float(np.mean(self.q_conf))

# ---------------- Database Storage ----------------

class DetectionStorage:
    """Store AI detections to database during live streaming."""
    
    def __init__(self, session_id: str = None, camera_id: str = None, 
                 room_id: str = None, model_name: str = "PoseTCN"):
        self.enabled = DATABASE_AVAILABLE
        self.session_id = session_id or str(uuid.uuid4())
        self.camera_id = camera_id or str(uuid.uuid4())
        self.room_id = room_id
        self.model_name = model_name
        self.sequence_number = 0
        self.last_store_time = 0
        self.store_interval = 2.0  # Store every 2 seconds to avoid overwhelming DB
        
        if self.enabled:
            logger.info(f"✅ Detection storage enabled - Session: {self.session_id[:8]}...")
        else:
            print("⚠️  Database not available - detections will not be stored")
    
    def should_store(self) -> bool:
        """Check if enough time has passed to store another detection."""
        current_time = time.time()
        if current_time - self.last_store_time >= self.store_interval:
            self.last_store_time = current_time
            return True
        return False
    
    def store_detection(self, predicted_class: str, confidence: float, 
                       all_probs: dict, temperature: float, 
                       frame_count: int = 60, processing_time_ms: int = None):
        """
        Store a single detection to the database.
        
        Args:
            predicted_class: Predicted movement class
            confidence: Confidence score (0-1)
            all_probs: Dict of all class probabilities
            temperature: Model temperature used
            frame_count: Number of frames in the sequence
            processing_time_ms: Inference time in milliseconds
        """
        if not self.enabled or not self.should_store():
            return
        
        try:
            detection_data = {
                'predicted_class': predicted_class,
                'confidence': confidence,
                'all_probabilities': all_probs,
                'frame_count': frame_count,
                'temperature': temperature,
                'model_name': self.model_name,
                'inference_mode': 'live_stream'
            }
            
            supabase.table('ai_detections').insert({
                'session_id': self.session_id,
                'camera_id': self.camera_id,
                'room_id': self.room_id,
                'detection_type': predicted_class,
                'confidence_score': float(confidence),
                'detection_data': detection_data,
                'frame_timestamp': datetime.now().isoformat(),
                'sequence_number': self.sequence_number,
                'model_used': self.model_name,
                'processing_time_ms': processing_time_ms,
                'processed_on': 'edge'  # Live inference on edge device
            }).execute()
            
            self.sequence_number += 1
            
            if self.sequence_number % 10 == 0:
                logger.info(f"📊 Stored {self.sequence_number} detections")
                
        except Exception as e:
            if logger:
                logger.error(f"Failed to store detection: {e}")
            else:
                print(f"❌ Failed to store detection: {e}")
    
    def store_batch_summary(self, detection_counts: dict, avg_confidence: float,
                           total_frames: int, duration_seconds: float):
        """Store a summary of detection session."""
        if not self.enabled:
            return
        
        try:
            summary_data = {
                'detection_counts': detection_counts,
                'avg_confidence': avg_confidence,
                'total_frames': total_frames,
                'duration_seconds': duration_seconds,
                'detections_per_second': total_frames / duration_seconds if duration_seconds > 0 else 0
            }
            
            supabase.table('ai_detections').insert({
                'session_id': self.session_id,
                'camera_id': self.camera_id,
                'room_id': self.room_id,
                'detection_type': 'session_summary',
                'confidence_score': avg_confidence,
                'detection_data': summary_data,
                'frame_timestamp': datetime.now().isoformat(),
                'sequence_number': self.sequence_number,
                'model_used': self.model_name,
                'processed_on': 'edge'
            }).execute()
            
            logger.info(f"✅ Stored session summary: {len(detection_counts)} unique detections")
            
        except Exception as e:
            if logger:
                logger.error(f"Failed to store session summary: {e}")
            else:
                print(f"❌ Failed to store summary: {e}")

# ---------------- Main loop ----------------

def run(args):
    device = torch.device("cuda" if (torch.cuda.is_available() and not args.cpu) else "cpu")
    use_cuda = (device.type == "cuda")
    if use_cuda:
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True
    amp_dtype = torch.bfloat16 if (use_cuda and torch.cuda.is_bf16_supported()) else torch.float16

    model, classes, num_views, landmarks_per_view, model_type, _, temperature = load_ckpt(args.ckpt, device)

    tag = f"{model_type}-pose(V={num_views})"
    print(f"Model type: {model_type}, Views: {num_views}, Temperature: {temperature:.4f}")
    
    # Initialize database storage if enabled
    storage = None
    if args.store_db:
        import uuid
        # Generate UUIDs if not provided
        session_id = args.session_id if args.session_id else str(uuid.uuid4())
        camera_id = args.camera_id if args.camera_id else str(uuid.uuid4())
        room_id = args.room_id  # Can be None
        
        storage = DetectionStorage(
            session_id=session_id,
            camera_id=camera_id,
            room_id=room_id,
            model_name=f"{model_type}-T{temperature:.2f}"
        )
        print(f"🔑 Session ID: {session_id}")
        print(f"📷 Camera ID: {camera_id}")
        if room_id:
            print(f"🚪 Room ID: {room_id}")
    
    # Simple argmax prediction (matches train.py logic)
    print(f"Using temperature scaling: T={temperature:.2f}")
    print("Prediction method: argmax(softmax(logits/T))")
    if storage and storage.enabled:
        print(f"📊 Database storage: ENABLED (storing every {storage.store_interval}s)")
    else:
        print("📊 Database storage: DISABLED")

    T = args.T
    buffer = deque(maxlen=T)
    smoother = PredSmoother(k=args.smooth_k)

    pose = mp_pose.Pose(static_image_mode=False, model_complexity=0,
                        enable_segmentation=False, min_detection_confidence=0.5,
                        min_tracking_confidence=0.5)

    cap = cv2.VideoCapture(args.cam)
    if args.width:  cap.set(cv2.CAP_PROP_FRAME_WIDTH, args.width)
    if args.height: cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
    if args.fps:    cap.set(cv2.CAP_PROP_FPS, args.fps)

    last_landmarks = None
    frame_i = 0
    start_time = time.time()
    detection_counts = Counter()
    all_confidences = []

    # Prealloc scratch for early-fusion tiling when V>1
    per_view_feat = 3 * landmarks_per_view  # 3*33
    tile_buf = torch.empty((1, T, per_view_feat * num_views), dtype=torch.float32, device=device) if num_views>1 else None

    print(f"Live demo running ({tag}). Press 'q' to quit.")
    try:
        while True:
            ok, frame = cap.read()
            if not ok: break
            frame_i += 1

            if frame_i % args.pose_every == 0:
                p33 = extract_pose(frame, pose, short=args.pose_short)
                if p33 is not None:
                    last_landmarks = p33  # (33,3)

            if last_landmarks is not None:
                buffer.append(last_landmarks)

            if len(buffer) == T and (frame_i % args.infer_every == 0):
                infer_start = time.time()
                
                seq = np.stack(buffer, 0).astype(np.float32)          # (T, 33, 3)
                seq = normalize_pose(seq)                              # (T, 33, 3)
                x_np = seq.reshape(T, -1)                              # (T, 99)
                if num_views > 1:
                    # For single camera with multi-view model: tile with small noise to differentiate views
                    # This is better than exact duplication which confuses view attention
                    views = []
                    for v in range(num_views):
                        if v == 0:
                            # First view: use original
                            views.append(x_np)
                        else:
                            # Other views: add tiny random noise to simulate different angles
                            noise = np.random.randn(*x_np.shape).astype(np.float32) * 0.02
                            views.append(x_np + noise)
                    x_np = np.concatenate(views, axis=1)               # (T, 99*V)
                    x = torch.from_numpy(x_np).unsqueeze(0).to(device, non_blocking=True)
                    tile_buf.copy_(x); x = tile_buf
                else:
                    x = torch.from_numpy(x_np).unsqueeze(0).to(device, non_blocking=True)

                with torch.no_grad(), torch.amp.autocast(device_type=device.type, dtype=amp_dtype, enabled=use_cuda):
                    logits = model(x)
                    # Temperature scaling (matches train.py evaluate() logic)
                    logits = logits.float()
                    scaled = logits / float(temperature)
                    pred = scaled.argmax(1)
                    
                    # Get probability for confidence
                    probs = torch.softmax(scaled, dim=1)
                    conf = probs[0, pred[0]]
                    
                    pred_idx = int(pred[0].item())
                    conf_val = float(conf.item())
                    pred_class = classes[pred_idx]
                    
                    # Calculate inference time
                    infer_time_ms = int((time.time() - infer_start) * 1000)
                    
                    # Store to database if enabled
                    if storage:
                        all_probs = {classes[i]: float(probs[0, i].item()) 
                                    for i in range(len(classes))}
                        storage.store_detection(
                            predicted_class=pred_class,
                            confidence=conf_val,
                            all_probs=all_probs,
                            temperature=temperature,
                            frame_count=T,
                            processing_time_ms=infer_time_ms
                        )
                    
                    # Track statistics
                    detection_counts[pred_class] += 1
                    all_confidences.append(conf_val)
                    
                    # Debug: Print raw predictions every 30 frames
                    if frame_i % 30 == 0:
                        print(f"\n[Frame {frame_i}] Raw model output:")
                        print(f"  Logits (raw):    {logits[0].cpu().numpy()}")
                        print(f"  Logits (scaled): {scaled[0].cpu().numpy()}")
                        print(f"  Probs:  {probs[0].cpu().numpy()}")
                        print(f"  Top 3 predictions:")
                        top3_confs, top3_preds = torch.topk(probs[0], k=min(3, len(classes)))
                        for i in range(len(top3_preds)):
                            print(f"    {i+1}. {classes[top3_preds[i]]:20s} {top3_confs[i].item():.4f}")
                        print(f"  Final prediction: {pred_class} ({conf_val:.4f})")
                        print(f"  Inference time: {infer_time_ms}ms")
                    
                    smoother.push(pred_idx, conf_val)


            s_pred, s_conf = smoother.value()
            label = classes[s_pred] if s_pred is not None else ("Collecting..." if len(buffer)<T else "...")

            fps = cap.get(cv2.CAP_PROP_FPS) or 0.0
            cv2.rectangle(frame, (10, 10), (520, 180), (0, 0, 0), -1)
            cv2.putText(frame, f"Model: {tag}", (20, 35), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (200, 200, 200), 1)
            cv2.putText(frame, f"T: {len(buffer)}/{T} | Pose every {args.pose_every} | Infer every {args.infer_every}",
                        (20, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)
            cv2.putText(frame, f"Cam FPS (cap): {fps:.1f}", (20, 85), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)
            
            # Show DB storage status
            if storage and storage.enabled:
                db_status = f"DB: {storage.sequence_number} stored"
                cv2.putText(frame, db_status, (20, 110), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
            
            color = (0, 255, 255) if s_conf >= 0.7 else (0, 165, 255) if s_conf >= 0.5 else (0, 0, 255)
            cv2.putText(frame, f"Pred: {label}  ({s_conf:.2f})", (20, 145), cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

            cv2.imshow(f"PoseTCN Live ({tag})", frame)
            if (cv2.waitKey(1) & 0xFF) == ord('q'):
                break
    finally:
        # Store session summary before closing
        if storage and storage.enabled and all_confidences:
            duration = time.time() - start_time
            storage.store_batch_summary(
                detection_counts=dict(detection_counts),
                avg_confidence=float(np.mean(all_confidences)),
                total_frames=frame_i,
                duration_seconds=duration
            )
            print(f"\n📊 Session Summary:")
            print(f"  Total frames: {frame_i}")
            print(f"  Duration: {duration:.1f}s")
            print(f"  Detections stored: {storage.sequence_number}")
            print(f"  Avg confidence: {np.mean(all_confidences):.3f}")
            print(f"  Detection distribution:")
            for cls, count in detection_counts.most_common():
                pct = 100 * count / sum(detection_counts.values())
                print(f"    {cls:20s}: {count:4d} ({pct:5.1f}%)")
        
        cap.release()
        cv2.destroyAllWindows()

# ---------------- CLI ----------------

def parse_args():
    ap = argparse.ArgumentParser(description="Live inference for PoseTCN checkpoints (pose-only, multi-view compatible)")
    ap.add_argument("--ckpt", type=str, required=True, help="Path to checkpoint (*.pt from trainer)")
    ap.add_argument("--cam", type=int, default=0, help="Webcam index")
    ap.add_argument("--T", type=int, default=60, help="Window length (frames)")
    ap.add_argument("--smooth_k", type=int, default=15, help="Prediction smoother length")
    ap.add_argument("--cpu", action="store_true", help="Force CPU")
    ap.add_argument("--width", type=int, default=640, help="Webcam width")
    ap.add_argument("--height", type=int, default=480, help="Webcam height")
    ap.add_argument("--fps", type=int, default=30, help="Webcam FPS")
    ap.add_argument("--pose_every", type=int, default=1, help="Run MediaPipe every N frames")
    ap.add_argument("--infer_every", type=int, default=1, help="Run model every N frames")
    ap.add_argument("--pose_short", type=int, default=256, help="Short side for pose downscale")
    
    # Database storage options
    ap.add_argument("--store_db", action="store_true", help="Store detections to database")
    ap.add_argument("--session_id", type=str, default=None, help="Ambulance session ID (auto-generated if not provided)")
    ap.add_argument("--camera_id", type=str, default=None, help="Camera ID (auto-generated if not provided)")
    ap.add_argument("--room_id", type=str, default=None, help="WebRTC room ID (optional)")
    
    return ap.parse_args()

if __name__ == "__main__":
    args = parse_args()
    run(args)
