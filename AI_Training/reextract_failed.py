#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Re-extract failed videos with lower confidence thresholds
"""

import sys
import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import warnings

warnings.filterwarnings("ignore")

import cv2
import numpy as np
import pickle
from pathlib import Path
from tqdm import tqdm
from concurrent.futures import ProcessPoolExecutor, as_completed

# Import reusable MediaPipe PoseLandmarker module
from mediapipe_poselandmarker import PoseLandmarkerExtractor


def process_single_video_low_confidence(video_path, target_frames, model_path):
    """
    Process a single video with LOWER confidence thresholds
    """
    import warnings

    warnings.filterwarnings("ignore")

    try:
        from mediapipe_poselandmarker import PoseLandmarkerExtractor

        # Initialize with MUCH LOWER confidence thresholds
        extractor = PoseLandmarkerExtractor(
            model_path=model_path,
            min_detection_confidence=0.3,  # Lowered from 0.5
            min_presence_confidence=0.3,  # Lowered from 0.5
            min_tracking_confidence=0.3,  # Lowered from 0.5
        )

        # Extract from single-view video
        landmarks = extractor.extract_from_video(
            video_path=str(video_path),
            target_frames=target_frames,
            return_format="numpy",
        )

        if landmarks is not None:
            skeleton_data = extractor.convert_to_unik_format(landmarks)
            return (True, skeleton_data, video_path.name)
        else:
            return (False, None, video_path.name)

    except Exception as e:
        print(f"ERROR processing {video_path.name}: {str(e)}", file=sys.stderr)
        return (False, None, video_path.name)


def main():
    """Re-extract only failed classes"""

    split_videos_dir = Path("split_videos")
    output_dir = Path("skeleton_data")
    model_path = "pose_landmarker_heavy.task"
    target_frames = 300
    num_workers = 8

    # Failed classes
    failed_classes = ["myoclonus", "normal", "tremor", "versive_head", "fencer_posture"]

    print("=" * 70)
    print("🔄 RE-EXTRACTING FAILED VIDEOS (Lower Confidence)")
    print("=" * 70)
    print(f"Target classes: {failed_classes}")
    print(f"Confidence thresholds: 0.3 (was 0.5)")
    print(f"Target frames: {target_frames}")
    print(f"Workers: {num_workers}")
    print("=" * 70)

    # Load existing successful videos
    with open(output_dir / "train_filenames.pkl", "rb") as f:
        existing_filenames = set(pickle.load(f))

    # Load existing data
    existing_data = np.load(output_dir / "train_data.npy")
    with open(output_dir / "train_label.pkl", "rb") as f:
        existing_labels_data = pickle.load(f)
    existing_labels = existing_labels_data[0]

    with open(output_dir / "label_mapping.pkl", "rb") as f:
        label_mapping = pickle.load(f)
    label_to_idx = label_mapping["label_to_idx"]

    print(f"\n✅ Loaded existing data: {len(existing_data)} samples")

    # Collect videos to process
    video_tasks = []
    for class_name in failed_classes:
        class_folder = split_videos_dir / class_name
        if not class_folder.exists():
            print(f"⚠️  Skipping {class_name} (folder not found)")
            continue

        class_videos = list(class_folder.glob("*.mp4"))
        label_idx = label_to_idx[class_name]

        for video_path in class_videos:
            if video_path.name not in existing_filenames:
                video_tasks.append((video_path, label_idx, class_name))

    print(f"\n📊 Videos to re-process: {len(video_tasks)}")

    if len(video_tasks) == 0:
        print("✅ No videos to process!")
        return

    # Process in parallel
    new_skeletons = []
    new_labels = []
    new_filenames = []

    results_dict = {}

    with ProcessPoolExecutor(max_workers=num_workers) as executor:
        futures = {}
        for task_id, (video_path, label_idx, label_name) in enumerate(video_tasks):
            future = executor.submit(
                process_single_video_low_confidence,
                video_path,
                target_frames,
                model_path,
            )
            futures[future] = (task_id, label_idx, label_name)

        # Collect results with progress bar
        pbar = tqdm(total=len(futures), desc="Extracting", unit="video")

        for future in as_completed(futures):
            task_id, label_idx, label_name = futures[future]
            success, skeleton_data, video_name = future.result()

            if success:
                results_dict[task_id] = (skeleton_data, label_idx, video_name)

            pbar.update(1)

        pbar.close()

    # Sort by task_id to maintain order
    for task_id in sorted(results_dict.keys()):
        skeleton_data, label_idx, video_name = results_dict[task_id]
        new_skeletons.append(skeleton_data)
        new_labels.append(label_idx)
        new_filenames.append(video_name)

    print(f"\n✅ Successfully extracted: {len(new_skeletons)} new skeletons")
    print(f"❌ Failed: {len(video_tasks) - len(new_skeletons)}")

    if len(new_skeletons) == 0:
        print(
            "\n⚠️  No new successful extractions. Try even lower confidence or manual review."
        )
        return

    # Combine with existing data
    print(f"\n📦 Combining data...")
    combined_data = np.concatenate([existing_data, np.array(new_skeletons)])
    combined_labels = list(existing_labels) + new_labels
    combined_filenames = (
        list(pickle.load(open(output_dir / "train_filenames.pkl", "rb")))
        + new_filenames
    )

    # Save updated data
    print(f"💾 Saving combined data...")
    np.save(output_dir / "train_data.npy", combined_data)

    with open(output_dir / "train_label.pkl", "wb") as f:
        pickle.dump((combined_labels, len(combined_labels)), f)

    with open(output_dir / "train_filenames.pkl", "wb") as f:
        pickle.dump(combined_filenames, f)

    print(f"\n✅ Updated data saved!")
    print(f"   Total samples now: {len(combined_data)}")
    print(f"   Shape: {combined_data.shape}")

    # Print class distribution
    from collections import Counter

    label_counts = Counter(combined_labels)
    idx_to_label = label_mapping["idx_to_label"]

    print(f"\n📊 Class distribution:")
    for idx in sorted(label_counts.keys()):
        print(f"   {idx_to_label[idx]}: {label_counts[idx]} samples")

    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()
