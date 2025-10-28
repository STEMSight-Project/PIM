"""
Quick test to see what the model predicts on a known video
"""

import sys
from pathlib import Path
import io

# Force UTF-8 encoding for Windows console
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

# Add backend path
BACKEND_PATH = Path(__file__).parent.parent / "Back-End"
sys.path.insert(0, str(BACKEND_PATH))

from services.ai import get_classifier_service
import numpy as np

# Initialize classifier
print("Loading classifier...")
classifier = get_classifier_service()

# Load a test sample
print("\nLoading test data...")
test_data_path = (
    Path(__file__).parent.parent
    / "AI_Training"
    / "skeleton_data"
    / "train_data_test.npy"
)
test_label_path = (
    Path(__file__).parent.parent
    / "AI_Training"
    / "skeleton_data"
    / "train_label_test.pkl"
)

import pickle

data = np.load(test_data_path)
with open(test_label_path, "rb") as f:
    filenames, labels = pickle.load(f)

print(f"Loaded {len(labels)} test samples")
print(f"Data shape: {data.shape}")

# Test on first 10 samples from each class
label_names = [
    "ballistic",
    "chorea",
    "decerebrate",
    "decorticate",
    "dystonia",
    "fencer_posture",
    "myoclonus",
    "normal",
    "tremor",
    "versive_head",
]

print("\n" + "=" * 70)
print("TESTING MODEL PREDICTIONS")
print("=" * 70)

# Group samples by class
from collections import defaultdict

samples_by_class = defaultdict(list)
for idx, label in enumerate(labels):
    samples_by_class[label].append(idx)

correct = 0
total = 0
errors_by_class = defaultdict(list)

# Test 5 samples per class
for class_idx in range(10):
    class_name = label_names[class_idx]
    sample_indices = samples_by_class[class_idx][:5]  # First 5 samples

    print(f"\n{class_name.upper()} (testing {len(sample_indices)} samples):")

    for sample_idx in sample_indices:
        skeleton = data[sample_idx]  # Shape: (3, 300, 33, 1)
        filename = filenames[sample_idx]

        # Remove person dimension for classifier (expects (T, V, 3))
        # Current: (3, 300, 33, 1) -> Need: (300, 33, 3)
        skeleton_transposed = skeleton.squeeze(-1).transpose(1, 2, 0)  # (300, 33, 3)

        try:
            prediction = classifier.predict(skeleton_transposed)
            predicted_class = prediction.predicted_class
            confidence = prediction.confidence

            is_correct = predicted_class == class_name
            correct += is_correct
            total += 1

            status = "✅" if is_correct else "❌"
            print(
                f"  {status} {filename[:40]:40} -> {predicted_class:15} ({confidence:.1%})"
            )

            if not is_correct:
                errors_by_class[class_name].append(
                    {
                        "file": filename,
                        "predicted": predicted_class,
                        "confidence": confidence,
                    }
                )

        except Exception as e:
            print(f"  ⚠️  Error: {e}")
            total += 1

print("\n" + "=" * 70)
print(f"ACCURACY: {correct}/{total} = {correct/total*100:.2f}%")
print("=" * 70)

if errors_by_class:
    print("\nCOMMON ERRORS:")
    for true_class, errors in errors_by_class.items():
        print(f"\n{true_class}:")
        for error in errors:
            print(f"  -> {error['predicted']} ({error['confidence']:.1%})")
