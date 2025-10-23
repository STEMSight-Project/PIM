"""
Evaluate the best trained model on test data
Usage: python evaluate_best_model.py --checkpoint pim_unik_model-84-1298.pt
"""

import argparse
import pickle
import numpy as np
import torch
from torch.autograd import Variable
from tqdm import tqdm

# Import your model architecture
import sys

sys.path.append(".")
from model.classifier import Model


def load_model(checkpoint_path, num_class=10, num_joints=33):  # Changed from 9 to 10
    """Load the trained model from checkpoint"""
    # Initialize model
    model = Model(
        num_class=num_class,
        num_joints=num_joints,
        num_person=2,
        tau=1,
        num_heads=3,
        in_channels=3,
        drop_out=0,
        backbone_fixed=False,
    )

    # Load weights
    print(f"Loading checkpoint: {checkpoint_path}")
    checkpoint = torch.load(checkpoint_path, weights_only=False)
    model.load_state_dict(checkpoint)

    # Move to GPU if available
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    model.eval()

    print(f"Model loaded successfully on {device}")
    return model, device


def load_data(data_path, label_path):
    """Load test data"""
    print(f"Loading data from {data_path}")
    data = np.load(data_path, mmap_mode="r")

    print(f"Loading labels from {label_path}")
    with open(label_path, "rb") as f:
        label_info = pickle.load(f)

    # Handle different label formats
    if isinstance(label_info, tuple):
        if len(label_info) == 2:
            # Check if it's (labels, count) or (filenames, labels)
            if isinstance(label_info[1], int):
                # Format: (labels, count)
                labels = label_info[0]
                filenames = None
                print(f"Found {label_info[1]} labels (old format)")
            else:
                # Format: (filenames, labels)
                filenames, labels = label_info
                print(f"Found {len(filenames)} files with {len(labels)} labels")
        else:
            labels = label_info[0]
            filenames = None
    else:
        labels = label_info
        filenames = None

    print(f"Data shape: {data.shape}")
    print(f"Number of samples: {len(labels)}")

    return data, labels


def load_label_mapping(mapping_path):
    """Load label mapping to get correct class names"""
    try:
        with open(mapping_path, "rb") as f:
            mapping = pickle.load(f)

        if isinstance(mapping, dict) and "idx_to_label" in mapping:
            idx_to_label = mapping["idx_to_label"]
            class_names = [idx_to_label[i] for i in sorted(idx_to_label.keys())]
            print(f"\nLoaded class mapping from {mapping_path}:")
            for idx, name in enumerate(class_names):
                print(f"   {idx}: {name}")
            return class_names
    except FileNotFoundError:
        print(f"⚠️  Label mapping not found at {mapping_path}, using default order")
    except Exception as e:
        print(f"⚠️  Error loading label mapping: {e}")

    return None


def evaluate(model, data, labels, device, batch_size=16):
    """Evaluate model on test data"""
    num_samples = len(labels)
    num_batches = (num_samples + batch_size - 1) // batch_size

    all_predictions = []
    all_labels = []
    all_confidences = []

    print(f"\nEvaluating on {num_samples} samples...")
    print(f"Data shape: {data.shape}")

    # Check if we need to pad the person dimension
    if data.shape[-1] == 1:
        print(f"⚠️  Padding data from M=1 to M=2 (adding dummy person)...")
        # Pad with zeros to match training (M=2)
        padding = np.zeros(
            (data.shape[0], data.shape[1], data.shape[2], data.shape[3], 1)
        )
        data = np.concatenate([data, padding], axis=-1)
        print(f"   New data shape: {data.shape}")

    with torch.no_grad():
        for i in tqdm(range(num_batches)):
            start_idx = i * batch_size
            end_idx = min((i + 1) * batch_size, num_samples)

            # Get batch
            batch_data = data[start_idx:end_idx]
            batch_labels = labels[start_idx:end_idx]

            # Convert to tensor (copy to make it writable)
            batch_data = torch.FloatTensor(np.array(batch_data)).to(device)

            # Forward pass
            outputs = model(batch_data)

            # Get predictions
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            confidences, predictions = torch.max(probabilities, dim=1)

            # Store results
            all_predictions.extend(predictions.cpu().numpy())
            all_labels.extend(batch_labels)
            all_confidences.extend(confidences.cpu().numpy())

    return np.array(all_predictions), np.array(all_labels), np.array(all_confidences)


def calculate_metrics(predictions, labels, confidences, class_names=None):
    """Calculate detailed metrics"""
    if class_names is None:
        # Order matches training label_mapping.pkl:
        # {'ballistic': 0, 'chorea': 1, 'decerebrate': 2, 'decorticate': 3,
        #  'dystonia': 4, 'fencer_posture': 5, 'myoclonus': 6, 'normal': 7,
        #  'tremor': 8, 'versive_head': 9}
        class_names = [
            "ballistic",  # 0
            "chorea",  # 1
            "decerebrate",  # 2
            "decorticate",  # 3
            "dystonia",  # 4
            "fencer_posture",  # 5
            "myoclonus",  # 6
            "normal",  # 7
            "tremor",  # 8
            "versive_head",  # 9
        ]

    num_classes = len(class_names)

    # Overall accuracy
    correct = (predictions == labels).sum()
    total = len(labels)
    accuracy = correct / total * 100

    print(f"\n{'='*60}")
    print(f"OVERALL PERFORMANCE")
    print(f"{'='*60}")
    print(f"Total Samples: {total}")
    print(f"Correct: {correct}")
    print(f"Accuracy: {accuracy:.2f}%")
    print(f"Average Confidence: {confidences.mean():.4f}")

    # Per-class metrics
    print(f"\n{'='*60}")
    print(f"PER-CLASS PERFORMANCE")
    print(f"{'='*60}")
    print(
        f"{'Class':<20} {'Samples':<10} {'Correct':<10} {'Accuracy':<10} {'Conf':<10}"
    )
    print(f"{'-'*60}")

    for i, class_name in enumerate(class_names):
        class_mask = labels == i
        class_samples = class_mask.sum()

        if class_samples > 0:
            class_correct = ((predictions == labels) & class_mask).sum()
            class_accuracy = class_correct / class_samples * 100
            class_confidence = confidences[class_mask].mean()

            print(
                f"{class_name:<20} {class_samples:<10} {class_correct:<10} "
                f"{class_accuracy:<10.2f} {class_confidence:<10.4f}"
            )

    # Confusion insights
    print(f"\n{'='*60}")
    print(f"COMMON MISCLASSIFICATIONS")
    print(f"{'='*60}")

    misclassified = predictions != labels
    if misclassified.sum() > 0:
        for true_class in range(num_classes):
            true_mask = (labels == true_class) & misclassified
            if true_mask.sum() > 0:
                pred_classes, counts = np.unique(
                    predictions[true_mask], return_counts=True
                )
                for pred_class, count in zip(pred_classes, counts):
                    if count > 1:  # Only show if happened more than once
                        print(
                            f"  {class_names[true_class]} → {class_names[pred_class]}: {count} times"
                        )

    return accuracy


def main():
    parser = argparse.ArgumentParser(description="Evaluate trained UNIK model")
    parser.add_argument(
        "--checkpoint",
        type=str,
        default="./pim_unik_model_10class_new-79-20800.pt",  # Updated to 10-class model
        help="Path to model checkpoint",
    )
    parser.add_argument(
        "--data",
        type=str,
        default="../skeleton_data/train_data_test.npy",
        help="Path to test data",
    )
    parser.add_argument(
        "--labels",
        type=str,
        default="../skeleton_data/train_label_test.pkl",
        help="Path to test labels",
    )
    parser.add_argument(
        "--batch_size", type=int, default=16, help="Batch size for evaluation"
    )
    parser.add_argument(
        "--num_class", type=int, default=10, help="Number of classes (default: 10)"
    )

    args = parser.parse_args()

    # Load model with specified number of classes
    model, device = load_model(args.checkpoint, num_class=args.num_class)

    # Load data
    data, labels = load_data(args.data, args.labels)

    # Try to load label mapping for correct class names
    label_mapping_path = args.labels.replace("train_label.pkl", "label_mapping.pkl")
    class_names = load_label_mapping(label_mapping_path)

    # Evaluate
    predictions, true_labels, confidences = evaluate(
        model, data, labels, device, args.batch_size
    )

    # Calculate metrics (will use loaded class names if available)
    accuracy = calculate_metrics(predictions, true_labels, confidences, class_names)

    # Save results
    results = {
        "predictions": predictions,
        "labels": true_labels,
        "confidences": confidences,
        "accuracy": accuracy,
    }

    output_file = "evaluation_results.pkl"
    with open(output_file, "wb") as f:
        pickle.dump(results, f)

    print(f"\n✅ Results saved to {output_file}")


if __name__ == "__main__":
    main()
