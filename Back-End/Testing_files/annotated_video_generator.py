#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Annotated PIM Video Generator (PoseTCN-only, thresholds-ready)

- Loads PoseTCNMultiView from train.py checkpoint
- Uses MultiViewPIMProcessor to extract pose landmarks (no hands)
- Supports per-class probability thresholds + 'normal' margin guard
- Minimal debug; only PoseTCN-related logic kept
"""

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")

import cv2
cv2.setNumThreads(1)

import torch
import numpy as np
from collections import deque, Counter
import time
from typing import List, Optional, Tuple

# ---------- Model + processor imports ----------
try:
    from train import PoseTCNMultiView, NUM_POSE_LANDMARKS, normalize_single_view
    TRAIN_IMPORT_ERROR = None
except ImportError as e:
    PoseTCNMultiView = None
    NUM_POSE_LANDMARKS = 33
    normalize_single_view = None
    TRAIN_IMPORT_ERROR = e

try:
    from mediapipe_processor import MultiViewPIMProcessor
    MEDIAPIPE_AVAILABLE = True
except ImportError as e:
    print(f"⚠️ Mediapipe processor unavailable: {e}")
    MEDIAPIPE_AVAILABLE = False

    class MockMultiViewPIMProcessor:
        def __init__(self, num_views=3, use_lite_model=False):
            self.num_views = num_views
            self.pose = None
            print("[DBG] Mock MultiViewPIMProcessor created", flush=True)

        def extract_pose_landmarks_from_single_view(self, frame):
            # Fallback: centered dummy pose
            return np.array([[0.5, 0.5, 0.0]] * NUM_POSE_LANDMARKS, dtype=np.float32)

    MultiViewPIMProcessor = MockMultiViewPIMProcessor


DEFAULT_DILATIONS = [1, 2, 4, 8, 16, 32]


def _require_train_components():
    if PoseTCNMultiView is None or normalize_single_view is None:
        raise ImportError(
            "PoseTCNMultiView/normalize_single_view unavailable. Ensure `train.py` is importable."
        ) from TRAIN_IMPORT_ERROR


def _parse_dilations(args_dict) -> List[int]:
    if not isinstance(args_dict, dict):
        return DEFAULT_DILATIONS
    raw = args_dict.get("dilations") or args_dict.get("dilation_list")
    if not raw:
        return DEFAULT_DILATIONS
    if isinstance(raw, str):
        tokens = [tok.strip() for tok in raw.split(",") if tok.strip()]
    elif isinstance(raw, (list, tuple)):
        tokens = raw
    else:
        return DEFAULT_DILATIONS
    out = []
    for tok in tokens:
        try:
            out.append(int(tok))
        except (TypeError, ValueError):
            continue
    return out if out else DEFAULT_DILATIONS


def _apply_thresholds_torch(probs: torch.Tensor,
                            thresholds: torch.Tensor,
                            normal_idx: Optional[int],
                            normal_margin: float = 0.05) -> torch.Tensor:
    """
    probs: (N,C) softmax probabilities (float32)
    thresholds: (C,) per-class cutoffs (float32)
    returns: (N,) predicted class indices after thresholding

    Logic:
      - Promote any class whose prob >= its threshold.
      - If none pass, fall back to argmax.
      - Optional 'normal' guard: if predicted == normal, require it to beat runner-up by margin.
    """
    assert probs.ndim == 2
    N, C = probs.shape
    device = probs.device

    # candidates that pass their per-class threshold
    cand = probs >= thresholds.view(1, C)
    pred = probs.argmax(dim=1)

    any_pass = cand.any(dim=1)
    if any_pass.any():
        idx = torch.nonzero(any_pass, as_tuple=False).squeeze(1)
        masked = probs[idx].clone()
        masked[~cand[idx]] = float("-inf")
        pred[idx] = masked.argmax(dim=1)

    if normal_idx is not None and normal_margin and normal_margin > 0:
        is_normal = pred == normal_idx
        if is_normal.any():
            i = torch.nonzero(is_normal, as_tuple=False).squeeze(1)
            p = probs[i]
            top = p[:, normal_idx]
            # second-best including normal
            top2_vals, top2_idx = torch.topk(p, k=2, dim=1)
            second_best = torch.where(
                top2_idx[:, 0] == normal_idx, top2_vals[:, 1], top2_vals[:, 0]
            )
            demote = top < (second_best + normal_margin)
            if demote.any():
                j = i[demote]
                masked = p[demote].clone()
                masked[:, normal_idx] = float("-inf")
                pred[j] = masked.argmax(dim=1)
    return pred


def load_model_from_train_checkpoint(model_path: str, device: torch.device):
    """Load a PoseTCNMultiView checkpoint and attach useful metadata."""
    _require_train_components()
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found: {model_path}")

    ckpt = torch.load(model_path, map_location="cpu", weights_only=False)
    state = ckpt.get("model_state_dict") or ckpt.get("model") or ckpt.get("state_dict")
    if state is None:
        raise ValueError(f"Checkpoint missing model weights: {model_path}")

    if "backbone_early.stem.0.weight" not in state:
        raise ValueError("Checkpoint is not a PoseTCNMultiView model (missing backbone_early stem).")

    classes = ckpt.get("classes")
    if not classes:
        raise ValueError("Checkpoint must include a 'classes' list for label decoding.")

    args_dict = ckpt.get("args", {}) or {}
    stem_w = state["backbone_early.stem.0.weight"]
    width = int(stem_w.shape[0])
    input_dim = int(stem_w.shape[1])

    # Pose-only: infer num_views from per-view = 33 pose landmarks * 3 coords
    landmarks_per_view = NUM_POSE_LANDMARKS
    in_per_view = landmarks_per_view * 3
    num_views = max(1, input_dim // in_per_view)

    drop = float(args_dict.get("dropout", 0.1))
    stochastic_depth = float(args_dict.get("stochastic_depth", 0.05))
    fusion = args_dict.get("fusion", "early")
    view_fusion = args_dict.get("view_fusion", "mean")
    hybrid_alpha = float(args_dict.get("hybrid_alpha", 0.5))
    dilations = _parse_dilations(args_dict)
    T = int(args_dict.get("T", 60))

    # Calibrated temperature (optional)
    temperature = float(ckpt.get("best_temperature", 1.0) or 1.0)
    if not np.isfinite(temperature) or temperature <= 0:
        temperature = 1.0

    model = PoseTCNMultiView(
        num_classes=len(classes),
        num_views=num_views,
        width=int(args_dict.get("width", width)),
        drop=drop,
        stochastic_depth=stochastic_depth,
        dilations=dilations,
        fusion=fusion,
        view_fusion=view_fusion,
        hybrid_alpha=hybrid_alpha,
        in_per_view=in_per_view,
    )
    model.load_state_dict(state, strict=True)

    # Attach runtime metadata
    model._expected_num_views = num_views
    model._expected_T = T
    model._temperature = temperature
    model._use_hands = False
    model._landmarks_per_view = landmarks_per_view

    # Class + threshold metadata
    try:
        normal_idx = next(i for i, n in enumerate(classes) if n.lower() == "normal")
    except StopIteration:
        normal_idx = None

    per_class_thresholds = None
    if "per_class_thresholds" in ckpt:
        arr = np.asarray(ckpt["per_class_thresholds"], dtype=np.float32)
        if arr.shape[0] == len(classes):
            per_class_thresholds = torch.tensor(arr, dtype=torch.float32)

    model._classes = list(classes)
    model._normal_class_idx = normal_idx
    model._per_class_thresholds = per_class_thresholds
    model._normal_margin = 0.05

    model = model.to(device).eval()
    return model, list(classes), {
        "fusion": fusion,
        "view_fusion": view_fusion,
        "temperature": temperature,
        "use_hands": False,
        "landmarks_per_view": landmarks_per_view,
    }


def _prepare_sequence_from_views(
    views_buffer: List[List[Tuple]],
    num_views: int,
    target_len: int,
) -> np.ndarray:
    """
    Prepare pose-only sequence.
    views_buffer: list over time, each item is a list (len=num_views) of tuples (pose, _, _)
                  but only pose is used; hands ignored.
    """
    if not views_buffer:
        raise ValueError("views_buffer is empty")

    seq = list(views_buffer)
    if len(seq) < target_len:
        last = seq[-1]
        seq = seq + [last] * (target_len - len(seq))
    elif len(seq) > target_len:
        seq = seq[-target_len:]

    per_view = []
    zeros_pose = np.zeros((NUM_POSE_LANDMARKS, 3), dtype=np.float32)

    for v in range(num_views):
        frames_v = []
        last_ok = None
        for per_views in seq:
            # Each per_views[v] is (pose, lh, rh) historically; here we only use pose.
            if v < len(per_views):
                pose_arr = per_views[v][0]
            else:
                pose_arr = None

            # Use pose if available, otherwise last good or zeros
            if pose_arr is not None:
                pose = np.asarray(pose_arr, dtype=np.float32)
            elif last_ok is not None:
                pose = last_ok.copy()
            else:
                pose = zeros_pose.copy()

            last_ok = pose
            frames_v.append(pose)

        stacked = np.stack(frames_v, axis=0)  # (T, 33, 3)
        stacked = normalize_single_view(stacked, num_pose_landmarks=NUM_POSE_LANDMARKS)
        per_view.append(stacked)

    fused = np.concatenate(per_view, axis=2).astype(np.float32, copy=False)  # (T, 33, 3*num_views)
    return fused.reshape(len(seq), -1)


def predict_from_views(model: torch.nn.Module, views_buffer: List[List[Tuple]], device: torch.device):
    """Run inference using a PoseTCNMultiView model (pose-only) with optional thresholds."""
    _require_train_components()
    num_views = int(getattr(model, "num_views", getattr(model, "_expected_num_views", 1)))
    target_len = int(getattr(model, "_expected_T", len(views_buffer)))
    temperature = float(getattr(model, "_temperature", 1.0) or 1.0)

    fused = _prepare_sequence_from_views(views_buffer, num_views, target_len)
    x = torch.from_numpy(fused).unsqueeze(0).to(device, non_blocking=True)

    use_cuda = device.type == "cuda"
    amp_dtype = torch.bfloat16 if (use_cuda and torch.cuda.is_bf16_supported()) else torch.float16
    with torch.no_grad(), torch.amp.autocast(device_type="cuda", dtype=amp_dtype, enabled=use_cuda):
        logits = model(x)
    if temperature != 1.0 and temperature > 0:
        logits = logits / temperature
    probs = torch.softmax(logits, dim=1)
    probs = probs.float()  # ensure fp32 for downstream

    # Thresholded prediction if available
    thr = getattr(model, "_per_class_thresholds", None)
    normal_idx = getattr(model, "_normal_class_idx", None)
    normal_margin = float(getattr(model, "_normal_margin", 0.05))
    if thr is not None and normal_idx is not None:
        thr_t = thr.to(device=probs.device, dtype=probs.dtype)
        pred = _apply_thresholds_torch(probs, thr_t, normal_idx, normal_margin)
        conf = probs[0, pred.item()]
    else:
        conf, pred = probs.max(dim=1)

    return int(pred.item()), float(conf.item()), probs.squeeze(0).detach().cpu().numpy()


# ---------- Annotated Video Generator (PoseTCN only) ----------
class AnnotatedVideoGenerator:
    def __init__(self, model_path="runs/best_posetcn.pt",
                 confidence_threshold=0.7, sequence_length=30,
                 skip_frames=1, use_lite_mediapipe=False):
        """
        Args:
            confidence_threshold: gate for appending frames to history summary
            sequence_length: will be overridden by the model's expected T if present
            skip_frames: downsample factor for output video frame writing
        """
        self.confidence_threshold = confidence_threshold
        self.sequence_length = sequence_length
        self.skip_frames = max(1, skip_frames)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"🖥️ Using device: {self.device}", flush=True)

        # Load PoseTCN model from checkpoint
        print(f"Loading model from: {model_path}", flush=True)
        self.model, self.movements, model_meta = load_model_from_train_checkpoint(model_path, self.device)
        self.model_type = model_meta.get("fusion", "pose_tcn")
        self.expected_views = int(getattr(self.model, "_expected_num_views", 1))
        self.sequence_length = int(getattr(self.model, "_expected_T", self.sequence_length))
        self.landmarks_per_view = model_meta.get("landmarks_per_view", 33)
        self.movement_names = {i: m for i, m in enumerate(self.movements)}

        print(
            f"✅ Loaded PoseTCN ({self.model_type}) with {len(self.movements)} movements "
            f"| views={self.expected_views} | T={self.sequence_length}",
            flush=True,
        )

        # MediaPipe processor (pose only)
        print(
            f"[DBG] constructing MultiViewPIMProcessor(num_views={self.expected_views}, "
            f"lite={use_lite_mediapipe})",
            flush=True,
        )
        self.processor = MultiViewPIMProcessor(
            num_views=self.expected_views,
            use_lite_model=use_lite_mediapipe,
        )
        print(
            "[DBG] MediaPipe Pose object:",
            type(getattr(self.processor, "pose", None)),
            flush=True,
        )

    # ---------- helper: draw overlay ----------
    def create_overlay_text(self, frame, prediction, confidence, ts, frame_i, history, pose_ok=True):
        overlay = frame.copy()
        h, w = frame.shape[:2]
        overlay_h = 160
        cv2.rectangle(overlay, (0, 0), (w, overlay_h), (0, 0, 0), -1)

        cv2.putText(overlay, f"Pred: {prediction.upper()} ({confidence:.2f})",
                    (10, 40), cv2.FONT_HERSHEY_DUPLEX, 0.7,
                    (0,255,0) if pose_ok else (0,0,255), 2)

        cv2.putText(overlay, f"Frame: {frame_i} | Time: {ts:.2f}s",
                    (10, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.5,
                    (200,200,200), 1)

        cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)
        return frame

    # ---------- main ----------
    def generate_annotated_video(self, input_video_path, output_video_path=None,
                                 max_duration=None, start_time=0):
        if output_video_path is None:
            base = os.path.splitext(os.path.basename(input_video_path))[0]
            output_video_path = f"annotated_{base}.mp4"

        print("[DBG] opening video:", input_video_path, flush=True)
        cap = cv2.VideoCapture(input_video_path)
        print("[DBG] cap.isOpened():", cap.isOpened(), flush=True)
        if not cap.isOpened():
            raise RuntimeError(f"Cannot open {input_video_path}")

        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        vw = w // max(1, self.expected_views)
        print(f"[DBG] props: {w}x{h}@{fps:.1f}fps | frames={total_frames} | views={self.expected_views}", flush=True)

        start_frame = int(start_time * fps) if start_time > 0 else 0
        end_frame = total_frames
        if max_duration and fps > 0:
            end_frame = min(total_frames, start_frame + int(max_duration * fps))
        print(f"[DBG] frame window: {start_frame}-{end_frame}", flush=True)
        cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

        out_fps = fps / self.skip_frames if self.skip_frames > 0 else fps
        out = cv2.VideoWriter(output_video_path, cv2.VideoWriter_fourcc(*'mp4v'),
                              out_fps, (vw, h))
        print("[DBG] writer opened:", out.isOpened(), flush=True)

        frame_buffer_views = deque(maxlen=self.sequence_length)
        history, frame_i, written = [], 0, 0
        t0 = time.time()

        print("[DBG] entering main loop", flush=True)
        try:
            while True:
                ok, frame = cap.read()
                if not ok or frame_i + start_frame >= end_frame:
                    print("[DBG] end of stream", flush=True)
                    break
                frame_i += 1
                if frame_i % self.skip_frames:
                    continue

                tstamp = (start_frame + frame_i) / fps
                per_views = []

                for v in range(self.expected_views):
                    x0, x1 = v * vw, (v + 1) * vw
                    pose = self.processor.extract_pose_landmarks_from_single_view(frame[:, x0:x1])
                    per_views.append((pose, None, None))  # tuple shape retained but hands unused

                n_ok = sum(lm[0] is not None for lm in per_views)
                if frame_i % int(max(1, fps)) == 0:
                    print(f"[DBG] frame={frame_i} | views_ok={n_ok}/{self.expected_views}", flush=True)

                pred, conf = "NO POSE", 0.0
                if n_ok > 0:
                    frame_buffer_views.append(per_views)
                    if len(frame_buffer_views) == self.sequence_length:
                        pred_idx, conf, _ = predict_from_views(
                            self.model, list(frame_buffer_views), self.device)
                        pred = self.movement_names.get(pred_idx, f"unk_{pred_idx}")
                        if conf >= self.confidence_threshold:
                            history.append({'f': frame_i, 'ts': tstamp,
                                            'movement': pred, 'conf': conf})
                        print(f"[DBG] posetcn pred: idx={pred_idx} label={pred} conf={conf:.3f}", flush=True)

                # Render last view + overlay
                last_view = frame[:, (self.expected_views-1)*vw:].copy()

                # Basic pose lines for a few joints (optional)
                last_pose = per_views[-1][0] if per_views else None
                if n_ok > 0 and last_pose is not None:
                    for (a, b) in [(11,12),(11,13),(12,14),(23,24),(23,25),(24,26)]:
                        if a < len(last_pose) and b < len(last_pose):
                            pa = (int(last_pose[a][0]*vw), int(last_pose[a][1]*h))
                            pb = (int(last_pose[b][0]*vw), int(last_pose[b][1]*h))
                            cv2.line(last_view, pa, pb, (255, 255, 255), 2)

                last_view = self.create_overlay_text(last_view, pred, conf, tstamp, frame_i, history, n_ok > 0)
                out.write(last_view)
                written += 1

                if written % (int(out_fps)*5) == 0:
                    print(f"[DBG] wrote {written} frames so far", flush=True)
        finally:
            print("[DBG] releasing resources", flush=True)
            cap.release()
            out.release()
            print("[DBG] released", flush=True)

        dt = time.time() - t0
        print(f"✅ Done. {frame_i} frames processed in {dt:.1f}s → {frame_i/dt:.1f} FPS", flush=True)
        if history:
            counts = Counter([h['movement'] for h in history])
            print("Detections:")
            for m, c in counts.most_common():
                print(f"  {m}: {c}")
        else:
            print("No detections")
        return output_video_path


# ---------- CLI ----------
if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("input_video")
    p.add_argument("--model", "-m", default="runs/best_posetcn.pt")
    p.add_argument("--output", "-o")
    p.add_argument("--confidence", "-c", type=float, default=0.7)
    p.add_argument("--duration", "-d", type=float)
    p.add_argument("--start", "-s", type=float, default=0)
    p.add_argument("--skip-frames", type=int, default=1)
    p.add_argument("--lite-mediapipe", action="store_true")

    # Thresholding controls
    p.add_argument("--thresholds", type=str, default=None,
                   help="Comma-separated per-class thresholds in checkpoint class order, e.g. '0.3,0.275,...'")
    p.add_argument("--normal-margin", type=float, default=0.05,
                   help="Require 'normal' to exceed runner-up by this margin")

    a = p.parse_args()

    gen = AnnotatedVideoGenerator(model_path=a.model,
                                  confidence_threshold=a.confidence,
                                  skip_frames=a.skip_frames,
                                  use_lite_mediapipe=a.lite_mediapipe)

    # Optional: override thresholds on the loaded model
    if a.thresholds:
        vals = [float(x.strip()) for x in a.thresholds.split(",") if x.strip()]
        arr = np.asarray(vals, dtype=np.float32)
        if len(arr) != len(gen.movements):
            raise ValueError(
                f"--thresholds length {len(arr)} != num classes {len(gen.movements)} "
                f"({gen.movements})"
            )
        gen.model._per_class_thresholds = torch.tensor(arr, dtype=torch.float32, device=gen.device)
    gen.model._normal_margin = float(a.normal_margin)

    gen.generate_annotated_video(a.input_video, a.output,
                                 max_duration=a.duration,
                                 start_time=a.start)