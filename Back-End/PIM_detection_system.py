#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PIM Detection System (CNN-only, early-fusion)
- Loads PoseTCN checkpoints trained on multi-view MediaPipe poses
- Supports BOTH 1-D (Conv1d) and 2-D (Conv2d) PoseTCN variants
- Provides helpers to fuse per-frame multi-view landmarks and run inference

Exposed API:
  load_trained_model(model_path) -> (model, classes, "cnn" or "cnn2d")
  cnn_prepare_sequence_from_views(views_buffer, num_views) -> np.ndarray[T,33,3*num_views]
  cnn_predict_from_views(model, views_buffer, device) -> (pred_idx, conf_float, probs_np)
"""

from __future__ import annotations
import os
import numpy as np
import torch
import torch.nn as nn

# ----------------------------- constants -----------------------------
NUM_LANDMARKS = 33
L_SHOULDER, R_SHOULDER, L_HIP, R_HIP = 11, 12, 23, 24

# ------------------------ normalization utils ------------------------
def _pair_dist(fr: np.ndarray, a: int, b: int):
    va, vb = fr[a], fr[b]
    if not (np.any(va != 0) and np.any(vb != 0)):
        return None
    return float(np.linalg.norm(va - vb) + 1e-8)

def _normalize_single_view_seq(seq: np.ndarray) -> np.ndarray:
    """
    Normalize a single-view sequence (T,33,3) with training-identical steps:
    - center by hip/shoulder midpoint
    - scale by median torso cues
    - clip and nan->0
    """
    T = seq.shape[0]
    hips_ok = (np.any(seq[:, L_HIP] != 0, axis=1) & np.any(seq[:, R_HIP] != 0, axis=1))
    hip_center = 0.5 * (seq[:, L_HIP] + seq[:, R_HIP])
    shoulder_center = 0.5 * (seq[:, L_SHOULDER] + seq[:, R_SHOULDER])

    center = hip_center.copy()
    center[~hips_ok] = shoulder_center[~hips_ok]
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
    if not np.isfinite(scale) or scale < 1e-3:
        scale = 1.0

    seq = (seq / scale).astype(np.float32, copy=False)
    seq = np.clip(seq, -10.0, 10.0)
    return np.nan_to_num(seq, nan=0.0, posinf=0.0, neginf=0.0)

# ------------------------------ CNN 1-D ------------------------------
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

class DSResBlock1d(nn.Module):
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
        out = self.pw(out)
        out = self.bn2(out)
        out = self.se(out)
        out = self.drop(out)
        out = self.act(out + x)
        return out

class PoseTCN1D(nn.Module):
    """
    Temporal CNN for fused pose sequences (Conv1d).
    Input: [B,T,33,3*V]  OR  [B,T,99*V]
    """
    def __init__(self, input_dim: int, num_classes: int, width: int = 256, drop: float = 0.1):
        super().__init__()
        self.stem = nn.Sequential(
            nn.Conv1d(input_dim, width, kernel_size=1, bias=False),
            nn.BatchNorm1d(width),
            nn.SiLU(),
        )
        dilations = [1, 2, 4, 8, 16, 32]
        self.blocks = nn.ModuleList([DSResBlock1d(width, d, drop=drop) for d in dilations])
        self.attn = nn.Conv1d(width, 1, kernel_size=1)
        self.norm = nn.LayerNorm(2 * width)
        self.head = nn.Linear(2 * width, num_classes)

    def forward(self, x):
        if x.dim() == 4:                 # [B,T,33,3*V]
            B, T, L, C = x.shape
            x = x.reshape(B, T, L * C)   # -> [B,T,99*V]
        B, T, F = x.shape
        x = x.transpose(1, 2)            # [B,F,T]
        h = self.stem(x)                 # [B,W,T]
        for blk in self.blocks:
            h = blk(h)
        w = torch.softmax(self.attn(h), dim=2)  # [B,1,T]
        z_attn = (h * w).sum(dim=2)             # [B,W]
        z_gap  = h.mean(dim=2)                  # [B,W]
        z = torch.cat([z_attn, z_gap], dim=1)   # [B,2W]
        z = self.norm(z)
        return self.head(z)                     # [B,C]

# ------------------------------ CNN 2-D ------------------------------
class SE2d(nn.Module):
    def __init__(self, ch: int, reduction: int = 8):
        super().__init__()
        hidden = max(1, ch // reduction)
        self.fc1 = nn.Conv2d(ch, hidden, kernel_size=1, bias=True)
        self.fc2 = nn.Conv2d(hidden, ch, kernel_size=1, bias=True)
        self.act = nn.SiLU()
        self.gate = nn.Sigmoid()
    def forward(self, x):
        s = x.mean(dim=(2,3), keepdim=True)  # GAP over (T,J)
        s = self.act(self.fc1(s))
        s = self.gate(self.fc2(s))
        return x * s

class DSResBlock2d(nn.Module):
    def __init__(self, channels: int, dilation: int = 1, drop: float = 0.1):
        super().__init__()
        pad = dilation
        self.dw = nn.Conv2d(channels, channels, kernel_size=3, padding=pad,
                            dilation=dilation, groups=channels, bias=False)
        self.bn1 = nn.BatchNorm2d(channels)
        self.pw = nn.Conv2d(channels, channels, kernel_size=1, bias=False)
        self.bn2 = nn.BatchNorm2d(channels)
        self.act = nn.SiLU()
        self.drop = nn.Dropout(drop)
        self.se = SE2d(channels, reduction=8)
    def forward(self, x):
        out = self.dw(x)
        out = self.bn1(out); out = self.act(out)
        out = self.pw(out)
        out = self.bn2(out)
        out = self.se(out)
        out = self.drop(out)
        out = self.act(out + x)
        return out

class PoseTCN2D(nn.Module):
    """
    Temporal CNN over [T,J] grid (Conv2d).
    Input: [B,T,33,3*V]  or [B,T,99]→reshaped to [B,C=3*V,T,J=33]
    Channels C = 3 * num_views.
    """
    def __init__(self, input_channels: int, num_classes: int, width: int = 256, drop: float = 0.1):
        super().__init__()
        self.stem = nn.Sequential(
            nn.Conv2d(input_channels, width, kernel_size=1, bias=False),
            nn.BatchNorm2d(width),
            nn.SiLU(),
        )
        dilations = [1, 2, 4, 8, 16, 32]
        self.blocks = nn.ModuleList([DSResBlock2d(width, d, drop=drop) for d in dilations])
        self.attn = nn.Conv2d(width, 1, kernel_size=1)
        self.norm = nn.LayerNorm(2 * width)
        self.head = nn.Linear(2 * width, num_classes)

    def forward(self, x):
        # Accept [B,T,33,3V] or [B,T,99] (assume V=1 then)
        if x.dim() == 3:  # [B,T,F]
            B, T, F = x.shape
            C = F // NUM_LANDMARKS  # expect F = 33 * (3*V)
            x = x.view(B, T, NUM_LANDMARKS, C)
        B, T, J, C = x.shape
        x = x.permute(0, 3, 1, 2).contiguous()  # [B,C,T,J]
        h = self.stem(x)
        for blk in self.blocks:
            h = blk(h)
        # attention over T*J
        att = self.attn(h)                       # [B,1,T,J]
        w = torch.softmax(att.flatten(2), dim=-1)  # [B,1,TJ]
        z_attn = (h.flatten(2) * w).sum(-1)        # [B,W]
        z_gap = h.mean(dim=(2, 3))                 # [B,W]
        z = torch.cat([z_attn, z_gap], dim=1)      # [B,2W]
        z = self.norm(z)
        return self.head(z)                        # [B,C]

# ------------------------------ loader ------------------------------
def load_trained_model(model_path: str):
    """
    Load a CNN/TCN (PoseTCN 1-D or 2-D) checkpoint trained with early-fusion.
    Returns: (model, classes, 'cnn' or 'cnn2d')
    """
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found: {model_path}")

    ckpt = torch.load(model_path, map_location="cpu", weights_only=False)

    state = ckpt.get("model_state_dict", ckpt.get("model", ckpt.get("state_dict")))
    if state is None or "stem.0.weight" not in state:
        raise ValueError("Checkpoint is not a PoseTCN CNN (missing 'stem.0.weight').")

    classes = ckpt.get("classes")
    if not classes:
        raise ValueError("CNN checkpoint must include a 'classes' list.")

    cfg = ckpt.get("cfg", {}) or {}
    T = int(cfg.get("T", 60))
    stem_w = state["stem.0.weight"]

    # Detect Conv1d (dim=3) vs Conv2d (dim=4)
    if stem_w.dim() == 3:
        # 1-D PoseTCN: stem weight [W, F_in, 1]
        width = int(stem_w.shape[0])
        input_dim = int(stem_w.shape[1])              # = 99 * num_views
        num_views = max(1, input_dim // (NUM_LANDMARKS * 3))
        drop = float(cfg.get("dropout", 0.1))

        model = PoseTCN1D(input_dim=input_dim, num_classes=len(classes), width=width, drop=drop)

        # filter to known keys and load non-strict to ignore harmless extras
        state_f = {k: v for k, v in state.items() if k in model.state_dict()}
        missing, unexpected = model.load_state_dict(state_f, strict=False)
        if unexpected:
            print(f"  (ignoring unexpected keys) {unexpected}")
        if missing:
            print(f"  (missing keys loaded as default) {missing}")

        model.eval()
        model._expected_num_views = num_views
        model._expected_T = T
        return model, classes, "cnn"

    elif stem_w.dim() == 4:
        # 2-D PoseTCN: stem weight [W, C_in, 1, 1]
        width = int(stem_w.shape[0])
        in_channels = int(stem_w.shape[1])            # = 3 * num_views
        num_views = max(1, in_channels // 3)
        drop = float(cfg.get("dropout", 0.1))

        model = PoseTCN2D(input_channels=in_channels, num_classes=len(classes), width=width, drop=drop)

        state_f = {k: v for k, v in state.items() if k in model.state_dict()}
        missing, unexpected = model.load_state_dict(state_f, strict=False)
        if unexpected:
            print(f"  (ignoring unexpected keys) {unexpected}")
        if missing:
            print(f"  (missing keys loaded as default) {missing}")

        model.eval()
        model._expected_num_views = num_views
        model._expected_T = T
        return model, classes, "cnn2d"

    else:
        raise ValueError(f"Unsupported stem.0.weight rank {stem_w.dim()} — expected 3 (Conv1d) or 4 (Conv2d).")

# ---------------------------- fusion helper ----------------------------
def _pad_or_repeat_last(seq_list: list, target_len: int):
    """Pad a list to target_len by repeating the last element."""
    if len(seq_list) == 0:
        return seq_list
    if len(seq_list) >= target_len:
        return seq_list[:target_len]
    last = seq_list[-1]
    return seq_list + [last] * (target_len - len(seq_list))

def cnn_prepare_sequence_from_views(views_buffer: list, num_views: int) -> np.ndarray:
    """
    Build a fused sequence (T,33,3*num_views) with per-view normalization across time.

    views_buffer: list/deque length T.
      Each item t is a list of per-view landmarks arrays (33,3) (None allowed).
    """
    if not views_buffer:
        raise ValueError("views_buffer is empty")

    T = len(views_buffer)

    # Build per-view sequences (T,33,3) with simple imputation (repeat last or zeros)
    per_view = []
    for v in range(num_views):
        frames_v = []
        last_ok = None
        for t in range(T):
            per_views_t = views_buffer[t]
            if v < len(per_views_t) and per_views_t[v] is not None:
                last_ok = per_views_t[v].astype(np.float32, copy=False)
                frames_v.append(last_ok)
            else:
                frames_v.append(last_ok if last_ok is not None else np.zeros((NUM_LANDMARKS, 3), dtype=np.float32))
        seq_v = np.stack(frames_v, axis=0)        # (T,33,3)
        seq_v = _normalize_single_view_seq(seq_v) # training-identical normalization
        per_view.append(seq_v)

    # Early fuse along coord axis -> (T,33,3*num_views)
    fused = np.concatenate(per_view, axis=2).astype(np.float32, copy=False)
    return fused

# ----------------------------- inference -----------------------------
def _infer_expected_views_from_model(model: nn.Module) -> int:
    # Prefer annotated hint
    if hasattr(model, "_expected_num_views"):
        return int(getattr(model, "_expected_num_views"))

    # Otherwise infer from the first conv layer
    for m in model.modules():
        if isinstance(m, nn.Conv1d):
            input_dim = int(m.weight.shape[1])  # 99 * V
            return max(1, input_dim // (NUM_LANDMARKS * 3))
        if isinstance(m, nn.Conv2d):
            in_ch = int(m.weight.shape[1])      # 3 * V
            return max(1, in_ch // 3)
    raise RuntimeError("CNN model missing Conv stem.")

def _infer_expected_T_from_model(model: nn.Module, fallback: int) -> int:
    return int(getattr(model, "_expected_T", fallback))

def cnn_predict_from_views(model: nn.Module, views_buffer: list, device: torch.device):
    """
    Run PoseTCN inference from a deque/list of per-frame multi-view landmarks.

    views_buffer: length T (or shorter) where each item is [view0(33,3), view1(33,3), ...]
    Returns: (pred_idx, conf_float, probs_np)
    """
    use_cuda = (device.type == "cuda")
    num_views = _infer_expected_views_from_model(model)
    T_req = _infer_expected_T_from_model(model, len(views_buffer))

    # pad sequence length (repeat last frame)
    vb = list(views_buffer)
    vb = _pad_or_repeat_last(vb, max(T_req, len(vb)))[:T_req]

    # fuse -> (T,33,3*num_views), then add batch
    x_np = cnn_prepare_sequence_from_views(vb, num_views)
    x = torch.from_numpy(x_np).unsqueeze(0).to(device, non_blocking=True)  # [1,T,33,3*V]

    amp_dtype = torch.bfloat16 if (use_cuda and torch.cuda.is_bf16_supported()) else torch.float16
    with torch.no_grad(), torch.amp.autocast(device_type="cuda", dtype=amp_dtype, enabled=use_cuda):
        logits = model(x)                         # [1,C]
        probs = torch.softmax(logits, dim=1)      # [1,C]
        conf, pred = probs.max(dim=1)
        return int(pred.item()), float(conf.item()), probs.squeeze(0).detach().cpu().numpy()

# ----------------------------- tiny smoke test -----------------------------
if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="CNN-only PIM loader smoke test (1D/2D)")
    ap.add_argument("--ckpt", required=True, help="Path to PoseTCN checkpoint")
    args = ap.parse_args()

    model, classes, kind = load_trained_model(args.ckpt)
    print(f"Loaded: kind={kind}, classes={classes}")
    print(f"expected_views={getattr(model,'_expected_num_views',None)}, T={getattr(model,'_expected_T',None)}")

    # dummy inference with zeros
    V = getattr(model, "_expected_num_views", 3)
    T = getattr(model, "_expected_T", 60)
    dummy = [[np.zeros((NUM_LANDMARKS,3), dtype=np.float32) for _ in range(V)] for _ in range(T)]
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    pred, conf, probs = cnn_predict_from_views(model, dummy, device)
    print(f"dummy pred={pred} ({classes[pred] if 0 <= pred < len(classes) else '?'}) conf={conf:.3f}")
