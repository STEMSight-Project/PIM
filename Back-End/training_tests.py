# -*- coding: utf-8 -*-
"""
PyTest suite for PoseTCN trainer (pose-only).
Tests the multi-view PoseTCN implementation in pose-tcn.py.
"""

import os
import math
import random
import numpy as np
import pytest
import torch
import importlib.util
from pathlib import Path

# Import pose-tcn.py using importlib (handles hyphenated filename)
pose_tcn_path = Path(__file__).parent / "pose-tcn.py"
spec = importlib.util.spec_from_file_location("pose_tcn", pose_tcn_path)
if spec is None or spec.loader is None:
    raise ImportError(f"Could not load pose-tcn.py from {pose_tcn_path}")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


# ---------- helpers / fixtures ----------

@pytest.fixture(autouse=True)
def _seed_everything():
    m.seed_everything(123)
    random.seed(123)
    np.random.seed(123)
    torch.manual_seed(123)


def _make_view_array(T, with_vis=True, view_offset=0.0):
    """Create a simple, valid pose stream of shape (T,33,3) or (T,33,4)."""
    L_S, R_S, L_H, R_H = m.L_SHOULDER, m.R_SHOULDER, m.L_HIP, m.R_HIP
    xyz = np.zeros((T, m.NUM_POSE_LANDMARKS, 3), np.float32)

    # define hips and shoulders with gentle motion + view offset
    for t in range(T):
        base = 10.0 + 0.05 * t + view_offset
        xyz[t, L_H] = np.array([base, 0.0, 0.0], np.float32)
        xyz[t, R_H] = np.array([base + 2.0, 0.0, 0.0], np.float32)
        xyz[t, L_S] = np.array([base, 2.0, 0.0], np.float32)
        xyz[t, R_S] = np.array([base + 2.0, 2.0, 0.0], np.float32)

    if not with_vis:
        return xyz

    # visibility channel: hide joint id 5 for first quarter frames
    vis = np.ones((T, m.NUM_POSE_LANDMARKS), np.float32)
    vis[: max(1, T // 4), 5] = 0.1  # below 0.2 → will be zeroed
    return np.concatenate([xyz, vis[..., None]], axis=-1)


def _write_npz(
    path,
    T=20,
    n_views=2,
    with_vis=True,
    file_label="normal",
    fps=30.0,
    subject_stub="Alice_Bob",
    include_date=True,
    with_frame_labels=True,
):
    """
    Write a small synthetic multi-view pose npz with required metadata.
    Meta keys: movement_type, fps, video_filename (+ frame_labels optional).
    """
    arrays = {}
    for v in range(n_views):
        arrays[f"view_{v}"] = _make_view_array(T, with_vis=(with_vis and v == 0), view_offset=0.1 * v)

    # meta as zero-dim arrays so allow_pickle=False is fine
    arrays["movement_type"] = np.array(file_label)
    arrays["fps"] = np.array(float(fps))
    if include_date:
        arrays["video_filename"] = np.array(f"{subject_stub}_clip_2024-10-03_take1.mp4")
    else:
        arrays["video_filename"] = np.array("clip.mp4")

    if with_frame_labels:
        # make the frame-level labels partly mixed
        fl = np.array(["normal"] * (T // 2) + [file_label] * (T - T // 2))
        arrays["frame_labels"] = fl

    np.savez_compressed(path, **arrays)


@pytest.fixture
def tmp_npz_dir(tmp_path):
    return tmp_path


@pytest.fixture
def two_file_dataset_paths(tmp_npz_dir):
    """Create 2 files: one with 2 views, one with 1 view, distinct subjects/labels."""
    p1 = tmp_npz_dir / "Alice_Bob_session1_clip_2024-10-03_seq0.npz"
    _write_npz(p1, T=20, n_views=2, with_vis=True, file_label="normal", subject_stub="Alice_Bob", include_date=True)

    p2 = tmp_npz_dir / "Charlie_Dan_trial_clip_seq1.npz"  # no date in name; will use date inside video_filename or fallbacks
    _write_npz(
        p2,
        T=20,
        n_views=1,  # single-view file to exercise view duplication
        with_vis=False,
        file_label="abnormal",
        subject_stub="Charlie_Dan",
        include_date=True,
    )
    return [str(p1), str(p2)]


# ---------- normalization ----------

def _median_distance_components(seq):
    """Compute the 3 distances used by normalize_single_view and return medians."""
    L_S, R_S, L_H, R_H = m.L_SHOULDER, m.R_SHOULDER, m.L_HIP, m.R_HIP
    def pair(a, b):
        va, vb = seq[:, a], seq[:, b]
        return np.linalg.norm(va - vb, axis=1)
    d1 = pair(L_S, R_S)
    d2 = pair(L_H, R_H)
    d3 = pair(L_S, L_H)
    vals = np.concatenate([d1, d2, d3])
    return np.median(vals), np.median(d1), np.median(d2), np.median(d3)


def test_normalize_single_view_hip_center_and_scale():
    T = 16
    arr = _make_view_array(T, with_vis=False)
    norm = m.normalize_single_view(arr.copy(), num_pose_landmarks=33)
    # hip center should be approximately zero after centering
    hip_ctr = 0.5 * (norm[:, m.L_HIP] + norm[:, m.R_HIP])
    assert np.allclose(hip_ctr, 0.0, atol=1e-5)

    # after scaling, median of body-size cues should be ~1
    med_all, *_ = _median_distance_components(norm)
    assert np.isfinite(med_all)
    assert abs(med_all - 1.0) < 1e-3


def test_normalize_single_view_fallback_to_shoulders_when_hips_missing():
    T = 12
    arr = _make_view_array(T, with_vis=False)
    # zero the hips to force shoulder centering
    arr[:, m.L_HIP] = 0.0
    arr[:, m.R_HIP] = 0.0
    norm = m.normalize_single_view(arr.copy(), num_pose_landmarks=33)
    sh_ctr = 0.5 * (norm[:, m.L_SHOULDER] + norm[:, m.R_SHOULDER])
    assert np.allclose(sh_ctr, 0.0, atol=1e-5)
    med_all, *_ = _median_distance_components(norm)
    assert abs(med_all - 1.0) < 1e-3


# ---------- losses / blocks / backbone / model ----------

def test_focal_loss_matches_cross_entropy_when_gamma_zero():
    torch.manual_seed(0)
    B, C = 8, 4
    logits = torch.randn(B, C)
    targets = torch.randint(0, C, (B,))
    ce = torch.nn.CrossEntropyLoss()(logits, targets)
    focal = m.FocalLoss(gamma=0.0, label_smoothing=0.0)
    fval = focal(logits, targets)
    assert torch.allclose(ce, fval, atol=1e-6)


def test_backbone1d_and_blocks_shapes():
    B, T, F = 3, 10, 99 * 2
    x = torch.randn(B, T, F)

    # try multiple possible signatures depending on your code version
    try:
        net = m.Backbone1D(in_features=F, width=16, drop=0.0, sd_total=0.1, dilations=[1, 2])
    except TypeError:
        try:
            net = m.Backbone1D(in_features=F, width=16, drop=0.0, stochastic_depth=0.1, dilations=[1, 2])
        except TypeError:
            # final fallback if both names fail
            net = m.Backbone1D(in_features=F, width=16, drop=0.0, dilations=[1, 2])

    z = net(x)
    assert z.shape == (B, 32)  # 2*width



@pytest.mark.parametrize("fusion,view_fusion", [
    ("early", "mean"),
    ("late", "mean"),
    ("hybrid", "mean"),
    ("late", "attn"),
    ("hybrid", "attn"),
])
def test_posetcnmultiview_forwards_and_backward(fusion, view_fusion):
    B, T, num_views = 4, 8, 2
    in_per_view = m.NUM_POSE_LANDMARKS * 3
    x = torch.randn(B, T, in_per_view * num_views)
    model = m.PoseTCNMultiView(
        num_classes=3,
        num_views=num_views,
        width=16,
        drop=0.0,
        stochastic_depth=0.1,
        dilations=[1, 2],
        fusion=fusion,
        view_fusion=view_fusion,
        in_per_view=in_per_view,
    )
    out = model(x)
    assert out.shape == (B, 3)
    out.sum().backward()  # ensure gradients flow


# ---------- subject inference ----------

def test_infer_subject_from_meta_variants(tmp_npz_dir):
    # 1) name with Two_Caps tokens
    s = m.infer_subject_from_meta(
        str(tmp_npz_dir / "Anna_Mike_clip_something.npz"),
        meta={}
    )
    assert s == "Anna_Mike"

    # 2) fall back to date in filename
    s2 = m.infer_subject_from_meta(
        str(tmp_npz_dir / "data_2023-11-09_trial.npz"),
        meta={}
    )
    assert s2 == "Date_20231109"

    # 3) fallback to video_filename meta
    s3 = m.infer_subject_from_meta(
        str(tmp_npz_dir / "no_subject_tokens_here.npz"),
        meta={"video_filename": "Carla_Doe_session.mp4"}
    )
    assert s3 == "Carla_Doe"

    # 4) unknown
    s4 = m.infer_subject_from_meta(
        str(tmp_npz_dir / "x.npz"),
        meta={}
    )
    assert s4 == "UnknownSubject"


# ---------- dataset (npz) ----------

def _build_dataset(files, **kwargs):
    ds = m.NPZWindowDataset(
        files=files,
        class_map={},
        T=8,
        default_stride=4,
        max_views=2,
        **kwargs,
    )
    # set class_map after discovery (mirrors main())
    classes = ds.discovered_labels
    ds.class_map = {lab: i for i, lab in enumerate(classes)}
    return ds


def test_npzwindowdataset_soft_labels_and_lazy(two_file_dataset_paths):
    # Eager + soft labels + visibility masking
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=True, lazy_load=False, use_visibility_mask=True)
    assert len(ds.meta_per_file) == 2
    assert ds.num_views == 2
    assert len(ds) == 8  # each file: (20-8)/4 + 1 = 4 windows → 2 files → 8

    x, y_soft, subj, is_soft = ds[0]
    assert is_soft is True
    assert x.shape == (8, 33, 3 * ds.num_views)
    assert y_soft.shape == (len(ds.class_map),)
    assert np.isclose(y_soft.sum(), 1.0, atol=1e-6)
    assert subj in {"Alice_Bob", "Charlie_Dan"}

    # Lazy loader must match eager for same index content (numerically very close)
    ds_lazy = _build_dataset(two_file_dataset_paths, use_soft_labels=True, lazy_load=True, use_visibility_mask=True)
    x_l, y_soft_l, subj_l, is_soft_l = ds_lazy[0]
    assert is_soft_l is True
    assert subj_l == subj
    assert x_l.shape == x.shape
    assert np.allclose(x_l, x, atol=1e-6)
    assert np.allclose(y_soft_l, y_soft, atol=1e-6)


def test_npzwindowdataset_view_duplication_for_single_view_file(two_file_dataset_paths):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=False, lazy_load=False, use_visibility_mask=False)
    single_meta_idxs = [i for i, mta in enumerate(ds.meta_per_file) if mta["views"] == 1]
    assert single_meta_idxs, "Expected at least one single-view file."
    meta_idx = single_meta_idxs[0]
    win_idx = next(i for i, (mi, _) in enumerate(ds.index) if mi == meta_idx)
    x, y, subj, is_soft = ds[win_idx]
    assert is_soft is False

    # Compare per-view feature blocks instead of reshaping
    V = ds.num_views
    for v in range(1, V):
        v0 = x[..., 0:3]              # view 0 (x,y,z)
        vN = x[..., 3*v:3*(v+1)]      # view v (x,y,z)
        assert np.allclose(v0, vN, atol=1e-6)



def test_analyze_and_filter_window_purity(two_file_dataset_paths, capsys):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=True, lazy_load=False)
    # should produce non-empty purity stats
    stats = m.analyze_window_purity(ds)
    assert stats and "all_purities" in stats
    assert all(0.0 <= p <= 1.0 for p in stats["all_purities"])

    all_idxs = list(range(len(ds)))
    kept = m.filter_windows_by_purity(ds, all_idxs, min_purity=0.9)
    assert 0 < len(kept) <= len(all_idxs)


# ---------- collate ----------

def test_collate_without_augmentation(two_file_dataset_paths):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=False, lazy_load=False)
    batch = [ds[i] for i in range(2)]
    collate = m.CollateWindows(augment=False)
    xb, yb, subs = collate(batch)
    assert xb.shape[0] == 2
    assert xb.ndim == 3  # (B,T,F)
    assert yb.dtype == torch.long
    assert len(subs) == 2


def test_collate_with_time_mask_and_joint_dropout(two_file_dataset_paths):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=False, lazy_load=False)
    batch = [ds[i] for i in range(2)]
    # Force the augs; keep noise=0 to keep zero masks visible
    collate = m.CollateWindows(
        augment=True,
        time_mask_prob=1.0, time_mask_max_frames=2,
        joint_dropout_prob=1.0, joint_dropout_frac=0.1,
        noise_std=0.0, rotation_prob=0.0, scale_prob=0.0, temporal_warp_prob=0.0,
    )
    xb, yb, subs = collate(batch)
    assert xb.shape == (2, 8, 33 * 3 * ds.num_views)
    # At least one full time step should be zeroed
    time_zeroed = (xb[0] == 0).all(dim=1).any()
    assert bool(time_zeroed)
    # And at least one joint triplet across all time should be zeroed by joint dropout
    L = xb.shape[-1] // 3
    # find any j such that all 3 dims are zeros across all T
    any_dropped_joint = False
    for j in range(L):
        if (xb[0, :, 3*j:3*j+3] == 0).all():
            any_dropped_joint = True
            break
    assert any_dropped_joint


def test_collate_aug_normal_scaling_disables_aug_for_normal_label():
    # craft a trivial batch: a single window of ones; label=0 ('normal'), and class_map matches
    T, V = 8, 2
    x_np = np.ones((T, 33, 3 * V), np.float32)
    batch = [(x_np, 0, "S1", False)]
    base = m.CollateWindows(augment=False)
    xb0, yb0, _ = base(batch)

    collate = m.CollateWindows(
        augment=True,
        rotation_prob=1.0,  # would rotate, but...
        noise_std=0.0, scale_prob=0.0, time_mask_prob=0.0, temporal_warp_prob=0.0, joint_dropout_prob=0.0,
        normal_class_name="normal",
        class_map={"normal": 0, "abnormal": 1},
        aug_normal_scale=0.0,  # ...scale=0 → rotation_prob becomes 0 for 'normal'
    )
    xb, yb, _ = collate(batch)
    assert torch.allclose(xb0, xb)


# ---------- weights / sampler ----------

def test_class_weights_from_train_subset(two_file_dataset_paths):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=False, lazy_load=False)
    # Build a subset of only the 1st file to get imbalance
    meta0 = 0
    sub_indices = [i for i, (mi, _) in enumerate(ds.index) if mi == meta0]
    subset = torch.utils.data.Subset(ds, sub_indices)

    w = m.class_weights_from_train_subset(ds, subset, ds.class_map, pow_smooth=0.5, clip=(0.5, 8.0))
    assert w.shape == (len(ds.class_map),)
    assert torch.isfinite(w).all()


def test_make_balanced_sampler_for_subset(two_file_dataset_paths):
    ds = _build_dataset(two_file_dataset_paths, use_soft_labels=False, lazy_load=False)
    subset_indices = list(range(len(ds)))  # use all windows
    sampler = m.make_balanced_sampler_for_subset(ds, subset_indices)
    # basic checks
    assert getattr(sampler, "num_samples", None) == len(subset_indices)
    # if torch exposes weights, check same length
    if hasattr(sampler, "weights"):
        assert len(sampler.weights) == len(subset_indices)


# ---------- prefetch / evaluate / temperature / training ----------

def _small_loaders_for_training(files, soft=False):
    ds = _build_dataset(files, use_soft_labels=soft, lazy_load=True)
    collate = m.CollateWindows(augment=False, class_map=ds.class_map, normal_class_name="normal")
    dl = torch.utils.data.DataLoader(
        ds,
        batch_size=3,
        shuffle=False,
        drop_last=False,
        num_workers=0,
        collate_fn=collate,
    )
    return ds, dl


def test_device_iter_cpu(two_file_dataset_paths):
    _, dl = _small_loaders_for_training(two_file_dataset_paths, soft=False)
    it = m.device_iter(dl, torch.device("cpu"))
    cnt = 0
    for _ in it:
        cnt += 1
    assert cnt == len(dl)


def test_evaluate_and_temperature_search(two_file_dataset_paths):
    ds, dl = _small_loaders_for_training(two_file_dataset_paths, soft=False)
    model = m.PoseTCNMultiView(
        num_classes=len(ds.class_map),
        num_views=2,
        width=16,
        drop=0.0,
        stochastic_depth=0.0,
        dilations=[1, 2],
        fusion="hybrid",
        view_fusion="mean",
        in_per_view=m.NUM_POSE_LANDMARKS * 3,
    )
    device = torch.device("cpu")
    criterion = torch.nn.CrossEntropyLoss()

    res1 = m.evaluate(model, dl, device, criterion_eval=criterion, return_preds=True, temperature=1.0)
    res2 = m.evaluate(model, dl, device, criterion_eval=criterion, return_preds=False, temperature=2.0)

    # accuracy shouldn't change with positive temperature scaling (argmax invariant)
    assert pytest.approx(res1["acc"], rel=0, abs=0) == res2["acc"]
    assert "val_loss" in res1

    best_T, best_nll = m.find_best_temperature(model, dl, device)
    assert 0.7 <= best_T <= 2.0
    assert np.isfinite(best_nll)


def test_train_one_epoch_updates_parameters(two_file_dataset_paths):
    ds, dl = _small_loaders_for_training(two_file_dataset_paths, soft=False)
    model = m.PoseTCNMultiView(
        num_classes=len(ds.class_map),
        num_views=2,
        width=16,
        drop=0.0,
        stochastic_depth=0.0,
        dilations=[1, 2],
        fusion="hybrid",
        view_fusion="mean",
        in_per_view=m.NUM_POSE_LANDMARKS * 3,
    )
    device = torch.device("cpu")
    model.to(device)
    opt = torch.optim.AdamW(model.parameters(), lr=1e-3, weight_decay=0.0)
    crit = torch.nn.CrossEntropyLoss()

    # capture parameter snapshot
    with torch.no_grad():
        before = [p.detach().cpu().clone() for p in model.parameters() if p.requires_grad]

    loss = m.train_one_epoch(
        model, dl, opt, device,
        accumulation_steps=2,
        scaler=None,
        criterion=crit,
        mixup_alpha=0.0,
        grad_clip=0.1
    )
    assert math.isfinite(loss)

    with torch.no_grad():
        after = [p.detach().cpu().clone() for p in model.parameters() if p.requires_grad]

    # at least one parameter should have changed
    changed = any(not torch.allclose(b, a) for b, a in zip(before, after))
    assert changed