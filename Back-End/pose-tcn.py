#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PoseTCN Trainer — POSE-ONLY + UPGRADED ATTENTION (Multi-Head Temporal & View Fusion)

What's new vs previous:
- ✅ All hands logic removed (pose-only, 33 landmarks per view)
- ✅ Fixed view-splitting so late/hybrid fusion receives correct per-view blocks
- ✅ Backbone upgraded: DS-Res TCN stack + Multi-Head Temporal Pooling (CLS query)
- ✅ Optional Multi-Head View Attention for late fusion (CLS fuse token)
- ✅ Configurable attention heads & dropout: --t_heads, --view_heads, --attn_dropout

Preserved features:
- Fast dataloading, group-based splits, class balancing (sampler/weights), focal loss
- Temporal tools (soft labels, purity analysis/filtering, mixup)
- EMA, AMP, torch.compile, resume, curves/CM, temperature calibration
"""

import os, glob, random, time, json, platform, re, threading, queue, multiprocessing as mp, warnings, tempfile
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from collections import defaultdict, Counter
from contextlib import suppress
import shutil
import copy

import numpy as np
import torch, torch.nn as nn
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler, Subset
from sklearn.model_selection import GroupShuffleSplit
from sklearn.metrics import (accuracy_score, balanced_accuracy_score, f1_score,
                             classification_report, confusion_matrix)

# ------------------------------- Constants / CUDA --------------------------------
NUM_POSE_LANDMARKS = 33  # pose only
L_SHOULDER, R_SHOULDER, L_HIP, R_HIP = 11, 12, 23, 24

def seed_everything(seed: int = 42, deterministic: bool = False):
    random.seed(seed); np.random.seed(seed)
    torch.manual_seed(seed); torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.benchmark = not deterministic
    torch.backends.cudnn.deterministic = deterministic
    with suppress(Exception):
        torch.use_deterministic_algorithms(deterministic)

torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True
if torch.cuda.is_available():
    with suppress(Exception): torch.set_float32_matmul_precision('high')

# -------------------------------- Normalization ----------------------------------
def normalize_single_view(seq: np.ndarray, num_pose_landmarks: int = 33) -> np.ndarray:
    """
    Center by hips (fallback shoulders), scale by robust median of pose-only distances,
    then apply same transform to entire sequence. seq: (T,L,3)
    """
    pose = seq[:, :num_pose_landmarks, :]
    hips_ok = (np.any(pose[:, L_HIP] != 0, axis=1) & np.any(pose[:, R_HIP] != 0, axis=1))
    ctr = np.where(hips_ok[:, None],
                   0.5 * (pose[:, L_HIP] + pose[:, R_HIP]),
                   0.5 * (pose[:, L_SHOULDER] + pose[:, R_SHOULDER]))
    seq = seq - ctr[:, None, :]

    def safe_pair(a, b):
        va, vb = pose[:, a], pose[:, b]
        valid = (np.any(va != 0, axis=1) & np.any(vb != 0, axis=1))
        d = np.full(len(va), np.nan, np.float32)
        if valid.any(): d[valid] = np.linalg.norm(va[valid] - vb[valid], axis=1).astype(np.float32)
        return d

    vals = np.concatenate([safe_pair(L_SHOULDER, R_SHOULDER),
                           safe_pair(L_HIP, R_HIP),
                           safe_pair(L_SHOULDER, L_HIP)])
    vals = vals[np.isfinite(vals)]
    scale = float(np.median(vals)) if vals.size else 1.0
    if (not np.isfinite(scale)) or scale < 1e-3: scale = 1.0
    return np.nan_to_num(np.clip(seq / scale, -10.0, 10.0), nan=0.0).astype(np.float32)

# ----------------------------------- Losses --------------------------------------
class FocalLoss(nn.Module):
    """Focal Loss with optional class weights and label smoothing."""
    def __init__(self, alpha=None, gamma=2.0, label_smoothing=0.0):
        super().__init__(); self.alpha, self.gamma, self.label_smoothing = alpha, gamma, label_smoothing

    def forward(self, inputs, targets):
        log_probs = nn.functional.log_softmax(inputs, dim=-1)
        C = inputs.size(-1)
        if self.label_smoothing > 0.0:
            smooth = torch.zeros_like(inputs).scatter_(1, targets.unsqueeze(1), 1.0)
            smooth = smooth * (1 - self.label_smoothing) + self.label_smoothing / C
            ce = -(smooth * log_probs).sum(dim=-1)
            if self.alpha is not None: ce = ce * self.alpha[targets]
        else:
            ce = nn.functional.nll_loss(log_probs, targets, reduction='none', weight=self.alpha)
        pt = log_probs.exp().gather(1, targets.unsqueeze(1)).squeeze(1)
        return ((1 - pt).pow(self.gamma) * ce).mean()

# ----------------------------------- Model pieces --------------------------------
class SE1d(nn.Module):
    def __init__(self, ch: int, reduction: int = 8):
        super().__init__()
        h = max(1, ch // reduction)
        self.fc1, self.fc2 = nn.Conv1d(ch, h, 1), nn.Conv1d(h, ch, 1)
        self.act, self.gate = nn.SiLU(), nn.Sigmoid()
    def forward(self, x):
        s = self.gate(self.fc2(self.act(self.fc1(x.mean(2, keepdim=True)))))
        return x * s

def _make_norm(norm: str, channels: int):
    norm = (norm or 'bn').lower()
    if norm == 'gn':
        return nn.GroupNorm(num_groups=min(8, channels), num_channels=channels)
    return nn.BatchNorm1d(channels)

class DSResBlock(nn.Module):
    def __init__(self, channels: int, dilation: int = 1, drop: float = 0.1,
                 stochastic_depth: float = 0.0, norm: str = 'bn'):
        super().__init__()
        self.dw = nn.Conv1d(channels, channels, 3, padding=dilation, dilation=dilation, groups=channels, bias=False)
        self.bn1, self.pw, self.bn2 = _make_norm(norm, channels), nn.Conv1d(channels, channels, 1, bias=False), _make_norm(norm, channels)
        self.act, self.drop, self.se, self.sd = nn.SiLU(), nn.Dropout(drop), SE1d(channels, 8), float(stochastic_depth)
    def forward(self, x):
        if self.training and self.sd > 0.0:
            keep = 1.0 - self.sd
            mask = torch.floor(keep + torch.rand((x.size(0),) + (1,) * (x.ndim - 1), dtype=x.dtype, device=x.device))
        out = self.act(self.bn1(self.dw(x)))
        out = self.drop(self.se(self.bn2(self.pw(out))))
        if self.training and self.sd > 0.0: out = out / keep * mask
        return self.act(out + x)

class TemporalMHAPool(nn.Module):
    """
    Multi-Head Temporal Pooling:
      - DS-Res outputs (B,C,T) -> (B,2C) via [CLS]-query attention + GAP, then LayerNorm
    """
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
        tok, _ = self.mha(q, x, x, need_weights=False)  # (B,1,C)
        cls = tok.squeeze(1)                            # (B,C)
        gap = x.mean(1)                                 # (B,C)
        return self.norm(torch.cat([cls, gap], dim=1))  # (B,2C)

class Backbone1D(nn.Module):
    """(B,T,F) -> (B,2*width) with DS-Res stack + multi-head temporal pooling."""
    def __init__(self, in_features: int, width: int, drop: float, stochastic_depth: float,
                 dilations: List[int], norm: str = 'bn', t_heads: int = 4, attn_dropout: float = 0.0):
        super().__init__()
        self.stem = nn.Sequential(nn.Conv1d(in_features, width, 1, bias=False), _make_norm(norm, width), nn.SiLU())
        sds = [stochastic_depth * i / max(1, len(dilations) - 1) for i in range(len(dilations))]
        self.blocks = nn.ModuleList([DSResBlock(width, d, drop, sd, norm=norm) for d, sd in zip(dilations, sds)])
        self.temporal_pool = TemporalMHAPool(width, heads=t_heads, dropout=attn_dropout)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B,T,F) -> conv1d expects (B,F,T)
        h = self.stem(x.transpose(1, 2))
        for blk in self.blocks: h = blk(h)
        return self.temporal_pool(h)  # (B,2*width)

class MultiHeadViewAttention(nn.Module):
    """Self-attention over views with a learnable fuse token."""
    def __init__(self, embed_dim: int, heads: int = 4, dropout: float = 0.0):
        super().__init__()
        assert embed_dim % heads == 0, "embed_dim must be divisible by heads"
        self.cls = nn.Parameter(torch.randn(1, 1, embed_dim) * 0.02)
        self.mha = nn.MultiheadAttention(embed_dim=embed_dim, num_heads=heads, dropout=dropout, batch_first=True)
        self.norm = nn.LayerNorm(embed_dim)

    def forward(self, z: torch.Tensor) -> torch.Tensor:
        # z: (B,V,D)
        B = z.size(0)
        tokens = torch.cat([self.cls.expand(B, -1, -1), z], dim=1)  # (B,1+V,D)
        out, _ = self.mha(tokens, tokens, tokens, need_weights=False)
        fused = out[:, 0, :]  # CLS
        return self.norm(fused)

class PoseTCNMultiView(nn.Module):
    """Multi-view classifier with early/late/hybrid fusion and optional multi-head view attention."""
    def __init__(self, num_classes: int, num_views: int, width: int = 384, drop: float = 0.1,
                 stochastic_depth: float = 0.05, dilations: Optional[List[int]] = None,
                 fusion: str = "early", view_fusion: str = "mean", hybrid_alpha: float = 0.5,
                 in_per_view: int = None, norm: str = 'bn',
                 t_heads: int = 4, view_heads: int = 4, attn_dropout: float = 0.0):
        super().__init__()
        dilations = dilations or [1, 2, 4, 8, 16, 32]
        self.num_classes, self.num_views = num_classes, num_views
        self.fusion, self.view_fusion, self.hybrid_alpha = fusion, view_fusion, float(hybrid_alpha)
        self.in_per_view = in_per_view or NUM_POSE_LANDMARKS * 3

        # Early fusion backbone over concatenated features
        self.backbone_early = Backbone1D(self.in_per_view * num_views, width, drop, stochastic_depth, dilations,
                                         norm=norm, t_heads=t_heads, attn_dropout=attn_dropout)
        self.head_early     = nn.Linear(2 * width, num_classes)

        # Late fusion backbone per view
        self.backbone_late  = Backbone1D(self.in_per_view, width, drop, stochastic_depth, dilations,
                                         norm=norm, t_heads=t_heads, attn_dropout=attn_dropout)
        self.head_late      = nn.Linear(2 * width, num_classes)

        # View fusion: mean or multi-head attention with fuse token
        self.view_attn = (MultiHeadViewAttention(embed_dim=2 * width, heads=view_heads, dropout=attn_dropout)
                          if self.view_fusion == "attn" else None)

    def _split_views(self, x: torch.Tensor) -> torch.Tensor:
        """
        Robustly reshape features into per-view blocks.
        Input x: (B,T,F) where F = V * (L*3) with layout produced by collate:
                  joints-major: for each joint, channels [x,y,z] for each view.
        Convert to (B,T,V,in_per_view) with in_per_view = L*3.
        """
        B, T, F = x.shape
        V = self.num_views
        L3 = self.in_per_view  # L*3
        assert F == V * L3, f"Feature dim {F} != num_views*in_per_view {V}*{L3}"
        L = L3 // 3
        # (B,T,L,3,V) -> (B,T,V,L,3) -> (B,T,V,L*3)
        xv = x.view(B, T, L, 3, V).permute(0, 1, 4, 2, 3).contiguous().view(B, T, V, L3)
        return xv  # (B,T,V,in_per_view)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        le = ll = None
        if self.fusion in ("early", "hybrid"):
            le = self.head_early(self.backbone_early(x))
        if self.fusion in ("late", "hybrid"):
            xv = self._split_views(x)  # (B,T,V,Fv)
            B, T, V, Fv = xv.shape
            z = self.backbone_late(xv.view(B * V, T, Fv)).view(B, V, -1)  # (B,V,2W)
            if self.view_attn is None: z = z.mean(1)                      # (B,2W)
            else:                      z = self.view_attn(z)              # (B,2W)
            ll = self.head_late(z)
        if self.fusion == "early": return le
        if self.fusion == "late":  return ll
        return self.hybrid_alpha * le + (1.0 - self.hybrid_alpha) * ll

# -------------------------------- Subject inference -------------------------------
def infer_subject_from_meta(npz_path: str, meta: dict) -> str:
    base = Path(npz_path).name
    parts = base.split('_')

    known = {
        'ella':'Cummings_Ella','garcia':'Garcia_Anika','mia':'Andrilla_Mia','christopher':'Andrilla_Christopher',
        'lilian':'Barrientos_Lilian','jose':'Montenegro_Jose','shelley':'Sinegal_Shelley','carrie':'Cummings_Carrie',
        'jesse':'Diepenbrock_Jesse','dekyi':'Llahmo_Dekyi','tenzin':'Tswang_Tenzin','mark':'Borsody_Mark',
        'dylan':'Goeppinger_Dylan','lucy':'Sinegal_Lucy','denise':'Castillo_Denise','avneet':'Sidhu_Avneet',
        'jacqui':'Chua_Jacqui','elena':'Countouriotus_Elena','jackson':'Henn_Jackson','pema':'Namgyal_Pema',
        'tania':'Perez_Tania','naresh':'Joshi_Naresh','padilla':'Ramirez_Padilla','andrilla':'Andrilla_Mia',
        'barrientos':'Barrientos_Lilian','montenegro':'Montenegro_Jose','sinegal':'Sinegal_Shelley','cummings':'Cummings_Carrie',
        'diepenbrock':'Diepenbrock_Jesse','llahmo':'Llahmo_Dekyi','tswang':'Tswang_Tenzin','borsody':'Borsody_Mark',
        'goeppinger':'Goeppinger_Dylan','castillo':'Castillo_Denise','sidhu':'Sidhu_Avneet','chua':'Chua_Jacqui',
        'countouriotus':'Countouriotus_Elena','henn':'Henn_Jackson','namgyal':'Namgyal_Pema','perez':'Perez_Tania',
        'joshi':'Joshi_Naresh','ramirez':'Ramirez_Padilla','lizeth':'Ramirez_Padilla','valencia':'Samantha_Valencia',
    }
    for i in range(len(parts) - 2):
        a,b,c = parts[i:i+3]
        if all(s and s[0].isupper() for s in (a,b,c)): return f"{a}_{b}"
    for i in range(len(parts) - 1):
        a,b = parts[i:i+2]
        if a and b and a[0].isupper() and b[0].isupper(): return f"{a}_{b}"
    for p in parts:
        pl = p.lower()
        if pl in known: return known[pl]
    m = next((re.search(r'(\d{4})-(\d{2})-(\d{2})(?:\s*(\d{2})-(\d{2})-(\d{2}))?', p) for p in parts if re.search(r'\d{4}-\d{2}-\d{2}', p)), None)
    if m:
        y,mo,d,h,mi,s = m.groups()
        return f"Date_{y}{mo}{d}" + (f"_{h}{mi}{s}" if h else "")
    stem = Path(meta.get('video_filename','') or '').stem
    if stem:
        toks = stem.split('_')
        for i in range(len(toks)-1):
            a,b = toks[i:i+2]
            if a and b and a[0].isupper() and b[0].isupper(): return f"{a}_{b}"
    return "UnknownSubject"

# --------------------------- Subject split report (compact) -----------------------
def print_subject_split_report(full_ds, train_files_idx, val_files_idx):
    print("\n" + "="*80 + "\nSUBJECT SPLIT REPORT\n" + "="*80)
    tr = [full_ds.meta_per_file[i]['subject'] for i in train_files_idx]
    va = [full_ds.meta_per_file[i]['subject'] for i in val_files_idx]
    overlap = set(tr) & set(va)
    print(f"Train subjects: {len(set(tr))} | Val subjects: {len(set(va))}")
    print("⚠️ Overlap:" if overlap else "✅ No subject overlap", overlap if overlap else "")
    for title, ct in (("\nTrain Subjects:", Counter(tr)), ("\nVal Subjects:", Counter(va))):
        print(title); [print(f"  - {s:<25} ({ct[s]} files)") for s in sorted(ct)]
    print("="*80 + "\n")

# -------------------------------- Dataset & helpers -------------------------------
def _np_to_xyz(arr, use_vis=False):
    arr = np.asarray(arr, np.float32)
    if arr.ndim != 3 or arr.shape[-1] < 3: return None
    xyz = arr[..., :3]
    if use_vis and arr.shape[-1] >= 4:
        vis = arr[..., 3]; mask = (vis < 0.2).astype(np.float32)
        xyz = xyz * (1.0 - mask[..., None])
    return xyz

def _first_T(shapes):  # min length across views
    T = None
    for s in shapes:
        if T is None: T = s[0]
        else: T = min(T, s[0])
    return T

class NPZWindowDataset(Dataset):
    def __init__(self, files: List[str], class_map: Dict[str, int],
                 T: int = 60, default_stride: int = 15,
                 target_stride_s: Optional[float] = None,
                 max_views: int = 3, use_visibility_mask: bool = False,
                 use_soft_labels: bool = False,
                 lazy_load: bool = False):
        self.files, self.class_map = files, class_map
        self.T, self.default_stride, self.target_stride_s = T, default_stride, target_stride_s
        self.max_views, self.use_visibility_mask = max_views, use_visibility_mask
        self.use_soft_labels, self.lazy_load = use_soft_labels, lazy_load

        self.landmarks_per_view = NUM_POSE_LANDMARKS  # pose only
        self.index: List[Tuple[int,int]] = []; self.meta_per_file: List[Dict] = []; self.discovered_labels = set()
        if not self.lazy_load: self.views_per_file, self.frame_labels_per_file = [], []
        failed = []

        for path in self.files:
            try:
                with np.load(path, allow_pickle=False) as z:
                    vkeys = [k for k in z.files if k.startswith("view_")][: self.max_views]
                    if not vkeys: continue

                    # metadata (compact scalar/array handling)
                    meta = {}
                    for k in z.files:
                        if k in vkeys: continue
                        arr = z[k]
                        if getattr(arr, 'shape', ()) == ():
                            with suppress(Exception):
                                try:
                                    v = arr.item()
                                    if isinstance(v, (bytes, bytearray)): v = v.decode(errors="ignore")
                                    meta[k] = v; continue
                                except Exception:
                                    pass
                        meta[k] = arr

                    label_name = str(meta.get("movement_type", "")).strip()
                    if not label_name: continue
                    self.discovered_labels.add(label_name)

                    fps = float(meta.get("fps", 60.0) or 60.0)
                    subject = infer_subject_from_meta(path, meta)

                    if not self.lazy_load:
                        views = []
                        for vk in vkeys:
                            xyz = _np_to_xyz(z[vk], self.use_visibility_mask)
                            if xyz is not None: views.append(xyz)
                        if not views: continue
                        Tlen = min(a.shape[0] for a in views)
                        views = [a[:Tlen] for a in views]

                        frame_labels = None
                        if self.use_soft_labels:
                            if 'frame_labels' in z: frame_labels = np.asarray(z['frame_labels'])
                            elif 'labels_per_frame' in z: frame_labels = np.asarray(z['labels_per_frame'])
                    else:
                        Tlen = _first_T([z[vk].shape for vk in vkeys]) if vkeys else None
                        if Tlen is None: continue

                    if Tlen < self.T: continue

                    stride = (max(1, int(round(fps * self.target_stride_s)))
                              if self.target_stride_s and fps > 0 else self.default_stride)
                    starts = list(range(0, Tlen - self.T + 1, stride)) or [0]

                    midx = len(self.meta_per_file)
                    self.meta_per_file.append({"path": path, "label": label_name, "fps": fps,
                                               "frames": Tlen, "subject": subject, "views": len(vkeys)})

                    if not self.lazy_load:
                        self.views_per_file.append(views)
                        self.frame_labels_per_file.append(frame_labels)

                    self.index.extend([(midx, s) for s in starts])
            except Exception as e:
                failed.append((path, str(e)))

        if failed:
            print(f"⚠️  Failed to load {len(failed)} files:")
            for path, err in failed[:5]: print(f"  - {Path(path).name}: {err}")
            if len(failed) > 5: print(f"  ... and {len(failed)-5} more")

        self.num_views = min(self.max_views, max((m.get("views",1) for m in self.meta_per_file), default=1))
        self.input_dim = self.landmarks_per_view * 3 * self.num_views
        self.discovered_labels = sorted(self.discovered_labels)
        if self.use_soft_labels and not self.lazy_load:
            has = sum(1 for fl in getattr(self, "frame_labels_per_file", []) if fl is not None)
            if has: print(f"\n📋 Frame-level labels found: {has}/{len(self.meta_per_file)} files")
        if self.lazy_load:  print("   🔄 Lazy loading enabled (lower memory, potentially slower)")

    def __len__(self): return len(self.index)

    def _load_views_lazy(self, midx: int) -> List[np.ndarray]:
        path = self.meta_per_file[midx]['path']
        with np.load(path, allow_pickle=False) as z:
            vkeys = [k for k in z.files if k.startswith("view_")][: self.max_views]
            out, Tlen = [], None
            for vk in vkeys:
                xyz = _np_to_xyz(z[vk], self.use_visibility_mask)
                if xyz is None: continue
                if Tlen is None: Tlen = xyz.shape[0]
                out.append(xyz)
        return out

    def _load_frame_labels_lazy(self, midx: int) -> Optional[np.ndarray]:
        if not self.use_soft_labels: return None
        path = self.meta_per_file[midx]['path']
        with np.load(path, allow_pickle=False) as z:
            return (np.asarray(z['frame_labels']) if 'frame_labels' in z else
                    np.asarray(z['labels_per_frame']) if 'labels_per_frame' in z else None)

    def _compute_soft_label(self, frame_labels: np.ndarray, start: int) -> np.ndarray:
        wl = frame_labels[start:start + self.T]
        cnt = Counter([str(l).strip() for l in wl])
        soft = np.zeros(len(self.class_map), np.float32)
        for s, c in cnt.items():
            if s in self.class_map: soft[self.class_map[s]] = c / len(wl)
        return soft

    def __getitem__(self, idx):
        midx, s = self.index[idx]
        if self.lazy_load:
            views = self._load_views_lazy(midx)
            frame_labels = self._load_frame_labels_lazy(midx) if self.use_soft_labels else None
        else:
            views = self.views_per_file[midx]
            frame_labels = self.frame_labels_per_file[midx] if self.use_soft_labels else None

        seqs = []
        num_v = min(len(views), self.num_views)
        for v in range(num_v):
            seq = normalize_single_view(views[v][s:s + self.T], NUM_POSE_LANDMARKS)
            seqs.append(seq)
        if num_v == 0:
            pad = np.zeros((self.T, self.landmarks_per_view, 3), np.float32)
            seqs = [pad] * self.num_views
        elif num_v < self.num_views:
            seqs.extend([seqs[0].copy() for _ in range(self.num_views - num_v)])

        fused = np.concatenate(seqs, 2).astype(np.float32)  # (T, L, 3*V)
        label = self.meta_per_file[midx]["label"]
        subj  = self.meta_per_file[midx]["subject"]

        if self.use_soft_labels and frame_labels is not None:
            return fused, self._compute_soft_label(frame_labels, s), subj, True
        return fused, self.class_map[label], subj, False

# ----------------------- Temporal Artifact Analysis & Filtering -------------------
def analyze_window_purity(dataset: NPZWindowDataset) -> Dict:
    if dataset.lazy_load:          print("⚠️  Lazy load: skip purity analysis."); return {}
    if not dataset.use_soft_labels: print("⚠️  Soft labels disabled; no frame labels."); return {}
    if not any(fl is not None for fl in dataset.frame_labels_per_file): print("⚠️  No frame-level labels."); return {}

    pur_by_cls, allp = defaultdict(list), []
    for midx, start in dataset.index:
        fl = dataset.frame_labels_per_file[midx]
        if fl is None: continue
        wl = [str(l).strip() for l in fl[start:start+dataset.T]]
        _, dom = Counter(wl).most_common(1)[0]
        purity = dom / len(wl)
        pur_by_cls[dataset.meta_per_file[midx]['label']].append(purity); allp.append(purity)

    if not allp: print("⚠️  No analyzable windows."); return {}
    print(f"\n{'='*80}\nTEMPORAL SEGMENTATION ARTIFACT ANALYSIS\n{'='*80}")
    print(f"Overall windows: {len(allp)}\n  Mean purity:   {np.mean(allp):.1%}\n  Median purity: {np.median(allp):.1%}")
    print(f"  ≥80% purity:   {100*sum(p>=0.8 for p in allp)/len(allp):.1f}%\n  ≥90% purity:   {100*sum(p>=0.9 for p in allp)/len(allp):.1f}%")
    return {'purities_by_class': pur_by_cls, 'all_purities': allp}

def filter_windows_by_purity(dataset: NPZWindowDataset, train_indices: List[int], min_purity: float = 0.8) -> List[int]:
    if dataset.lazy_load or not dataset.use_soft_labels:
        print("⚠️  Cannot filter by purity (lazy or no soft labels)."); return train_indices
    if not any(fl is not None for fl in dataset.frame_labels_per_file):
        print("⚠️  No frame-level labels for purity filtering."); return train_indices
    kept = []
    for idx in train_indices:
        midx, s = dataset.index[idx]; fl = dataset.frame_labels_per_file[midx]
        if fl is None: kept.append(idx); continue
        wl = [str(l).strip() for l in fl[s:s + dataset.T]]
        if Counter(wl).most_common(1)[0][1] / len(wl) >= min_purity: kept.append(idx)
    print(f"\n🎯 Window Purity Filtering: kept {len(kept)}/{len(train_indices)}")
    return kept

# --------------------------- Balancing: Sampler & Weights -------------------------
def make_balanced_sampler_for_subset(full_ds: NPZWindowDataset, subset_indices: List[int]) -> WeightedRandomSampler:
    file_to_n = defaultdict(int)
    for wi in subset_indices:
        midx, _ = full_ds.index[wi]; file_to_n[midx] += 1
    lab_cnt, sub_cnt = Counter(), Counter()
    for midx, n in file_to_n.items():
        m = full_ds.meta_per_file[midx]
        lab_cnt[m['label']] += n; sub_cnt[m['subject']] += n
    lab_w = {k: (1/max(c,1)) for k,c in lab_cnt.items()}; lw = np.mean(list(lab_w.values())) if lab_w else 1.0
    lab_w = {k: v/lw for k,v in lab_w.items()}
    sub_w = {k: (1/max(c,1)) for k,c in sub_cnt.items()}; sw = np.mean(list(sub_w.values())) if sub_w else 1.0
    sub_w = {k: v/sw for k,v in sub_w.items()}

    weights = []
    for wi in subset_indices:
        midx, _ = full_ds.index[wi]; m = full_ds.meta_per_file[midx]
        weights.append(lab_w.get(m['label'],1.0)*sub_w.get(m['subject'],1.0))
    weights_t = torch.as_tensor(weights, dtype=torch.float32)
    return WeightedRandomSampler(weights_t, num_samples=len(weights), replacement=True)

def class_weights_from_train_subset(full_ds: NPZWindowDataset, train_subset: Subset, class_map: Dict[str,int],
                                    pow_smooth: float = 0.5, clip: Tuple[float,float] = (0.5,8.0)) -> torch.Tensor:
    counts = np.zeros(len(class_map), np.int64)
    for wi in train_subset.indices:
        midx, _ = full_ds.index[wi]; lab = full_ds.meta_per_file[midx]['label']; counts[class_map[lab]] += 1
    inv = counts.sum() / np.clip(counts, 1, None)
    w = np.clip(np.power(inv / inv.mean(), pow_smooth), clip[0], clip[1])
    return torch.tensor(w, dtype=torch.float32)

# ----------------------------- Collate / Augmentations ----------------------------
class CollateWindows:
    def __init__(self, augment: bool = False,
                 time_mask_prob: float = 0.0, time_mask_max_frames: int = 8,
                 joint_dropout_prob: float = 0.0, joint_dropout_frac: float = 0.15,
                 noise_std: float = 0.0,
                 rotation_prob: float = 0.0, rotation_angle_deg: float = 15.0,
                 scale_prob: float = 0.0, scale_min: float = 0.9, scale_max: float = 1.1,
                 temporal_warp_prob: float = 0.0,
                 normal_class_name: str = "normal",
                 class_map: Optional[Dict[str,int]] = None,
                 aug_normal_scale: float = 0.5,
                 aug_normal_overrides: Optional[Dict[str,float]] = None):
        self.augment = augment
        self.time_mask_prob, self.time_mask_max_frames = time_mask_prob, time_mask_max_frames
        self.joint_dropout_prob, self.joint_dropout_frac = joint_dropout_prob, joint_dropout_frac
        self.noise_std = noise_std
        self.rotation_prob, self.rotation_angle_deg = rotation_prob, rotation_angle_deg
        self.scale_prob, self.scale_min, self.scale_max = scale_prob, scale_min, scale_max
        self.temporal_warp_prob = temporal_warp_prob
        self.normal_class_name, self.class_map = normal_class_name, (class_map or {})
        self.aug_normal_scale = float(aug_normal_scale)
        self.aug_normal_overrides = aug_normal_overrides or {}
        self.normal_class_idx = self.class_map.get(self.normal_class_name, None)

    def _aug_params(self, y_label: int):
        if self.normal_class_idx is None or y_label != self.normal_class_idx:
            return (self.time_mask_prob, self.joint_dropout_prob, self.noise_std,
                    self.rotation_prob, self.scale_prob, self.temporal_warp_prob)
        tmp = dict(time_mask_prob=self.time_mask_prob, joint_dropout_prob=self.joint_dropout_prob,
                   noise_std=self.noise_std, rotation_prob=self.rotation_prob,
                   scale_prob=self.scale_prob, temporal_warp_prob=self.temporal_warp_prob)
        for k in tmp: tmp[k] *= self.aug_normal_scale
        tmp.update({k: self.aug_normal_overrides[k] for k in self.aug_normal_overrides})
        return (tmp['time_mask_prob'], tmp['joint_dropout_prob'], tmp['noise_std'],
                tmp['rotation_prob'], tmp['scale_prob'], tmp['temporal_warp_prob'])

    def __call__(self, batch):
        xs, ys, subs, _ = zip(*batch)
        x = torch.from_numpy(np.stack(xs, 0))
        if x.dim() == 4: x = x.flatten(2, 3)  # (B,T,L,3V) -> (B,T,L*3V)
        elif x.dim() != 3: raise ValueError(f"Unexpected input shape {tuple(x.shape)}")

        y_soft = isinstance(ys[0], np.ndarray)
        y = torch.from_numpy(np.stack(ys,0)).float() if y_soft else torch.tensor(ys, dtype = torch.long)
        if not self.augment: return x, y, list(subs)

        B, T, F = x.shape; L = (F // 3) // max(1, (F // (3 * max(1, (F // (3 * 1))))))  # robust but not relied upon
        def _rotate_y(sample, deg):
            # (T,F) where F = L*3*V -> treat as (T,L,3,V) and rotate xyz
            V = F // (3 * L)
            pts = sample.view(T, L, 3, V)
            a = torch.tensor(np.radians(deg), dtype=sample.dtype, device=sample.device)
            c, s = torch.cos(a), torch.sin(a)
            R = torch.stack([torch.stack([c, torch.zeros_like(c),  s]),
                             torch.stack([torch.zeros_like(c), torch.ones_like(c), torch.zeros_like(c)]),
                             torch.stack([-s, torch.zeros_like(c), c])], 0)  # (3,3)
            rot = torch.einsum('ij,tlvj->tlvi', R, pts).reshape(T, F)
            return rot

        def _tw(sample, r=(0.8,1.2)):
            rate = float(np.random.uniform(*r)); newT = int(max(4, round(T*rate)))
            warped = torch.nn.functional.interpolate(sample.t().unsqueeze(0), size=newT, mode='linear', align_corners=False).squeeze(0).t()
            if newT >= T: return warped[:T]
            out = sample.clone(); out[:newT]=warped; out[newT:]=warped[-1]; return out

        xo = x.clone()
        for b in range(B):
            lbl = int(y[b].item()) if not y_soft else -1
            tm_p, jd_p, nz, rot_p, sc_p, tw_p = self._aug_params(lbl)
            s = xo[b]
            if rot_p > 0 and random.random() < rot_p: s = _rotate_y(s, random.uniform(-self.rotation_angle_deg, self.rotation_angle_deg))
            if sc_p > 0 and random.random() < sc_p: s = s * float(np.random.uniform(self.scale_min, self.scale_max))
            if tw_p > 0 and random.random() < tw_p: s = _tw(s)
            if tm_p > 0 and self.time_mask_max_frames > 0 and random.random() < tm_p:
                Lm = random.randint(1, min(self.time_mask_max_frames, T)); st = random.randint(0, T-Lm); s[st:st+Lm,:] = 0
            if jd_p > 0 and self.joint_dropout_frac > 0 and random.random() < jd_p:
                # drop landmark triplets across all views
                V = F // (3 * NUM_POSE_LANDMARKS)
                k = max(1, int(round(NUM_POSE_LANDMARKS * self.joint_dropout_frac))); drop = torch.randperm(NUM_POSE_LANDMARKS)[:k]
                for j in drop:
                    for v in range(V):
                        base = 3 * (v * NUM_POSE_LANDMARKS + j)
                        s[:, base:base+3] = 0.0
            if nz > 0: s = s + torch.randn_like(s)*float(nz)
            xo[b] = s
        return xo, y, list(subs)

# ----------------------------- Threaded GPU prefetcher ----------------------------
class _ThreadedCUDAPrefetcher:
    def __init__(self, loader, device: torch.device, max_prefetch: int = 2):
        self.loader = iter(loader); self.device = device
        self.queue, self.stream = queue.Queue(max_prefetch), (torch.cuda.Stream() if device.type == "cuda" else None)
        self._t = threading.Thread(target=self._producer, daemon=True); self._t.start()

    def _to_device(self, batch):
        xb, yb, subs = batch
        xb = xb.to(self.device, non_blocking=True) if isinstance(xb, torch.Tensor) else xb
        yb = yb.to(self.device, non_blocking=True) if isinstance(yb, torch.Tensor) else yb
        return xb, yb, subs

    def _producer(self):
        try:
            while True:
                try: nxt = next(self.loader)
                except StopIteration: self.queue.put(None); break
                if self.stream is None: self.queue.put(self._to_device(nxt))
                else:
                    with torch.cuda.stream(self.stream): batch = self._to_device(nxt)
                    self.queue.put(batch)
        except Exception as e: self.queue.put(e)

    def __iter__(self): return self
    def __next__(self):
        item = self.queue.get()
        if item is None: raise StopIteration
        if isinstance(item, Exception): raise item
        if self.stream is not None: torch.cuda.current_stream().wait_stream(self.stream)
        return item

def device_iter(loader, device: torch.device, max_prefetch: int = 2):
    return _ThreadedCUDAPrefetcher(loader, device, max_prefetch) if device.type == "cuda" else iter(loader)

# ----------------------------------- EMA -----------------------------------------
class ModelEMA:
    """Exponential Moving Average of model weights (safe & lightweight)."""
    def __init__(self, model: nn.Module, decay: float = 0.9999, device: Optional[torch.device] = None):
        self.ema = copy.deepcopy(model).eval()
        for p in self.ema.parameters(): p.requires_grad_(False)
        self.decay = float(decay)
        if device is not None: self.ema.to(device)

    @torch.no_grad()
    def update(self, model: nn.Module):
        d = self.decay
        msd = model.state_dict()
        for k, v in self.ema.state_dict().items():
            if v.dtype.is_floating_point:
                v.copy_(v * d + msd[k].detach() * (1. - d))
            else:
                v.copy_(msd[k])

    def state_dict(self):
        return self.ema.state_dict()

    def load_state_dict(self, sd, strict=True):
        self.ema.load_state_dict(sd, strict=strict)

# ----------------------------------- Plotting ------------------------------------
def plot_training_curves(history: dict, out_dir: str):
    try:
        import matplotlib; matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception:
        return
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    axes[0,0].plot(history['train_loss'], label='Train')
    if 'val_loss' in history: axes[0,0].plot(history['val_loss'], label='Val')
    axes[0,0].set_title('Loss'); axes[0,0].legend(); axes[0,0].set_xlabel('Epoch')

    axes[0,1].plot(history['val_acc'], label='Val Acc')
    axes[0,1].plot(history['val_balanced_acc'], label='Val Balanced Acc')
    axes[0,1].set_title("Accuracy Metrics"); axes[0,1].legend()

    axes[1,0].plot(history['val_macro_f1'], label='Val Macro F1')
    axes[1,0].set_title("Macro F1"); axes[1,0].legend()

    axes[1,1].plot(history['lr'], label='Learning Rate'); axes[1,1].set_yscale('log')
    axes[1,1].set_title('LR'); axes[1,1].legend()
    plt.tight_layout(); os.makedirs(out_dir, exist_ok=True)
    plt.savefig(os.path.join(out_dir, "training_curves.png"), dpi=150); plt.close()

def plot_confusion(y_true, y_pred, classes, out_path: str):
    try:
        import matplotlib; matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        import seaborn as sns  # optional
        cm = confusion_matrix(y_true, y_pred, labels=list(range(len(classes))))
        cmn = cm.astype(np.float32) / np.clip(cm.sum(axis=1, keepdims=True), 1, None)
        plt.figure(figsize=(max(6, 0.35*len(classes)), max(5, 0.35*len(classes))))
        sns.heatmap(cmn, annot=False, fmt=".2f", xticklabels=classes, yticklabels=classes)
        plt.ylabel("True"); plt.xlabel("Predicted"); plt.title("Confusion (row-normalized)")
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        plt.tight_layout(); plt.savefig(out_path, dpi=160); plt.close()
    except Exception as e:
        print(f"⚠️  Could not plot confusion matrix: {e}")

# --------------------------- Class distribution diagnostic ------------------------
def print_class_distribution(full_ds, train_ds, val_ds, classes):
    print("\n" + "="*80 + "\nCLASS DISTRIBUTION DIAGNOSTIC\n" + "="*80)
    def dist(indices):
        c = Counter(); [c.update([full_ds.meta_per_file[full_ds.index[i][0]]['label']]) for i in indices]; return c
    trd, vad = dist(train_ds.indices), dist(val_ds.indices)
    print("\nTRAIN vs VAL distribution:")
    print(f"{'Class':<20} {'Train':>10} {'Val':>10} {'Train%':>8} {'Val%':>8} {'Weight':>8}")
    print("-"*80)
    for cls in classes:
        tr = trd.get(cls,0); va = vad.get(cls,0); trp = 100*tr/max(1,len(train_ds)); vap = 100*va/max(1,len(val_ds))
        w = len(train_ds)/max(1,tr) if tr>0 else 0
        print(f"{cls:<20} {tr:>10} {va:>10} {trp:>7.2f}% {vap:>7.2f}% {w:>7.2f}x")
    if trd:
        r = max(trd.values())/max(1,min(trd.values()))
        print(f"\n{'Imbalance Ratio:':<20} {r:>7.1f}:1")
        print("🚨 SEVERE IMBALANCE! Consider sampler and smoothed/clipped weights." if r>20 else
              "⚠️  MODERATE IMBALANCE. Sampler or weights will help." if r>10 else
              "✓ Relatively balanced dataset.")
    print("="*80 + "\n")

# ----------------------------------- Evaluation ----------------------------------
@torch.no_grad()
def evaluate(model, loader, device, criterion_eval=None, return_preds: bool=False, temperature: float = 1.0):
    model.eval(); ys, ps, logits_all = [], [], []; n, loss_sum = 0, 0.0
    use_cuda = (device.type == 'cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    for xb, yb, _ in device_iter(loader, device):
        y_soft = torch.is_floating_point(yb) if isinstance(yb, torch.Tensor) else False
        with torch.amp.autocast(device_type=device.type, dtype=torch.bfloat16 if use_bf16 else torch.float16, enabled=use_cuda):
            logits = model(xb)
            if criterion_eval is not None:
                if y_soft:
                    loss_sum += (-(yb * nn.functional.log_softmax(logits, -1)).sum(-1).mean().item() * xb.size(0))
                else:
                    loss_sum += criterion_eval(logits, yb).item() * xb.size(0)
        logits = logits.float(); scaled = logits / float(temperature); pred = scaled.argmax(1)
        ps.append(pred.cpu().numpy()); ys.append((yb.argmax(1) if y_soft else yb).cpu().numpy())
        if return_preds: logits_all.append(scaled.cpu().numpy())
        n += xb.size(0)

    y = np.concatenate(ys) if ys else np.array([]); p = np.concatenate(ps) if ps else np.array([])
    out = {'acc': float(accuracy_score(y, p)) if len(y) else 0.0,
           'balanced_acc': float(balanced_accuracy_score(y, p)) if len(y) else 0.0,
           'macro_f1': float(f1_score(y, p, average='macro', zero_division=0)) if len(y) else 0.0}
    if criterion_eval is not None and n > 0: out['val_loss'] = loss_sum / n
    if return_preds:
        out.update({'y': y, 'p': p})
        if logits_all: out['logits'] = np.concatenate(logits_all)
    return out

def find_best_temperature(model, val_loader, device, T_range=None):
    T_range = T_range or np.linspace(0.7, 2.0, 14)
    model.eval(); all_logits, all_labels = [], []
    use_cuda = (device.type == 'cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    with torch.no_grad():
        for xb, yb, _ in device_iter(val_loader, device):
            y_soft = torch.is_floating_point(yb) if isinstance(yb, torch.Tensor) else False
            with torch.amp.autocast(device_type=device.type, dtype=torch.bfloat16 if use_bf16 else torch.float16, enabled=use_cuda):
                logits = model(xb)
            all_logits.append(logits.float().cpu())
            all_labels.append((yb.argmax(1) if y_soft else yb).cpu())
    all_logits = torch.cat(all_logits, 0); all_labels = torch.cat(all_labels, 0)
    best_T, best_nll = 1.0, float('inf')
    for T in T_range:
        nll = nn.functional.cross_entropy(all_logits / float(T), all_labels).item()
        if nll < best_nll: best_T, best_nll = float(T), nll
    return best_T, best_nll

# --------------------------- Robust, atomic checkpoint save -----------------------
def safe_save(obj, path, use_legacy_zip=False, light=False):
    """
    Atomically write a checkpoint to disk:
      - writes to a temp file in the same dir
      - fsyncs & rename() to avoid partial/corrupt files on Windows & network shares
      - optional: legacy (non-zip) format for flaky filesystems
      - optional: 'light' to drop big states (optimizer/scheduler/ema)
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)

    if light and isinstance(obj, dict):
        keys_keep = {"epoch", "model_state_dict", "classes", "best_macro_f1", "args"}
        obj = {k: v for k, v in obj.items() if k in keys_keep}

    save_kwargs = {}
    if use_legacy_zip:
        save_kwargs["_use_new_zipfile_serialization"] = False

    dir_ = os.path.dirname(path) or "."
    with tempfile.NamedTemporaryFile(dir=dir_, delete=False) as tmp:
        tmp_name = tmp.name
    try:
        with open(tmp_name, "wb") as f:
            torch.save(obj, f, **save_kwargs)
            f.flush(); os.fsync(f.fileno())
        os.replace(tmp_name, path)
    finally:
        with suppress(Exception):
            if os.path.exists(tmp_name):
                os.remove(tmp_name)

# ----------------------------------- Training ------------------------------------
def train_one_epoch(model, loader, optimizer, device, accumulation_steps=2, scaler=None,
                    criterion=None, mixup_alpha: float = 0.0, grad_clip: float = 0.0,
                    ema: Optional[ModelEMA] = None, skip_oom: bool = False):
    model.train(); total, n = 0.0, 0
    class _NoScaler:
        def is_enabled(self): return False
        def scale(self, x): return x
        def step(self, opt): opt.step()
        def update(self): pass
        def unscale_(self, opt): pass
    scaler = scaler or _NoScaler()
    optimizer.zero_grad(set_to_none=True)
    use_cuda = (device.type == 'cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()

    def _flush_step():
        nonlocal ema
        if grad_clip > 0:
            if scaler.is_enabled(): scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), grad_clip)
        (scaler.step(optimizer) if scaler.is_enabled() else optimizer.step())
        (scaler.update() if scaler.is_enabled() else None)
        optimizer.zero_grad(set_to_none=True)
        if ema is not None: ema.update(model)

    for b_idx, (xb, yb, _) in enumerate(device_iter(loader, device)):
        try:
            y_soft = torch.is_floating_point(yb) if isinstance(yb, torch.Tensor) else False
            lam, yb2 = 1.0, None
            if mixup_alpha > 0 and xb.size(0) > 1 and not y_soft:
                lam = np.random.beta(mixup_alpha, mixup_alpha); perm = torch.randperm(xb.size(0), device=xb.device)
                xb = lam * xb + (1 - lam) * xb[perm]; yb2 = yb[perm]

            with torch.amp.autocast(device_type=device.type, dtype=torch.bfloat16 if use_bf16 else torch.float16, enabled=use_cuda):
                logits = model(xb)
                if y_soft:
                    loss = -(yb * nn.functional.log_softmax(logits, -1)).sum(-1).mean()
                else:
                    loss = criterion(logits, yb) if yb2 is None else lam*criterion(logits, yb) + (1-lam)*criterion(logits, yb2)

            (scaler.scale(loss / accumulation_steps) if scaler.is_enabled() else (loss / accumulation_steps)).backward()

            if (b_idx + 1) % accumulation_steps == 0:
                _flush_step()

            bs = xb.size(0); total += loss.item() * bs; n += bs

        except torch.cuda.OutOfMemoryError:
            if not skip_oom: raise
            warnings.warn("⚠️  CUDA OOM encountered — skipping this batch.")
            if torch.cuda.is_available(): torch.cuda.empty_cache()
            optimizer.zero_grad(set_to_none=True)
            continue

    if (len(loader) % accumulation_steps) != 0:
        _flush_step()
    return total / max(1, n)

# -------------------------------------- Main -------------------------------------
def main():
    import argparse
    ap = argparse.ArgumentParser(description="PoseTCN — Pose-only + Multi-Head Attention")
    add = ap.add_argument

    # Paths & basics
    add("--data_dir", type=str, required=True)
    add("--out", type=str, default="runs_pose"); add("--seed", type=int, default=42)
    add("--deterministic", action="store_true")

    # Data & windowing
    add("--T", type=int, default=60); add("--target_stride_s", type=float, default=0.25)
    add("--default_stride", type=int, default=15); add("--max_views", type=int, default=3)
    add("--use_visibility_mask", action="store_true"); add("--val_size", type=float, default=0.2)

    # Dataloader performance
    add("--num_workers", type=int, default=0); add("--prefetch_factor", type=int, default=2)
    add("--lazy_load", action="store_true"); add("--mp_start_method", type=str, default=None)

    # Model
    add("--width", type=int, default=384); add("--dropout", type=float, default=0.1)
    add("--stochastic_depth", type=float, default=0.05); add("--dilations", type=str, default="1,2,4,8,16,32,64")
    add("--norm", type=str, default="bn", choices=["bn","gn"])

    # Attention controls
    add("--t_heads", type=int, default=4, help="Temporal MHA heads")
    add("--view_heads", type=int, default=4, help="View MHA heads (if view_fusion=attn)")
    add("--attn_dropout", type=float, default=0.0)

    # Fusion
    add("--fusion", type=str, default="hybrid", choices=["early", "late", "hybrid"])
    add("--view_fusion", type=str, default="mean", choices=["mean", "attn"])
    add("--hybrid_alpha", type=float, default=0.5)

    # Training
    add("--epochs", type=int, default=60); add("--batch", type=int, default=384)
    add("--accumulation_steps", type=int, default=1); add("--lr", type=float, default=5e-4)
    add("--weight_decay", type=float, default=0.01); add("--grad_clip", type=float, default=1.0)
    add("--ckpt_prefix", type=str, default="pose_best"); add("--report_each", type=int, default=5)
    add("--early_stop_patience", type=int, default=12)
    add("--skip_oom", action="store_true", help="Skip OOM batches instead of failing")

    # Imbalance handling
    add("--imbalance_strategy", type=str, default="sampler", choices=["sampler","weights","none"])
    add("--use_focal_loss", action="store_true"); add("--focal_gamma", type=float, default=1.0)
    add("--label_smoothing", type=float, default=0.1); add("--weight_smooth_power", type=float, default=0.5)
    add("--weight_clip_min", type=float, default=0.5); add("--weight_clip_max", type=float, default=8.0)

    # Augmentations
    add("--aug_enable", action="store_true")
    add("--aug_time_mask_prob", type=float, default=0.1); add("--aug_time_mask_max_frames", type=int, default=6)
    add("--aug_joint_dropout_prob", type=float, default=0.2); add("--aug_joint_dropout_frac", type=float, default=0.1)
    add("--aug_noise_std", type=float, default=0.01); add("--aug_rotation_prob", type=float, default=0.2)
    add("--aug_rotation_angle_deg", type=float, default=10.0); add("--aug_scale_prob", type=float, default=0.2)
    add("--aug_scale_min", type=float, default=0.95); add("--aug_scale_max", type=float, default=1.05)
    add("--aug_temporal_warp_prob", type=float, default=0.0)

    # Normal-class-aware augmentation
    add("--aug_normal_scale", type=float, default=0.5); add("--normal_class_name", type=str, default="normal")

    # Mixup
    add("--mixup_alpha", type=float, default=0.0)

    # Scheduler
    add("--use_cosine_schedule", action="store_true"); add("--warmup_epochs", type=int, default=5)

    # Temporal artifact & soft labels
    add("--use_soft_labels", action="store_true"); add("--analyze_temporal_artifacts", action="store_true")
    add("--filter_window_purity", type=float, default=0.0)

    # Calibration
    add("--calibrate_temperature", action="store_true")

    # Logging
    add("--plot_curves", action="store_true"); add("--save_history", action="store_true")
    add("--save_cm", action="store_true", help="Save confusion matrix on report epochs")

    # Advanced runtime
    add("--compile", action="store_true"); add("--compile_mode", type=str, default="reduce-overhead",
        choices=["default","reduce-overhead","max-autotune"])
    add("--ema_decay", type=float, default=0.0, help="EMA decay; 0 disables")
    add("--eval_ema", action="store_true", help="Evaluate EMA model instead of raw weights (if EMA enabled)")
    add("--resume", type=str, default="", help="Path to checkpoint to resume")
    add("--resume_strict", action="store_true", help="Strict state dict load")

    args = ap.parse_args()

    # Multiprocessing start method
    try:
        if args.mp_start_method: mp.set_start_method(args.mp_start_method, force=True)
        else: mp.set_start_method("spawn" if platform.system()=="Windows" else "forkserver", force=True)
    except (RuntimeError, ValueError): pass

    os.makedirs(args.out, exist_ok=True); seed_everything(args.seed, deterministic=args.deterministic)

    # Collect files
    all_npz = sorted(glob.glob(os.path.join(args.data_dir, "**", "*.npz"), recursive=True))
    if not all_npz: print(f"❌ No NPZ files found in {args.data_dir}"); return
    print(f"📂 Found {len(all_npz)} NPZ files\nLoading dataset...")

    # Dataset
    full_ds = NPZWindowDataset(
        files=all_npz, class_map={}, T=args.T, default_stride=args.default_stride,
        target_stride_s=(args.target_stride_s if args.target_stride_s > 0 else None),
        max_views=args.max_views, use_visibility_mask=args.use_visibility_mask,
        use_soft_labels=args.use_soft_labels, lazy_load=args.lazy_load
    )
    if not full_ds.discovered_labels: print("❌ No 'movement_type' found in NPZ files."); return
    classes = full_ds.discovered_labels; class_map = {lab:i for i,lab in enumerate(classes)}; full_ds.class_map = class_map

    # Sanity check
    try:
        x0, y0, s0, soft0 = full_ds[0]
        print(f"✓ Files: {len(full_ds.meta_per_file)}  |  Windows: {len(full_ds)}  |  Views: {full_ds.num_views}")
        print(f"✓ Sample window: {x0.shape}  |  Label: {'soft' if soft0 else int(y0)}  |  Subject: {s0}")
        exp = (args.T, full_ds.landmarks_per_view, 3*full_ds.num_views)
        assert x0.shape == exp, f"Shape mismatch: {x0.shape} vs {exp}"
    except Exception as e:
        print(f"⚠️  Sanity check warning: {e}")

    # Dilations
    try:
        dilations = [int(x.strip()) for x in args.dilations.split(",") if x.strip()] or [1,2,4,8,16,32]
    except Exception:
        dilations = [1,2,4,8,16,32]; print(f"⚠️  Invalid dilations, using default: {dilations}")

    # Subject-group split
    file_subjects = [m['subject'] for m in full_ds.meta_per_file]
    uidx = list(range(len(full_ds.meta_per_file)))
    print("\n🔀 Splitting dataset by subjects...")
    try:
        from sklearn.model_selection import StratifiedGroupKFold
        y_file, groups = [m['label'] for m in full_ds.meta_per_file], file_subjects
        sgkf, best, best_diff = StratifiedGroupKFold(n_splits=5, shuffle=True, random_state=args.seed), None, 1e9
        for tr, va in sgkf.split(uidx, y=y_file, groups=groups):
            diff = abs(len(va)/len(uidx) - args.val_size)
            if diff < best_diff: best, best_diff = (tr, va), diff
        train_files_idx, val_files_idx = best; print("✓ Using StratifiedGroupKFold")
    except Exception as e:
        print(f"⚠️  StratifiedGroupKFold failed ({e}), using GroupShuffleSplit")
        gss = GroupShuffleSplit(n_splits=1, test_size=args.val_size, random_state=args.seed)
        train_files_idx, val_files_idx = next(gss.split(uidx, groups=file_subjects))

    print_subject_split_report(full_ds, train_files_idx, val_files_idx)

    # Map file idx -> window idx
    file_to_windows = defaultdict(list)
    for wi, (midx, _) in enumerate(full_ds.index): file_to_windows[midx].append(wi)
    train_win_idxs, val_win_idxs = [], []
    for fi in train_files_idx: train_win_idxs.extend(file_to_windows[fi])
    for fi in val_files_idx:   val_win_idxs.extend(file_to_windows[fi])

    # Purity analysis / filtering
    if args.analyze_temporal_artifacts or args.filter_window_purity > 0: _ = analyze_window_purity(full_ds)
    if args.filter_window_purity > 0:
        train_win_idxs = filter_windows_by_purity(full_ds, train_win_idxs, args.filter_window_purity)

    # Subsets
    train_ds, val_ds = Subset(full_ds, train_win_idxs), Subset(full_ds, val_win_idxs)
    if len(train_ds) == 0 or len(val_ds) == 0: print("❌ Error: train or val dataset is empty"); return
    print(f"\n✓ Train windows: {len(train_ds):,}  |  Val windows: {len(val_ds):,}")
    print(f"✓ Views used: {full_ds.num_views}  → input_dim = {full_ds.input_dim}")
    print(f"✓ Landmarks per view: {full_ds.landmarks_per_view}")
    print_class_distribution(full_ds, train_ds, val_ds, classes)

    # Sampler strategy
    print(f"\n🎯 Imbalance Strategy: {args.imbalance_strategy.upper()}")
    use_sampler = (args.imbalance_strategy == "sampler")
    subset_sampler = make_balanced_sampler_for_subset(full_ds, train_win_idxs) if use_sampler else None
    print("   ✓ Using balanced sampler (label × subject) from TRAIN subset only" if use_sampler else "   ✓ Using random sampling (shuffle=True)")
    shuffle_train = not use_sampler

    # Collates
    ckw = dict(augment=args.aug_enable, time_mask_prob=args.aug_time_mask_prob, time_mask_max_frames=args.aug_time_mask_max_frames,
               joint_dropout_prob=args.aug_joint_dropout_prob, joint_dropout_frac=args.aug_joint_dropout_frac, noise_std=args.aug_noise_std,
               rotation_prob=args.aug_rotation_prob, rotation_angle_deg=args.aug_rotation_angle_deg, scale_prob=args.aug_scale_prob,
               scale_min=args.aug_scale_min, scale_max=args.aug_scale_max, temporal_warp_prob=args.aug_temporal_warp_prob,
               normal_class_name=args.normal_class_name, class_map=class_map, aug_normal_scale=args.aug_normal_scale, aug_normal_overrides=None)
    train_collate, val_collate = CollateWindows(**ckw), CollateWindows(augment=False, class_map=class_map, normal_class_name=args.normal_class_name)

    # Dataloaders
    pin = True
    train_loader = DataLoader(train_ds, batch_size=args.batch, sampler=subset_sampler, shuffle=(shuffle_train if subset_sampler is None else False),
                              num_workers=args.num_workers, pin_memory=pin, drop_last=True, collate_fn=train_collate,
                              persistent_workers=(args.num_workers > 0),
                              prefetch_factor=(args.prefetch_factor if args.num_workers > 0 else None),
                              worker_init_fn=worker_init_fn if args.num_workers > 0 else None)
    val_loader = DataLoader(val_ds, batch_size=args.batch, shuffle=False, num_workers=args.num_workers, pin_memory=pin, drop_last=False,
                            collate_fn=val_collate, persistent_workers=(args.num_workers > 0),
                            prefetch_factor=(args.prefetch_factor if args.num_workers > 0 else None),
                            worker_init_fn=worker_init_fn if args.num_workers > 0 else None)

    # Device
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n🖥️  Device: {device}")
    if device.type == 'cuda':
        print(f"   GPU: {torch.cuda.get_device_name(0)}")
        print(f"   Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")

    # Model
    model = PoseTCNMultiView(
        num_classes=len(classes), num_views=full_ds.num_views, width=args.width, drop=args.dropout,
        stochastic_depth=args.stochastic_depth, dilations=dilations, fusion=args.fusion,
        view_fusion=args.view_fusion, hybrid_alpha=args.hybrid_alpha, norm=args.norm,
        in_per_view=full_ds.landmarks_per_view * 3,
        t_heads=args.t_heads, view_heads=args.view_heads, attn_dropout=args.attn_dropout
    ).to(device)

    # torch.compile (PyTorch 2.x)
    if args.compile:
        try:
            model = torch.compile(model, mode=args.compile_mode)
            print(f"⚡ torch.compile enabled (mode={args.compile_mode})")
        except Exception as e:
            print(f"⚠️  torch.compile not available/failed: {e}")

    # Optimizer
    try:
        optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay, fused=torch.cuda.is_available())
    except TypeError:
        optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)

    # Scheduler
    if args.use_cosine_schedule:
        from torch.optim.lr_scheduler import CosineAnnealingLR, LinearLR, SequentialLR
        warm = int(max(0, args.warmup_epochs))
        if warm > 0:
            rem = max(1, args.epochs - warm)
            scheduler = SequentialLR(optimizer,
                                     schedulers=[LinearLR(optimizer, 0.1, 1.0, total_iters=warm),
                                                 CosineAnnealingLR(optimizer, T_max=rem, eta_min=1e-6)],
                                     milestones=[warm])
            print(f"📈 Scheduler: Cosine Annealing with {warm} epoch warmup")
        else:
            scheduler = CosineAnnealingLR(optimizer, T_max=args.epochs, eta_min=1e-6)
            print("📈 Scheduler: Cosine Annealing (no warmup)")
    else:
        try:
            scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='max', factor=0.5, patience=3, verbose=True)
        except TypeError:
            scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='max', factor=0.5, patience=3)
        print("📈 Scheduler: ReduceLROnPlateau")

    # AMP scaler
    use_cuda = (device.type == 'cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    try:
        scaler = torch.amp.GradScaler(enabled=use_cuda and not use_bf16, device='cuda')
    except TypeError:
        scaler = torch.cuda.amp.GradScaler(enabled=use_cuda and not use_bf16)
    print(f"   Mixed Precision: {'BF16' if use_bf16 else 'FP16' if use_cuda else 'Disabled'}")

    # EMA
    ema = ModelEMA(model, decay=args.ema_decay, device=device) if args.ema_decay and args.ema_decay > 0 else None
    if ema: print(f"   EMA: enabled (decay={args.ema_decay})")

    # Losses
    if args.use_focal_loss:
        if (args.imbalance_strategy == "weights"):
            cls_w = class_weights_from_train_subset(full_ds, train_ds, class_map,
                                                    pow_smooth=args.weight_smooth_power,
                                                    clip=(args.weight_clip_min, args.weight_clip_max)).to(device)
            print(f"🎯 Loss: Focal (γ={args.focal_gamma}) + Smoothed Class Weights + Label Smoothing ({args.label_smoothing})")
            criterion, criterion_eval = FocalLoss(alpha=cls_w, gamma=args.focal_gamma, label_smoothing=args.label_smoothing), nn.CrossEntropyLoss(weight=cls_w)
        else:
            print(f"🎯 Loss: Focal (γ={args.focal_gamma}) + Label Smoothing ({args.label_smoothing})")
            criterion, criterion_eval = FocalLoss(gamma=args.focal_gamma, label_smoothing=args.label_smoothing), nn.CrossEntropyLoss()
    else:
        if args.imbalance_strategy == "weights":
            cls_w = class_weights_from_train_subset(full_ds, train_ds, class_map,
                                                    pow_smooth=args.weight_smooth_power,
                                                    clip=(args.weight_clip_min, args.weight_clip_max)).to(device)
            print(f"🎯 Loss: CrossEntropy + Smoothed Class Weights + Label Smoothing ({args.label_smoothing})")
            criterion = nn.CrossEntropyLoss(weight=cls_w, label_smoothing=args.label_smoothing); criterion_eval = nn.CrossEntropyLoss(weight=cls_w)
        else:
            print(f"🎯 Loss: CrossEntropy + Label Smoothing ({args.label_smoothing})")
            criterion = nn.CrossEntropyLoss(label_smoothing=args.label_smoothing); criterion_eval = nn.CrossEntropyLoss()

    # Init classifier head bias with train priors (skip when using class weights)
    if args.imbalance_strategy != "weights":
        try:
            class_counts = np.zeros(len(classes), np.int64)
            for wi in train_win_idxs:
                midx, _ = full_ds.index[wi]; lab = full_ds.meta_per_file[midx]['label']
                class_counts[class_map[lab]] += 1
            priors = class_counts / np.clip(class_counts.sum(), 1, None)
            with torch.no_grad():
                if hasattr(model, "head_early"): model.head_early.bias.copy_(torch.log(torch.tensor(priors + 1e-8, device=model.head_early.bias.device)))
                if hasattr(model, "head_late"):  model.head_late.bias.copy_(torch.log(torch.tensor(priors + 1e-8, device=model.head_late.bias.device)))
            print("🧭 Initialized classifier biases with train priors.")
        except Exception as e:
            print(f"⚠️ Could not initialize head bias to priors: {e}")
    else:
        print("🧭 Skipping bias init (class weights in use).")

    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"   Parameters: {trainable_params:,} / {total_params:,} trainable")

    # Resume
    start_epoch, best_macro_f1, best_epoch = 0, -1.0, 0
    best_path = os.path.join(args.out, f"best_{args.ckpt_prefix}.pt")
    last_path = os.path.join(args.out, f"last_{args.ckpt_prefix}.pt")
    if args.resume and os.path.isfile(args.resume):
        print(f"\n🔁 Resuming from {args.resume}")
        ckpt = torch.load(args.resume, map_location=device)
        model.load_state_dict(ckpt['model_state_dict'], strict=args.resume_strict)
        with suppress(Exception): optimizer.load_state_dict(ckpt['optimizer_state_dict'])
        with suppress(Exception): scheduler.load_state_dict(ckpt.get('scheduler_state_dict', {}))
        if ema and 'ema_state_dict' in ckpt:
            with suppress(Exception): ema.load_state_dict(ckpt['ema_state_dict'], strict=False)
        start_epoch = int(ckpt.get('epoch', 0)); best_macro_f1 = float(ckpt.get('best_macro_f1', -1.0))
        print(f"   Resumed epoch {start_epoch}, best F1={best_macro_f1:.4f}")

    patience, no_improve = max(0, args.early_stop_patience), 0
    history = {'train_loss': [], 'val_loss': [], 'val_acc': [], 'val_balanced_acc': [], 'val_macro_f1': [], 'lr': []}

    print(f"\n{'='*80}\n🚀 Training Configuration\n{'='*80}")
    print(f"Epochs: {args.epochs}  |  Start: {start_epoch+1}  |  Batch: {args.batch}  |  Accum: {args.accumulation_steps}  |  LR: {args.lr}")
    print(f"Width: {args.width}  |  Dilations: {dilations}  |  Norm: {args.norm}")
    print(f"Dropout: {args.dropout}  |  Stochastic Depth: {args.stochastic_depth}")
    print(f"Fusion: {args.fusion}  |  View fusion: {args.view_fusion}  |  Hybrid α: {args.hybrid_alpha}")
    print(f"Temporal Heads: {args.t_heads}  |  View Heads: {args.view_heads}  |  Attn Dropout: {args.attn_dropout}")
    print(f"Weight Decay: {args.weight_decay}  |  Grad Clip: {args.grad_clip if args.grad_clip > 0 else 'None'}")
    print(f"Imbalance: {args.imbalance_strategy}  |  Focal γ: {args.focal_gamma if args.use_focal_loss else 'N/A'}")
    print(f"Soft Labels: {'ON' if args.use_soft_labels else 'OFF'}  |  Lazy Load: {'ON' if args.lazy_load else 'OFF'}")
    if args.compile: print(f"torch.compile: {args.compile_mode}")
    if ema: print(f"EMA: decay={args.ema_decay}  |  Eval EMA: {args.eval_ema}")
    if args.skip_oom: print("OOM skip: Enabled")
    if args.mixup_alpha > 0: print(f"Mixup: α={args.mixup_alpha}")
    if args.aug_enable: print(f"Augmentation: Enabled (normal scale={args.aug_normal_scale})")
    print(f"Early Stopping: {patience} epochs")
    if args.calibrate_temperature: print(f"Post-hoc: Temperature scaling enabled")
    print(f"{'='*80}\n")

    # Training loop
    def _eval_target():
        if ema and args.eval_ema: return ema.ema
        return model

    for epoch in range(start_epoch + 1, args.epochs + 1):
        t0 = time.time()
        train_loss = train_one_epoch(model, train_loader, optimizer, device,
                                     accumulation_steps=args.accumulation_steps, scaler=scaler,
                                     criterion=criterion, mixup_alpha=args.mixup_alpha, grad_clip=args.grad_clip,
                                     ema=ema, skip_oom=args.skip_oom)
        eval_model = _eval_target()
        val_metrics = evaluate(eval_model, val_loader, device, criterion_eval=criterion_eval,
                               return_preds=(args.report_each > 0 and (epoch % args.report_each == 0)))
        dt = time.time() - t0
        macro_f1, balanced_acc, raw_acc = val_metrics['macro_f1'], val_metrics['balanced_acc'], val_metrics['acc']
        val_loss, current_lr = val_metrics.get('val_loss', float('nan')), optimizer.param_groups[0]['lr']

        print(f"[{epoch:03d}/{args.epochs}] loss: {train_loss:.4f} → {val_loss:.4f} | acc: {raw_acc:.3f} | bal_acc: {balanced_acc:.3f} | "
              f"f1: {macro_f1:.3f} | lr: {current_lr:.2e} | {dt:.1f}s")

        if 'y' in val_metrics and 'p' in val_metrics:
            try:
                print(classification_report(val_metrics['y'], val_metrics['p'], target_names=classes, digits=3, zero_division=0))
                if args.save_cm:
                    cm_path = os.path.join(args.out, f"cm_epoch{epoch:03d}_{args.ckpt_prefix}.png")
                    plot_confusion(val_metrics['y'], val_metrics['p'], classes, cm_path)
                    print(f"   ✓ Confusion saved: {cm_path}")
            except Exception as e:
                print(f"  ⚠️  Could not generate classification report: {e}")

        # Save "last" (lighter & legacy format to reduce Windows FS issues)
        safe_save({
            'epoch': epoch,
            'model_state_dict': model.state_dict(),
            'optimizer_state_dict': optimizer.state_dict(),
            'scheduler_state_dict': getattr(scheduler, 'state_dict', lambda: {})(),
            'classes': classes,
            'best_macro_f1': max(best_macro_f1, macro_f1),
            'args': vars(args),
            **({'ema_state_dict': ema.state_dict()} if ema else {})
            }, last_path, use_legacy_zip=True, light=True)

        # Track best by macro F1
        if macro_f1 > best_macro_f1 + 1e-4:
            best_macro_f1, best_epoch, no_improve = macro_f1, epoch, 0
            safe_save({
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'scheduler_state_dict': getattr(scheduler, 'state_dict', lambda: {})(),
                'classes': classes, 'best_macro_f1': best_macro_f1, 'args': vars(args),
                **({'ema_state_dict': ema.state_dict()} if ema else {})
                }, best_path, use_legacy_zip=True, light=False)
            print(f"  ✨ New best! F1: {macro_f1:.4f}, Bal Acc: {balanced_acc:.4f}")
        else:
            no_improve += 1
            if patience > 0: print(f"  ⏳ No improvement for {no_improve}/{patience} epochs")

        if args.use_cosine_schedule:
            with suppress(Exception): scheduler.step()
        else:
            scheduler.step(macro_f1)

        history['train_loss'].append(train_loss); history['val_loss'].append(val_loss)
        history['val_acc'].append(raw_acc); history['val_balanced_acc'].append(balanced_acc)
        history['val_macro_f1'].append(macro_f1); history['lr'].append(current_lr)

        if patience > 0 and no_improve >= patience:
            print(f"\n⏹️  Early stopping triggered ({no_improve} epochs without improvement)"); break
        if args.plot_curves and epoch % 5 == 0: plot_training_curves(history, args.out)

    print(f"\n{'='*80}\n✅ Training Complete!\n{'='*80}")
    print(f"Best Macro F1: {best_macro_f1:.4f} (epoch {best_epoch})")
    print(f"Checkpoint: {best_path}\n{'='*80}\n")

    # Post-hoc Temperature calibration
    if args.calibrate_temperature and os.path.isfile(best_path):
        print(f"\n{'='*80}\n🌡️  Post-hoc Temperature Calibration\n{'='*80}")
        ckpt = torch.load(best_path, map_location=device)
        model.load_state_dict(ckpt['model_state_dict'])
        if args.eval_ema and 'ema_state_dict' in ckpt:
            print("Using EMA weights for calibration.")
            ema = ema or ModelEMA(model, decay=args.ema_decay or 0.999, device=device)
            ema.load_state_dict(ckpt['ema_state_dict'], strict=False)
            model.load_state_dict(ema.state_dict(), strict=False)

        print("Finding optimal temperature on validation set...")
        best_T, best_nll = find_best_temperature(model, val_loader, device)
        print(f"✓ Best temperature: {best_T:.3f} (NLL: {best_nll:.4f})")

        print("\nEvaluating with calibrated predictions...")
        cal_metrics = evaluate(model, val_loader, device, criterion_eval=None, return_preds=True, temperature=best_T)
        print(f"Calibrated Results:\n  Accuracy: {cal_metrics['acc']:.4f}\n  Balanced Acc: {cal_metrics['balanced_acc']:.4f}\n  Macro F1: {cal_metrics['macro_f1']:.4f}")
        if 'y' in cal_metrics and 'p' in cal_metrics:
            print("\nCalibrated Classification Report:")
            with suppress(Exception):
                print(classification_report(cal_metrics['y'], cal_metrics['p'], target_names=classes, digits=3, zero_division=0))

        ckpt['best_temperature'] = best_T
        safe_save(ckpt, best_path, use_legacy_zip=True, light=False)
        print(f"\n✓ Saved temperature={best_T:.3f} to checkpoint")
        if 'logits' in cal_metrics:
            cal_path = os.path.join(args.out, f"calibrated_results_{args.ckpt_prefix}.npz")
            np.savez_compressed(cal_path, logits=cal_metrics['logits'], labels=cal_metrics['y'],
                                predictions=cal_metrics['p'], temperature=best_T, classes=np.array(classes, dtype=object))
            print(f"✓ Saved calibrated results to {cal_path}")

    if args.plot_curves: plot_training_curves(history, args.out)
    if args.save_history:
        with open(os.path.join(args.out, f"history_{args.ckpt_prefix}.json"), 'w') as f: json.dump(history, f, indent=2)
        print(f"📊 Training history saved to {os.path.join(args.out, f'history_{args.ckpt_prefix}.json')}")

def worker_init_fn(worker_id: int):
    seed = (torch.initial_seed() + worker_id) % (2**32 - 1)
    random.seed(seed); np.random.seed(seed)

if __name__ == "__main__":
    main()
