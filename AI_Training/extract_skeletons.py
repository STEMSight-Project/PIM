#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Extract Skeleton Data from Video Segments using MediaPipe

This script processes segmented videos and extracts pose skeleton data
in the format required for UNIK training.

Input: Segmented videos in AI_Training/segmented_videos/
Output: .npy skeleton files + .pkl labels in AI_Training/skeleton_data/

Usage:
    python extract_skeletons.py
    python extract_skeletons.py --split train
"""

# Suppress TensorFlow/MediaPipe warnings for cleaner output
import os
import sys

# Force UTF-8 encoding for Windows console
if sys.platform == "win32":
    import codecs

    sys.stdout = codecs.getwriter("utf-8")(sys.stdout.buffer, "strict")
    sys.stderr = codecs.getwriter("utf-8")(sys.stderr.buffer, "strict")

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
os.environ["GLOG_minloglevel"] = "2"

import warnings

warnings.filterwarnings("ignore", category=UserWarning)
warnings.filterwarnings("ignore", category=FutureWarning)

import cv2
import numpy as np
import pickle
from pathlib import Path
import argparse
from tqdm import tqdm
from concurrent.futures import ProcessPoolExecutor, as_completed
import multiprocessing

# Import reusable MediaPipe PoseLandmarker module
from mediapipe_poselandmarker import PoseLandmarkerExtractor


def process_single_video(video_path, target_frames, model_path):
    """
    Process a single video file using reusable PoseLandmarkerExtractor.

    Parameters:
    -----------
    video_path: Path
        Path to video file (single-view)
    target_frames: int or None
        Number of frames to extract (None = all frames)
    model_path: str
        Path to pose_landmarker.task model file

    Returns:
    --------
    tuple: (success, skeleton_data, video_name, error_msg) or (False, None, video_name, error_msg)
    """
    # Suppress warnings in worker process
    import warnings
    import sys
    import os

    warnings.filterwarnings("ignore")

    try:
        # Import here to avoid pickling issues
        from mediapipe_poselandmarker import PoseLandmarkerExtractor

        # Initialize extractor for this worker
        extractor = PoseLandmarkerExtractor(
            model_path=model_path,
            min_detection_confidence=0.3,  # Lower threshold for better detection
            min_presence_confidence=0.3,
            min_tracking_confidence=0.3,
        )

        # Extract from single-view video
        landmarks = extractor.extract_from_video(
            video_path=str(video_path),
            target_frames=target_frames,
            return_format="numpy",
        )

        if landmarks is not None:
            # Convert to UNIK format
            skeleton_data = extractor.convert_to_unik_format(landmarks)
            return (True, skeleton_data, video_path.name, None)
        else:
            return (False, None, video_path.name, "No landmarks detected")

    except Exception as e:
        # Return detailed error message
        error_msg = f"{type(e).__name__}: {str(e)}"
        return (False, None, video_path.name, error_msg)


class SkeletonExtractor:
    """Extract skeleton sequences from videos using MediaPipe Pose"""

    def __init__(
        self,
        video_dir=None,
        output_dir=None,
        target_frames=None,
        num_workers=10,
        model_path=None,
    ):
        """
        Initialize skeleton extractor.

        Parameters:
        -----------
        video_dir: str or Path
            Directory containing split videos (single-view per file)
        output_dir: str or Path
            Directory to save skeleton data
        target_frames: int or None
            Number of frames to extract per video (None = use all frames from video)
        num_workers: int
            Number of parallel workers (default: 10, set to 1 for sequential)
        model_path: str or Path
            Path to pose_landmarker.task model file
        """
        self.project_root = Path.cwd()

        # Handle relative paths based on current directory
        if self.project_root.name == "AI_Training":
            # Already in AI_Training directory
            default_video_dir = (
                self.project_root / "split_videos"
            )  # Changed from segmented_videos
            default_output_dir = (
                self.project_root / "skeleton_data"
            )  # Separate output folder
            default_model_path = self.project_root / "pose_landmarker_heavy.task"
        else:
            # In parent PIM directory
            default_video_dir = (
                self.project_root / "AI_Training" / "split_videos"
            )  # Changed from segmented_videos
            default_output_dir = (
                self.project_root / "AI_Training" / "skeleton_data"
            )  # Separate output folder
            default_model_path = (
                self.project_root / "AI_Training" / "pose_landmarker_heavy.task"
            )

        self.video_dir = Path(video_dir) if video_dir else default_video_dir
        self.output_dir = Path(output_dir) if output_dir else default_output_dir
        self.model_path = (
            str(Path(model_path)) if model_path else str(default_model_path)
        )
        self.target_frames = target_frames  # Can be None to use all frames
        self.num_workers = num_workers

        # Create output directory
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Verify model file exists
        if not Path(self.model_path).exists():
            print(f"⚠️  WARNING: Model file not found: {self.model_path}")
            print(f"   Using default MediaPipe Pose instead")
            self.use_legacy_api = True
        else:
            print(
                f"✅ Using MediaPipe PoseLandmarker model: {Path(self.model_path).name}"
            )
            self.use_legacy_api = False

        print(f"📁 Project root: {self.project_root}")
        print(f"📂 Video directory: {self.video_dir}")
        print(f"📂 Output directory: {self.output_dir}")
        print(
            f"🎯 Frame extraction mode: {'All frames (video length)' if target_frames is None else f'{target_frames} frames (resampled)'}"
        )
        print(f"📹 Video format: Single-view (already split)")

        # Show processing mode
        if num_workers > 1:
            cpu_count = multiprocessing.cpu_count()
            print(f"🚀 Parallel mode: {num_workers} workers (CPU cores: {cpu_count})")
        else:
            print(f"🔄 Sequential mode: Processing one video at a time")

        # Initialize PoseLandmarkerExtractor for sequential mode
        if num_workers == 1:
            self.extractor = PoseLandmarkerExtractor(
                model_path=self.model_path,
                min_detection_confidence=0.3,  # Lower threshold for better detection
                min_presence_confidence=0.3,
                min_tracking_confidence=0.3,
            )
            print(f"✅ PoseLandmarker extractor initialized")
        else:
            self.extractor = None
            print(f"✅ Workers will create their own extractors")

        # Statistics
        self.stats = {"total_videos": 0, "successful": 0, "failed": 0, "by_label": {}}

    def extract_pose_from_video(self, video_path):
        """
        Extract pose landmarks from a single-view video file.

        Parameters:
        -----------
        video_path: Path
            Path to video file (single-view)

        Returns:
        --------
        np.ndarray:
            Skeleton sequence in UNIK format
            Shape: (C, T, V, M) - C=3, T=frames, V=33 joints, M=1 person
        """
        # Extract from single-view video
        landmarks = self.extractor.extract_from_video(
            video_path=str(video_path),
            target_frames=self.target_frames,
            return_format="numpy",
        )

        if landmarks is not None:
            # Convert to UNIK format
            skeleton_data = self.extractor.convert_to_unik_format(landmarks)
            return skeleton_data
        else:
            return None

    def process_videos(self, split="train"):
        """
        Process all videos and extract skeletons (supports parallel and sequential).

        Parameters:
        -----------
        split: str
            'train', 'val', or 'all'

        Returns:
        --------
        dict: Processing statistics
        """
        print(f"\n{'='*70}")
        if self.num_workers > 1:
            print(f"🦴 EXTRACTING SKELETONS (PARALLEL - {self.num_workers} WORKERS)")
        else:
            print(f"🦴 EXTRACTING SKELETONS (SEQUENTIAL)")
        print(f"{'='*70}\n")

        # Get all label directories
        label_dirs = [d for d in self.video_dir.iterdir() if d.is_dir()]

        if not label_dirs:
            print(f"❌ No label directories found in {self.video_dir}")
            return self.stats

        print(f"📁 Found {len(label_dirs)} label directories")

        # Collect all skeleton data and labels
        all_skeletons = []
        all_labels = []
        all_filenames = []

        # Create label mapping
        label_to_idx = {
            label_dir.name: idx for idx, label_dir in enumerate(sorted(label_dirs))
        }
        idx_to_label = {idx: label for label, idx in label_to_idx.items()}

        print(f"\n🏷️  Label mapping:")
        for idx, label in sorted(idx_to_label.items()):
            print(f"   {idx}: {label}")

        if self.num_workers > 1:
            # PARALLEL MODE
            self._process_parallel(
                label_dirs,
                label_to_idx,
                idx_to_label,
                all_skeletons,
                all_labels,
                all_filenames,
            )
        else:
            # SEQUENTIAL MODE
            self._process_sequential(
                label_dirs,
                label_to_idx,
                idx_to_label,
                all_skeletons,
                all_labels,
                all_filenames,
            )

        # Save skeleton data
        if all_skeletons:
            print(f"\n{'='*70}")
            print(f"💾 SAVING SKELETON DATA")
            print(f"{'='*70}\n")

            # Check if all skeletons have the same T dimension
            frame_counts = [skel.shape[1] for skel in all_skeletons]  # T is at index 1
            unique_frames = set(frame_counts)

            if len(unique_frames) == 1:
                # All videos have same frame count - can save as single array
                skeleton_array = np.array(all_skeletons)  # (N, C, T, V, M)
                label_array = np.array(all_labels)
                print(f"   Skeleton data shape: {skeleton_array.shape}")
                print(f"   Labels shape: {label_array.shape}")
            else:
                # Variable frame counts - save as object array
                print(f"   ⚠️  Variable frame counts detected:")
                print(f"      Min frames: {min(frame_counts)}")
                print(f"      Max frames: {max(frame_counts)}")
                print(f"      Unique counts: {sorted(unique_frames)}")
                print(f"   Saving as object array (variable length)")

                # Create object array properly - can't use np.array() directly
                skeleton_array = np.empty(len(all_skeletons), dtype=object)
                for i, skel in enumerate(all_skeletons):
                    skeleton_array[i] = skel

                label_array = np.array(all_labels)
                print(
                    f"   Skeleton data: {len(all_skeletons)} samples (variable T dimension)"
                )
                print(f"   Labels shape: {label_array.shape}")

            # Save data
            data_file = self.output_dir / f"{split}_data.npy"
            label_file = self.output_dir / f"{split}_label.pkl"
            mapping_file = self.output_dir / "label_mapping.pkl"
            filenames_file = self.output_dir / f"{split}_filenames.pkl"

            np.save(data_file, skeleton_array)

            with open(label_file, "wb") as f:
                # Save in UNIK-compatible format: (sample_names, labels)
                pickle.dump((all_filenames, all_labels), f)

            with open(mapping_file, "wb") as f:
                pickle.dump(
                    {"label_to_idx": label_to_idx, "idx_to_label": idx_to_label}, f
                )

            with open(filenames_file, "wb") as f:
                pickle.dump(all_filenames, f)

            print(f"   ✅ Saved: {data_file}")
            print(f"   ✅ Saved: {label_file}")
            print(f"   ✅ Saved: {mapping_file}")
            print(f"   ✅ Saved: {filenames_file}")

        return self.stats

    def _process_parallel(
        self,
        label_dirs,
        label_to_idx,
        idx_to_label,
        all_skeletons,
        all_labels,
        all_filenames,
    ):
        """Process videos in parallel using multiple workers."""
        # Collect all video tasks
        video_tasks = []
        for label_dir in sorted(label_dirs):
            label_name = label_dir.name
            label_idx = label_to_idx[label_name]
            video_files = list(label_dir.glob("*.mp4"))

            if not video_files:
                print(f"\n📁 {label_name}: No videos found")
                continue

            for video_path in video_files:
                video_tasks.append((video_path, label_idx, label_name))

            # Initialize label stats
            if label_name not in self.stats["by_label"]:
                self.stats["by_label"][label_name] = {"successful": 0, "failed": 0}

        if not video_tasks:
            print("❌ No videos to process")
            return

        print(
            f"\n🚀 Processing {len(video_tasks)} videos with {self.num_workers} workers..."
        )

        # Process videos in parallel
        with ProcessPoolExecutor(max_workers=self.num_workers) as executor:
            # Submit all tasks with task_id to maintain order
            future_to_info = {}
            for task_id, (video_path, label_idx, label_name) in enumerate(video_tasks):
                future = executor.submit(
                    process_single_video,
                    video_path,
                    self.target_frames,
                    self.model_path,
                )
                future_to_info[future] = {
                    "task_id": task_id,
                    "video_path": video_path,
                    "label_idx": label_idx,
                    "label_name": label_name,
                }

            # Collect results in a dictionary (keyed by task_id) to maintain order
            results = {}
            failed_videos = []  # Track failures with error messages

            # Process results as they complete (for progress bar)
            with tqdm(
                total=len(video_tasks), desc="   Overall Progress", ncols=70
            ) as pbar:
                for future in as_completed(future_to_info):
                    info = future_to_info[future]
                    task_id = info["task_id"]
                    video_path = info["video_path"]
                    label_idx = info["label_idx"]
                    label_name = info["label_name"]

                    self.stats["total_videos"] += 1

                    try:
                        success, skeleton, video_name, error_msg = future.result()

                        if success:
                            # Single view processing
                            if skeleton is not None and isinstance(
                                skeleton, np.ndarray
                            ):
                                # Validate shape: should be (C, T, V, M) where C=3, V=33, M=1
                                # T can vary if target_frames is None
                                C, T, V, M = skeleton.shape
                                if C == 3 and V == 33 and M == 1:
                                    # Store in results dict (will be sorted later)
                                    results[task_id] = {
                                        "skeleton": skeleton,
                                        "label_idx": label_idx,
                                        "video_name": video_name,
                                    }
                                else:
                                    failed_videos.append(
                                        {
                                            "video": video_name,
                                            "label": label_name,
                                            "error": f"Invalid shape {skeleton.shape}",
                                        }
                                    )
                            else:
                                failed_videos.append(
                                    {
                                        "video": video_name,
                                        "label": label_name,
                                        "error": "Invalid skeleton data",
                                    }
                                )

                            self.stats["successful"] += 1
                            self.stats["by_label"][label_name]["successful"] += 1
                        else:
                            self.stats["failed"] += 1
                            self.stats["by_label"][label_name]["failed"] += 1
                            failed_videos.append(
                                {
                                    "video": video_name,
                                    "label": label_name,
                                    "error": error_msg or "Unknown error",
                                }
                            )

                    except Exception as e:
                        self.stats["failed"] += 1
                        self.stats["by_label"][label_name]["failed"] += 1
                        failed_videos.append(
                            {
                                "video": video_path.name,
                                "label": label_name,
                                "error": f"Exception: {str(e)}",
                            }
                        )

                    pbar.update(1)

            # Print failed videos summary if any
            if failed_videos:
                print(f"\n⚠️  Failed videos ({len(failed_videos)}):")
                # Group by error type
                from collections import defaultdict

                errors_by_type = defaultdict(list)
                for fail in failed_videos:
                    errors_by_type[fail["error"]].append(
                        f"{fail['label']}/{fail['video']}"
                    )

                for error, videos in sorted(errors_by_type.items()):
                    print(f"\n   {error} ({len(videos)} videos):")
                    for video in videos[:5]:  # Show first 5
                        print(f"      - {video}")
                    if len(videos) > 5:
                        print(f"      ... and {len(videos) - 5} more")

            # Now append results in correct order (sorted by task_id)
            for task_id in sorted(results.keys()):
                result = results[task_id]
                all_skeletons.append(result["skeleton"])
                all_labels.append(result["label_idx"])
                all_filenames.append(result["video_name"])

    def _process_sequential(
        self,
        label_dirs,
        label_to_idx,
        idx_to_label,
        all_skeletons,
        all_labels,
        all_filenames,
    ):
        """Process videos sequentially (one at a time)."""
        # Process each label directory
        for label_dir in sorted(label_dirs):
            label_name = label_dir.name
            label_idx = label_to_idx[label_name]

            # Get all videos in this label
            video_files = list(label_dir.glob("*.mp4"))

            if not video_files:
                print(f"\n📁 {label_name}: No videos found")
                continue

            print(f"\n📁 {label_name}: Processing {len(video_files)} videos")

            # Initialize label stats
            if label_name not in self.stats["by_label"]:
                self.stats["by_label"][label_name] = {"successful": 0, "failed": 0}

            # Process each video with progress bar
            for video_path in tqdm(video_files, desc=f"   {label_name}", ncols=70):
                self.stats["total_videos"] += 1

                # Extract skeleton
                skeleton = self.extract_pose_from_video(video_path)

                if skeleton is not None:
                    # Single view processing
                    if skeleton is not None and isinstance(skeleton, np.ndarray):
                        # Validate shape: should be (C, T, V, M) where C=3, V=33, M=1
                        # T can vary if target_frames is None
                        C, T, V, M = skeleton.shape
                        if C == 3 and V == 33 and M == 1:
                            all_skeletons.append(skeleton)
                            all_labels.append(label_idx)
                            all_filenames.append(video_path.name)
                        else:
                            print(
                                f"⚠️  Skipping {video_path.name}: "
                                f"invalid shape {skeleton.shape} (expected (3, T, 33, 1))"
                            )
                    else:
                        print(f"⚠️  Skipping invalid skeleton for {video_path.name}")

                    self.stats["successful"] += 1
                    self.stats["by_label"][label_name]["successful"] += 1
                else:
                    self.stats["failed"] += 1
                    self.stats["by_label"][label_name]["failed"] += 1

    def print_summary(self):
        """Print processing summary"""
        print(f"\n{'='*70}")
        print(f"📊 SKELETON EXTRACTION SUMMARY")
        print(f"{'='*70}")
        print(f"Total videos:     {self.stats['total_videos']}")
        print(f"✅ Successful:    {self.stats['successful']}")
        print(f"❌ Failed:        {self.stats['failed']}")

        print(f"\n🏷️  BY LABEL:")
        print(f"{'-'*70}")
        print(f"{'Label':<25} {'Successful':>15} {'Failed':>15}")
        print(f"{'-'*70}")
        for label in sorted(self.stats["by_label"].keys()):
            stats = self.stats["by_label"][label]
            print(f"{label:<25} {stats['successful']:>15} {stats['failed']:>15}")

        print(f"\n{'='*70}")
        print(f"📂 Output directory: {self.output_dir}")
        print(f"{'='*70}\n")


def main():
    """Main execution"""
    parser = argparse.ArgumentParser(
        description="Extract skeleton data from split videos (single-view per file)"
    )
    parser.add_argument(
        "--video-dir", help="Directory containing split videos (default: split_videos/)"
    )
    parser.add_argument(
        "--output-dir",
        help="Directory to save skeleton data (default: skeleton_data/)",
    )
    parser.add_argument(
        "--frames",
        type=int,
        default=300,
        help="Target frames per video (default: 300 frames = 5 seconds at 60fps)",
    )
    parser.add_argument(
        "--split",
        default="train",
        choices=["train", "val", "all"],
        help="Which split to process (default: train)",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=10,
        help="Number of parallel workers (default: 10, set to 1 for sequential)",
    )
    parser.add_argument(
        "--model-path",
        type=str,
        help="Path to pose_landmarker.task model file (default: pose_landmarker_heavy.task)",
    )

    args = parser.parse_args()

    print("=" * 70)
    print("🦴 SKELETON EXTRACTION FOR UNIK TRAINING")
    print("   Format: (N, C, T, V, M) = (samples, 3, 300, 33, 1)")
    print("   Default: 300 frames (5 seconds at 60fps)")
    print("=" * 70)

    # Initialize extractor
    extractor = SkeletonExtractor(
        video_dir=args.video_dir,
        output_dir=args.output_dir,
        target_frames=args.frames,
        num_workers=args.workers,
        model_path=args.model_path,
    )

    # Process videos
    extractor.process_videos(split=args.split)

    # Print summary
    extractor.print_summary()

    print("✅ Skeleton extraction complete!")
    print("\n📝 Next steps:")
    print("   1. Verify skeleton data in output directory")
    print(f"      Data shape: (N, 3, 300, 33, 1) saved in {extractor.output_dir}")
    print("   2. Update UNIK config to point to new skeleton data:")
    print(f"      data_path: '{extractor.output_dir}'")
    print("   3. Train UNIK model:")
    print("      cd UNIK && python run_unik.py --config config_pim.yaml")

    return 0


if __name__ == "__main__":
    sys.exit(main())
