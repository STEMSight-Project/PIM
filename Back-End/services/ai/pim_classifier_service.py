"""
PIM Movement Classifier Service
Business logic layer for movement classification
Self-contained service with integrated model loading and prediction
"""

import numpy as np
import torch
import torch.nn as nn
from typing import Dict, List, Tuple, Optional
from pathlib import Path
import sys
from datetime import datetime
import logging
from collections import OrderedDict
import math

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Add UNIK model path for importing Model class
UNIK_MODEL_PATH = Path(__file__).parent.parent.parent.parent / "AI_Training" / "UNIK"
sys.path.insert(0, str(UNIK_MODEL_PATH))


# ============================================================
# Configuration & Constants
# ============================================================


class PIMClassifierConfig:
    """Configuration for PIM classifier service"""

    # Model settings
    # Checkpoint from epoch 69 (best checkpoint: 83.27% validation accuracy)
    # Test set accuracy: 82.88% (evaluated on 520 samples)
    # Model is copied to services/ai folder for easy access
    MODEL_CHECKPOINT = UNIK_MODEL_PATH / "pim_unik_model_10class_new-69-18200.pt"
    MODEL_VERSION = "v2.0"  # New training on 300-frame data
    TRAINED_DATE = "2025-10-18"  # Training completion date

    # Performance metrics (from final evaluation on test set)
    OVERALL_ACCURACY = 82.88  # Test set accuracy (520 samples)
    PEAK_ACCURACY = 89.16  # Peak validation accuracy (epoch 71, checkpoint not saved)
    BEST_CHECKPOINT_ACCURACY = 83.27  # Epoch 69 validation accuracy

    # Movement classes with per-class accuracy (from test set evaluation)
    CLASS_METRICS = {
        "ballistic": {"accuracy": 80.70, "tier": "excellent", "id": 0},
        "chorea": {"accuracy": 78.95, "tier": "good", "id": 1},
        "decerebrate": {"accuracy": 79.31, "tier": "good", "id": 2},
        "decorticate": {"accuracy": 89.66, "tier": "excellent", "id": 3},
        "dystonia": {"accuracy": 84.48, "tier": "excellent", "id": 4},
        "fencer_posture": {"accuracy": 81.03, "tier": "excellent", "id": 5},
        "myoclonus": {"accuracy": 77.59, "tier": "good", "id": 6},
        "normal": {"accuracy": 74.58, "tier": "good", "id": 7},
        "tremor": {"accuracy": 92.98, "tier": "excellent", "id": 8},
        "versive_head": {"accuracy": 91.38, "tier": "excellent", "id": 9},
    }

    # Confidence thresholds
    HIGH_CONFIDENCE_THRESHOLD = 0.85
    MEDIUM_CONFIDENCE_THRESHOLD = 0.70
    LOW_CONFIDENCE_THRESHOLD = 0.50

    # Input validation
    EXPECTED_JOINTS = 33
    EXPECTED_COORDINATES = 3
    MIN_FRAMES = 30
    MAX_FRAMES = 300


# ============================================================
# Model Loading & Prediction Functions
# ============================================================


def load_trained_model(checkpoint_path: str) -> Tuple[torch.nn.Module, torch.device]:
    """
    Load the trained UNIK model

    Args:
        checkpoint_path: Path to model checkpoint file

    Returns:
        (model, device) tuple
    """
    logger.info(f"Loading trained model from: {checkpoint_path}")

    # Import Model class here to avoid import errors when module loads
    from model.classifier import Model

    # Initialize model architecture
    model = Model(
        num_class=10,  # 10 classes: normal + 9 PIM movement types
        num_joints=33,  # MediaPipe has 33 landmarks
        num_person=2,  # Always 2 (single person + padding)
        tau=1,
        num_heads=3,
        in_channels=3,  # x, y, visibility
        drop_out=0,
        backbone_fixed=False,
    )

    # Load trained weights
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    checkpoint = torch.load(checkpoint_path, map_location=device)
    model.load_state_dict(checkpoint)
    model = model.to(device)
    model.eval()  # Set to evaluation mode

    logger.info(f"✅ Model loaded successfully on {device}")
    return model, device


def prepare_skeleton_data(skeleton_sequence: np.ndarray) -> torch.Tensor:
    """
    Convert skeleton data to model input format

    Args:
        skeleton_sequence: Input skeleton data
            - Shape: (frames, joints, coords) e.g., (60, 33, 3)
            - Or: (C, T, V, M) e.g., (3, 60, 33, 1)

    Returns:
        Tensor of shape (1, 3, frames, 33, 2) ready for model
    """

    # Handle different input shapes
    if skeleton_sequence.ndim == 3:  # (frames, joints, coords)
        # Example: (60, 33, 3) -> need to transpose
        C, T, V = (
            skeleton_sequence.shape[2],
            skeleton_sequence.shape[0],
            skeleton_sequence.shape[1],
        )

        # Transpose to (C, T, V, M)
        data = skeleton_sequence.transpose(2, 0, 1)  # (3, 60, 33)
        data = data[:, :, :, np.newaxis]  # (3, 60, 33, 1)

        # Pad to 2 persons
        data = np.concatenate([data, np.zeros_like(data)], axis=3)  # (3, 60, 33, 2)

    elif skeleton_sequence.ndim == 4:  # Already in (C, T, V, M) format
        C, T, V, M = skeleton_sequence.shape
        if M == 1:
            # Pad to 2 persons
            data = np.concatenate(
                [skeleton_sequence, np.zeros_like(skeleton_sequence)], axis=3
            )
        else:
            data = skeleton_sequence

    else:
        raise ValueError(f"Unsupported data shape: {skeleton_sequence.shape}")

    # Convert to tensor and add batch dimension
    tensor = torch.FloatTensor(data).unsqueeze(0)  # (1, 3, T, 33, 2)

    return tensor


def predict_movement(
    model: torch.nn.Module,
    skeleton_data: np.ndarray,
    device: torch.device,
    return_all_probs: bool = False,
) -> Dict:
    """
    Predict movement type from skeleton sequence

    Args:
        model: Trained PyTorch model
        skeleton_data: Skeleton sequence array
        device: PyTorch device (cuda/cpu)
        return_all_probs: Whether to return probabilities for all classes

    Returns:
        Dictionary with 'class', 'confidence', and optionally 'all_probabilities'
    """

    # Class names (must match training order from label_mapping.pkl)
    # Training was done with alphabetically sorted label directories
    CLASSES = [
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

    # Prepare data
    input_tensor = prepare_skeleton_data(skeleton_data).to(device)

    # Make prediction
    with torch.no_grad():
        output = model(input_tensor)
        probabilities = torch.nn.functional.softmax(output, dim=1)
        confidence, prediction = torch.max(probabilities, dim=1)

    # Get results
    pred_class_idx = prediction.item()
    pred_class = CLASSES[pred_class_idx]
    pred_confidence = confidence.item()

    result = {
        "class": pred_class,
        "class_index": pred_class_idx,
        "confidence": pred_confidence,
    }

    if return_all_probs:
        all_probs = probabilities[0].cpu().numpy()
        result["all_probabilities"] = {
            cls: float(prob) for cls, prob in zip(CLASSES, all_probs)
        }

    return result


# ============================================================
# Data Models
# ============================================================


class MovementPrediction:
    """Structured prediction result"""

    def __init__(
        self,
        predicted_class: str,
        confidence: float,
        all_probabilities: Dict[str, float],
        tier: str,
        recommendation: str,
        model_accuracy: float,
        movement_id: int,
        timestamp: datetime = None,
        metadata: Dict = None,
    ):
        self.predicted_class = predicted_class
        self.confidence = confidence
        self.all_probabilities = all_probabilities
        self.tier = tier
        self.recommendation = recommendation
        self.model_accuracy = model_accuracy
        self.movement_id = movement_id
        self.timestamp = timestamp or datetime.now()
        self.metadata = metadata or {}

    def to_dict(self) -> Dict:
        """Convert to dictionary for API response"""
        return {
            "predicted_class": self.predicted_class,
            "confidence": self.confidence,
            "all_probabilities": self.all_probabilities,
            "tier": self.tier,
            "recommendation": self.recommendation,
            "model_accuracy": self.model_accuracy,
            "movement_id": self.movement_id,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata,
        }

    def to_db_record(self, video_id: int, patient_id: int) -> Dict:
        """Convert to database record format"""
        return {
            "video_id": video_id,
            "patient_id": patient_id,
            "movement_type": self.predicted_class,
            "movement_id": self.movement_id,
            "confidence_score": float(self.confidence),
            "model_accuracy": float(self.model_accuracy),
            "tier": self.tier,
            "recommendation": self.recommendation,
            "all_probabilities": self.all_probabilities,
            "requires_review": self.requires_review(),
            "detected_at": self.timestamp.isoformat(),
            "metadata": self.metadata,
        }

    def is_high_confidence(self) -> bool:
        """Check if prediction meets high confidence threshold"""
        return self.confidence >= PIMClassifierConfig.HIGH_CONFIDENCE_THRESHOLD

    def requires_review(self) -> bool:
        """Check if prediction requires manual review"""
        return (
            self.tier == "needs_review"
            or self.confidence < PIMClassifierConfig.MEDIUM_CONFIDENCE_THRESHOLD
        )


# ============================================================
# PIM Classifier Service
# ============================================================


class PIMClassifierService:
    """
    Service for PIM movement classification
    Handles model loading, prediction, validation, and result interpretation
    """

    def __init__(self, config: PIMClassifierConfig = None):
        """
        Initialize the classifier service

        Args:
            config: Configuration object (uses default if None)
        """
        self.config = config or PIMClassifierConfig()
        self.model = None
        self.device = None
        self.is_loaded = False
        self._prediction_count = 0

    def load_model(self, checkpoint_path: str = None) -> bool:
        """
        Load the trained model

        Args:
            checkpoint_path: Path to model checkpoint (uses config default if None)

        Returns:
            True if successful, False otherwise
        """
        try:
            model_path = checkpoint_path or str(self.config.MODEL_CHECKPOINT)
            logger.info(f"Loading PIM model from: {model_path}")

            self.model, self.device = load_trained_model(model_path)
            self.is_loaded = True

            logger.info(f"✅ Model loaded successfully on device: {self.device}")
            return True

        except Exception as e:
            logger.error(f"❌ Failed to load model: {str(e)}")
            self.is_loaded = False
            return False

    def validate_input(self, skeleton_data: np.ndarray) -> Tuple[bool, Optional[str]]:
        """
        Validate skeleton data input

        Args:
            skeleton_data: Numpy array of shape (frames, joints, coordinates)

        Returns:
            (is_valid, error_message)
        """
        # Check if numpy array
        if not isinstance(skeleton_data, np.ndarray):
            return False, "Input must be a numpy array"

        # Check dimensions
        if skeleton_data.ndim != 3:
            return (
                False,
                f"Expected 3D array (frames, joints, coords), got {skeleton_data.ndim}D",
            )

        frames, joints, coords = skeleton_data.shape

        # Validate joints
        if joints != self.config.EXPECTED_JOINTS:
            return False, f"Expected {self.config.EXPECTED_JOINTS} joints, got {joints}"

        # Validate coordinates
        if coords != self.config.EXPECTED_COORDINATES:
            return (
                False,
                f"Expected {self.config.EXPECTED_COORDINATES} coordinates, got {coords}",
            )

        # Validate frame count
        if frames < self.config.MIN_FRAMES:
            return (
                False,
                f"Too few frames: {frames} (minimum: {self.config.MIN_FRAMES})",
            )

        if frames > self.config.MAX_FRAMES:
            return (
                False,
                f"Too many frames: {frames} (maximum: {self.config.MAX_FRAMES})",
            )

        # Check for NaN or Inf values
        if np.isnan(skeleton_data).any():
            return False, "Input contains NaN values"

        if np.isinf(skeleton_data).any():
            return False, "Input contains infinite values"

        return True, None

    def _determine_tier_and_recommendation(
        self, predicted_class: str, confidence: float
    ) -> Tuple[str, str]:
        """
        Determine prediction tier and recommendation

        Args:
            predicted_class: The predicted movement class
            confidence: Prediction confidence score

        Returns:
            (tier, recommendation)
        """
        class_info = self.config.CLASS_METRICS.get(predicted_class, {})
        model_accuracy = class_info.get("accuracy", 0)
        tier = class_info.get("tier", "unknown")

        # High confidence + excellent tier
        if tier == "excellent" and confidence >= self.config.HIGH_CONFIDENCE_THRESHOLD:
            return "excellent", (
                f"High confidence prediction (≥{self.config.HIGH_CONFIDENCE_THRESHOLD:.0%}). "
                f"Model accuracy: {model_accuracy:.1f}%. Clinically ready for deployment."
            )

        # Good tier with adequate confidence
        elif tier == "good" and confidence >= self.config.MEDIUM_CONFIDENCE_THRESHOLD:
            return "good", (
                f"Good prediction with {confidence:.1%} confidence. "
                f"Model accuracy: {model_accuracy:.1f}%. Recommend physician review for confirmation."
            )

        # Low accuracy classes
        elif tier == "needs_review":
            return "needs_review", (
                f"⚠️ This class has lower accuracy ({model_accuracy:.1f}%). "
                f"Requires physician confirmation. Consider collecting more training data."
            )

        # Low confidence predictions
        elif confidence < self.config.MEDIUM_CONFIDENCE_THRESHOLD:
            return "needs_review", (
                f"⚠️ Low confidence prediction ({confidence:.1%}). "
                f"Manual review required before clinical use."
            )

        # Default case
        else:
            return "good", (
                f"Moderate confidence prediction. "
                f"Physician review recommended before final diagnosis."
            )

    def predict(
        self, skeleton_data: np.ndarray, metadata: Dict = None
    ) -> MovementPrediction:
        """
        Predict movement class from skeleton data

        Args:
            skeleton_data: Numpy array of shape (frames, 33, 3)
            metadata: Optional metadata (patient_id, recording_id, etc.)

        Returns:
            MovementPrediction object

        Raises:
            ValueError: If input validation fails
            RuntimeError: If model not loaded
        """
        # Check if model is loaded
        if not self.is_loaded:
            raise RuntimeError("Model not loaded. Call load_model() first.")

        # Validate input
        is_valid, error_msg = self.validate_input(skeleton_data)
        if not is_valid:
            raise ValueError(f"Invalid input: {error_msg}")

        # Make prediction
        try:
            result = predict_movement(
                self.model, skeleton_data, self.device, return_all_probs=True
            )

            predicted_class = result["class"]
            confidence = result["confidence"]
            all_probs = result["all_probabilities"]

            # Get class info
            class_info = self.config.CLASS_METRICS.get(predicted_class, {})
            model_accuracy = class_info.get("accuracy", 0)
            movement_id = class_info.get("id", 0)

            # Determine tier and recommendation
            tier, recommendation = self._determine_tier_and_recommendation(
                predicted_class, confidence
            )

            # Increment counter
            self._prediction_count += 1

            # Create prediction object
            prediction = MovementPrediction(
                predicted_class=predicted_class,
                confidence=confidence,
                all_probabilities=all_probs,
                tier=tier,
                recommendation=recommendation,
                model_accuracy=model_accuracy,
                movement_id=movement_id,
                metadata=metadata or {},
            )

            logger.info(
                f"Prediction #{self._prediction_count}: {predicted_class} "
                f"({confidence:.1%}) - Tier: {tier}"
            )

            return prediction

        except Exception as e:
            logger.error(f"Prediction error: {str(e)}")
            raise RuntimeError(f"Prediction failed: {str(e)}")

    def predict_batch(
        self, skeleton_data_list: List[np.ndarray], metadata_list: List[Dict] = None
    ) -> List[MovementPrediction]:
        """
        Predict movement classes for multiple sequences

        Args:
            skeleton_data_list: List of skeleton data arrays
            metadata_list: Optional list of metadata dicts

        Returns:
            List of MovementPrediction objects
        """
        if metadata_list is None:
            metadata_list = [{}] * len(skeleton_data_list)

        predictions = []

        for i, (data, meta) in enumerate(zip(skeleton_data_list, metadata_list)):
            try:
                prediction = self.predict(data, meta)
                predictions.append(prediction)
            except Exception as e:
                logger.error(f"Batch prediction failed for item {i}: {str(e)}")
                # Continue with other predictions
                continue

        logger.info(
            f"Batch prediction complete: {len(predictions)}/{len(skeleton_data_list)} successful"
        )

        return predictions

    def get_top_k_predictions(
        self, skeleton_data: np.ndarray, k: int = 3, metadata: Dict = None
    ) -> List[Tuple[str, float]]:
        """
        Get top-k most likely movement classes

        Args:
            skeleton_data: Skeleton data array
            k: Number of top predictions to return
            metadata: Optional metadata

        Returns:
            List of (class_name, probability) tuples sorted by probability
        """
        prediction = self.predict(skeleton_data, metadata)

        # Sort by probability
        sorted_probs = sorted(
            prediction.all_probabilities.items(), key=lambda x: x[1], reverse=True
        )

        return sorted_probs[:k]

    def get_model_info(self) -> Dict:
        """Get information about the loaded model"""
        return {
            "model_name": "UNIK Transformer",
            "architecture": "Attention-based Skeleton Action Recognition",
            "version": self.config.MODEL_VERSION,
            "trained_date": self.config.TRAINED_DATE,
            "checkpoint": str(self.config.MODEL_CHECKPOINT),
            "performance": {
                "overall_accuracy": f"{self.config.OVERALL_ACCURACY:.2f}%",
                "peak_accuracy": f"{self.config.PEAK_ACCURACY:.2f}%",
            },
            "classes": self.config.CLASS_METRICS,
            "input_requirements": {
                "frames": f"{self.config.MIN_FRAMES}-{self.config.MAX_FRAMES}",
                "joints": self.config.EXPECTED_JOINTS,
                "coordinates": self.config.EXPECTED_COORDINATES,
                "format": "(frames, joints, coordinates) with coordinates=[x, y, visibility]",
            },
            "device": str(self.device) if self.device else "Not loaded",
            "is_loaded": self.is_loaded,
            "predictions_made": self._prediction_count,
        }

    def get_health_status(self) -> Dict:
        """Get service health status"""
        return {
            "status": "healthy" if self.is_loaded else "not_ready",
            "model_loaded": self.is_loaded,
            "device": str(self.device) if self.device else None,
            "predictions_made": self._prediction_count,
            "config": {
                "model_checkpoint": str(self.config.MODEL_CHECKPOINT),
                "version": self.config.MODEL_VERSION,
            },
        }

    def reload_model(self, new_checkpoint_path: str = None) -> bool:
        """
        Reload model (useful when retraining with more data)

        Args:
            new_checkpoint_path: Path to new checkpoint

        Returns:
            True if successful
        """
        logger.info("Reloading model...")

        # Reset state
        self.model = None
        self.device = None
        self.is_loaded = False

        # Clear GPU cache
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

        # Load new model
        success = self.load_model(new_checkpoint_path)

        if success:
            logger.info("✅ Model reloaded successfully")
            self._prediction_count = 0  # Reset counter

        return success


# ============================================================
# Singleton Instance
# ============================================================

# Create a singleton instance for use across the application
_classifier_service = None


def get_classifier_service() -> PIMClassifierService:
    """
    Get the singleton classifier service instance
    Lazy initialization on first call
    """
    global _classifier_service

    if _classifier_service is None:
        logger.info("Initializing PIM Classifier Service...")
        _classifier_service = PIMClassifierService()
        _classifier_service.load_model()

    return _classifier_service


# ============================================================
# Convenience Functions
# ============================================================


def classify_movement(
    skeleton_data: np.ndarray, metadata: Dict = None
) -> MovementPrediction:
    """
    Convenience function for single prediction
    Uses singleton service instance
    """
    service = get_classifier_service()
    return service.predict(skeleton_data, metadata)


def classify_batch(
    skeleton_data_list: List[np.ndarray], metadata_list: List[Dict] = None
) -> List[MovementPrediction]:
    """
    Convenience function for batch prediction
    Uses singleton service instance
    """
    service = get_classifier_service()
    return service.predict_batch(skeleton_data_list, metadata_list)
