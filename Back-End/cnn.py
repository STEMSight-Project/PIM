#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PoseTCN Trainer – BEST HYBRID VERSION
Combines critical fixes from FINAL with UX improvements

Key Features:
- ✅ Proper normalization in __getitem__ (CRITICAL)
- ✅ SHA1-based deterministic subject IDs
- ✅ Sequence length validation
- ✅ Clean validation criterion
- ✅ Enhanced logging with emojis and progress tracking
- ✅ Gradient clipping support
- ✅ JSON history export
- ✅ Persistent workers for DataLoader
- ✅ Better error handling and diagnostics

Run example:
python train.py --data_dir npz_output --width 256 --dropout 0.2 --weight_decay 0.05 \
  --use_focal_loss --focal_gamma 2.0 --use_class_weights --label_smoothing 0.1 \
  --epochs 60 --batch 64 --accumulation_steps 2 --grad_clip 1.0 \
  --use_cosine_schedule --warmup_epochs 5 \
  --aug_enable --aug_time_mask_prob 0.2 --aug_joint_dropout_prob 0.3 --aug_joint_dropout_frac 0.2 \
  --aug_noise_std 0.015 --aug_rotation_prob 0.3 --aug_scale_prob 0.3 --aug_temporal_warp_prob 0.2 \
  --mixup_alpha 0.2 --stochastic_depth 0.1 --report_each 1 --early_stop_patience 8 \
  --num_workers 4 --plot_curves --save_history
"""

import os, glob, random, time, hashlib, json
from pathlib import Path
from typing import List, Dict, Optional
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader, WeightedRandomSampler, Subset
from sklearn.model_selection import GroupShuffleSplit
from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score, classification_report
from collections import defaultdict, Counter

# --------- Constants ---------
NUM_LANDMARKS = 33
INPUT_LANDMARK_DIM = 33 * 3
L_SHOULDER, R_SHOULDER, L_HIP, R_HIP = 11, 12, 23, 24

# --------- Reproducibility & CUDA ---------
def seed_everything(seed: int = 42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = False
    torch.backends.cudnn.benchmark = True

torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True
if torch.cuda.is_available():
    try:
        torch.set_float32_matmul_precision('high')
    except Exception:
        pass

# --------- Normalization ---------
def _pair_dist(fr: np.ndarray, a: int, b: int) -> Optional[float]:
    va, vb = fr[a], fr[b]
    if not (np.any(va != 0) and np.any(vb != 0)):
        return None
    return float(np.linalg.norm(va - vb) + 1e-8)

def normalize_single_view(seq: np.ndarray) -> np.ndarray:
    """Center by hips (fallback shoulders), scale by median body-size cue."""
    T = seq.shape[0]
    hips_ok = (np.any(seq[:, L_HIP] != 0, axis=1) & np.any(seq[:, R_HIP] != 0, axis=1))
    hip_ctr = 0.5 * (seq[:, L_HIP] + seq[:, R_HIP])
    sh_ctr = 0.5 * (seq[:, L_SHOULDER] + seq[:, R_SHOULDER])
    ctr = hip_ctr.copy(); ctr[~hips_ok] = sh_ctr[~hips_ok]
    seq = seq - ctr[:, None, :]

    dists = []
    for t in range(T):
        fr = seq[t]
        cues = [d for d in (
            _pair_dist(fr, L_SHOULDER, R_SHOULDER),
            _pair_dist(fr, L_HIP, R_HIP),
            _pair_dist(fr, L_SHOULDER, L_HIP)) if d is not None]
        dists.append(np.median(cues) if cues else np.nan)
    vals = np.asarray(dists, dtype=np.float32)
    scale = np.nanmedian(vals) if np.isfinite(vals).any() else 1.0
    if not np.isfinite(scale) or scale < 1e-3:
        scale = 1.0
    seq = np.clip(seq / scale, -10.0, 10.0)
    return np.nan_to_num(seq, nan=0.0).astype(np.float32)

# --------- Focal Loss ---------
class FocalLoss(nn.Module):
    """Focal Loss with optional class weights and label smoothing."""
    def __init__(self, alpha=None, gamma=2.0, label_smoothing=0.0):
        super().__init__()
        self.alpha = alpha  # (C,) tensor on device
        self.gamma = gamma
        self.label_smoothing = label_smoothing

    def forward(self, inputs, targets):
        log_probs = nn.functional.log_softmax(inputs, dim=-1)
        num_classes = inputs.size(-1)

        if self.label_smoothing > 0:
            smooth = torch.zeros_like(inputs).scatter_(1, targets.unsqueeze(1), 1.0)
            smooth = smooth * (1 - self.label_smoothing) + self.label_smoothing / num_classes
            ce_loss = -(smooth * log_probs).sum(dim=-1)  # (B,)
            if self.alpha is not None:
                w = self.alpha[targets]
                ce_loss = ce_loss * w
        else:
            ce_loss = nn.functional.nll_loss(log_probs, targets, reduction='none', weight=self.alpha)

        pt = log_probs.exp().gather(1, targets.unsqueeze(1)).squeeze(1)
        focal = (1 - pt).pow(self.gamma)
        return (focal * ce_loss).mean()

# --------- Model ---------
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
    def __init__(self, channels: int, dilation: int = 1, drop: float = 0.1, stochastic_depth: float = 0.0):
        super().__init__()
        self.dw = nn.Conv1d(channels, channels, kernel_size=3, padding=dilation,
                            dilation=dilation, groups=channels, bias=False)
        self.bn1 = nn.BatchNorm1d(channels)
        self.pw = nn.Conv1d(channels, channels, kernel_size=1, bias=False)
        self.bn2 = nn.BatchNorm1d(channels)
        self.act = nn.SiLU()
        self.drop = nn.Dropout(drop)
        self.se = SE1d(channels, reduction=8)
        self.sd = float(stochastic_depth)
    def forward(self, x):
        if self.training and self.sd > 0 and torch.rand(1).item() < self.sd:
            return x
        out = self.dw(x)
        out = self.bn1(out); out = self.act(out)
        out = self.pw(out);  out = self.bn2(out)
        out = self.se(out);  out = self.drop(out)
        return self.act(out + x)

class PoseTCN(nn.Module):
    def __init__(self, input_dim: int, num_classes: int, width: int = 256, drop: float = 0.1, stochastic_depth: float = 0.0, dilations=None):
        super().__init__()
        self.stem = nn.Sequential(
            nn.Conv1d(input_dim, width, kernel_size=1, bias=False),
            nn.BatchNorm1d(width),
            nn.SiLU(),
        )
        if dilations is None:
            dilations = [1,2,4,8,16,32]
        sd_rates = [stochastic_depth * i / max(1,len(dilations)-1) for i in range(len(dilations))]
        self.blocks = nn.ModuleList([DSResBlock(width, d, drop=drop, stochastic_depth=sd) for d,sd in zip(dilations, sd_rates)])
        self.attn = nn.Conv1d(width, 1, kernel_size=1)
        self.norm = nn.LayerNorm(2 * width)
        self.head = nn.Linear(2 * width, num_classes)
    def forward(self, x):
        if x.dim() == 4:
            B, T, L, C = x.shape
            x = x.reshape(B, T, L*C)
        B, T, F = x.shape
        expected_F = self.stem[0].in_channels
        assert F == expected_F, f"Input F {F} != expected {expected_F}"
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

# --------- Dataset ---------
def infer_subject_from_meta(npz_path: str, meta: dict) -> str:
    """Deterministic subject inference using SHA1 hash."""
    base = Path(npz_path).name
    parts = base.split('_')
    for i in range(len(parts)-2):
        a,b,c = parts[i], parts[i+1], parts[i+2]
        if (a and b and c and a[0].isupper() and b[0].isupper() and c[0].isupper()):
            return f"{a}_{b}"
    for i in range(len(parts)-1):
        a,b = parts[i], parts[i+1]
        if a and b and a[0].isupper() and b[0].isupper():
            return f"{a}_{b}"
    # Deterministic fallback using SHA1
    token = hashlib.sha1(npz_path.encode("utf-8")).hexdigest()[:8]
    return f"Unknown_{token}"

class NPZWindowDataset(Dataset):
    def __init__(self, files: List[str], class_map: Dict[str, int],
                 T: int = 60, default_stride: int = 15,
                 target_stride_s: Optional[float] = None,
                 max_views: int = 3, use_visibility_mask: bool = False):
        self.files = files
        self.class_map = class_map
        self.T = T
        self.default_stride = default_stride
        self.target_stride_s = target_stride_s
        self.max_views = max_views
        self.use_visibility_mask = use_visibility_mask
        self.index = []
        self.meta_per_file = []
        self.views_per_file = []
        discovered_labels = set()
        failed_files = []

        for fi, path in enumerate(self.files):
            try:
                with np.load(path, allow_pickle=False) as z:
                    view_keys = [k for k in z.files if k.startswith("view_")]
                    if not view_keys:
                        continue
                    view_keys = view_keys[: self.max_views]

                    # meta
                    meta = {}
                    for k in z.files:
                        if k in view_keys:
                            continue
                        arr = z[k]
                        if getattr(arr, 'shape', ()) == ():
                            try:
                                v = arr.item()
                                if isinstance(v, (bytes, bytearray)):
                                    v = v.decode(errors="ignore")
                                meta[k] = v
                            except Exception:
                                meta[k] = str(arr)
                        else:
                            meta[k] = arr

                    # Require movement_type label; skip missing ones
                    label_name = meta.get("movement_type", None)
                    if label_name is None or str(label_name).strip() == "":
                        continue
                    label_name = str(label_name).strip()
                    discovered_labels.add(label_name)

                    fps = float(meta.get("fps", 60.0) or 60.0)
                    subject = infer_subject_from_meta(path, meta)

                    view_arrays = []
                    for vk in view_keys:
                        arr = np.asarray(z[vk], dtype=np.float32)
                        if arr.ndim != 3 or arr.shape[-1] < 3:
                            continue
                        xyz = arr[..., :3]
                        if self.use_visibility_mask and arr.shape[-1] >= 4:
                            vis = arr[..., 3]
                            mask = (vis < 0.2).astype(np.float32)
                            xyz = xyz * (1.0 - mask[..., None])
                        view_arrays.append(xyz)
                    if not view_arrays:
                        continue

                    Tlen = min(a.shape[0] for a in view_arrays)
                    view_arrays = [a[:Tlen] for a in view_arrays]
                    
                    # Skip sequences that are too short (CRITICAL FIX)
                    if Tlen < self.T:
                        continue
                    
                    stride = (
                        max(1, int(round(fps * self.target_stride_s)))
                        if self.target_stride_s and fps > 0 else self.default_stride
                    )
                    starts = list(range(0, Tlen - self.T + 1, stride))
                    if not starts:
                        starts = [0]
                    self.index.extend([(fi, s) for s in starts])
                    self.meta_per_file.append({
                        "path": path, "label": label_name, "fps": fps,
                        "frames": Tlen, "subject": subject, "views": len(view_arrays),
                    })
                    self.views_per_file.append(view_arrays)
            except Exception as e:
                failed_files.append((path, str(e)))
                continue
        
        if failed_files:
            print(f"⚠️  Failed to load {len(failed_files)} files:")
            for path, err in failed_files[:5]:  # Show first 5
                print(f"  - {Path(path).name}: {err}")
            if len(failed_files) > 5:
                print(f"  ... and {len(failed_files) - 5} more")
        
        self.num_views = min(self.max_views, max((m.get("views",1) for m in self.meta_per_file), default=1))
        self.input_dim = 33 * 3 * self.num_views
        self.discovered_labels = sorted(discovered_labels)

    def __len__(self):
        return len(self.index)

    def __getitem__(self, idx):
        fi, s = self.index[idx]
        views = self.views_per_file[fi]
        seqs = []

        num_v = min(len(views), self.num_views)
        for v in range(num_v):
            seq = views[v][s : s + self.T]          # (T, 33, 3)
            seq = normalize_single_view(seq)        # CRITICAL: normalization per window
            seqs.append(seq)

        # Handle edge cases with padding
        if num_v == 0:
            pad = np.zeros((self.T, NUM_LANDMARKS, 3), dtype=np.float32)
            seqs = [pad] * self.num_views
        elif num_v < self.num_views:
            base = seqs[0]
            seqs.extend([base.copy() for _ in range(self.num_views - num_v)])

        fused = np.concatenate(seqs, axis=2).astype(np.float32)  # (T, 33, 3*num_views)
        label = self.meta_per_file[fi]["label"]
        y = self.class_map[label]
        subj = self.meta_per_file[fi]["subject"]
        return fused, y, subj

# --------- Sampler & Weights ---------
def make_balanced_sampler(dataset: NPZWindowDataset):
    file_to_nwin = defaultdict(int)
    for fi, _ in dataset.index:
        file_to_nwin[fi] += 1
    label_counts = Counter(); subject_counts = Counter()
    for fi, n in file_to_nwin.items():
        lab = dataset.meta_per_file[fi]['label']
        sub = dataset.meta_per_file[fi]['subject']
        label_counts[lab] += n
        subject_counts[sub] += n
    label_w = {lab: 1.0/max(c,1) for lab,c in label_counts.items()}
    lw_mean = np.mean(list(label_w.values())) if label_w else 1.0
    label_w = {k:v/lw_mean for k,v in label_w.items()}
    subject_w = {sub: 1.0/max(c,1) for sub,c in subject_counts.items()}
    sw_mean = np.mean(list(subject_w.values())) if subject_w else 1.0
    subject_w = {k:v/sw_mean for k,v in subject_w.items()}
    weights = [label_w.get(dataset.meta_per_file[fi]['label'],1.0)*subject_w.get(dataset.meta_per_file[fi]['subject'],1.0) for fi,_ in dataset.index]
    return WeightedRandomSampler(torch.as_tensor(weights, dtype=torch.float), num_samples=len(weights), replacement=True)

def class_weights_from_train_subset(full_ds: NPZWindowDataset, train_subset: Subset, class_map: Dict[str, int]) -> torch.Tensor:
    counts = np.zeros(len(class_map), dtype=np.int64)
    for win_idx in train_subset.indices:
        fi,_ = full_ds.index[win_idx]
        lab = full_ds.meta_per_file[fi]['label']
        counts[class_map[lab]] += 1
    weights = (counts.sum() / np.clip(counts, 1, None))
    weights = weights / weights.mean()
    return torch.tensor(weights, dtype=torch.float32)

# --------- Collate with Augmentation ---------
class CollateWindows:
    def __init__(self, augment: bool = False,
                 time_mask_prob: float = 0.0, time_mask_max_frames: int = 8,
                 joint_dropout_prob: float = 0.0, joint_dropout_frac: float = 0.15,
                 noise_std: float = 0.0,
                 rotation_prob: float = 0.0, rotation_angle_deg: float = 15.0,
                 scale_prob: float = 0.0, scale_min: float = 0.9, scale_max: float = 1.1,
                 temporal_warp_prob: float = 0.0):
        self.augment = augment
        self.time_mask_prob = time_mask_prob
        self.time_mask_max_frames = time_mask_max_frames
        self.joint_dropout_prob = joint_dropout_prob
        self.joint_dropout_frac = joint_dropout_frac
        self.noise_std = noise_std
        self.rotation_prob = rotation_prob
        self.rotation_angle_deg = rotation_angle_deg
        self.scale_prob = scale_prob
        self.scale_min = scale_min
        self.scale_max = scale_max
        self.temporal_warp_prob = temporal_warp_prob

    def _rotate_y(self, pose_np, angle_rad):
        T, F = pose_np.shape
        if F % 3 != 0:
            return pose_np
        L = F // 3
        x = pose_np.reshape(T, L, 3)
        c, s = np.cos(angle_rad), np.sin(angle_rad)
        R = np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]], dtype=np.float32)
        x = x @ R.T
        return x.reshape(T, F)

    def _temporal_warp(self, pose_np, rate_range=(0.8, 1.2)):
        T, F = pose_np.shape
        rate = float(np.random.uniform(*rate_range))
        new_T = int(max(4, round(T * rate)))
        old_idx = np.linspace(0, T - 1, T, dtype=np.float32)
        new_idx = np.linspace(0, T - 1, new_T, dtype=np.float32)
        out = np.empty((new_T, F), dtype=np.float32)
        for f in range(F):
            out[:, f] = np.interp(new_idx, old_idx, pose_np[:, f])
        if new_T >= T:
            return out[:T]
        pad = np.zeros((T, F), dtype=np.float32)
        pad[:new_T] = out
        return pad

    def __call__(self, batch):
        xs, ys, subs = zip(*batch)
        x = torch.from_numpy(np.stack(xs, 0))  # (B, T, F) or (B, T, L, C)
        y = torch.tensor(ys, dtype=torch.long)
        if x.dim() == 4:
            x = x.flatten(2, 3)
        elif x.dim() != 3:
            raise ValueError(f"Unexpected input shape {tuple(x.shape)}")
        if not self.augment:
            return x, y, list(subs)

        B, T, F = x.shape
        x_np = x.numpy().copy()
        for b in range(B):
            sample = x_np[b]
            if self.rotation_prob > 0.0 and random.random() < self.rotation_prob:
                angle = np.radians(random.uniform(-self.rotation_angle_deg, self.rotation_angle_deg))
                sample = self._rotate_y(sample, angle)
            if self.scale_prob > 0.0 and random.random() < self.scale_prob:
                scale = float(np.random.uniform(self.scale_min, self.scale_max))
                sample = sample * scale
            if self.temporal_warp_prob > 0.0 and random.random() < self.temporal_warp_prob:
                sample = self._temporal_warp(sample)
            x_np[b] = sample

        if self.time_mask_prob > 0.0 and self.time_mask_max_frames > 0:
            for b in range(B):
                if random.random() < self.time_mask_prob:
                    L = random.randint(1, min(self.time_mask_max_frames, T))
                    s = random.randint(0, T - L)
                    x_np[b, s:s + L, :] = 0.0

        if self.joint_dropout_prob > 0.0 and self.joint_dropout_frac > 0.0 and (F % 3 == 0):
            joints_total = F // 3
            k = max(1, int(round(joints_total * self.joint_dropout_frac)))
            for b in range(B):
                if random.random() < self.joint_dropout_prob:
                    drop_idx = np.random.choice(joints_total, size=k, replace=False)
                    for j in drop_idx:
                        x_np[b, :, 3 * j:3 * j + 3] = 0.0

        if self.noise_std > 0.0:
            x_np += np.random.randn(*x_np.shape).astype(np.float32) * float(self.noise_std)

        x = torch.from_numpy(x_np)
        return x, y, list(subs)

# --------- Evaluation ---------
@torch.no_grad()
def evaluate(model, loader, device, criterion_eval=None, return_preds: bool=False):
    model.eval()
    ys, ps = [], []
    n, loss_sum = 0, 0.0
    use_cuda = (device.type=='cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    for xb, yb, _ in loader:
        xb = xb.to(device, non_blocking=True); yb = yb.to(device, non_blocking=True)
        with torch.amp.autocast(device_type=device.type, dtype=torch.bfloat16 if use_bf16 else torch.float16, enabled=use_cuda):
            logits = model(xb)
            if criterion_eval is not None:
                loss_sum += criterion_eval(logits, yb).item() * xb.size(0)
        pred = logits.argmax(1)
        ps.append(pred.cpu().numpy()); ys.append(yb.cpu().numpy())
        n += xb.size(0)
    y = np.concatenate(ys) if ys else np.array([])
    p = np.concatenate(ps) if ps else np.array([])
    out = {'acc': float(accuracy_score(y,p)) if len(y)>0 else 0.0,
           'balanced_acc': float(balanced_accuracy_score(y,p)) if len(y)>0 else 0.0,
           'macro_f1': float(f1_score(y,p,average='macro',zero_division=0)) if len(y)>0 else 0.0}
    if criterion_eval is not None and n>0:
        out['val_loss'] = loss_sum / n
    if return_preds:
        out.update({'y': y, 'p': p})
    return out

# --------- Training ---------
def train_one_epoch(model, loader, optimizer, device, accumulation_steps=2, scaler=None, 
                    criterion=None, mixup_alpha: float=0.0, grad_clip: float=0.0):
    model.train()
    total = 0.0; n = 0
    class _NoScaler:
        def is_enabled(self): return False
        def scale(self, x): return x
        def step(self, opt): opt.step()
        def update(self): pass
        def unscale_(self, opt): pass
    scaler = scaler or _NoScaler()
    optimizer.zero_grad(set_to_none=True)
    use_cuda = (device.type=='cuda'); use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    
    for b_idx, (xb, yb, _) in enumerate(loader):
        xb = xb.to(device, non_blocking=True); yb = yb.to(device, non_blocking=True)
        lam = 1.0; yb2 = None
        if mixup_alpha > 0 and xb.size(0) > 1:
            lam = np.random.beta(mixup_alpha, mixup_alpha)
            perm = torch.randperm(xb.size(0), device=xb.device)
            xb = lam*xb + (1-lam)*xb[perm]
            yb2 = yb[perm]
        with torch.amp.autocast(device_type=device.type, dtype=torch.bfloat16 if use_bf16 else torch.float16, enabled=use_cuda):
            logits = model(xb)
            if yb2 is None:
                loss = criterion(logits, yb)
            else:
                loss = lam * criterion(logits, yb) + (1 - lam) * criterion(logits, yb2)
        
        if scaler.is_enabled(): 
            scaler.scale(loss / accumulation_steps).backward()
        else: 
            (loss / accumulation_steps).backward()
        
        if (b_idx + 1) % accumulation_steps == 0:
            # Gradient clipping
            if grad_clip > 0:
                if scaler.is_enabled():
                    scaler.unscale_(optimizer)
                torch.nn.utils.clip_grad_norm_(model.parameters(), grad_clip)
            
            if scaler.is_enabled():
                scaler.step(optimizer); scaler.update()
            else:
                optimizer.step()
            optimizer.zero_grad(set_to_none=True)
        
        bs = xb.size(0); total += loss.item() * bs; n += bs
    
    # Final step if needed
    if (len(loader) % accumulation_steps) != 0:
        if grad_clip > 0:
            if scaler.is_enabled():
                scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), grad_clip)
        
        if scaler.is_enabled():
            scaler.step(optimizer); scaler.update()
        else:
            optimizer.step()
        optimizer.zero_grad(set_to_none=True)
    
    return total / max(1,n)

# --------- Plotting ---------
def plot_training_curves(history: dict, out_dir: str):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception:
        return
    fig, axes = plt.subplots(2,2, figsize=(12,10))
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
    path = os.path.join(out_dir, "training_curves.png")
    plt.savefig(path, dpi=150); plt.close()

# --------- Class Distribution Diagnostic ---------
def print_class_distribution(full_ds, train_ds, val_ds, classes):
    print("\n" + "="*80)
    print("CLASS DISTRIBUTION DIAGNOSTIC")
    print("="*80)
    train_class_dist = Counter()
    for idx in train_ds.indices:
        fi, _ = full_ds.index[idx]
        train_class_dist[full_ds.meta_per_file[fi]['label']] += 1
    val_class_dist = Counter()
    for idx in val_ds.indices:
        fi, _ = full_ds.index[idx]
        val_class_dist[full_ds.meta_per_file[fi]['label']] += 1
    print("\nTRAIN vs VAL distribution:")
    print(f"{'Class':<20} {'Train':>10} {'Val':>10} {'Train%':>8} {'Val%':>8} {'Weight':>8}")
    print("-"*80)
    for cls in classes:
        tr = train_class_dist.get(cls, 0); va = val_class_dist.get(cls, 0)
        tr_pct = 100 * tr / max(1, len(train_ds)); va_pct = 100 * va / max(1, len(val_ds))
        weight = len(train_ds) / max(1, tr) if tr > 0 else 0
        print(f"{cls:<20} {tr:>10} {va:>10} {tr_pct:>7.2f}% {va_pct:>7.2f}% {weight:>7.2f}x")
    if train_class_dist:
        max_train = max(train_class_dist.values()); min_train = min(train_class_dist.values())
        ratio = max_train / max(1, min_train)
        print(f"\n{'Imbalance Ratio:':<20} {ratio:>7.1f}:1")
        if ratio > 20:
            print("🚨 SEVERE IMBALANCE! Focal Loss strongly recommended.")
        elif ratio > 10:
            print("⚠️  MODERATE IMBALANCE. Focal Loss + class weights will help.")
        else:
            print("✓ Relatively balanced dataset.")
    print("="*80 + "\n")

# --------- Get Current LR ---------
def get_lr(optimizer):
    """Safely get current learning rate from optimizer"""
    for param_group in optimizer.param_groups:
        return param_group['lr']
    return 0.0

# --------- Main ---------
def main():
    import argparse, multiprocessing as mp
    ap = argparse.ArgumentParser(description="PoseTCN Best Hybrid – All Critical Fixes + UX Improvements")
    ap.add_argument("--data_dir", type=str, required=True)
    ap.add_argument("--out", type=str, default="runs_cnn")
    ap.add_argument("--T", type=int, default=60)
    ap.add_argument("--target_stride_s", type=float, default=0.25)
    ap.add_argument("--default_stride", type=int, default=15)
    ap.add_argument("--epochs", type=int, default=60)
    ap.add_argument("--batch", type=int, default=256)
    ap.add_argument("--lr", type=float, default=5e-4)
    ap.add_argument("--width", type=int, default=384)
    ap.add_argument("--dropout", type=float, default=0.1)
    ap.add_argument("--stochastic_depth", type=float, default=0.05)
    ap.add_argument("--dilations", type=str, default="1,2,4,8,16,32,64")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--max_views", type=int, default=3)
    ap.add_argument("--val_size", type=float, default=0.2)
    ap.add_argument("--num_workers", type=int, default=4)
    ap.add_argument("--use_visibility_mask", action="store_true")
    ap.add_argument("--ckpt_prefix", type=str, default="cnn_best")
    ap.add_argument("--accumulation_steps", type=int, default=2)
    ap.add_argument("--weight_decay", type=float, default=0.01)
    ap.add_argument("--grad_clip", type=float, default=1.0, help="Gradient clipping (0 to disable)")
    ap.add_argument("--report_each", type=int, default=5)
    ap.add_argument("--use_focal_loss", action="store_true")
    ap.add_argument("--focal_gamma", type=float, default=2.0)
    ap.add_argument("--use_class_weights", action="store_true")
    ap.add_argument("--label_smoothing", type=float, default=0.1)
    ap.add_argument("--early_stop_patience", type=int, default=12)
    ap.add_argument("--aug_enable", action="store_true")
    ap.add_argument("--aug_time_mask_prob", type=float, default=0.1)
    ap.add_argument("--aug_time_mask_max_frames", type=int, default=6)
    ap.add_argument("--aug_joint_dropout_prob", type=float, default=0.2)
    ap.add_argument("--aug_joint_dropout_frac", type=float, default=0.1)
    ap.add_argument("--aug_noise_std", type=float, default=0.01)
    ap.add_argument("--aug_rotation_prob", type=float, default=0.2)
    ap.add_argument("--aug_rotation_angle_deg", type=float, default=10.0)
    ap.add_argument("--aug_scale_prob", type=float, default=0.2)
    ap.add_argument("--aug_scale_min", type=float, default=0.95)
    ap.add_argument("--aug_scale_max", type=float, default=1.05)
    ap.add_argument("--aug_temporal_warp_prob", type=float, default=0.0)
    ap.add_argument("--mixup_alpha", type=float, default=0.2)
    ap.add_argument("--plot_curves", action="store_true")
    ap.add_argument("--save_history", action="store_true", help="Save training history to JSON")
    ap.add_argument("--use_cosine_schedule", action="store_true")
    ap.add_argument("--warmup_epochs", type=int, default=5)
    args = ap.parse_args(); mp.freeze_support()

    os.makedirs(args.out, exist_ok=True)
    seed_everything(args.seed)

    all_npz = sorted(glob.glob(os.path.join(args.data_dir, "**", "*.npz"), recursive=True))
    if not all_npz:
        print(f"❌ No NPZ files found in {args.data_dir}"); return

    print(f"📂 Found {len(all_npz)} NPZ files")
    print("Loading dataset...")
    full_ds = NPZWindowDataset(
        files=all_npz, class_map={}, T=args.T,
        default_stride=args.default_stride,
        target_stride_s=(args.target_stride_s if args.target_stride_s > 0 else None),
        max_views=args.max_views,
        use_visibility_mask=args.use_visibility_mask
    )
    if not full_ds.discovered_labels:
        print("❌ No 'movement_type' found in NPZ files."); return
    
    classes = full_ds.discovered_labels
    class_map = {lab:i for i,lab in enumerate(classes)}
    print(f"\n✓ Classes ({len(classes)}): {classes}")
    full_ds.class_map = class_map

    # Quick sanity check on shapes
    try:
        x0, y0, s0 = full_ds[0]
        print(f"✓ Files: {len(full_ds.meta_per_file)}  |  Windows: {len(full_ds)}  |  Views: {full_ds.num_views}")
        print(f"✓ Sample window: {x0.shape}  |  Label: {y0}  |  Subject: {s0}")
        assert x0.shape == (args.T, NUM_LANDMARKS, 3 * full_ds.num_views), f"Shape mismatch: {x0.shape}"
    except Exception as e:
        print(f"⚠️  Sanity check warning: {e}")

    try:
        dilations = [int(x.strip()) for x in args.dilations.split(",") if x.strip()]
        if not dilations:
            dilations = [1,2,4,8,16,32]
    except Exception:
        dilations = [1,2,4,8,16,32]
        print(f"⚠️  Invalid dilations, using default: {dilations}")

    file_subjects = [m['subject'] for m in full_ds.meta_per_file]
    unique_file_idxs = list(range(len(full_ds.meta_per_file)))
    
    print("\n🔀 Splitting dataset by subjects...")
    try:
        from sklearn.model_selection import StratifiedGroupKFold
        y_file = [m['label'] for m in full_ds.meta_per_file]
        groups = file_subjects
        sgkf = StratifiedGroupKFold(n_splits=5, shuffle=True, random_state=args.seed)
        best=None; best_diff=1e9
        for tr_idx, va_idx in sgkf.split(unique_file_idxs, y=y_file, groups=groups):
            diff = abs(len(va_idx)/len(unique_file_idxs) - args.val_size)
            if diff < best_diff: best=(tr_idx,va_idx); best_diff=diff
        train_files_idx, val_files_idx = best
        print("✓ Using StratifiedGroupKFold")
    except Exception as e:
        print(f"⚠️  StratifiedGroupKFold failed ({e}), using GroupShuffleSplit")
        gss = GroupShuffleSplit(n_splits=1, test_size=args.val_size, random_state=args.seed)
        train_files_idx, val_files_idx = next(gss.split(unique_file_idxs, groups=file_subjects))

    file_to_windows = defaultdict(list)
    for win_idx, (fi, _) in enumerate(full_ds.index):
        file_to_windows[fi].append(win_idx)
    train_win_idxs = []; val_win_idxs = []
    for fi in train_files_idx: train_win_idxs.extend(file_to_windows[fi])
    for fi in val_files_idx: val_win_idxs.extend(file_to_windows[fi])
    train_ds = Subset(full_ds, train_win_idxs)
    val_ds = Subset(full_ds, val_win_idxs)
    if len(train_ds)==0 or len(val_ds)==0:
        print("❌ Error: train or val dataset is empty"); return

    print(f"\n✓ Train windows: {len(train_ds):,}  |  Val windows: {len(val_ds):,}")
    print(f"✓ Views used (early-fused): {full_ds.num_views}  → input_dim = {full_ds.input_dim}")
    print_class_distribution(full_ds, train_ds, val_ds, classes)

    sampler = make_balanced_sampler(full_ds)
    base_w = sampler.weights.detach().cpu().tolist()
    subset_w = [base_w[i] for i in train_win_idxs]
    subset_sampler = WeightedRandomSampler(subset_w, num_samples=len(train_win_idxs), replacement=True)

    train_collate = CollateWindows(
        augment=args.aug_enable,
        time_mask_prob=args.aug_time_mask_prob, time_mask_max_frames=args.aug_time_mask_max_frames,
        joint_dropout_prob=args.aug_joint_dropout_prob, joint_dropout_frac=args.aug_joint_dropout_frac,
        noise_std=args.aug_noise_std,
        rotation_prob=args.aug_rotation_prob, rotation_angle_deg=args.aug_rotation_angle_deg,
        scale_prob=args.aug_scale_prob, scale_min=args.aug_scale_min, scale_max=args.aug_scale_max,
        temporal_warp_prob=args.aug_temporal_warp_prob
    )
    val_collate = CollateWindows(augment=False)

    train_loader = DataLoader(train_ds, batch_size=args.batch, sampler=subset_sampler,
                              num_workers=args.num_workers, pin_memory=True, collate_fn=train_collate,
                              persistent_workers=(args.num_workers > 0))
    val_loader = DataLoader(val_ds, batch_size=args.batch, shuffle=False,
                            num_workers=args.num_workers, pin_memory=True, collate_fn=val_collate,
                            persistent_workers=(args.num_workers > 0))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n🖥️  Device: {device}")
    if device.type == 'cuda':
        print(f"   GPU: {torch.cuda.get_device_name(0)}")
        print(f"   Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")
    
    model = PoseTCN(input_dim=full_ds.input_dim, num_classes=len(classes),
                    width=args.width, drop=args.dropout, stochastic_depth=args.stochastic_depth,
                    dilations=dilations).to(device)
    
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"   Parameters: {trainable_params:,} / {total_params:,} trainable")

    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=args.weight_decay)

    if args.use_cosine_schedule:
        from torch.optim.lr_scheduler import CosineAnnealingLR, LinearLR, SequentialLR
        warm = int(max(0, args.warmup_epochs))
        if warm > 0:
            rem = max(1, args.epochs - warm)
            warmup_scheduler = LinearLR(optimizer, start_factor=0.1, end_factor=1.0, total_iters=warm)
            cosine_scheduler = CosineAnnealingLR(optimizer, T_max=rem, eta_min=1e-6)
            scheduler = SequentialLR(optimizer, schedulers=[warmup_scheduler, cosine_scheduler], milestones=[warm])
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

    use_cuda = (device.type=='cuda')
    use_bf16 = use_cuda and torch.cuda.is_bf16_supported()
    try:
        scaler = torch.amp.GradScaler(enabled=use_cuda and not use_bf16, device='cuda')
    except TypeError:
        # Fallback for older torch
        scaler = torch.cuda.amp.GradScaler(enabled=use_cuda and not use_bf16)
    print(f"   Mixed Precision: {'BF16' if use_bf16 else 'FP16' if use_cuda else 'Disabled'}")

    if args.use_focal_loss:
        if args.use_class_weights:
            cls_w = class_weights_from_train_subset(full_ds, train_ds, class_map).to(device)
            print(f"🎯 Loss: Focal (γ={args.focal_gamma}) + Class Weights + Label Smoothing ({args.label_smoothing})")
            criterion = FocalLoss(alpha=cls_w, gamma=args.focal_gamma, label_smoothing=args.label_smoothing)
            criterion_eval = nn.CrossEntropyLoss(weight=cls_w)  # Clean eval loss
        else:
            print(f"🎯 Loss: Focal (γ={args.focal_gamma}) + Label Smoothing ({args.label_smoothing})")
            criterion = FocalLoss(gamma=args.focal_gamma, label_smoothing=args.label_smoothing)
            criterion_eval = nn.CrossEntropyLoss()  # Clean eval loss
    else:
        if args.use_class_weights:
            cls_w = class_weights_from_train_subset(full_ds, train_ds, class_map).to(device)
            print(f"🎯 Loss: CrossEntropy + Class Weights + Label Smoothing ({args.label_smoothing})")
            criterion = nn.CrossEntropyLoss(weight=cls_w, label_smoothing=args.label_smoothing)
            criterion_eval = nn.CrossEntropyLoss(weight=cls_w, label_smoothing=args.label_smoothing)
        else:
            print(f"🎯 Loss: CrossEntropy + Label Smoothing ({args.label_smoothing})")
            criterion = nn.CrossEntropyLoss(label_smoothing=args.label_smoothing)
            criterion_eval = nn.CrossEntropyLoss(label_smoothing=args.label_smoothing)

    best_macro_f1 = -1.0
    best_epoch = 0
    best_path = os.path.join(args.out, f"best_{args.ckpt_prefix}.pt")
    last_path = os.path.join(args.out, f"last_{args.ckpt_prefix}.pt")
    patience = max(0, args.early_stop_patience)
    no_improve = 0
    history = {'train_loss': [], 'val_loss': [], 'val_acc': [], 'val_balanced_acc': [], 'val_macro_f1': [], 'lr': []}

    print(f"\n{'='*80}")
    print(f"🚀 Training Configuration")
    print(f"{'='*80}")
    print(f"Epochs: {args.epochs}  |  Batch: {args.batch}  |  Accum: {args.accumulation_steps}  |  LR: {args.lr}")
    print(f"Width: {args.width}  |  Dilations: {dilations}")
    print(f"Dropout: {args.dropout}  |  Stochastic Depth: {args.stochastic_depth}")
    print(f"Weight Decay: {args.weight_decay}  |  Grad Clip: {args.grad_clip if args.grad_clip > 0 else 'None'}")
    if args.mixup_alpha > 0:
        print(f"Mixup: α={args.mixup_alpha}")
    if args.aug_enable:
        print(f"Augmentation: Enabled")
    print(f"Early Stopping: {patience} epochs")
    print(f"{'='*80}\n")

    for epoch in range(1, args.epochs+1):
        t0 = time.time()
        train_loss = train_one_epoch(model, train_loader, optimizer, device,
                                     accumulation_steps=args.accumulation_steps, scaler=scaler, 
                                     criterion=criterion, mixup_alpha=args.mixup_alpha,
                                     grad_clip=args.grad_clip)
        val_metrics = evaluate(model, val_loader, device, criterion_eval=criterion_eval,
                               return_preds=(args.report_each>0 and (epoch % args.report_each==0)))
        dt = time.time()-t0

        macro_f1 = val_metrics['macro_f1']
        balanced_acc = val_metrics['balanced_acc']
        raw_acc = val_metrics['acc']
        val_loss = val_metrics.get('val_loss', float('nan'))
        current_lr = get_lr(optimizer)

        print(f"[{epoch:03d}/{args.epochs}] "
              f"loss: {train_loss:.4f} → {val_loss:.4f} | "
              f"acc: {raw_acc:.3f} | bal_acc: {balanced_acc:.3f} | "
              f"f1: {macro_f1:.3f} | lr: {current_lr:.2e} | {dt:.1f}s")

        if 'y' in val_metrics and 'p' in val_metrics:
            try:
                print(classification_report(val_metrics['y'], val_metrics['p'], 
                                          target_names=classes, digits=3, zero_division=0))
            except Exception as e:
                print(f"  ⚠️  Could not generate classification report: {e}")

        torch.save({
            'epoch': epoch, 'model_state_dict': model.state_dict(),
            'optimizer_state_dict': optimizer.state_dict(),
            'classes': classes, 'best_macro_f1': best_macro_f1,
            'args': vars(args)
        }, last_path)

        improved = macro_f1 > best_macro_f1 + 1e-4
        if improved:
            best_macro_f1 = macro_f1
            best_epoch = epoch
            torch.save({
                'epoch': epoch, 'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'classes': classes, 'best_macro_f1': best_macro_f1,
                'args': vars(args)
            }, best_path)
            print(f"  ✨ New best! F1: {macro_f1:.4f}, Bal Acc: {balanced_acc:.4f}")
            no_improve = 0
        else:
            no_improve += 1
            if patience > 0:
                print(f"  ⏳ No improvement for {no_improve}/{patience} epochs")

        if args.use_cosine_schedule:
            try:
                scheduler.step()
            except Exception:
                pass
        else:
            scheduler.step(macro_f1)

        history['train_loss'].append(train_loss)
        history['val_loss'].append(val_loss)
        history['val_acc'].append(raw_acc)
        history['val_balanced_acc'].append(balanced_acc)
        history['val_macro_f1'].append(macro_f1)
        history['lr'].append(current_lr)

        if patience>0 and no_improve>=patience:
            print(f"\n⏹️  Early stopping triggered ({no_improve} epochs without improvement)")
            break

        if args.plot_curves and epoch % 5 == 0:
            plot_training_curves(history, args.out)

    print(f"\n{'='*80}")
    print(f"✅ Training Complete!")
    print(f"{'='*80}")
    print(f"Best Macro F1: {best_macro_f1:.4f} (epoch {best_epoch})")
    print(f"Checkpoint: {best_path}")
    print(f"{'='*80}\n")

    if args.plot_curves:
        plot_training_curves(history, args.out)
    
    if args.save_history:
        history_path = os.path.join(args.out, f"history_{args.ckpt_prefix}.json")
        with open(history_path, 'w') as f:
            json.dump(history, f, indent=2)
        print(f"📊 Training history saved to {history_path}")

if __name__ == "__main__":
    main()