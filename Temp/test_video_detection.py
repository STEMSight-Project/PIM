"""
Temporary Video Testing Script
Test PIM movement detection on video file using production services
"""

import sys
from pathlib import Path
import cv2
import mediapipe as mp
import numpy as np
from collections import deque

# Force UTF-8 encoding for Windows console
if sys.platform == "win32":
    import io

    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

# Add AI_Training path for new MediaPipe module
AI_MODEL_PATH = Path(__file__).parent.parent / "AI_Training"
sys.path.insert(0, str(AI_MODEL_PATH))

# Add backend path for services
BACKEND_PATH = Path(__file__).parent.parent / "Back-End"
sys.path.insert(0, str(BACKEND_PATH))

from mediapipe_poselandmarker import PoseLandmarkerExtractor
from services.ai import get_classifier_service

# ============================================================
# Configuration
# ============================================================


class Config:
    # Video settings
    VIDEO_PATH = r"D:\DevProj\STEMSight\PIM\AI_Training\split_videos\ballistic\2025-08-04 19-15-27_00-10-35_39_view1.mp4"

    # MediaPipe model settings
    MODEL_PATH = r"D:\DevProj\STEMSight\PIM\AI_Training\pose_landmarker_heavy.task"

    # Detection settings (match training: 300 frames = 5 seconds at 60 FPS)
    WINDOW_SIZE = 300  # Frames to collect before prediction (MUST MATCH TRAINING)
    STRIDE = 150  # Overlap (50% overlap for better temporal coverage)
    MIN_CONFIDENCE = 0.60  # Lower threshold to catch subtle movements

    # Multi-scale detection for subtle movements
    USE_MULTI_SCALE = True  # Detect at multiple temporal scales
    TEMPORAL_SCALES = [300, 240, 180]  # Full, 80%, 60% of training window

    # Motion analysis
    DETECT_MOTION_MAGNITUDE = True  # Analyze movement intensity
    MOTION_THRESHOLD = 0.01  # Minimum motion to consider (Euclidean distance)

    # Multi-angle settings
    MULTI_ANGLE = False  # Single view mode (set to True for 4-view horizontal layout)
    NUM_VIEWS = 4  # Number of camera angles

    # Display settings
    SHOW_SKELETON = True
    SHOW_INFO_PANEL = True

    # Performance settings
    PROCESS_EVERY_N_FRAMES = 2  # Process every Nth frame (2 = 30 FPS from 60 FPS video)
    FAST_MODE = True  # Skip some visual details for better performance


# ============================================================
# Video Processor
# ============================================================


class VideoDetectionTester:
    """Test video with PIM classifier service - Enhanced for subtle movement detection"""

    def __init__(self, config=Config()):
        self.config = config

        # Initialize NEW MediaPipe PoseLandmarker (Task API)
        print("🔄 Initializing MediaPipe PoseLandmarker (Task API)...")
        self.pose_extractor = PoseLandmarkerExtractor(
            model_path=config.MODEL_PATH,
            min_detection_confidence=0.3,  # Lower for subtle movements
            min_presence_confidence=0.3,
            min_tracking_confidence=0.3,
        )
        print("✅ MediaPipe PoseLandmarker ready!")

        # Keep legacy MediaPipe for drawing connections
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils

        print("✅ MediaPipe drawing utilities ready!")

        # Initialize classifier service
        print("🔄 Loading PIM classifier service...")
        self.classifier = get_classifier_service()
        print("✅ Classifier ready!")

        # Frame buffers (one per view if multi-angle)
        if config.MULTI_ANGLE:
            self.frame_buffers = [
                deque(maxlen=config.WINDOW_SIZE) for _ in range(config.NUM_VIEWS)
            ]
            print(f"📹 Multi-angle mode: {config.NUM_VIEWS} views")
        else:
            self.frame_buffer = deque(maxlen=config.WINDOW_SIZE)
            print("📹 Single view mode")

        # Statistics (per view)
        self.stats = {
            "frames_processed": 0,
            "poses_detected": [0] * (config.NUM_VIEWS if config.MULTI_ANGLE else 1),
            "predictions_made": [0] * (config.NUM_VIEWS if config.MULTI_ANGLE else 1),
            "detections_by_class": [
                {} for _ in range(config.NUM_VIEWS if config.MULTI_ANGLE else 1)
            ],
        }

        # Sliding window control
        self.frames_since_last_prediction = 0  # Track frames since last prediction
        self.should_predict = False  # Flag to control when to predict

        # Initialize separate PoseLandmarker instances for each view (for multi-angle)
        if config.MULTI_ANGLE:
            print(
                f"🔄 Creating {config.NUM_VIEWS} PoseLandmarker instances for multi-angle..."
            )
            BaseOptions = mp.tasks.BaseOptions
            PoseLandmarker = mp.tasks.vision.PoseLandmarker
            PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
            VisionRunningMode = mp.tasks.vision.RunningMode

            options = PoseLandmarkerOptions(
                base_options=BaseOptions(model_asset_path=str(config.MODEL_PATH)),
                running_mode=VisionRunningMode.VIDEO,
                num_poses=1,
                min_pose_detection_confidence=0.5,
                min_pose_presence_confidence=0.5,
                min_tracking_confidence=0.5,
            )

            self.landmarkers = [
                PoseLandmarker.create_from_options(options)
                for _ in range(config.NUM_VIEWS)
            ]
            # Track frame count per view for monotonic timestamps
            self.view_frame_counters = [0] * config.NUM_VIEWS
            print(f"✅ Created {config.NUM_VIEWS} landmarker instances!")
        else:
            self.landmarkers = None
            self.view_frame_counters = None

    def extract_landmarks_from_result(self, pose_landmarks):
        """Extract landmarks from PoseLandmarker result as numpy array (33, 3)"""
        landmarks = []
        for landmark in pose_landmarks:
            landmarks.append([landmark.x, landmark.y, landmark.visibility])
        return np.array(landmarks)

    def calculate_motion_magnitude(self, skeleton_sequence):
        """
        Calculate motion magnitude to detect subtle vs. obvious movements.

        Args:
            skeleton_sequence: numpy array (T, 33, 3) where T is frames

        Returns:
            float: Average motion magnitude per frame
        """
        if len(skeleton_sequence) < 2:
            return 0.0

        # Calculate frame-to-frame Euclidean distance for each joint
        motion = []
        for i in range(1, len(skeleton_sequence)):
            prev_frame = skeleton_sequence[i - 1][:, :2]  # x, y only
            curr_frame = skeleton_sequence[i][:, :2]

            # Euclidean distance for each joint
            distances = np.sqrt(np.sum((curr_frame - prev_frame) ** 2, axis=1))
            # Average across all joints
            motion.append(np.mean(distances))

        avg_motion = np.mean(motion)
        return avg_motion

    def resample_sequence(self, skeleton_sequence, target_frames):
        """
        Resample skeleton sequence to target number of frames.
        Uses linear interpolation for smooth resampling.

        Args:
            skeleton_sequence: list or numpy array (current_frames, 33, 3)
            target_frames: int - desired number of frames

        Returns:
            numpy array (target_frames, 33, 3)
        """
        skeleton_array = np.array(skeleton_sequence)
        current_frames = skeleton_array.shape[0]

        if current_frames == target_frames:
            return skeleton_array

        # Create interpolation indices
        old_indices = np.linspace(0, current_frames - 1, current_frames)
        new_indices = np.linspace(0, current_frames - 1, target_frames)

        # Interpolate each joint and coordinate
        resampled = np.zeros((target_frames, 33, 3))
        for joint in range(33):
            for coord in range(3):
                resampled[:, joint, coord] = np.interp(
                    new_indices, old_indices, skeleton_array[:, joint, coord]
                )

        return resampled

    def split_frame_into_views(self, frame):
        """
        Split frame into 4 views (horizontal 1x4 layout).
        Assumes views are arranged side by side with small spacing.

        Returns: list of 4 view frames
        """
        h, w = frame.shape[:2]
        view_width = w // self.config.NUM_VIEWS
        spacing = 10  # Estimated spacing between views

        views = []
        for i in range(self.config.NUM_VIEWS):
            x_start = i * view_width
            x_end = (i + 1) * view_width

            # Adjust for spacing
            if i > 0:
                x_start += spacing // 2
            if i < self.config.NUM_VIEWS - 1:
                x_end -= spacing // 2

            view = frame[0:h, x_start:x_end]
            views.append(view)

        return views

    def draw_info_panel(self, frame, results_list):
        """
        Draw information panel on frame with probability distribution chart.

        Parameters:
        -----------
        frame: np.ndarray
            Original frame
        results_list: list of dict
            Results for each view (or single result if not multi-angle)
        """
        h, w = frame.shape[:2]

        if self.config.MULTI_ANGLE:
            # Multi-view panel (taller to show all views + probability chart)
            panel_height = 550
        else:
            # Single view with probability chart
            panel_height = 450

        panel = np.zeros((panel_height, w, 3), dtype=np.uint8)

        # Title
        title = (
            "PIM Multi-Angle Detection Test"
            if self.config.MULTI_ANGLE
            else "PIM Movement Detection Test"
        )
        cv2.putText(
            panel,
            title,
            (10, 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.8,
            (255, 255, 255),
            2,
        )

        if not self.config.MULTI_ANGLE:
            # Single view - use original panel logic
            result = results_list[0] if results_list else {"status": "no_pose"}
            status = result.get("status", "unknown")

            if status == "no_pose":
                cv2.putText(
                    panel,
                    "Status: No pose detected",
                    (10, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (0, 0, 255),
                    2,
                )

            elif status == "collecting":
                buffer_size = result.get("buffer_size", 0)
                progress = buffer_size / self.config.WINDOW_SIZE

                cv2.putText(
                    panel,
                    f"Status: Collecting frames ({buffer_size}/{self.config.WINDOW_SIZE})",
                    (10, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (255, 255, 0),
                    2,
                )

                # Progress bar
                bar_width = int(w * 0.8)
                bar_x = int(w * 0.1)
                cv2.rectangle(
                    panel, (bar_x, 90), (bar_x + bar_width, 110), (100, 100, 100), 2
                )
                cv2.rectangle(
                    panel,
                    (bar_x, 90),
                    (bar_x + int(bar_width * progress), 110),
                    (0, 255, 0),
                    -1,
                )

            elif status == "waiting_stride":
                frames_until = result.get("frames_until_prediction", 0)
                stride_progress = 1.0 - (frames_until / self.config.STRIDE)

                cv2.putText(
                    panel,
                    f"Status: Ready - Next prediction in {frames_until} frames",
                    (10, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (100, 200, 255),  # Light blue
                    2,
                )

                cv2.putText(
                    panel,
                    f"Sliding window: {self.config.STRIDE} frame stride (overlap: {self.config.WINDOW_SIZE - self.config.STRIDE} frames)",
                    (10, 100),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.45,
                    (150, 150, 150),
                    1,
                )

                # Stride progress bar
                bar_width = int(w * 0.8)
                bar_x = int(w * 0.1)
                cv2.rectangle(
                    panel, (bar_x, 115), (bar_x + bar_width, 135), (100, 100, 100), 2
                )
                cv2.rectangle(
                    panel,
                    (bar_x, 115),
                    (bar_x + int(bar_width * stride_progress), 135),
                    (100, 200, 255),
                    -1,
                )

            elif status == "prediction":
                pred_class = result.get("predicted_class", "Unknown")
                confidence = result.get("confidence", 0.0)
                tier = result.get("tier", "unknown")
                model_accuracy = result.get("model_accuracy", 0.0)
                all_probs = result.get("all_probabilities", {})
                motion_magnitude = result.get("motion_magnitude", 0.0)
                movement_intensity = result.get("movement_intensity", "unknown")

                # Determine color based on tier
                tier_colors = {
                    "excellent": (0, 255, 0),  # Green
                    "good": (0, 255, 255),  # Yellow
                    "needs_review": (0, 165, 255),  # Orange
                }
                color = tier_colors.get(tier, (255, 255, 255))

                # Movement intensity colors
                intensity_colors = {
                    "very_subtle": (200, 200, 200),  # Light gray
                    "subtle": (150, 150, 255),  # Light purple
                    "moderate": (100, 200, 255),  # Light blue
                    "obvious": (50, 255, 50),  # Bright green
                }
                intensity_color = intensity_colors.get(
                    movement_intensity, (255, 255, 255)
                )

                # Display results
                cv2.putText(
                    panel,
                    f"Movement: {pred_class.upper()}",
                    (10, 70),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.8,
                    color,
                    2,
                )
                cv2.putText(
                    panel,
                    f"Confidence: {confidence:.1%}",
                    (10, 105),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (255, 255, 255),
                    2,
                )
                cv2.putText(
                    panel,
                    f"Model Accuracy: {model_accuracy:.1f}%",
                    (10, 135),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (255, 255, 255),
                    2,
                )
                cv2.putText(
                    panel,
                    f"Tier: {tier.upper()}",
                    (10, 165),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    color,
                    2,
                )

                # Display movement intensity analysis
                cv2.putText(
                    panel,
                    f"Intensity: {movement_intensity.upper().replace('_', ' ')} ({motion_magnitude:.4f})",
                    (10, 195),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    intensity_color,
                    2,
                )

                # Confidence bar
                bar_x = int(w * 0.5)
                bar_width = int(w * 0.45)
                cv2.rectangle(
                    panel, (bar_x, 60), (bar_x + bar_width, 85), (100, 100, 100), 2
                )
                cv2.rectangle(
                    panel,
                    (bar_x, 60),
                    (bar_x + int(bar_width * confidence), 85),
                    color,
                    -1,
                )

                # ===== PROBABILITY DISTRIBUTION CHART =====
                cv2.line(panel, (0, 200), (w, 200), (100, 100, 100), 2)
                cv2.putText(
                    panel,
                    "PROBABILITY DISTRIBUTION - ALL MOVEMENTS:",
                    (10, 230),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    (255, 255, 255),
                    2,
                )

                # Sort probabilities for display
                sorted_probs = sorted(
                    all_probs.items(), key=lambda x: x[1], reverse=True
                )

                # Draw horizontal bars for each class
                y_start = 260
                bar_height = 18
                bar_spacing = 3
                max_bar_width = w - 250

                for i, (cls, prob) in enumerate(sorted_probs):
                    y_pos = y_start + i * (bar_height + bar_spacing)

                    # Class name
                    cls_display = cls.replace("_", " ").title()
                    cv2.putText(
                        panel,
                        f"{cls_display}:",
                        (10, y_pos + 14),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.45,
                        (200, 200, 200),
                        1,
                    )

                    # Percentage text
                    cv2.putText(
                        panel,
                        f"{prob*100:.1f}%",
                        (w - 80, y_pos + 14),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.45,
                        (255, 255, 255),
                        1,
                    )

                    # Bar background
                    bar_x_start = 180
                    cv2.rectangle(
                        panel,
                        (bar_x_start, y_pos),
                        (bar_x_start + max_bar_width, y_pos + bar_height),
                        (50, 50, 50),
                        -1,
                    )

                    # Bar fill (color based on whether it's the predicted class)
                    bar_fill_width = int(max_bar_width * prob)
                    if cls == pred_class:
                        bar_color = color  # Use tier color for predicted class
                    else:
                        bar_color = (100, 100, 200)  # Gray-blue for others

                    cv2.rectangle(
                        panel,
                        (bar_x_start, y_pos),
                        (bar_x_start + bar_fill_width, y_pos + bar_height),
                        bar_color,
                        -1,
                    )

                    # Bar outline
                    cv2.rectangle(
                        panel,
                        (bar_x_start, y_pos),
                        (bar_x_start + max_bar_width, y_pos + bar_height),
                        (100, 100, 100),
                        1,
                    )
        else:
            # Multi-view panel
            view_width = w // self.config.NUM_VIEWS
            y_start = 60

            for view_idx, result in enumerate(results_list):
                x_offset = view_idx * view_width
                status = result.get("status", "unknown")

                # View header
                cv2.putText(
                    panel,
                    f"View {view_idx + 1}",
                    (x_offset + 10, y_start),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (200, 200, 200),
                    1,
                )

                if status == "no_pose":
                    cv2.putText(
                        panel,
                        "No pose",
                        (x_offset + 10, y_start + 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.4,
                        (0, 0, 255),
                        1,
                    )

                elif status == "collecting":
                    buffer_size = result.get("buffer_size", 0)
                    progress = buffer_size / self.config.WINDOW_SIZE

                    cv2.putText(
                        panel,
                        f"{buffer_size}/{self.config.WINDOW_SIZE}",
                        (x_offset + 10, y_start + 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.4,
                        (255, 255, 0),
                        1,
                    )

                    # Mini progress bar
                    bar_w = view_width - 20
                    cv2.rectangle(
                        panel,
                        (x_offset + 10, y_start + 40),
                        (x_offset + 10 + bar_w, y_start + 50),
                        (100, 100, 100),
                        1,
                    )
                    cv2.rectangle(
                        panel,
                        (x_offset + 10, y_start + 40),
                        (x_offset + 10 + int(bar_w * progress), y_start + 50),
                        (0, 255, 0),
                        -1,
                    )

                elif status == "prediction":
                    pred_class = result.get("predicted_class", "Unknown")
                    confidence = result.get("confidence", 0.0)
                    tier = result.get("tier", "unknown")

                    tier_colors = {
                        "excellent": (0, 255, 0),
                        "good": (0, 255, 255),
                        "needs_review": (0, 165, 255),
                    }
                    color = tier_colors.get(tier, (255, 255, 255))

                    # Class name
                    cv2.putText(
                        panel,
                        pred_class[:10],  # Truncate if too long
                        (x_offset + 10, y_start + 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.5,
                        color,
                        1,
                    )

                    # Confidence
                    cv2.putText(
                        panel,
                        f"{confidence:.0%}",
                        (x_offset + 10, y_start + 55),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.4,
                        (255, 255, 255),
                        1,
                    )

                    # Tier
                    cv2.putText(
                        panel,
                        tier[:8],
                        (x_offset + 10, y_start + 75),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.3,
                        color,
                        1,
                    )

                    # Top 2 predictions
                    all_probs = result.get("all_probabilities", {})
                    sorted_probs = sorted(
                        all_probs.items(), key=lambda x: x[1], reverse=True
                    )[:2]

                    y_pos = y_start + 100
                    for i, (cls, prob) in enumerate(sorted_probs, 1):
                        cv2.putText(
                            panel,
                            f"{i}. {cls[:8]}: {prob:.0%}",
                            (x_offset + 10, y_pos),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.3,
                            (180, 180, 180),
                            1,
                        )
                        y_pos += 15

                # Separator line
                if view_idx < self.config.NUM_VIEWS - 1:
                    cv2.line(
                        panel,
                        (x_offset + view_width, y_start - 10),
                        (x_offset + view_width, y_start + 150),
                        (100, 100, 100),
                        1,
                    )

            # Summary section with ensemble probability distribution
            cv2.line(panel, (0, 220), (w, 220), (100, 100, 100), 2)
            cv2.putText(
                panel,
                "ENSEMBLE PREDICTION (All Views Combined):",
                (10, 250),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.6,
                (255, 255, 255),
                2,
            )

            # Calculate ensemble result (majority vote + average probabilities)
            predictions = [
                r.get("predicted_class")
                for r in results_list
                if r.get("status") == "prediction"
            ]

            if predictions:
                from collections import Counter

                vote_counts = Counter(predictions)
                ensemble_class, count = vote_counts.most_common(1)[0]
                ensemble_confidence = count / len(predictions)

                cv2.putText(
                    panel,
                    f"{ensemble_class.upper()} ({count}/{len(predictions)} views agree, {ensemble_confidence:.0%})",
                    (10, 285),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 255, 0) if ensemble_confidence >= 0.75 else (0, 255, 255),
                    2,
                )

                # ===== ENSEMBLE PROBABILITY DISTRIBUTION =====
                # Average probabilities across all views that made predictions
                all_probs_list = [
                    r.get("all_probabilities", {})
                    for r in results_list
                    if r.get("status") == "prediction" and r.get("all_probabilities")
                ]

                if all_probs_list:
                    # Get all class names
                    all_classes = set()
                    for probs in all_probs_list:
                        all_classes.update(probs.keys())

                    # Calculate average probability for each class
                    avg_probs = {}
                    for cls in all_classes:
                        probs = [p.get(cls, 0.0) for p in all_probs_list]
                        avg_probs[cls] = sum(probs) / len(probs)

                    # Draw probability bars
                    cv2.line(panel, (0, 310), (w, 310), (80, 80, 80), 1)
                    cv2.putText(
                        panel,
                        "Average Probability Distribution:",
                        (10, 335),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.5,
                        (200, 200, 200),
                        1,
                    )

                    sorted_avg_probs = sorted(
                        avg_probs.items(), key=lambda x: x[1], reverse=True
                    )

                    y_start = 355
                    bar_height = 14
                    bar_spacing = 2
                    max_bar_width = w - 250

                    for i, (cls, prob) in enumerate(sorted_avg_probs):
                        y_pos = y_start + i * (bar_height + bar_spacing)

                        # Class name
                        cls_display = cls.replace("_", " ").title()
                        cv2.putText(
                            panel,
                            f"{cls_display}:",
                            (10, y_pos + 11),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.35,
                            (180, 180, 180),
                            1,
                        )

                        # Percentage
                        cv2.putText(
                            panel,
                            f"{prob*100:.1f}%",
                            (w - 70, y_pos + 11),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            0.35,
                            (220, 220, 220),
                            1,
                        )

                        # Bar
                        bar_x_start = 150
                        bar_fill_width = int(max_bar_width * prob)

                        # Background
                        cv2.rectangle(
                            panel,
                            (bar_x_start, y_pos),
                            (bar_x_start + max_bar_width, y_pos + bar_height),
                            (40, 40, 40),
                            -1,
                        )

                        # Fill
                        bar_color = (
                            (0, 255, 0) if cls == ensemble_class else (100, 100, 180)
                        )
                        cv2.rectangle(
                            panel,
                            (bar_x_start, y_pos),
                            (bar_x_start + bar_fill_width, y_pos + bar_height),
                            bar_color,
                            -1,
                        )

                        # Outline
                        cv2.rectangle(
                            panel,
                            (bar_x_start, y_pos),
                            (bar_x_start + max_bar_width, y_pos + bar_height),
                            (80, 80, 80),
                            1,
                        )

            else:
                cv2.putText(
                    panel,
                    "Collecting data...",
                    (10, 285),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (255, 255, 0),
                    2,
                )

        # Statistics at the bottom
        stats_y = panel_height - 50
        cv2.line(panel, (0, stats_y), (w, stats_y), (100, 100, 100), 1)

        if self.config.MULTI_ANGLE:
            total_poses = sum(self.stats["poses_detected"])
            total_predictions = sum(self.stats["predictions_made"])
            stats_text = (
                f"Frames: {self.stats['frames_processed']} | "
                f"Poses: {total_poses} (total) | "
                f"Predictions: {total_predictions} (total)"
            )
        else:
            stats_text = (
                f"Frames: {self.stats['frames_processed']} | "
                f"Poses: {self.stats['poses_detected'][0]} | "
                f"Predictions: {self.stats['predictions_made'][0]}"
            )

        cv2.putText(
            panel,
            stats_text,
            (10, stats_y + 30),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.5,
            (180, 180, 180),
            1,
        )

        return panel

    def process_frame(self, frame, frame_idx, fps):
        """Process single frame and return result(s) - Using NEW PoseLandmarker API"""
        self.stats["frames_processed"] += 1

        if not self.config.MULTI_ANGLE:
            # Single view processing with NEW API
            timestamp_ms = int((frame_idx / fps) * 1000)

            # Convert to RGB
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # Create MediaPipe Image
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

            # Use the pose_extractor's first landmarker (create one if needed)
            if not hasattr(self, "single_landmarker"):
                BaseOptions = mp.tasks.BaseOptions
                PoseLandmarker = mp.tasks.vision.PoseLandmarker
                PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
                VisionRunningMode = mp.tasks.vision.RunningMode

                options = PoseLandmarkerOptions(
                    base_options=BaseOptions(
                        model_asset_path=str(self.config.MODEL_PATH)
                    ),
                    running_mode=VisionRunningMode.VIDEO,
                    num_poses=1,
                    min_pose_detection_confidence=0.5,
                    min_pose_presence_confidence=0.5,
                    min_tracking_confidence=0.5,
                )
                self.single_landmarker = PoseLandmarker.create_from_options(options)

            # Detect pose
            result = self.single_landmarker.detect_for_video(mp_image, timestamp_ms)

            if not result.pose_landmarks or len(result.pose_landmarks) == 0:
                return {"status": "no_pose", "frame": frame}

            self.stats["poses_detected"][0] += 1

            # Draw skeleton on frame
            annotated_frame = frame.copy()
            if self.config.SHOW_SKELETON:
                pose = result.pose_landmarks[0]
                h, w = annotated_frame.shape[:2]

                # Draw landmarks
                for lm in pose:
                    cx, cy = int(lm.x * w), int(lm.y * h)
                    color = (0, 255, 0) if lm.visibility > 0.5 else (0, 255, 255)
                    cv2.circle(annotated_frame, (cx, cy), 5, color, -1)
                    cv2.circle(annotated_frame, (cx, cy), 7, (255, 255, 255), 2)

                # Draw connections
                for connection in self.mp_pose.POSE_CONNECTIONS:
                    start_idx, end_idx = connection
                    if start_idx < len(pose) and end_idx < len(pose):
                        start_lm = pose[start_idx]
                        end_lm = pose[end_idx]
                        start_pt = (int(start_lm.x * w), int(start_lm.y * h))
                        end_pt = (int(end_lm.x * w), int(end_lm.y * h))
                        cv2.line(annotated_frame, start_pt, end_pt, (0, 255, 0), 2)

            # Extract landmarks as numpy array
            landmarks = self.extract_landmarks_from_result(result.pose_landmarks[0])
            self.frame_buffer.append(landmarks)

            # Still collecting initial window
            if len(self.frame_buffer) < self.config.WINDOW_SIZE:
                return {
                    "status": "collecting",
                    "buffer_size": len(self.frame_buffer),
                    "frame": annotated_frame,
                }

            # Buffer is full - check if we should make a prediction
            self.frames_since_last_prediction += 1

            # Only predict when stride is reached (or first time buffer fills)
            if (
                self.frames_since_last_prediction < self.config.STRIDE
                and self.stats["predictions_made"][0] > 0
            ):
                # Show "waiting" status
                return {
                    "status": "waiting_stride",
                    "buffer_size": len(self.frame_buffer),
                    "frames_until_prediction": self.config.STRIDE
                    - self.frames_since_last_prediction,
                    "frame": annotated_frame,
                }

            # Reset counter and make prediction
            self.frames_since_last_prediction = 0

            # Get skeleton sequence (should be 300 frames now)
            skeleton_sequence = np.array(list(self.frame_buffer))

            # Calculate motion magnitude to assess movement intensity
            motion_magnitude = 0.0
            if self.config.DETECT_MOTION_MAGNITUDE:
                motion_magnitude = self.calculate_motion_magnitude(skeleton_sequence)

            try:
                # Ensure exactly 300 frames (resample if needed due to frame drops)
                if skeleton_sequence.shape[0] != 300:
                    print(
                        f"⚠️  Warning: Got {skeleton_sequence.shape[0]} frames, resampling to 300"
                    )
                    skeleton_sequence = self.resample_sequence(skeleton_sequence, 300)

                prediction = self.classifier.predict(skeleton_sequence)
                self.stats["predictions_made"][0] += 1

                pred_class = prediction.predicted_class
                self.stats["detections_by_class"][0][pred_class] = (
                    self.stats["detections_by_class"][0].get(pred_class, 0) + 1
                )

                # Classify movement intensity
                if motion_magnitude < 0.005:
                    movement_intensity = "very_subtle"
                elif motion_magnitude < 0.015:
                    movement_intensity = "subtle"
                elif motion_magnitude < 0.030:
                    movement_intensity = "moderate"
                else:
                    movement_intensity = "obvious"

                return {
                    "status": "prediction",
                    "predicted_class": prediction.predicted_class,
                    "confidence": prediction.confidence,
                    "tier": prediction.tier,
                    "model_accuracy": prediction.model_accuracy,
                    "all_probabilities": prediction.all_probabilities,
                    "motion_magnitude": motion_magnitude,
                    "movement_intensity": movement_intensity,
                    "frame": annotated_frame,
                }

            except Exception as e:
                print(f"⚠️ Prediction error: {e}")
                return {"status": "error", "error": str(e), "frame": annotated_frame}

        else:
            # Multi-angle processing with NEW API
            views = self.split_frame_into_views(frame)
            view_results = []
            annotated_views = []

            timestamp_ms = int((frame_idx / fps) * 1000)

            for view_idx, view_frame in enumerate(views):
                # Use separate frame counter for each view for monotonic timestamps
                self.view_frame_counters[view_idx] += 1
                timestamp_ms = int((self.view_frame_counters[view_idx] / fps) * 1000)

                # Convert to RGB
                rgb_view = cv2.cvtColor(view_frame, cv2.COLOR_BGR2RGB)

                # Create MediaPipe Image
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_view)

                # Process with view-specific landmarker
                result = self.landmarkers[view_idx].detect_for_video(
                    mp_image, timestamp_ms
                )

                # Annotate view
                annotated_view = view_frame.copy()

                if not result.pose_landmarks or len(result.pose_landmarks) == 0:
                    view_results.append({"status": "no_pose", "view_idx": view_idx})
                    annotated_views.append(annotated_view)
                    continue

                self.stats["poses_detected"][view_idx] += 1

                # Draw skeleton
                if self.config.SHOW_SKELETON:
                    pose = result.pose_landmarks[0]
                    h, w = annotated_view.shape[:2]

                    # Draw landmarks
                    for lm in pose:
                        cx, cy = int(lm.x * w), int(lm.y * h)
                        color = (0, 255, 0) if lm.visibility > 0.5 else (0, 255, 255)
                        cv2.circle(annotated_view, (cx, cy), 4, color, -1)
                        cv2.circle(annotated_view, (cx, cy), 6, (255, 255, 255), 1)

                    # Draw connections
                    for connection in self.mp_pose.POSE_CONNECTIONS:
                        start_idx, end_idx = connection
                        if start_idx < len(pose) and end_idx < len(pose):
                            start_lm = pose[start_idx]
                            end_lm = pose[end_idx]
                            start_pt = (int(start_lm.x * w), int(start_lm.y * h))
                            end_pt = (int(end_lm.x * w), int(end_lm.y * h))
                            cv2.line(annotated_view, start_pt, end_pt, (0, 255, 0), 2)

                annotated_views.append(annotated_view)

                # Extract and buffer landmarks
                landmarks = self.extract_landmarks_from_result(result.pose_landmarks[0])
                self.frame_buffers[view_idx].append(landmarks)

                # Check if buffer ready
                if len(self.frame_buffers[view_idx]) < self.config.WINDOW_SIZE:
                    view_results.append(
                        {
                            "status": "collecting",
                            "buffer_size": len(self.frame_buffers[view_idx]),
                            "view_idx": view_idx,
                        }
                    )
                    continue

                # Make prediction for this view
                skeleton_sequence = np.array(list(self.frame_buffers[view_idx]))

                try:
                    prediction = self.classifier.predict(skeleton_sequence)
                    self.stats["predictions_made"][view_idx] += 1

                    pred_class = prediction.predicted_class
                    self.stats["detections_by_class"][view_idx][pred_class] = (
                        self.stats["detections_by_class"][view_idx].get(pred_class, 0)
                        + 1
                    )

                    view_results.append(
                        {
                            "status": "prediction",
                            "predicted_class": prediction.predicted_class,
                            "confidence": prediction.confidence,
                            "tier": prediction.tier,
                            "model_accuracy": prediction.model_accuracy,
                            "all_probabilities": prediction.all_probabilities,
                            "view_idx": view_idx,
                        }
                    )

                except Exception as e:
                    print(f"⚠️ View {view_idx + 1} prediction error: {e}")
                    view_results.append(
                        {
                            "status": "error",
                            "error": str(e),
                            "view_idx": view_idx,
                        }
                    )

            # Combine annotated views back into single frame
            annotated_frame = np.hstack(annotated_views)

            return {
                "status": "multi_view",
                "view_results": view_results,
                "frame": annotated_frame,
            }

    def extract_landmarks_from_result(self, pose_landmarks):
        """Extract landmarks from PoseLandmarker result as numpy array (33, 3)"""
        landmarks = []
        for landmark in pose_landmarks:
            landmarks.append([landmark.x, landmark.y, landmark.visibility])
        return np.array(landmarks)

    def test_video(self, display=True, save_output=None):
        import time

        """Test video file"""
        print("\n" + "=" * 60)
        print("🎥 Starting Video Detection Test")
        print("=" * 60)

        # Open video
        cap = cv2.VideoCapture(self.config.VIDEO_PATH)

        if not cap.isOpened():
            print(f"❌ Could not open video: {self.config.VIDEO_PATH}")
            return

        # Get video properties
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        if fps <= 0:
            fps = 60  # Default to 60 FPS if not detected
        target_frame_time = 1.0 / 60  # Target 60 FPS
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        duration = total_frames / fps if fps > 0 else 0

        print(f"\n📹 Video Info:")
        print(f"   Resolution: {width}x{height}")
        print(f"   FPS: {fps}")
        print(f"   Total Frames: {total_frames}")
        print(f"   Duration: {duration:.1f} seconds")
        print(f"\n⚙️  Detection Settings:")
        print(f"   Window Size: {self.config.WINDOW_SIZE} frames (5 seconds at 60 FPS)")
        print(f"   Stride: {self.config.STRIDE} frames")
        print(
            f"   Overlap: {self.config.WINDOW_SIZE - self.config.STRIDE} frames ({(self.config.WINDOW_SIZE - self.config.STRIDE) / self.config.WINDOW_SIZE * 100:.0f}%)"
        )
        print(f"   Min Confidence: {self.config.MIN_CONFIDENCE:.0%}")
        print(f"\n📊 Sliding Window Behavior:")
        print(f"   • Collect 300 frames → Make prediction")
        print(f"   • Slide forward 150 frames → Make next prediction")
        print(f"   • Result: Prediction every ~2.5 seconds with 50% temporal overlap")

        # Video writer if saving
        writer = None
        if save_output:
            panel_height = 250 if self.config.SHOW_INFO_PANEL else 0
            fourcc = cv2.VideoWriter_fourcc(*"mp4v")
            writer = cv2.VideoWriter(
                save_output, fourcc, fps, (width, height + panel_height)
            )
            print(f"\n💾 Saving output to: {save_output}")

        print("\n▶️  Processing... Press 'q' to quit, SPACE to pause\n")

        frame_count = 0
        paused = False
        last_prediction = None

        # For real-time playback: skip frames if processing is too slow
        PROCESS_EVERY_N_FRAMES = self.config.PROCESS_EVERY_N_FRAMES
        target_frame_time = 1.0 / (
            fps / PROCESS_EVERY_N_FRAMES
        )  # Adjust target based on skip rate

        print(
            f"   Processing every {PROCESS_EVERY_N_FRAMES} frame(s) for {fps/PROCESS_EVERY_N_FRAMES:.0f} FPS effective rate"
        )

        while cap.isOpened():
            frame_start = time.time()
            if not paused:
                ret, frame = cap.read()
                if not ret:
                    break

                frame_count += 1

                # Skip frames for real-time playback
                if frame_count % PROCESS_EVERY_N_FRAMES != 0:
                    continue

                # Process frame with NEW API (pass frame_idx and fps)
                result = self.process_frame(frame, frame_count, fps)

                # Handle results
                if self.config.MULTI_ANGLE and result.get("status") == "multi_view":
                    view_results = result["view_results"]
                    predictions = [
                        r for r in view_results if r.get("status") == "prediction"
                    ]
                    if predictions:
                        last_prediction = result
                        from collections import Counter

                        classes = [p["predicted_class"] for p in predictions]
                        vote_counts = Counter(classes)
                        ensemble_class, count = vote_counts.most_common(1)[0]
                        print(
                            f"Frame {frame_count}: ENSEMBLE={ensemble_class.upper()} "
                            f"({count}/{len(predictions)} views) | "
                            f"Views: {', '.join([f'V{p['view_idx']+1}:{p['predicted_class'][:3]}' for p in predictions])}"
                        )
                else:
                    if result["status"] == "prediction":
                        last_prediction = result
                        motion_mag = result.get("motion_magnitude", 0)
                        intensity = result.get("movement_intensity", "unknown")
                        print(
                            f"🔍 Frame {frame_count}: {result['predicted_class'].upper()} "
                            f"({result['confidence']:.1%}) | "
                            f"Intensity: {intensity.upper().replace('_', ' ')} ({motion_mag:.4f}) | "
                            f"Tier: {result['tier']}"
                        )
                    elif result["status"] == "waiting_stride":
                        frames_until = result.get("frames_until_prediction", 0)
                        if frames_until % 30 == 0:  # Print every 30 frames
                            print(
                                f"   ⏳ Frame {frame_count}: Sliding window - {frames_until} frames until next prediction"
                            )

                output_frame = result["frame"]
                if self.config.SHOW_INFO_PANEL:
                    if self.config.MULTI_ANGLE:
                        results_list = result.get("view_results", [])
                    else:
                        results_list = [result]
                    panel = self.draw_info_panel(result["frame"], results_list)
                    output_frame = np.vstack([result["frame"], panel])

            # Display
            if display:
                cv2.imshow("PIM Movement Detection Test", output_frame)
                # Use fixed delay for smoother playback (don't try to compensate for processing time)
                key = cv2.waitKey(1) & 0xFF  # Fixed 1ms delay for fastest rendering

                if key == ord("q"):
                    print("\n⏹️  Stopped by user")
                    break
                elif key == ord(" "):
                    paused = not paused
                    print(f"\n{'⏸️  Paused' if paused else '▶️  Resumed'}")

            # Save
            if writer and not paused:
                writer.write(output_frame)

            # Progress
            if frame_count % 100 == 0:
                progress = (frame_count / total_frames) * 100
                print(f"Progress: {frame_count}/{total_frames} ({progress:.1f}%)")

        # Cleanup
        cap.release()
        if writer:
            writer.release()
        if display:
            cv2.destroyAllWindows()

        # Print summary
        self.print_summary()

    def print_summary(self):
        """Print detection summary"""
        print("\n" + "=" * 60)
        print("📊 DETECTION SUMMARY")
        print("=" * 60)

        print(f"\n📈 Statistics:")
        print(f"   Total Frames Processed: {self.stats['frames_processed']}")

        if self.config.MULTI_ANGLE:
            print(f"\n🎥 Per-View Statistics:")
            for view_idx in range(self.config.NUM_VIEWS):
                print(f"\n   View {view_idx + 1}:")
                print(f"      Poses Detected: {self.stats['poses_detected'][view_idx]}")
                print(
                    f"      Predictions Made: {self.stats['predictions_made'][view_idx]}"
                )

                if self.stats["predictions_made"][view_idx] > 0:
                    print(f"      Detections by Class:")
                    detections = self.stats["detections_by_class"][view_idx]
                    if detections:
                        sorted_det = sorted(
                            detections.items(), key=lambda x: x[1], reverse=True
                        )
                        for cls, count in sorted_det:
                            percentage = (
                                count / self.stats["predictions_made"][view_idx]
                            ) * 100
                            print(f"         {cls}: {count} ({percentage:.1f}%)")

            # Overall statistics
            total_poses = sum(self.stats["poses_detected"])
            total_predictions = sum(self.stats["predictions_made"])

            print(f"\n   📊 Overall:")
            print(f"      Total Poses: {total_poses}")
            print(f"      Total Predictions: {total_predictions}")

            if self.stats["frames_processed"] > 0:
                avg_poses_per_frame = total_poses / self.stats["frames_processed"]
                print(f"      Avg Poses per Frame: {avg_poses_per_frame:.2f}")
        else:
            # Single view statistics
            print(f"   Poses Detected: {self.stats['poses_detected'][0]}")
            print(f"   Predictions Made: {self.stats['predictions_made'][0]}")

            if self.stats["poses_detected"][0] > 0:
                detection_rate = (
                    self.stats["poses_detected"][0] / self.stats["frames_processed"]
                ) * 100
                print(f"   Pose Detection Rate: {detection_rate:.1f}%")

            if self.stats["detections_by_class"][0]:
                print(f"\n🎯 Detections by Movement Class:")
                sorted_detections = sorted(
                    self.stats["detections_by_class"][0].items(),
                    key=lambda x: x[1],
                    reverse=True,
                )
                for cls, count in sorted_detections:
                    percentage = (count / self.stats["predictions_made"][0]) * 100
                    print(f"   {cls.upper()}: {count} ({percentage:.1f}%)")

        print("\n✅ Test complete!")


# ============================================================
# Main
# ============================================================


def main():
    print("\n" + "=" * 60)
    print("🧪 PIM Movement Detection - Video Test")
    print("=" * 60)

    # Check if video exists
    if not Path(Config.VIDEO_PATH).exists():
        print(f"\n❌ Video file not found: {Config.VIDEO_PATH}")
        return

    print(f"\n📁 Video: {Config.VIDEO_PATH}")

    # Initialize tester
    tester = VideoDetectionTester()

    # Ask for options
    print("\n⚙️  Options:")
    save = input("Save output video? (y/n): ").strip().lower() == "y"

    output_path = None
    if save:
        output_path = str(Path(__file__).parent / "test_output.mp4")
        print(f"   Output will be saved to: {output_path}")

    # Run test
    tester.test_video(display=True, save_output=output_path)


if __name__ == "__main__":
    main()
