#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Annotated PIM Video Generator (DEBUG BUILD)
- Works with CNN/TCN checkpoints from cnn_pose_trainer.py
- Verbose debug prints to isolate hangs or silent stalls
"""

import os
os.environ.setdefault("OMP_NUM_THREADS", "1")
import cv2
cv2.setNumThreads(1)

import torch
import numpy as np
from collections import deque, Counter
import time

# ---------- Safe ML imports with fallbacks ----------
try:
    from pim_detection_system import load_trained_model, cnn_predict_from_views
    from mediapipe_processor import MultiViewPIMProcessor
    MEDIAPIPE_AVAILABLE = True
except ImportError as e:
    print(f"⚠️ ML components not available: {e}")
    MEDIAPIPE_AVAILABLE = False

    class MockMultiViewPIMProcessor:
        def __init__(self, num_views=3, use_lite_model=False):
            self.num_views = num_views
            self.pose = None
            print("[DBG] Mock processor created", flush=True)
        def extract_pose_landmarks_from_single_view(self, frame):
            return np.array([[0.5, 0.5, 0.0]] * 33, dtype=np.float32)

    class MockModel:
        def eval(self): return self
        def to(self, d): return self
        def __call__(self, x): return torch.randn(x.shape[0], 10)
        _expected_num_views = 3
        _expected_T = 60

    def load_trained_model(path):
        print(f"[DBG] Mock model for {path}", flush=True)
        return MockModel(), ['mock'] * 10, 'mock'

    def cnn_predict_from_views(model, views_buffer, device):
        logits = torch.randn(1, 10)
        probs = torch.softmax(logits, dim=1)
        conf, idx = probs.max(1)
        return int(idx.item()), float(conf.item()), probs.squeeze(0).numpy()

    MultiViewPIMProcessor = MockMultiViewPIMProcessor


# ---------- Annotated Video Generator ----------
class AnnotatedVideoGenerator:
    def __init__(self, model_path="runs_cnn/best_cnn_early.pt",
                 confidence_threshold=0.7, sequence_length=30,
                 skip_frames=1, use_lite_mediapipe=False):
        self.confidence_threshold = confidence_threshold
        self.sequence_length = sequence_length
        self.skip_frames = max(1, skip_frames)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"🖥️ Using device: {self.device}", flush=True)

        # Load CNN model
        print(f"Loading model from: {model_path}", flush=True)
        self.model, self.movements, self.model_type = load_trained_model(model_path)
        self.expected_views = int(getattr(self.model, "_expected_num_views", 1))
        self.sequence_length = int(getattr(self.model, "_expected_T", self.sequence_length))
        self.model = self.model.to(self.device).eval()
        self.movement_names = {i: m for i, m in enumerate(self.movements)}
        print(f"✅ Loaded {self.model_type} with {len(self.movements)} movements "
              f"| views={self.expected_views} | T={self.sequence_length}", flush=True)

        # MediaPipe processor
        print(f"[DBG] constructing MultiViewPIMProcessor(num_views={self.expected_views}, "
              f"lite={use_lite_mediapipe})", flush=True)
        self.processor = MultiViewPIMProcessor(num_views=self.expected_views,
                                               use_lite_model=use_lite_mediapipe)
        print("[DBG] MediaPipe Pose object:", type(getattr(self.processor, "pose", None)), flush=True)

    # ---------- helper: draw overlay ----------
    def create_overlay_text(self, frame, prediction, confidence, ts, frame_i, history, pose_ok=True):
        overlay = frame.copy()
        h, w = frame.shape[:2]
        cv2.rectangle(overlay, (0, 0), (w, 180), (0, 0, 0), -1)
        cv2.putText(overlay, f"Pred: {prediction.upper()} ({confidence:.2f})",
                    (10, 60), cv2.FONT_HERSHEY_DUPLEX, 0.8,
                    (0,255,0) if pose_ok else (0,0,255), 2)
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

        # Quick pose test
        ok, f0 = cap.read()
        print("[DBG] first frame ok:", ok, flush=True)
        if ok:
            pose = getattr(self.processor, "pose", None)
            if pose:
                rgb = cv2.cvtColor(f0[:, (self.expected_views-1)*vw:], cv2.COLOR_BGR2RGB)
                try:
                    res = pose.process(rgb)
                    print("[DBG] pose.process() landmarks:", bool(getattr(res, "pose_landmarks", None)), flush=True)
                except Exception as e:
                    print("[DBG] pose.process() raised:", repr(e), flush=True)
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
                    lm = self.processor.extract_pose_landmarks_from_single_view(frame[:, x0:x1])
                    per_views.append(lm)
                n_ok = sum(lm is not None for lm in per_views)
                if frame_i % int(max(1, fps)) == 0:
                    print(f"[DBG] frame={frame_i} | views_ok={n_ok}/{self.expected_views}", flush=True)

                pred, conf = "NO POSE", 0.0
                if n_ok > 0:
                    frame_buffer_views.append(per_views)
                    if len(frame_buffer_views) == self.sequence_length:
                        pred_idx, conf, _ = cnn_predict_from_views(
                            self.model, list(frame_buffer_views), self.device)
                        pred = self.movement_names.get(pred_idx, f"unk_{pred_idx}")
                        if conf >= self.confidence_threshold:
                            history.append({'f': frame_i, 'ts': tstamp,
                                            'movement': pred, 'conf': conf})
                        print(f"[DBG] cnn pred: idx={pred_idx} conf={conf:.3f}", flush=True)

                last_view = frame[:, (self.expected_views-1)*vw:]
                if n_ok > 0 and per_views[-1] is not None:
                    for (a,b) in [(11,12),(11,13),(12,14),(23,24),(23,25),(24,26)]:
                        if a<len(per_views[-1]) and b<len(per_views[-1]):
                            pa = (int(per_views[-1][a][0]*vw), int(per_views[-1][a][1]*h))
                            pb = (int(per_views[-1][b][0]*vw), int(per_views[-1][b][1]*h))
                            cv2.line(last_view, pa, pb, (255,255,255), 2)
                last_view = self.create_overlay_text(last_view, pred, conf, tstamp, frame_i, history, n_ok>0)
                out.write(last_view)
                written += 1
                if written % (int(out_fps)*5) == 0:
                    print(f"[DBG] wrote {written} frames so far", flush=True)
        finally:
            print("[DBG] releasing resources", flush=True)
            cap.release(); out.release()
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
    p.add_argument("--model", "-m", default="runs_cnn/best_cnn_early.pt")
    p.add_argument("--output", "-o")
    p.add_argument("--confidence", "-c", type=float, default=0.7)
    p.add_argument("--duration", "-d", type=float)
    p.add_argument("--start", "-s", type=float, default=0)
    p.add_argument("--skip-frames", type=int, default=1)
    p.add_argument("--lite-mediapipe", action="store_true")
    a = p.parse_args()

    gen = AnnotatedVideoGenerator(model_path=a.model,
                                  confidence_threshold=a.confidence,
                                  skip_frames=a.skip_frames,
                                  use_lite_mediapipe=a.lite_mediapipe)
    gen.generate_annotated_video(a.input_video, a.output,
                                 max_duration=a.duration,
                                 start_time=a.start)
