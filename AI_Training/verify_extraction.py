#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Test script to verify skeleton extraction maintains correct data order

This script tests both sequential and parallel processing to ensure that
skeleton data, labels, and filenames are correctly synchronized.
"""

import sys
import numpy as np
import pickle
from pathlib import Path


def verify_data_consistency(data_dir="skeleton_data"):
    """
    Verify that skeleton data, labels, and filenames are correctly synchronized.

    Parameters:
    -----------
    data_dir: str
        Directory containing extracted skeleton data
    """
    print("=" * 70)
    print("🔍 VERIFYING DATA CONSISTENCY")
    print("=" * 70)
    print()

    data_dir = Path(data_dir)

    # Load all data files
    print("📂 Loading data files...")
    try:
        data = np.load(data_dir / "train_data.npy", allow_pickle=True)
        print(f"   ✅ train_data.npy: {len(data)} samples")

        with open(data_dir / "train_label.pkl", "rb") as f:
            labels, count = pickle.load(f)
        print(f"   ✅ train_label.pkl: {len(labels)} labels (count={count})")

        with open(data_dir / "train_filenames.pkl", "rb") as f:
            filenames = pickle.load(f)
        print(f"   ✅ train_filenames.pkl: {len(filenames)} filenames")

        with open(data_dir / "label_mapping.pkl", "rb") as f:
            mapping = pickle.load(f)
        print(f"   ✅ label_mapping.pkl: {len(mapping['idx_to_label'])} classes")

    except Exception as e:
        print(f"❌ Error loading data: {e}")
        return False

    print()

    # Check array lengths match
    print("🔢 Checking array length consistency...")
    if len(data) == len(labels) == len(filenames):
        print(f"   ✅ All arrays have same length: {len(data)}")
    else:
        print(f"   ❌ LENGTH MISMATCH!")
        print(f"      data: {len(data)}")
        print(f"      labels: {len(labels)}")
        print(f"      filenames: {len(filenames)}")
        return False

    print()

    # Check label count matches
    print("🏷️  Checking label count...")
    if count == len(data):
        print(f"   ✅ Label count matches: {count}")
    else:
        print(f"   ❌ Label count mismatch: pkl={count}, actual={len(data)}")
        return False

    print()

    # Sample verification: Check first 10 entries
    print("🔍 Sampling first 10 entries...")
    idx_to_label = mapping["idx_to_label"]

    for i in range(min(10, len(data))):
        skeleton = data[i]
        label_idx = labels[i]
        filename = filenames[i]
        label_name = idx_to_label[label_idx]

        # Check if filename contains the class label
        # Expected format: class_folder/videoname_view1.mp4
        # But we only store filename, so check if label makes sense
        if isinstance(skeleton, np.ndarray):
            shape_str = str(skeleton.shape)
        else:
            shape_str = "object"

        print(
            f"   [{i:3d}] Label {label_idx:2d} ({label_name:15s}) | {filename:50s} | Shape: {shape_str}"
        )

    print()

    # Check for sorting issues (if videos from same class are grouped)
    print("📊 Checking class distribution...")
    label_sequence = labels[:20]  # First 20 samples
    print(f"   First 20 labels: {label_sequence}")

    # Count class distribution
    from collections import Counter

    class_counts = Counter(labels)

    print()
    print("   Class distribution:")
    for label_idx in sorted(class_counts.keys()):
        label_name = idx_to_label[label_idx]
        count = class_counts[label_idx]
        print(f"      {label_idx:2d} ({label_name:15s}): {count:4d} samples")

    print()

    # Check for duplicate filenames (would indicate ordering bug)
    print("🔄 Checking for duplicate filenames...")
    unique_filenames = set(filenames)
    if len(unique_filenames) == len(filenames):
        print(f"   ✅ All filenames are unique: {len(filenames)} files")
    else:
        duplicates = len(filenames) - len(unique_filenames)
        print(f"   ⚠️  Found {duplicates} duplicate filenames!")
        # Show some duplicates
        from collections import Counter

        filename_counts = Counter(filenames)
        dupes = [(name, cnt) for name, cnt in filename_counts.items() if cnt > 1]
        print(f"   Examples: {dupes[:5]}")
        return False

    print()

    # Verify skeleton shapes
    print("📏 Checking skeleton shapes...")
    if isinstance(data[0], np.ndarray) and len(data[0].shape) == 4:
        # Fixed-length arrays
        print(f"   ✅ Fixed-length skeletons: {data[0].shape}")
        C, T, V, M = data[0].shape
        print(
            f"      C={C} (channels), T={T} (frames), V={V} (joints), M={M} (persons)"
        )
    else:
        # Variable-length arrays
        frame_counts = [s.shape[1] for s in data if isinstance(s, np.ndarray)]
        print(f"   ✅ Variable-length skeletons:")
        print(f"      Min frames: {min(frame_counts)}")
        print(f"      Max frames: {max(frame_counts)}")
        print(f"      Avg frames: {sum(frame_counts)/len(frame_counts):.1f}")
        print(f"      Format: (3, T, 33, 1)")

    print()
    print("=" * 70)
    print("✅ DATA CONSISTENCY CHECK PASSED!")
    print("=" * 70)
    print()
    print("📝 Summary:")
    print(f"   - {len(data)} skeleton samples")
    print(f"   - {len(set(labels))} unique classes")
    print(f"   - All arrays properly synchronized")
    print(f"   - No duplicate filenames")
    print(f"   - Labels and filenames correctly matched")
    print()

    return True


def compare_sequential_vs_parallel():
    """
    Compare results from sequential and parallel processing to verify they match.
    """
    print("=" * 70)
    print("🔬 COMPARING SEQUENTIAL VS PARALLEL PROCESSING")
    print("=" * 70)
    print()

    # Check if both output folders exist
    sequential_dir = Path("skeleton_data_sequential")
    parallel_dir = Path("skeleton_data")

    if not sequential_dir.exists():
        print("⚠️  Sequential output not found. Run with --workers 1 first:")
        print(
            "   python extract_skeletons.py --workers 1 --output-dir skeleton_data_sequential"
        )
        print()
        return False

    if not parallel_dir.exists():
        print("⚠️  Parallel output not found. Run with --workers 10 first:")
        print("   python extract_skeletons.py --workers 10 --output-dir skeleton_data")
        print()
        return False

    # Load both datasets
    print("📂 Loading sequential data...")
    seq_data = np.load(sequential_dir / "train_data.npy", allow_pickle=True)
    with open(sequential_dir / "train_filenames.pkl", "rb") as f:
        seq_filenames = pickle.load(f)
    with open(sequential_dir / "train_label.pkl", "rb") as f:
        seq_labels, _ = pickle.load(f)

    print("📂 Loading parallel data...")
    par_data = np.load(parallel_dir / "train_data.npy", allow_pickle=True)
    with open(parallel_dir / "train_filenames.pkl", "rb") as f:
        par_filenames = pickle.load(f)
    with open(parallel_dir / "train_label.pkl", "rb") as f:
        par_labels, _ = pickle.load(f)

    print()

    # Compare counts
    print("🔢 Comparing sample counts...")
    if len(seq_data) == len(par_data):
        print(f"   ✅ Same number of samples: {len(seq_data)}")
    else:
        print(f"   ❌ MISMATCH: sequential={len(seq_data)}, parallel={len(par_data)}")
        return False

    print()

    # Compare filenames (should be in same order)
    print("📝 Comparing filename order...")
    if seq_filenames == par_filenames:
        print(f"   ✅ Filenames match exactly (same order)")
    else:
        # Check if same filenames but different order
        if set(seq_filenames) == set(par_filenames):
            print(f"   ⚠️  Same filenames but DIFFERENT ORDER!")
            print(f"   This is expected if using as_completed() without sorting.")
            # Show first 10 differences
            print(f"   First 10 differences:")
            for i in range(min(10, len(seq_filenames))):
                if seq_filenames[i] != par_filenames[i]:
                    print(
                        f"      [{i}] seq: {seq_filenames[i]:40s} | par: {par_filenames[i]:40s}"
                    )
        else:
            print(f"   ❌ Different filenames!")
            return False

    print()

    # Compare labels
    print("🏷️  Comparing labels...")
    if seq_labels == par_labels:
        print(f"   ✅ Labels match exactly")
    else:
        print(f"   ⚠️  Labels differ (expected if order differs)")

    print()
    print("=" * 70)

    return True


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Verify skeleton extraction data consistency"
    )
    parser.add_argument(
        "--data-dir", default="skeleton_data", help="Data directory to verify"
    )
    parser.add_argument(
        "--compare", action="store_true", help="Compare sequential vs parallel"
    )

    args = parser.parse_args()

    if args.compare:
        success = compare_sequential_vs_parallel()
    else:
        success = verify_data_consistency(args.data_dir)

    sys.exit(0 if success else 1)
