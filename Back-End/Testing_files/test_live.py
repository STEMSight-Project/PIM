#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Live inference demo (GPU-optimized) for pose classification models
- Works with BiLSTM, BiLSTM+Transformer, and CNN (PoseTCN) checkpoints
- Single-view and early-fusion support (auto-detected from checkpoint)
- GPU tweaks: TF32 enable, BF16/FP16 autocast
- Throughput tweaks: run pose & inference every N frames

Usage:
  python test_live.py --ckpt runs_earlyfusion/best_bilstm_early.pt
  python test_live.py --ckpt runs_cnn/best_cnn_early.pt --pose_every 2 --infer_every 2
"""

import argparse
import time
from collections import deque, Counter
from typing import Optional

import numpy as np
import cv2
import torch
import torch.nn as nn
import mediapipe as mp

# Fallback (ignored if classes are present in checkpoint)
ALL_CLASSES = [
    "normal","decorticate","dystonia","chorea","myoclonus",
    "decerebrate","fencer posture","ballistic","tremor","versive head"
]
NUM_LANDMARKS = 33
L_SHOULDER, R_SHOULDER, L_HIP, R_HIP = 11, 12, 23, 24

# ==================== Normalization ====================
def _pair_dist(fr: np.ndarray, a: int, b: int):
    va, vb = fr[a], fr[b]
    if not (np.any(va != 0) and np.any(vb != 0)): return None
    return float(np.linalg.norm(va - vb) + 1e-8)

def normalize_seq(seq: np.ndarray) -> np.ndarray:
    """Normalize pose sequence: center by hips (fallback shoulders), scale by median body-size cue, clip."""
    T = seq.shape[0]
    hips_ok = (np.any(seq[:, L_HIP] != 0, axis=1) & np.any(seq[:, R_HIP] != 0, axis=1))
    hip_center = 0.5*(seq[:, L_HIP] + seq[:, R_HIP])
    shoulder_center = 0.5*(seq[:, L_SHOULDER] + seq[:, R_SHOULDER])
    center = hip_center.copy(); center[~hips_ok] = shoulder_center[~hips_ok]
    seq = seq - center[:, None, :]

    dists = []
    for t in range(T):
        fr = seq[t]
        cues = [d for d in (_pair_dist(fr, L_SHOULDER, R_SHOULDER),
                            _pair_dist(fr, L_HIP, R_HIP),
                            _pair_dist(fr, L_SHOULDER, L_HIP)) if d is not None]
        dists.append(np.median(cues) if cues else np.nan)
    vals = np.asarray(dists, dtype=np.float32)
    scale = np.nanmedian(vals) if np.isfinite(vals).any() else 1.0
    if not np.isfinite(scale) or scale < 1e-3: scale = 1.0
    seq = np.clip(seq / scale, -10.0, 10.0).astype(np.float32, copy=False)
    return np.nan_to_num(seq, nan=0.0, posinf=0.0, neginf=0.0)

# ==================== Models ====================
class BiLSTM(nn.Module):
    def __init__(self, num_classes: int, input_dim: int, hidden=256, layers=2, drop=0.3):
        super().__init__()
        self.lstm = nn.LSTM(input_dim, hidden, layers, batch_first=True, bidirectional=True,
                            dropout=(drop if layers>1 else 0.0))
        self.attn = nn.Linear(hidden*2, 1)
        self.head = nn.Sequential(nn.LayerNorm(hidden*2), nn.Linear(hidden*2, num_classes))
    def forward(self, x):
        if x.dim()==4:
            B,T,L,C = x.shape
            x = x.view(B,T,L*C)
        h,_ = self.lstm(x)
        a = torch.softmax(self.attn(h), dim=1)
        z = (h * a).sum(1)
        return self.head(z)

class BiLSTMTransformer(nn.Module):
    def __init__(self, num_classes: int, input_dim: int, hidden=256, layers=2, drop=0.3,
                 num_heads=4, transformer_layers=1, ff_mult=2, transformer_drop=0.3, **kwargs):
        super().__init__()
        self.lstm = nn.LSTM(input_dim, hidden, layers, batch_first=True, bidirectional=True,
                            dropout=(drop if layers>1 else 0.0))
        dim = hidden * 2
        encoder_layer = nn.TransformerEncoderLayer(
            d_model=dim, nhead=num_heads, dim_feedforward=int(dim * ff_mult),
            batch_first=True, dropout=transformer_drop, activation="gelu", norm_first=True
        )
        self.transformer = nn.TransformerEncoder(encoder_layer, num_layers=transformer_layers)
        self.attn = nn.Linear(dim, 1)
        self.head = nn.Sequential(nn.LayerNorm(dim), nn.Linear(dim, num_classes))
    
    def forward(self, x):
        if x.dim()==4:
            B,T,L,C = x.shape
            x = x.view(B,T,L*C)
        h,_ = self.lstm(x)
        h = self.transformer(h)
        a = torch.softmax(self.attn(h), dim=1)
        z = (h * a).sum(1)
        return self.head(z)

class SE1d(nn.Module):
    def __init__(self, ch: int, reduction: int = 8):
        super().__init__()
        hidden = max(1, ch // reduction)
        self.fc1 = nn.Conv1d(ch, hidden, kernel_size=1, bias=True)
        self.fc2 = nn.Conv1d(hidden, ch, kernel_size=1, bias=True)
        self.act = nn.SiLU()
        self.gate = nn.Sigmoid()
    def forward(self, x):
        s = x.mean(dim=2, keepdim=True)
        s = self.act(self.fc1(s))
        s = self.gate(self.fc2(s))
        return x * s

class DSResBlock(nn.Module):
    def __init__(self, channels: int, dilation: int = 1, drop: float = 0.1):
        super().__init__()
        pad = dilation
        self.dw = nn.Conv1d(channels, channels, kernel_size=3, padding=pad,
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

class PoseTCN(nn.Module):
    def __init__(self, input_dim: int, num_classes: int, width: int = 256, drop: float = 0.1, dilations=None, **kwargs):
        super().__init__()
        self.stem = nn.Sequential(
            nn.Conv1d(input_dim, width, kernel_size=1, bias=False),
            nn.BatchNorm1d(width),
            nn.SiLU(),
        )
        if dilations is None:
            dilations = [1, 2, 4, 8, 16, 32]
        self.blocks = nn.ModuleList([DSResBlock(width, d, drop=drop) for d in dilations])
        self.attn = nn.Conv1d(width, 1, kernel_size=1)
        self.norm = nn.LayerNorm(2*width)
        self.head = nn.Linear(2*width, num_classes)

    def forward(self, x):
        if x.dim() == 4:
            B,T,L,C = x.shape
            x = x.reshape(B, T, L*C)
        B, T, F = x.shape
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

# ==================== Checkpoint Loader ====================
def load_ckpt(path: str, device: torch.device):
    """Load checkpoint and instantiate correct model. Supports our CNN PoseTCN trainer."""
    ckpt = torch.load(path, map_location="cpu")
    # Trainer saves 'classes' and 'args'; keep fallback if missing.
    classes = ckpt.get("classes", ALL_CLASSES)
    cfg = ckpt.get("args", {}) or {}   # <-- NOTE: trainer uses 'args', not 'cfg'
    state = ckpt["model_state_dict"]

    # Infer input_dim (and width for CNN) from weights
    input_dim = None
    width = None
    inferred_hidden = None
    if "lstm.weight_ih_l0" in state:
        lstm_w = state["lstm.weight_ih_l0"].shape
        input_dim = int(lstm_w[1])
        inferred_hidden = int(lstm_w[0] // 4)
    elif "stem.0.weight" in state:
        # Conv1d: [out_channels, in_channels, k]
        w = state["stem.0.weight"].shape
        width = int(w[0])
        input_dim = int(w[1])

    # Compute num_views from input_dim
    if input_dim is None:
        # fallback if something odd
        num_views = int(cfg.get("max_views", 1))
        input_dim = NUM_LANDMARKS * 3 * num_views
    else:
        num_views = input_dim // (NUM_LANDMARKS * 3)
        if num_views < 1: num_views = 1

    hidden = int(cfg.get("width", inferred_hidden or 256))  # for BiLSTM default
    layers = int(cfg.get("layers", 2))
    drop = float(cfg.get("dropout", 0.1))
    # Attempt to read dilations (CNN)
    dilations = None
    if "dilations" in cfg:
        try:
            if isinstance(cfg["dilations"], str):
                dilations = [int(x.strip()) for x in cfg["dilations"].split(",") if x.strip()]
            elif isinstance(cfg["dilations"], (list, tuple)):
                dilations = [int(x) for x in cfg["dilations"]]
        except Exception:
            dilations = None

    # Detect model type from keys
    is_cnn = "stem.0.weight" in state
    has_transformer = any(k.startswith("transformer.") for k in state.keys())

    if is_cnn:
        width = int(cfg.get("width", width or 256))
        model = PoseTCN(input_dim=input_dim, num_classes=len(classes), width=width, drop=drop, dilations=dilations)
        model_type = "cnn"
    elif has_transformer:
        num_heads = int(cfg.get("num_heads", 4))
        transformer_layers = int(cfg.get("transformer_layers", 1))
        ff_mult = float(cfg.get("ff_mult", 2.0))
        transformer_drop = float(cfg.get("transformer_dropout", drop))
        model = BiLSTMTransformer(
            num_classes=len(classes), input_dim=input_dim, hidden=hidden, layers=layers, drop=drop,
            num_heads=num_heads, transformer_layers=transformer_layers,
            ff_mult=ff_mult, transformer_drop=transformer_drop
        )
        model_type = "transformer"
    else:
        model = BiLSTM(num_classes=len(classes), input_dim=input_dim, hidden=hidden, layers=layers, drop=drop)
        model_type = "bilstm"

    model.load_state_dict(state, strict=True)
    model.to(device).eval()
    return model, classes, num_views, model_type

# ==================== MediaPipe ====================
mp_pose = mp.solutions.pose

def extract_pose_fast(frame_bgr, pose, short=256) -> Optional[np.ndarray]:
    """Extract pose landmarks; return [33,3] or None."""
    h, w = frame_bgr.shape[:2]
    scale = short / max(h, w)
    if scale < 1.0:
        frame_bgr = cv2.resize(frame_bgr, (int(w*scale), int(h*scale)), interpolation=cv2.INTER_AREA)
    rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
    res = pose.process(rgb)
    if not res.pose_landmarks: return None
    lm = res.pose_landmarks.landmark
    arr = np.array([[p.x, p.y, p.z] for p in lm], dtype=np.float32)
    return arr

# ==================== Prediction Smoother ====================
class PredSmoother:
    def __init__(self, k=15):
        self.q_pred = deque(maxlen=k)
        self.q_conf = deque(maxlen=k)
    def push(self, p: int, c: float):
        self.q_pred.append(p); self.q_conf.append(c)
    def value(self):
        if not self.q_pred: return None, 0.0
        top = Counter(self.q_pred).most_common(1)[0][0]
        return top, float(np.mean(self.q_conf))

# ==================== Main ====================
def run(args):
    device = torch.device("cuda" if (torch.cuda.is_available() and not args.cpu) else "cpu")
    use_cuda = (device.type == "cuda")
    if use_cuda:
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True
    amp_dtype = torch.bfloat16 if (use_cuda and torch.cuda.is_bf16_supported()) else torch.float16

    model, classes, num_views, model_type = load_ckpt(args.ckpt, device)

    fusion_tag = "early" if num_views > 1 else "single"
    tag = f"{model_type}-{fusion_tag}"

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

    tile_buf = None
    if num_views > 1:
        C = 3 * num_views
        tile_buf = torch.empty((1, T, NUM_LANDMARKS, C), dtype=torch.float32, device=device)

    last_t = time.time()
    last_landmarks = None
    frame_i = 0

    print(f"Live demo running ({tag}). Press 'q' to quit.")

    try:
        while True:
            ok, frame = cap.read()
            if not ok: break
            frame_i += 1

            if frame_i % args.pose_every == 0:
                landmarks = extract_pose_fast(frame, pose, short=args.pose_short)
                if landmarks is not None:
                    last_landmarks = landmarks
            if last_landmarks is not None:
                buffer.append(last_landmarks)

            if len(buffer) == T and (frame_i % args.infer_every == 0):
                seq = np.stack(buffer, 0).astype(np.float32)
                seq = normalize_seq(seq)  # (T, 33, 3)

                if num_views > 1:
                    # Early fusion: repeat along channel dim → (T, 33, 3*num_views)
                    x_np = np.concatenate([seq] * num_views, axis=2)
                    x = torch.from_numpy(x_np).unsqueeze(0).to(device, non_blocking=True)
                    # Ensure a fixed preallocated tensor for stable latency
                    tile_buf.copy_(x)
                    x = tile_buf
                else:
                    # Single view keeps (B,T,33,3) → model handles 4D
                    x = torch.from_numpy(seq).unsqueeze(0).to(device, non_blocking=True)

                with torch.no_grad(), torch.amp.autocast(device_type=device.type, dtype=amp_dtype, enabled=use_cuda):
                    logits = model(x)
                    probs = torch.softmax(logits, dim=1)
                    conf, pred = probs.max(dim=1)
                    pred = int(pred.item())
                    conf = float(conf.item())

                smoother.push(pred, conf)

            s_pred, s_conf = smoother.value()
            label = classes[s_pred] if s_pred is not None else ("Collecting..." if len(buffer)<T else "...")

            now = time.time()
            dt = now - last_t
            last_t = now
            fps = 1.0 / max(1e-6, dt)
            
            cv2.rectangle(frame, (10, 10), (440, 170), (0, 0, 0), -1)
            cv2.putText(frame, f"FPS: {fps:.1f}", (20, 35), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
            cv2.putText(frame, f"T window: {len(buffer)}/{T}", (20, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)
            cv2.putText(frame, f"Model: {tag}", (20, 80), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)
            cv2.putText(frame, f"Pose: {args.pose_every}x | Infer: {args.infer_every}x", (20, 100),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 200, 200), 1)
            
            color = (0, 255, 255) if s_conf >= 0.7 else (0, 165, 255) if s_conf >= 0.5 else (0, 0, 255)
            cv2.putText(frame, f"Pred: {label}  ({s_conf:.2f})", (20, 130), cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

            cv2.imshow(f"PIM Live ({tag})", frame)
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'): break
    finally:
        cap.release()
        cv2.destroyAllWindows()

def parse_args():
    ap = argparse.ArgumentParser(description="Live inference for pose classification models")
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
    return ap.parse_args()

if __name__ == "__main__":
    args = parse_args()
    run(args)
