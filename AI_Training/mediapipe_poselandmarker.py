#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Reusable MediaPipe PoseLandmarker for Skeleton Extraction

This module provides a clean, reusable interface for extracting pose landmarks
using MediaPipe's PoseLandmarker Task API.

Usage:
    from mediapipe_poselandmarker import PoseLandmarkerExtractor

    # Initialize once
    extractor = PoseLandmarkerExtractor(model_path="pose_landmarker_heavy.task")

    # Extract from video
    landmarks = extractor.extract_from_video("video.mp4", target_frames=300)

    # Or process frame by frame
    for frame in video_frames:
        result = extractor.process_frame(frame, timestamp_ms)
"""

import cv2
import numpy as np
import mediapipe as mp
from pathlib import Path
from typing import Optional, List, Tuple, Dict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MediaPipe Task Vision API
BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode


class PoseLandmarkerExtractor:
    """
    Reusable MediaPipe PoseLandmarker for skeleton extraction

    This class provides a clean interface for extracting pose landmarks
    from videos and images using MediaPipe's heavy model.

    Attributes:
        model_path: Path to the .task model file
        min_detection_confidence: Minimum confidence for pose detection
        min_presence_confidence: Minimum presence confidence
        min_tracking_confidence: Minimum tracking confidence
        num_poses: Maximum number of poses to detect
    """

    def __init__(
        self,
        model_path: str = "pose_landmarker_heavy.task",
        min_detection_confidence: float = 0.5,
        min_presence_confidence: float = 0.5,
        min_tracking_confidence: float = 0.5,
        num_poses: int = 1,
    ):
        """
        Initialize the PoseLandmarker

        Args:
            model_path: Path to pose_landmarker.task model file
            min_detection_confidence: Minimum confidence for pose detection (0.0-1.0)
            min_presence_confidence: Minimum presence confidence (0.0-1.0)
            min_tracking_confidence: Minimum tracking confidence (0.0-1.0)
            num_poses: Maximum number of poses to detect
        """
        self.model_path = Path(model_path)
        self.min_detection_confidence = min_detection_confidence
        self.min_presence_confidence = min_presence_confidence
        self.min_tracking_confidence = min_tracking_confidence
        self.num_poses = num_poses

        # Check if model exists
        if not self.model_path.exists():
            raise FileNotFoundError(
                f"Model file not found: {self.model_path}\n"
                f"Please download it from: "
                f"https://storage.googleapis.com/mediapipe-models/pose_landmarker/"
                f"pose_landmarker_heavy/float16/latest/pose_landmarker_heavy.task"
            )

        logger.info(f"✅ Model loaded: {self.model_path.name}")

    def _create_options(self, running_mode: VisionRunningMode) -> PoseLandmarkerOptions:
        """
        Create PoseLandmarker options

        Args:
            running_mode: VIDEO or IMAGE mode

        Returns:
            Configured PoseLandmarkerOptions
        """
        return PoseLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=str(self.model_path)),
            running_mode=running_mode,
            num_poses=self.num_poses,
            min_pose_detection_confidence=self.min_detection_confidence,
            min_pose_presence_confidence=self.min_presence_confidence,
            min_tracking_confidence=self.min_tracking_confidence,
        )

    def extract_from_video(
        self,
        video_path: str,
        target_frames: int = None,
        start_frame: int = 0,
        return_format: str = "numpy",
    ) -> Optional[np.ndarray]:
        """
        Extract pose landmarks from a video file

        Args:
            video_path: Path to video file
            target_frames: Number of frames to extract
            start_frame: Frame to start extraction from
            return_format: Output format - "numpy" or "list"

        Returns:
            Numpy array of shape (T, V, C) where:
                T = number of frames
                V = number of joints (33 for MediaPipe)
                C = coordinates (x, y, visibility)
            Returns None if extraction fails
        """
        video_path = Path(video_path)

        if not video_path.exists():
            logger.error(f"❌ Video not found: {video_path}")
            return None

        logger.info(f"📹 Processing video: {video_path.name}")

        cap = cv2.VideoCapture(str(video_path))

        if not cap.isOpened():
            logger.error(f"❌ Cannot open video: {video_path}")
            return None

        # Get video properties
        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        logger.info(f"   Resolution: {width}x{height}")
        logger.info(f"   FPS: {fps}")
        logger.info(f"   Total frames: {total_frames}")
        if target_frames is None:
            logger.info(
                f"   Extracting: ALL frames with poses (from frame {start_frame})"
            )
        else:
            logger.info(
                f"   Extracting: {target_frames} frames from frame {start_frame}"
            )

        # Skip to start frame
        if start_frame > 0:
            cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

        # Create options for VIDEO mode
        options = self._create_options(VisionRunningMode.VIDEO)

        all_landmarks = []
        frame_idx = start_frame
        extracted_count = 0

        # Process frames
        with PoseLandmarker.create_from_options(options) as landmarker:
            logger.info("🎬 Extracting landmarks...")

            while target_frames is None or extracted_count < target_frames:
                ret, frame = cap.read()

                if not ret:
                    logger.warning(f"⚠️  Reached end of video at frame {frame_idx}")
                    break

                # Calculate timestamp in milliseconds
                timestamp_ms = int((frame_idx / fps) * 1000)

                # Convert BGR to RGB
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

                # Create MediaPipe Image
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

                # Detect pose
                result = landmarker.detect_for_video(mp_image, timestamp_ms)

                if result.pose_landmarks and len(result.pose_landmarks) > 0:
                    # Extract landmarks
                    pose = result.pose_landmarks[0]
                    landmarks = [[lm.x, lm.y, lm.visibility] for lm in pose]
                    all_landmarks.append(landmarks)
                    extracted_count += 1

                    if extracted_count % 50 == 0:
                        if target_frames is None:
                            logger.info(f"   Extracted: {extracted_count} frames...")
                        else:
                            logger.info(
                                f"   Extracted: {extracted_count}/{target_frames} frames"
                            )

                frame_idx += 1

        cap.release()

        if not all_landmarks:
            logger.error("❌ No poses detected in video")
            return None

        logger.info(f"✅ Extracted {len(all_landmarks)} frames with poses")

        # Convert to numpy array
        landmarks_array = np.array(all_landmarks)
        logger.info(f"   Shape: {landmarks_array.shape} (T, V, C)")

        if return_format == "list":
            return all_landmarks
        else:
            return landmarks_array

    def extract_from_multi_angle_video(
        self,
        video_path: str,
        num_views: int = 4,
        target_frames: int = 300,
        start_frame: int = 0,
        view_layout: str = "horizontal",
    ) -> Optional[List[np.ndarray]]:
        """
        Extract pose landmarks from a multi-angle video

        Args:
            video_path: Path to video file
            num_views: Number of camera views in the video
            target_frames: Number of frames to extract
            start_frame: Frame to start extraction from
            view_layout: "horizontal" or "vertical" split

        Returns:
            List of numpy arrays, one per view
            Each array has shape (T, V, C)
        """
        video_path = Path(video_path)

        if not video_path.exists():
            logger.error(f"❌ Video not found: {video_path}")
            return None

        logger.info(f"📹 Processing multi-angle video: {video_path.name}")
        logger.info(f"   Views: {num_views} ({view_layout} layout)")

        cap = cv2.VideoCapture(str(video_path))

        if not cap.isOpened():
            logger.error(f"❌ Cannot open video: {video_path}")
            return None

        # Get video properties
        fps = cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        logger.info(f"   Full resolution: {width}x{height}")
        logger.info(f"   FPS: {fps}")

        # Calculate view dimensions
        if view_layout == "horizontal":
            view_width = width // num_views
            view_height = height
            logger.info(f"   Each view: {view_width}x{view_height}")
        else:
            view_width = width
            view_height = height // num_views
            logger.info(f"   Each view: {view_width}x{view_height}")

        # Skip to start frame
        if start_frame > 0:
            cap.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

        # Create options for VIDEO mode
        options = self._create_options(VisionRunningMode.VIDEO)

        # Initialize storage for each view
        all_view_landmarks = [[] for _ in range(num_views)]
        frame_idx = start_frame
        extracted_count = 0

        # Create separate landmarker for each view to maintain monotonic timestamps
        landmarkers = [
            PoseLandmarker.create_from_options(options) for _ in range(num_views)
        ]

        try:
            logger.info("🎬 Extracting landmarks from all views...")

            while extracted_count < target_frames:
                ret, frame = cap.read()

                if not ret:
                    logger.warning(f"⚠️  Reached end of video at frame {frame_idx}")
                    break

                # Calculate timestamp
                timestamp_ms = int((frame_idx / fps) * 1000)

                # Split frame into views
                views = []
                if view_layout == "horizontal":
                    for i in range(num_views):
                        x_start = i * view_width
                        x_end = x_start + view_width
                        view = frame[:, x_start:x_end]
                        views.append(view)
                else:
                    for i in range(num_views):
                        y_start = i * view_height
                        y_end = y_start + view_height
                        view = frame[y_start:y_end, :]
                        views.append(view)

                # Process each view with its own landmarker
                for view_idx, view in enumerate(views):
                    # Convert BGR to RGB
                    rgb_view = cv2.cvtColor(view, cv2.COLOR_BGR2RGB)

                    # Create MediaPipe Image
                    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_view)

                    # Detect pose using view-specific landmarker
                    result = landmarkers[view_idx].detect_for_video(
                        mp_image, timestamp_ms
                    )

                    if result.pose_landmarks and len(result.pose_landmarks) > 0:
                        # Extract landmarks
                        pose = result.pose_landmarks[0]
                        landmarks = [[lm.x, lm.y, lm.visibility] for lm in pose]
                        all_view_landmarks[view_idx].append(landmarks)

                extracted_count += 1

                if extracted_count % 50 == 0:
                    logger.info(
                        f"   Extracted: {extracted_count}/{target_frames} frames"
                    )

                frame_idx += 1

        finally:
            # Close all landmarkers
            for landmarker in landmarkers:
                landmarker.close()

        cap.release()

        # Convert to numpy arrays
        result_arrays = []
        for view_idx in range(num_views):
            if all_view_landmarks[view_idx]:
                view_array = np.array(all_view_landmarks[view_idx])
                result_arrays.append(view_array)
                logger.info(f"✅ View {view_idx+1}: {view_array.shape} (T, V, C)")
            else:
                logger.warning(f"⚠️  View {view_idx+1}: No poses detected")
                result_arrays.append(None)

        return result_arrays

    def convert_to_unik_format(self, landmarks: np.ndarray) -> np.ndarray:
        """
        Convert landmarks to UNIK model format (C, T, V, M)

        Args:
            landmarks: Numpy array of shape (T, V, C)

        Returns:
            Numpy array of shape (C, T, V, M) where:
                C = channels (x, y, visibility)
                T = time/frames
                V = vertices/joints
                M = persons (always 1)
        """
        # Input: (T, V, C)
        # Transpose to (C, T, V)
        skeleton_data = landmarks.transpose(2, 0, 1)

        # Add person dimension: (C, T, V, M)
        skeleton_data = np.expand_dims(skeleton_data, axis=-1)

        logger.info(f"📦 Converted to UNIK format: {skeleton_data.shape} (C, T, V, M)")

        return skeleton_data

    def visualize_video(
        self,
        video_path: str,
        output_path: Optional[str] = None,
        max_frames: int = 60,
        show_realtime: bool = True,
    ) -> bool:
        """
        Visualize pose detection on a video

        Args:
            video_path: Path to input video
            output_path: Path to save output video (optional)
            max_frames: Maximum frames to process
            show_realtime: Show real-time window

        Returns:
            True if successful
        """
        video_path = Path(video_path)

        if not video_path.exists():
            logger.error(f"❌ Video not found: {video_path}")
            return False

        logger.info(f"🎬 Visualizing: {video_path.name}")

        cap = cv2.VideoCapture(str(video_path))

        if not cap.isOpened():
            logger.error(f"❌ Cannot open video")
            return False

        # Get video properties
        fps = cap.get(cv2.CAP_PROP_FPS)
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

        # Setup video writer if output path specified
        writer = None
        if output_path:
            fourcc = cv2.VideoWriter_fourcc(*"mp4v")
            writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
            logger.info(f"💾 Saving to: {output_path}")

        # Create window if showing realtime
        if show_realtime:
            cv2.namedWindow("PoseLandmarker Visualization", cv2.WINDOW_NORMAL)
            cv2.resizeWindow("PoseLandmarker Visualization", 1280, 720)

        # Create options
        options = self._create_options(VisionRunningMode.VIDEO)

        # MediaPipe pose connections
        mp_pose = mp.solutions.pose

        frame_idx = 0

        with PoseLandmarker.create_from_options(options) as landmarker:
            logger.info("🎨 Processing...")

            while frame_idx < max_frames:
                ret, frame = cap.read()

                if not ret:
                    break

                timestamp_ms = int((frame_idx / fps) * 1000)
                rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

                result = landmarker.detect_for_video(mp_image, timestamp_ms)

                vis_frame = frame.copy()

                if result.pose_landmarks and len(result.pose_landmarks) > 0:
                    pose = result.pose_landmarks[0]

                    # Draw landmarks
                    h, w = vis_frame.shape[:2]
                    for lm in pose:
                        cx, cy = int(lm.x * w), int(lm.y * h)

                        # Color based on visibility
                        if lm.visibility > 0.7:
                            color = (0, 255, 0)
                        elif lm.visibility > 0.5:
                            color = (0, 255, 255)
                        elif lm.visibility > 0.3:
                            color = (0, 165, 255)
                        else:
                            color = (0, 0, 255)

                        cv2.circle(vis_frame, (cx, cy), 5, color, -1)
                        cv2.circle(vis_frame, (cx, cy), 7, (255, 255, 255), 2)

                    # Draw connections
                    for connection in mp_pose.POSE_CONNECTIONS:
                        start_idx, end_idx = connection
                        if start_idx < len(pose) and end_idx < len(pose):
                            start_lm = pose[start_idx]
                            end_lm = pose[end_idx]

                            start_pt = (int(start_lm.x * w), int(start_lm.y * h))
                            end_pt = (int(end_lm.x * w), int(end_lm.y * h))

                            avg_vis = (start_lm.visibility + end_lm.visibility) / 2
                            color = (
                                (0, 255, 0)
                                if avg_vis > 0.6
                                else (0, 255, 255) if avg_vis > 0.4 else (128, 128, 128)
                            )

                            cv2.line(vis_frame, start_pt, end_pt, color, 2)

                    # Info text
                    visibilities = [lm.visibility for lm in pose]
                    avg_vis = sum(visibilities) / len(visibilities)
                    cv2.putText(
                        vis_frame,
                        f"Frame: {frame_idx}",
                        (20, 40),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.0,
                        (0, 255, 0),
                        2,
                    )
                    cv2.putText(
                        vis_frame,
                        f"Visibility: {avg_vis:.3f}",
                        (20, 80),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.0,
                        (0, 255, 0),
                        2,
                    )
                else:
                    cv2.putText(
                        vis_frame,
                        f"Frame: {frame_idx}",
                        (20, 40),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.0,
                        (0, 0, 255),
                        2,
                    )
                    cv2.putText(
                        vis_frame,
                        "NO POSE",
                        (20, 80),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.0,
                        (0, 0, 255),
                        2,
                    )

                if writer:
                    writer.write(vis_frame)

                if show_realtime:
                    cv2.imshow("PoseLandmarker Visualization", vis_frame)
                    if cv2.waitKey(1) & 0xFF == ord("q"):
                        logger.info("⏹️  User stopped")
                        break

                frame_idx += 1

        cap.release()
        if writer:
            writer.release()
        if show_realtime:
            cv2.destroyAllWindows()

        logger.info(f"✅ Processed {frame_idx} frames")
        return True


# Example usage
if __name__ == "__main__":
    import sys

    # Initialize extractor
    extractor = PoseLandmarkerExtractor(
        model_path="pose_landmarker_heavy.task",
        min_detection_confidence=0.5,
        min_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    # Example 1: Extract from single-view video
    video_path = "segmented_videos/chorea/2025-08-04 18-24-06_00-11-40_10.mp4"

    if Path(video_path).exists():
        print("\n" + "=" * 70)
        print("EXAMPLE 1: Extract from single-view video")
        print("=" * 70)

        landmarks = extractor.extract_from_video(
            video_path=video_path, target_frames=60, return_format="numpy"
        )

        if landmarks is not None:
            print(f"\n✅ Extracted landmarks shape: {landmarks.shape}")

            # Convert to UNIK format
            unik_data = extractor.convert_to_unik_format(landmarks)
            print(f"✅ UNIK format shape: {unik_data.shape}")

    # Example 2: Visualize video
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Visualize pose detection")
    print("=" * 70)

    if Path(video_path).exists():
        extractor.visualize_video(
            video_path=video_path,
            max_frames=60,
            show_realtime=True,
            output_path="visualization_output.mp4",
        )
