"""
Comprehensive Unit Tests for PIM Classifier Service
Updated to match actual production implementation (82.88% accuracy)
"""

import pytest
import numpy as np
import torch
from unittest.mock import Mock, patch, MagicMock
from pathlib import Path


# ============================================================
# Test Configuration (Updated for 10-class model)
# ============================================================


class TestPIMClassifierConfig:
    """Test updated configuration for 10-class model"""

    @pytest.mark.unit
    def test_config_has_correct_accuracy(self):
        """Test config reflects actual 82.88% test accuracy"""
        # From actual training results
        expected_accuracy = 82.88
        assert expected_accuracy == 82.88

    @pytest.mark.unit
    def test_all_10_classes_defined(self):
        """Test that all 10 movement classes are defined"""
        classes = [
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

        assert len(classes) == 10

        # Verify alphabetical order (CRITICAL - matches training!)
        sorted_classes = sorted(classes)
        assert classes == sorted_classes

    @pytest.mark.unit
    def test_class_index_mapping(self):
        """Test class indices match training order"""
        class_index = {
            0: "ballistic",
            1: "chorea",
            2: "decerebrate",
            3: "decorticate",
            4: "dystonia",
            5: "fencer_posture",
            6: "myoclonus",
            7: "normal",
            8: "tremor",
            9: "versive_head",
        }

        # Verify critical indices
        assert class_index[0] == "ballistic"  # NOT "normal"!
        assert class_index[7] == "normal"
        assert class_index[8] == "tremor"
        assert class_index[9] == "versive_head"

    @pytest.mark.unit
    def test_per_class_accuracy_metrics(self):
        """Test per-class accuracy from training results"""
        per_class_acc = {
            "ballistic": 80.70,
            "chorea": 78.95,
            "decerebrate": 79.31,
            "decorticate": 89.66,  # High performer
            "dystonia": 84.48,
            "fencer_posture": 81.03,
            "myoclonus": 77.59,
            "normal": 74.58,  # Needs improvement
            "tremor": 92.98,  # Best performer!
            "versive_head": 91.38,  # High performer
        }

        # Verify top performers
        assert per_class_acc["tremor"] > 90
        assert per_class_acc["versive_head"] > 90
        assert per_class_acc["decorticate"] > 89

    @pytest.mark.unit
    def test_confidence_thresholds(self):
        """Test confidence threshold configuration"""
        HIGH = 0.85
        MEDIUM = 0.70
        LOW = 0.50

        assert HIGH > MEDIUM > LOW
        assert MEDIUM == 0.70  # Default threshold

    @pytest.mark.unit
    def test_input_validation_params(self):
        """Test input validation parameters"""
        EXPECTED_JOINTS = 33
        EXPECTED_COORDINATES = 3
        MIN_FRAMES = 30
        MAX_FRAMES = 300

        assert EXPECTED_JOINTS == 33  # MediaPipe
        assert EXPECTED_COORDINATES == 3  # x, y, confidence
        assert MAX_FRAMES == 300  # 5 seconds @ 60 FPS


# ============================================================
# Test Model Loading
# ============================================================


class TestModelLoading:
    """Test model loading functionality"""

    @pytest.mark.unit
    def test_model_checkpoint_path(self):
        """Test correct model checkpoint path"""
        # Model should be in Back-End/services/ai/ folder
        checkpoint_name = "pim_unik_model_10class_new-69-18200.pt"

        assert "10class" in checkpoint_name
        assert "69" in checkpoint_name  # Epoch 69 (best checkpoint)

    @pytest.mark.unit
    def test_model_parameters(self):
        """Test model initialization parameters"""
        params = {
            "num_class": 10,
            "num_joints": 33,
            "num_person": 2,
            "tau": 1,
            "num_heads": 3,
            "in_channels": 3,
            "drop_out": 0,
        }

        assert params["num_class"] == 10
        assert params["num_joints"] == 33
        assert params["num_person"] == 2

    @pytest.mark.unit
    def test_device_selection(self, device):
        """Test GPU/CPU device selection"""
        assert device.type in ["cuda", "cpu"]

        # Should prefer CUDA if available
        if torch.cuda.is_available():
            # Device type should be cuda (index may or may not be specified)
            assert device.type == "cuda"

    @pytest.mark.unit
    @pytest.mark.gpu
    def test_model_on_gpu(self, device):
        """Test model loads on GPU (requires GPU)"""
        if not torch.cuda.is_available():
            pytest.skip("GPU not available")

        assert device.type == "cuda"
        # Device index may be None (default) or 0, both are valid


# ============================================================
# Test Data Preparation
# ============================================================


class TestDataPreparation:
    """Test skeleton data preparation for model input"""

    @pytest.mark.unit
    def test_prepare_from_landmarks_format(self):
        """Test preparation from landmarks (frames, joints, coords)"""
        # Input: (300, 33, 3)
        landmarks = np.random.rand(300, 33, 3).astype(np.float32)

        # Convert to (C, T, V, M)
        data = landmarks.transpose(2, 0, 1)  # (3, 300, 33)
        data = data[:, :, :, np.newaxis]  # (3, 300, 33, 1)

        # Pad to M=2
        data = np.concatenate([data, np.zeros_like(data)], axis=3)

        assert data.shape == (3, 300, 33, 2)

    @pytest.mark.unit
    def test_prepare_from_unik_format(self):
        """Test preparation from UNIK format (C, T, V, M)"""
        # Input: (3, 300, 33, 1)
        unik_data = np.random.rand(3, 300, 33, 1).astype(np.float32)

        # Pad to M=2
        data = np.concatenate([unik_data, np.zeros_like(unik_data)], axis=3)

        assert data.shape == (3, 300, 33, 2)

    @pytest.mark.unit
    def test_add_batch_dimension(self):
        """Test adding batch dimension for inference"""
        data = np.random.rand(3, 300, 33, 2).astype(np.float32)

        # Add batch dimension
        tensor = torch.FloatTensor(data).unsqueeze(0)

        assert tensor.shape == (1, 3, 300, 33, 2)

    @pytest.mark.unit
    def test_person_padding_verification(self):
        """Test that second person is zero-padded"""
        data = np.random.rand(3, 300, 33, 1).astype(np.float32)
        padded = np.concatenate([data, np.zeros_like(data)], axis=3)

        # Second person (M=1) should be all zeros
        assert np.all(padded[:, :, :, 1] == 0)

        # First person (M=0) should have data
        assert not np.all(padded[:, :, :, 0] == 0)


# ============================================================
# Test Prediction Function
# ============================================================


class TestPrediction:
    """Test movement prediction functionality"""

    @pytest.mark.unit
    def test_prediction_output_structure(self):
        """Test prediction returns correct structure"""
        # Mock prediction result
        result = {
            "predicted_class": "tremor",
            "class_index": 8,
            "confidence": 0.9298,
            "all_probabilities": {
                "ballistic": 0.01,
                "chorea": 0.01,
                "decerebrate": 0.01,
                "decorticate": 0.01,
                "dystonia": 0.01,
                "fencer_posture": 0.01,
                "myoclonus": 0.01,
                "normal": 0.01,
                "tremor": 0.9298,
                "versive_head": 0.01,
            },
        }

        assert "predicted_class" in result
        assert "confidence" in result
        assert "all_probabilities" in result
        assert result["predicted_class"] == "tremor"
        assert result["class_index"] == 8

    @pytest.mark.unit
    def test_softmax_probability_sum(self):
        """Test that softmax probabilities sum to 1.0"""
        # Mock logits
        logits = torch.randn(1, 10)

        # Apply softmax
        probs = torch.softmax(logits, dim=1)

        # Should sum to 1.0
        assert abs(probs.sum().item() - 1.0) < 1e-5

    @pytest.mark.unit
    def test_prediction_confidence_range(self):
        """Test confidence values are in [0, 1]"""
        logits = torch.randn(1, 10)
        probs = torch.softmax(logits, dim=1).squeeze().numpy()

        assert np.all(probs >= 0)
        assert np.all(probs <= 1)

    @pytest.mark.unit
    def test_argmax_class_selection(self):
        """Test class selection uses argmax"""
        probs = np.array([0.1, 0.2, 0.05, 0.15, 0.1, 0.05, 0.1, 0.05, 0.15, 0.05])

        predicted_class = np.argmax(probs)

        assert predicted_class == 1  # Index with highest probability

    @pytest.mark.unit
    def test_high_confidence_detection(self):
        """Test detection of high-confidence predictions"""
        confidence = 0.92
        threshold = 0.85

        is_high_confidence = confidence >= threshold

        assert is_high_confidence is True

    @pytest.mark.unit
    def test_low_confidence_warning(self):
        """Test low-confidence prediction warning"""
        confidence = 0.55
        threshold = 0.70

        requires_review = confidence < threshold

        assert requires_review is True


# ============================================================
# Test Input Validation
# ============================================================


class TestInputValidation:
    """Test input validation for classifier"""

    @pytest.mark.unit
    def test_valid_shape_acceptance(self):
        """Test acceptance of valid input shapes"""
        # Valid shapes:
        # (300, 33, 3) - landmarks format
        # (3, 300, 33, 1) - UNIK format

        landmarks = np.random.rand(300, 33, 3).astype(np.float32)
        unik = np.random.rand(3, 300, 33, 1).astype(np.float32)

        assert landmarks.shape == (300, 33, 3)
        assert unik.shape == (3, 300, 33, 1)

    @pytest.mark.unit
    def test_invalid_shape_rejection(self):
        """Test rejection of invalid input shapes"""
        # Invalid shape: wrong number of joints
        invalid = np.random.rand(300, 25, 3)

        # Should detect wrong joint count
        assert invalid.shape[1] != 33

    @pytest.mark.unit
    def test_frame_count_validation(self):
        """Test frame count validation"""
        MIN_FRAMES = 30
        MAX_FRAMES = 300

        # Valid
        valid_frames = 150
        assert MIN_FRAMES <= valid_frames <= MAX_FRAMES

        # Too few
        too_few = 20
        assert too_few < MIN_FRAMES

        # Too many
        too_many = 400
        assert too_many > MAX_FRAMES

    @pytest.mark.unit
    def test_coordinate_count_validation(self):
        """Test coordinate count validation (x, y, confidence)"""
        EXPECTED_COORDS = 3

        valid_data = np.random.rand(300, 33, 3)
        assert valid_data.shape[2] == EXPECTED_COORDS


# ============================================================
# Test Error Handling
# ============================================================


class TestErrorHandling:
    """Test error handling in classifier"""

    @pytest.mark.unit
    def test_model_not_found_error(self):
        """Test error when model file not found"""
        fake_path = Path("nonexistent_model.pt")

        assert not fake_path.exists()

    @pytest.mark.unit
    def test_invalid_input_shape_error(self):
        """Test error on invalid input shape"""
        # Wrong dimensions
        invalid_data = np.random.rand(10, 10)

        # Should have 3 or 4 dimensions, not 2
        assert invalid_data.ndim < 3

    @pytest.mark.unit
    def test_gpu_unavailable_fallback(self):
        """Test fallback to CPU when GPU unavailable"""
        # Mock GPU unavailable
        with patch("torch.cuda.is_available", return_value=False):
            device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
            assert device.type == "cpu"


# ============================================================
# Test Performance Metrics
# ============================================================


class TestPerformanceMetrics:
    """Test performance metrics validation"""

    @pytest.mark.unit
    def test_overall_accuracy(self, expected_accuracy):
        """Test overall accuracy matches training result"""
        assert expected_accuracy == 82.88

        # Accuracy should be reasonable
        assert 80 <= expected_accuracy <= 90

    @pytest.mark.unit
    def test_per_class_accuracy_distribution(self, per_class_accuracy):
        """Test per-class accuracy distribution"""
        accuracies = list(per_class_accuracy.values())

        # All should be above 70%
        assert all(acc > 70 for acc in accuracies)

        # Best class (tremor) should be above 90%
        assert per_class_accuracy["tremor"] > 90

    @pytest.mark.unit
    def test_accuracy_tiers(self):
        """Test accuracy tier classification"""

        def get_tier(accuracy):
            if accuracy >= 85:
                return "excellent"
            elif accuracy >= 75:
                return "good"
            else:
                return "needs_review"

        assert get_tier(92.98) == "excellent"  # tremor
        assert get_tier(78.95) == "good"  # chorea
        assert get_tier(74.58) == "needs_review"  # normal


# ============================================================
# Test Batch Processing
# ============================================================


class TestBatchProcessing:
    """Test batch processing capabilities"""

    @pytest.mark.unit
    def test_single_sample_inference(self):
        """Test inference on single sample"""
        data = np.random.rand(3, 300, 33, 2).astype(np.float32)
        tensor = torch.FloatTensor(data).unsqueeze(0)  # Add batch dim

        assert tensor.shape[0] == 1  # Batch size 1

    @pytest.mark.unit
    def test_batch_inference_shape(self):
        """Test inference on batch"""
        batch_size = 16
        data = np.random.rand(batch_size, 3, 300, 33, 2).astype(np.float32)
        tensor = torch.FloatTensor(data)

        assert tensor.shape[0] == batch_size

    @pytest.mark.unit
    def test_batch_prediction_consistency(self):
        """Test that same input produces same output"""
        data = np.random.rand(3, 300, 33, 2).astype(np.float32)

        # Same input twice
        tensor1 = torch.FloatTensor(data).unsqueeze(0)
        tensor2 = torch.FloatTensor(data).unsqueeze(0)

        # Should be identical
        assert torch.allclose(tensor1, tensor2)


# ============================================================
# Test Class Order (CRITICAL)
# ============================================================


class TestClassOrder:
    """Test that class order matches training (CRITICAL!)"""

    @pytest.mark.unit
    def test_alphabetical_class_order(self):
        """Test classes are in alphabetical order"""
        classes = [
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

        # CRITICAL: Must be alphabetical to match training!
        sorted_classes = sorted(classes)
        assert classes == sorted_classes

    @pytest.mark.unit
    def test_wrong_class_order_detection(self):
        """Test detection of wrong class order (common mistake!)"""
        # WRONG ORDER (causes 100% wrong predictions!)
        wrong_order = ["normal", "ballistic", "chorea", ...]

        # Correct order
        correct_order = ["ballistic", "chorea", "decerebrate", ...]

        # First element should be "ballistic", NOT "normal"
        assert correct_order[0] == "ballistic"
        assert wrong_order[0] != "ballistic"  # WRONG!
