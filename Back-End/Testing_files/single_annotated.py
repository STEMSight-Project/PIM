#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Annotated PIM Video Generator (Single-View PoseTCN, thresholds-ready)

- Loads PoseTCNSingleView from train_single_view.py checkpoint
- Crops one view from 3-view video (hardcoded division by 3)
- Uses MediaPipe processor to extract pose landmarks (no hands)
- Supports per-class probability thresholds + 'normal' margin guard
"""

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")

import cv2
cv2.setNumThreads(1)

import torch
import numpy as np
from collections import deque, Counter
import time
from typing import List, Optional

# ---------- Model + processor imports ----------
try:
    from train_single_view import PoseTCNSingleView, NUM_POSE_LANDMARKS, normalize_single_view
    TRAIN_IMPORT_ERROR = None
except ImportError as e:
    PoseTCNSingleView = None
    NUM_POSE_LANDMARKS = 33
    normalize_single_view = None
    TRAIN_IMPORT_ERROR = e

try:
    import mediapipe as mp
    MEDIAPIPE_AVAILABLE = True
except ImportError as e:
    print(f"⚠️ Mediapipe unavailable: {e}")
    MEDIAPIPE_AVAILABLE = False


DEFAULT_DILATIONS = [1, 2, 4, 8, 16, 32]


def _require_train_components():
    if PoseTCNSingleView is None or normalize_single_view is None:
        raise ImportError(
            "PoseTCNSingleView/normalize_single_view unavailable. Ensure `train_single_view.py` is importable."
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
    """Apply per-class thresholds with optional normal class margin guard."""
    assert probs.ndim == 2
    N, C = probs.shape

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


def load_single_view_model(model_path: str, device: torch.device):
    """Load a PoseTCNSingleView checkpoint and attach useful metadata."""
    _require_train_components()
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found: {model_path}")

    ckpt = torch.load(model_path, map_location="cpu", weights_only=False)
    state = ckpt.get("model_state_dict") or ckpt.get("model") or ckpt.get("state_dict")
    if state is None:
        raise ValueError(f"Checkpoint missing model weights: {model_path}")

    if "backbone.stem.0.weight" not in state:
        raise ValueError("Checkpoint is not a PoseTCNSingleView model (missing backbone.stem).")

    classes = ckpt.get("classes")
    if not classes:
        raise ValueError("Checkpoint must include a 'classes' list for label decoding.")

    args_dict = ckpt.get("args", {}) or {}
    stem_w = state["backbone.stem.0.weight"]
    width = int(stem_w.shape[0])
    input_dim = int(stem_w.shape[1])

    landmarks_per_view = NUM_POSE_LANDMARKS
    in_features = landmarks_per_view * 3
    
    if input_dim != in_features:
        print(f"⚠️ Warning: Expected input_dim={in_features}, got {input_dim}")

    drop = float(args_dict.get("dropout", 0.1))
    stochastic_depth = float(args_dict.get("stochastic_depth", 0.05))
    dilations = _parse_dilations(args_dict)
    T = int(args_dict.get("T", 60))
    norm = args_dict.get("norm", "bn")
    t_heads = int(args_dict.get("t_heads", 4))
    attn_dropout = float(args_dict.get("attn_dropout", 0.0))

    temperature = float(ckpt.get("best_temperature", 1.0) or 1.0)
    if not np.isfinite(temperature) or temperature <= 0:
        temperature = 1.0

    model = PoseTCNSingleView(
        num_classes=len(classes),
        width=int(args_dict.get("width", width)),
        drop=drop,
        stochastic_depth=stochastic_depth,
        dilations=dilations,
        in_features=in_features,
        norm=norm,
        t_heads=t_heads,
        attn_dropout=attn_dropout,
    )
    model.load_state_dict(state, strict=True)

    model._expected_T = T
    model._temperature = temperature
    model._landmarks_per_view = landmarks_per_view

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
        "temperature": temperature,
        "landmarks_per_view": landmarks_per_view,
        "T": T,
    }


def _prepare_single_view_sequence(pose_buffer: List[np.ndarray], target_len: int) -> np.ndarray:
    """Prepare pose-only sequence from single view."""
    if not pose_buffer:
        raise ValueError("pose_buffer is empty")

    seq = list(pose_buffer)
    if len(seq) < target_len:
        last = seq[-1]
        seq = seq + [last] * (target_len - len(seq))
    elif len(seq) > target_len:
        seq = seq[-target_len:]

    stacked = np.stack(seq, axis=0)
    stacked = normalize_single_view(stacked, num_pose_landmarks=NUM_POSE_LANDMARKS)
    return stacked.reshape(len(seq), -1).astype(np.float32)


def predict_single_view(model: torch.nn.Module, pose_buffer: List[np.ndarray], device: torch.device):
    """Run inference using a PoseTCNSingleView model with optional thresholds."""
    _require_train_components()
    target_len = int(getattr(model, "_expected_T", len(pose_buffer)))
    temperature = float(getattr(model, "_temperature", 1.0) or 1.0)

    fused = _prepare_single_view_sequence(pose_buffer, target_len)
    x = torch.from_numpy(fused).unsqueeze(0).to(device, non_blocking=True)

    use_cuda = device.type == "cuda"
    amp_dtype = torch.bfloat16 if (use_cuda and torch.cuda.is_bf16_supported()) else torch.float16
    with torch.no_grad(), torch.amp.autocast(device_type="cuda", dtype=amp_dtype, enabled=use_cuda):
        logits = model(x)
    
    if temperature != 1.0 and temperature > 0:
        logits = logits / temperature
    probs = torch.softmax(logits, dim=1)
    probs = probs.float()

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


class SimplePoseExtractor:
    """Simple MediaPipe Pose extractor for single view."""
    def __init__(self, use_lite=False):
        if not MEDIAPIPE_AVAILABLE:
            raise ImportError("MediaPipe is required but not available")
        
        self.mp_pose = mp.solutions.pose
        model_complexity = 0 if use_lite else 1
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=model_complexity,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        print(f"✅ MediaPipe Pose initialized (lite={use_lite})")

    def extract_pose(self, frame):
        """Extract pose landmarks from a single frame."""
        if frame is None:
            return None
        
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(rgb)
        
        if not results.pose_landmarks:
            return None
        
        landmarks = []
        for lm in results.pose_landmarks.landmark:
            landmarks.append([lm.x, lm.y, lm.z])
        
        return np.array(landmarks, dtype=np.float32)

    def __del__(self):
        if hasattr(self, 'pose'):
            self.pose.close()


class SingleViewVideoGenerator:
    def __init__(self, model_path="runs/best_single_view.pt",
                 confidence_threshold=0.7, sequence_length=60,
                 skip_frames=1, use_lite_mediapipe=False,
                 view_index=1):
        """
        Args:
            view_index: which view to crop from 3-view video (0=left, 1=middle, 2=right)
        """
        self.confidence_threshold = confidence_threshold
        self.sequence_length = sequence_length
        self.skip_frames = max(1, skip_frames)
        self.view_index = view_index
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"🖥️ Using device: {self.device}", flush=True)

        print(f"Loading single-view model from: {model_path}", flush=True)
        self.model, self.movements, model_meta = load_single_view_model(model_path, self.device)
        self.sequence_length = int(model_meta.get("T", self.sequence_length))
        self.landmarks_per_view = model_meta.get("landmarks_per_view", 33)
        self.movement_names = {i: m for i, m in enumerate(self.movements)}

        print(
            f"✅ Loaded Single-View PoseTCN with {len(self.movements)} movements "
            f"| T={self.sequence_length} | input_dim={self.landmarks_per_view * 3}",
            flush=True,
        )
        print(f"🎥 Cropping view {self.view_index} (0=left, 1=middle, 2=right)", flush=True)

        print(f"Initializing MediaPipe Pose (lite={use_lite_mediapipe})", flush=True)
        self.processor = SimplePoseExtractor(use_lite=use_lite_mediapipe)

    def crop_single_view(self, frame):
        """Crop one view from 3-view horizontal concatenation."""
        h, w = frame.shape[:2]
        view_width = w // 3
        x_start = self.view_index * view_width
        x_end = (self.view_index + 1) * view_width
        return frame[:, x_start:x_end].copy()

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
        
        cv2.putText(overlay, f"Buffer: {len(history)}/{self.sequence_length}",
                    (10, 110), cv2.FONT_HERSHEY_SIMPLEX, 0.5,
                    (200,200,200), 1)

        cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)
        return frame

    def draw_pose_connections(self, frame, pose_landmarks):
        """Draw pose skeleton on frame."""
        if pose_landmarks is None:
            return frame
        
        h, w = frame.shape[:2]
        
        connections = [
            (11, 12), (11, 23), (12, 24), (23, 24),
            (12, 14), (14, 16),
            (11, 13), (13, 15),
            (24, 26), (26, 28),
            (23, 25), (25, 27),
        ]
        
        for (a, b) in connections:
            if a < len(pose_landmarks) and b < len(pose_landmarks):
                pa = (int(pose_landmarks[a][0] * w), int(pose_landmarks[a][1] * h))
                pb = (int(pose_landmarks[b][0] * w), int(pose_landmarks[b][1] * h))
                cv2.line(frame, pa, pb, (0, 255, 0), 2)
        
        for idx in [11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]:
            if idx < len(pose_landmarks):
                pt = (int(pose_landmarks[idx][0] * w), int(pose_landmarks[idx][1] * h))
                cv2.circle(frame, pt, 4, (0, 0, 255), -1)
        
        return frame

    def generate_annotated_video(self, input_video_path, output_video_path=None,
                                 max_duration=None, start_time=0):
        if output_video_path is None:
            base = os.path.splitext(os.path.basename(input_video_path))[0]
            output_video_path = f"annotated_single_view_{base}_v{self.view_index}.mp4"

        cap = cv2.VideoCapture(input_video_path)
        if not cap.isOpened():
            raise RuntimeError(f"Cannot open {input_video_path}")

        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        full_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        
        view_width = full_w // 3
        
        print(f"📹 INPUT: {full_w}x{h}@{fps:.1f}fps | {total_frames} frames")
        print(f"✂️ CROPPING view {self.view_index}: x=[{self.view_index * view_width}:{(self.view_index + 1) * view_width}]")
        print(f"📤 OUTPUT: {view_width}x{h}")

        start_frame = int(start_time * fps) if start_time > 0 else 0
        end_frame = total_frames
        if max_duration and fps > 0:
            end_frame = min(total_frames, start_frame + int(max_duration * fps))
        cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

        out_fps = fps / self.skip_frames if self.skip_frames > 0 else fps
        out = cv2.VideoWriter(output_video_path, cv2.VideoWriter_fourcc(*'mp4v'),
                              out_fps, (view_width, h))
        if not out.isOpened():
            raise RuntimeError(f"Cannot open VideoWriter for {output_video_path}")

        pose_buffer = deque(maxlen=self.sequence_length)
        detection_history, frame_i, written = [], 0, 0
        t0 = time.time()

        try:
            while True:
                ok, full_frame = cap.read()
                if not ok or frame_i + start_frame >= end_frame:
                    break
                frame_i += 1
                if frame_i % self.skip_frames:
                    continue

                tstamp = (start_frame + frame_i) / fps

                # CROP TO SINGLE VIEW
                frame = self.crop_single_view(full_frame)

                pose = self.processor.extract_pose(frame)

                if frame_i % int(max(1, fps)) == 0:
                    print(f"[{frame_i}] cropped={frame.shape} | pose={'✓' if pose is not None else '✗'}")

                pred, conf = "NO POSE", 0.0
                if pose is not None:
                    pose_buffer.append(pose)
                    if len(pose_buffer) == self.sequence_length:
                        pred_idx, conf, _ = predict_single_view(
                            self.model, list(pose_buffer), self.device)
                        pred = self.movement_names.get(pred_idx, f"unk_{pred_idx}")
                        if conf >= self.confidence_threshold:
                            detection_history.append({
                                'f': frame_i, 'ts': tstamp,
                                'movement': pred, 'conf': conf
                            })

                annotated = frame.copy()
                
                if pose is not None:
                    annotated = self.draw_pose_connections(annotated, pose)
                
                annotated = self.create_overlay_text(
                    annotated, pred, conf, tstamp, frame_i, 
                    pose_buffer, pose is not None
                )
                
                out.write(annotated)
                written += 1

        finally:
            cap.release()
            out.release()

        dt = time.time() - t0
        print(f"✅ Done. {written} frames written in {dt:.1f}s → {written/dt:.1f} FPS")
        
        if detection_history:
            counts = Counter([h['movement'] for h in detection_history])
            print("\n📊 Detection Summary:")
            for m, c in counts.most_common():
                print(f"  {m}: {c}")
        else:
            print("❌ No detections above confidence threshold")
        
        return output_video_path


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser(description="Single-View PoseTCN Video Annotator")
    p.add_argument("input_video", help="Path to 3-view input video")
    p.add_argument("--model", "-m", default="runs/best_single_view.pt")
    p.add_argument("--output", "-o")
    p.add_argument("--confidence", "-c", type=float, default=0.7)
    p.add_argument("--duration", "-d", type=float)
    p.add_argument("--start", "-s", type=float, default=0)
    p.add_argument("--skip-frames", type=int, default=1)
    p.add_argument("--lite-mediapipe", action="store_true")
    p.add_argument("--view-index", type=int, default=1,
                   help="0=left, 1=middle, 2=right")
    p.add_argument("--thresholds", type=str, default=None)
    p.add_argument("--normal-margin", type=float, default=0.05)

    a = p.parse_args()

    gen = SingleViewVideoGenerator(
        model_path=a.model,
        confidence_threshold=a.confidence,
        skip_frames=a.skip_frames,
        use_lite_mediapipe=a.lite_mediapipe,
        view_index=a.view_index
    )

    if a.thresholds:
        vals = [float(x.strip()) for x in a.thresholds.split(",") if x.strip()]
        arr = np.asarray(vals, dtype=np.float32)
        if len(arr) != len(gen.movements):
            raise ValueError(f"Thresholds length mismatch")
        gen.model._per_class_thresholds = torch.tensor(arr, dtype=torch.float32, device=gen.device)
    gen.model._normal_margin = float(a.normal_margin)

    gen.generate_annotated_video(
        a.input_video, a.output,
        max_duration=a.duration,
        start_time=a.start
    )