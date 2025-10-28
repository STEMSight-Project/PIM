#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MediaPipe Multi-View Processor (lean, CNN-friendly)

What this provides:
- MultiViewPIMProcessor: split frames into N views and extract pose landmarks (33x3) per view
- process_multi_view_video_for_pim(): export per-view CSVs for dataset building
- prepare_sequences(): convert a single CSV into sliding windows (T,33,3)

Designed to pair with a CNN/TCN early-fusion model expecting fused inputs of shape [T,33,3*num_views].
"""

from __future__ import annotations
import os
import csv
import time
import logging
from typing import List, Optional

import cv2
import numpy as np
import pandas as pd
import mediapipe as mp

# ----------------------------- logging -----------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ----------------------------- constants -----------------------------
NUM_LANDMARKS = 33

# Optional label map (kept tiny for convenience – not used by the processor itself)
PIM_MOVEMENTS = {
    'normal': 0, 'decorticate': 1, 'dystonia': 2, 'chorea': 3,
    'myoclonus': 4, 'decerebrate': 5, 'fencer posture': 6,
    'ballistic': 7, 'tremor': 8, 'versive head': 9
}

# ----------------------- Multi-view MediaPipe -----------------------
class MultiViewPIMProcessor:
    """
    Minimal MediaPipe multi-view pose processor.

    Usage:
      proc = MultiViewPIMProcessor(num_views=3, use_lite_model=True)
      views = proc.split_views(frame)  # -> [view0_bgr, view1_bgr, ...]
      lm = proc.extract_pose_landmarks_from_single_view(views[0])  # -> (33,3) or None
    """

    def __init__(self,
                 num_views: int = 3,
                 use_lite_model: bool = False):
        """
        Args:
            num_views: How many views to slice from a horizontal composite frame
            use_lite_model: MediaPipe Pose model_complexity (0) vs full (1)
        """
        self.num_views = max(1, int(num_views))
        self.mp_pose = mp.solutions.pose
        model_complexity = 0 if use_lite_model else 1
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=model_complexity,
            enable_segmentation=False,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        logger.info(f"MediaPipe Pose initialized (model_complexity={model_complexity})")

    # ---- basic view splitting ----
    def split_views(self, frame_bgr: np.ndarray) -> List[np.ndarray]:
        """
        Evenly splits a horizontal composite frame into num_views views.
        No heuristics: assumes frame width is divisible by num_views.
        """
        h, w = frame_bgr.shape[:2]
        vw = w // self.num_views
        views = []
        for i in range(self.num_views):
            x0, x1 = i * vw, (i + 1) * vw
            views.append(frame_bgr[:, x0:x1])
        return views

    # ---- single-view pose extraction ----
    def extract_pose_landmarks_from_single_view(self, view_bgr: np.ndarray) -> Optional[np.ndarray]:
        """
        Returns (33,3) landmark array in normalized image coords (x,y,z) or None.
        """
        rgb = cv2.cvtColor(view_bgr, cv2.COLOR_BGR2RGB)
        res = self.pose.process(rgb)
        if not res.pose_landmarks:
            return None
        lm = res.pose_landmarks.landmark
        arr = np.array([[p.x, p.y, p.z] for p in lm], dtype=np.float32)
        if arr.shape != (NUM_LANDMARKS, 3):
            return None
        return arr

    # ---- dataset CSV export (optional) ----
    def process_multi_view_video_for_pim(self,
                                         video_path: str,
                                         movement_name: str,
                                         output_dir: str = "pose_data") -> bool:
        """
        Extract per-view pose landmarks from a multi-view video and write one CSV per view.

        CSV columns: timestamp, landmark_id, x, y, z
        """
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            logger.error(f"Could not open video file: {video_path}")
            return False

        os.makedirs(output_dir, exist_ok=True)
        stem = os.path.splitext(os.path.basename(video_path))[0].replace(' ', '_')
        timestamp = int(time.time())

        # Prepare writers/handles
        files, writers, handles = [], [], []
        try:
            for v in range(self.num_views):
                out_path = os.path.join(
                    output_dir, f"{movement_name}_{stem}_view{v}_{timestamp}_data.csv"
                )
                f = open(out_path, "w", newline="")
                w = csv.DictWriter(f, fieldnames=["timestamp", "landmark_id", "x", "y", "z"])
                w.writeheader()
                files.append(out_path); writers.append(w); handles.append(f)

            fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
            n_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
            logger.info(f"Processing: {video_path}  ({n_frames} frames @ {fps:.1f} FPS)")

            ok_frames = 0
            frame_idx = 0
            while True:
                ok, frame = cap.read()
                if not ok:
                    break
                t = round(frame_idx / fps, 3)
                frame_idx += 1

                views = self.split_views(frame)
                for vidx, view in enumerate(views):
                    lm = self.extract_pose_landmarks_from_single_view(view)
                    if lm is None:
                        continue
                    # write 33 rows
                    wr = writers[vidx]
                    for lid, (x, y, z) in enumerate(lm):
                        wr.writerow({"timestamp": t, "landmark_id": lid, "x": float(x), "y": float(y), "z": float(z)})
                    if vidx == 0:
                        ok_frames += 1

            logger.info(f"Done. Successful frames: {ok_frames}/{max(1, n_frames)}")
            for p in files:
                logger.info(f"Saved: {p}")
            return ok_frames > 0
        finally:
            cap.release()
            for f in handles:
                try:
                    f.close()
                except Exception:
                    pass

# ------------------------------- demo CLI -------------------------------
if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description="Lean MediaPipe multi-view extractor")
    ap.add_argument("video", help="Path to multi-view video")
    ap.add_argument("--movement", default="normal", help="Label used in CSV filenames")
    ap.add_argument("--views", type=int, default=3, help="Number of horizontal views")
    ap.add_argument("--lite", action="store_true", help="Use MediaPipe lite model (faster)")
    ap.add_argument("--out", default="pose_data", help="Output directory for CSVs")
    args = ap.parse_args()

    proc = MultiViewPIMProcessor(num_views=args.views, use_lite_model=args.lite)
    ok = proc.process_multi_view_video_for_pim(args.video, args.movement, args.out)
    print("Success" if ok else "No frames written")
