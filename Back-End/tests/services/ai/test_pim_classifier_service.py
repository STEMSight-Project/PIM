"""
Pytest tests for PIM Classifier Service
Tests model loading, prediction, validation, and error handling
"""

import pytest
import numpy as np
from unittest.mock import Mock, patch, MagicMock
from services.ai.pim_classifier_service import (
    PIMClassifierService,
    PIMClassifierConfig,
    MovementPrediction,
    get_classifier_service,
)


class TestPIMClassifierConfig:
    """Test configuration class"""

    def test_config_defaults(self):
        """Test that config has all required attributes"""
        config = PIMClassifierConfig()

        assert config.OVERALL_ACCURACY == 82.88  # Updated for 10-class model
        assert config.PEAK_ACCURACY == 89.16  # Updated for 10-class model
        assert config.EXPECTED_JOINTS == 33
        assert config.EXPECTED_COORDINATES == 3
        assert config.MIN_FRAMES == 30
        assert config.MAX_FRAMES == 300

    def test_class_metrics(self):
        """Test that all 10 movement classes are defined"""
        config = PIMClassifierConfig()

        assert len(config.CLASS_METRICS) == 10  # Updated from 9 to 10 classes
        assert "tremor" in config.CLASS_METRICS
        assert "myoclonus" in config.CLASS_METRICS

        # Check tremor has high accuracy
        assert config.CLASS_METRICS["tremor"]["accuracy"] == 92.98  # Updated actual accuracy
        assert config.CLASS_METRICS["tremor"]["tier"] == "excellent"

    def test_confidence_thresholds(self):
        """Test confidence threshold values"""
        config = PIMClassifierConfig()

        assert config.HIGH_CONFIDENCE_THRESHOLD == 0.85
        assert config.MEDIUM_CONFIDENCE_THRESHOLD == 0.70
        assert config.LOW_CONFIDENCE_THRESHOLD == 0.50


class TestMovementPrediction:
    """Test MovementPrediction data model"""

    def test_prediction_creation(self):
        """Test creating a prediction object"""
        pred = MovementPrediction(
            predicted_class="tremor",
            confidence=0.95,
            all_probabilities={"tremor": 0.95, "myoclonus": 0.05},
            tier="excellent",
            recommendation="High confidence",
            model_accuracy=100.0,
            movement_id=8,
            metadata={"test": "data"},
        )

        assert pred.predicted_class == "tremor"
        assert pred.confidence == 0.95
        assert pred.tier == "excellent"
        assert pred.movement_id == 8

    def test_is_high_confidence(self):
        """Test high confidence detection"""
        pred = MovementPrediction(
            predicted_class="tremor",
            confidence=0.90,
            all_probabilities={},
            tier="excellent",
            recommendation="",
            model_accuracy=100.0,
            movement_id=8,
        )

        assert pred.is_high_confidence() is True

        pred.confidence = 0.80
        assert pred.is_high_confidence() is False

    def test_requires_review(self):
        """Test review requirement detection"""
        # Low tier requires review
        pred = MovementPrediction(
            predicted_class="myoclonus",
            confidence=0.80,
            all_probabilities={},
            tier="needs_review",
            recommendation="",
            model_accuracy=37.5,
            movement_id=7,
        )
        assert pred.requires_review() is True

        # Low confidence requires review
        pred.tier = "excellent"
        pred.confidence = 0.60
        assert pred.requires_review() is True

        # High confidence + excellent tier doesn't require review
        pred.confidence = 0.90
        pred.tier = "excellent"
        assert pred.requires_review() is False

    def test_to_dict(self):
        """Test converting to dictionary"""
        pred = MovementPrediction(
            predicted_class="tremor",
            confidence=0.95,
            all_probabilities={"tremor": 0.95},
            tier="excellent",
            recommendation="High confidence",
            model_accuracy=100.0,
            movement_id=8,
        )

        result = pred.to_dict()

        assert result["predicted_class"] == "tremor"
        assert result["confidence"] == 0.95
        assert result["tier"] == "excellent"
        assert "timestamp" in result

    def test_to_db_record(self):
        """Test converting to database record format"""
        pred = MovementPrediction(
            predicted_class="tremor",
            confidence=0.95,
            all_probabilities={"tremor": 0.95},
            tier="excellent",
            recommendation="High confidence",
            model_accuracy=100.0,
            movement_id=8,
        )

        record = pred.to_db_record(video_id=1, patient_id=1)

        assert record["video_id"] == 1
        assert record["patient_id"] == 1
        assert record["movement_type"] == "tremor"
        assert record["movement_id"] == 8
        assert record["confidence_score"] == 0.95
        assert record["requires_review"] is False


class TestPIMClassifierService:
    """Test PIM Classifier Service"""

    @pytest.fixture
    def service(self):
        """Create service instance without loading model"""
        return PIMClassifierService()

    def test_service_initialization(self, service):
        """Test service initializes correctly"""
        assert service.is_loaded is False
        assert service._prediction_count == 0
        assert service.config is not None

    def test_validate_input_valid(self, service, valid_skeleton_data):
        """Test validation passes for valid input"""
        is_valid, error = service.validate_input(valid_skeleton_data)

        assert is_valid is True
        assert error is None

    def test_validate_input_wrong_shape(self, service, invalid_skeleton_data_shape):
        """Test validation fails for wrong shape"""
        is_valid, error = service.validate_input(invalid_skeleton_data_shape)

        assert is_valid is False
        assert "Expected 33 joints" in error

    def test_validate_input_nan_values(self, service, skeleton_data_with_nan):
        """Test validation fails for NaN values"""
        is_valid, error = service.validate_input(skeleton_data_with_nan)

        assert is_valid is False
        assert "NaN" in error

    def test_validate_input_too_few_frames(self, service, skeleton_data_too_few_frames):
        """Test validation fails for too few frames"""
        is_valid, error = service.validate_input(skeleton_data_too_few_frames)

        assert is_valid is False
        assert "Too few frames" in error

    def test_validate_input_not_numpy(self, service):
        """Test validation fails for non-numpy input"""
        is_valid, error = service.validate_input([1, 2, 3])

        assert is_valid is False
        assert "numpy array" in error

    def test_determine_tier_excellent(self, service):
        """Test tier determination for excellent prediction"""
        tier, rec = service._determine_tier_and_recommendation("tremor", 0.95)

        assert tier == "excellent"
        assert "High confidence" in rec
        assert "93.0%" in rec  # Updated: Model accuracy for tremor is 92.98%

    def test_determine_tier_good(self, service):
        """Test tier determination for good prediction"""
        tier, rec = service._determine_tier_and_recommendation("chorea", 0.85)

        assert tier == "good"
        assert "physician review" in rec.lower()

    def test_determine_tier_needs_review_low_accuracy(self, service):
        """Test tier determination for good tier class with adequate confidence"""
        # Myoclonus is now "good" tier with 77.59% accuracy
        tier, rec = service._determine_tier_and_recommendation("myoclonus", 0.80)

        assert tier == "good"  # Updated: myoclonus is now "good" tier
        assert "77.6%" in rec  # Updated: Model accuracy for myoclonus is 77.59%

    def test_determine_tier_needs_review_low_confidence(self, service):
        """Test tier determination for low confidence"""
        tier, rec = service._determine_tier_and_recommendation("tremor", 0.60)

        assert tier == "needs_review"
        assert "Low confidence" in rec

    @patch("services.ai.pim_classifier_service.load_trained_model")
    def test_load_model_success(self, mock_load, service):
        """Test successful model loading"""
        mock_model = Mock()
        mock_device = "cpu"
        mock_load.return_value = (mock_model, mock_device)

        success = service.load_model("test_checkpoint.pt")

        assert success is True
        assert service.is_loaded is True
        assert service.model is mock_model
        assert service.device == mock_device

    @patch("services.ai.pim_classifier_service.load_trained_model")
    def test_load_model_failure(self, mock_load, service):
        """Test model loading failure"""
        mock_load.side_effect = Exception("Model not found")

        success = service.load_model("invalid_checkpoint.pt")

        assert success is False
        assert service.is_loaded is False

    @patch("services.ai.pim_classifier_service.predict_movement")
    def test_predict_success(
        self, mock_predict, service, valid_skeleton_data, mock_prediction_result
    ):
        """Test successful prediction"""
        # Setup
        service.is_loaded = True
        service.model = Mock()
        service.device = "cpu"
        mock_predict.return_value = mock_prediction_result

        # Predict
        prediction = service.predict(valid_skeleton_data)

        # Verify
        assert prediction.predicted_class == "tremor"
        assert prediction.confidence == 0.95
        assert prediction.tier == "excellent"
        assert service._prediction_count == 1

    def test_predict_model_not_loaded(self, service, valid_skeleton_data):
        """Test prediction fails when model not loaded"""
        with pytest.raises(RuntimeError, match="Model not loaded"):
            service.predict(valid_skeleton_data)

    def test_predict_invalid_input(self, service, invalid_skeleton_data_shape):
        """Test prediction fails for invalid input"""
        service.is_loaded = True

        with pytest.raises(ValueError, match="Invalid input"):
            service.predict(invalid_skeleton_data_shape)

    @patch("services.ai.pim_classifier_service.predict_movement")
    def test_predict_batch(
        self, mock_predict, service, valid_skeleton_data, mock_prediction_result
    ):
        """Test batch prediction"""
        # Setup
        service.is_loaded = True
        service.model = Mock()
        service.device = "cpu"
        mock_predict.return_value = mock_prediction_result

        # Batch predict
        batch_data = [valid_skeleton_data, valid_skeleton_data, valid_skeleton_data]
        predictions = service.predict_batch(batch_data)

        # Verify
        assert len(predictions) == 3
        assert all(p.predicted_class == "tremor" for p in predictions)

    @patch("services.ai.pim_classifier_service.predict_movement")
    def test_get_top_k_predictions(
        self, mock_predict, service, valid_skeleton_data, mock_prediction_result
    ):
        """Test getting top-k predictions"""
        # Setup
        service.is_loaded = True
        service.model = Mock()
        service.device = "cpu"
        mock_predict.return_value = mock_prediction_result

        # Get top-3
        top_k = service.get_top_k_predictions(valid_skeleton_data, k=3)

        # Verify
        assert len(top_k) == 3
        assert top_k[0][0] == "tremor"  # Class name
        assert top_k[0][1] == 0.95  # Probability

    def test_get_model_info(self, service):
        """Test getting model information"""
        info = service.get_model_info()

        assert info["model_name"] == "UNIK Transformer"
        assert "version" in info
        assert "classes" in info
        assert len(info["classes"]) == 10  # Updated from 9 to 10 classes

    def test_get_health_status(self, service):
        """Test getting health status"""
        status = service.get_health_status()

        assert "status" in status
        assert "model_loaded" in status
        assert status["model_loaded"] is False  # Not loaded yet

    @patch("services.ai.pim_classifier_service.load_trained_model")
    @patch("services.ai.pim_classifier_service.torch")
    def test_reload_model(self, mock_torch, mock_load, service):
        """Test model reloading"""
        # Setup
        mock_model = Mock()
        mock_device = "cpu"
        mock_load.return_value = (mock_model, mock_device)
        mock_torch.cuda.is_available.return_value = False

        # Initial load
        service.load_model("checkpoint1.pt")
        service._prediction_count = 10

        # Reload
        success = service.reload_model("checkpoint2.pt")

        # Verify
        assert success is True
        assert service._prediction_count == 0  # Reset
        assert service.model is mock_model


class TestSingletonService:
    """Test singleton service instance"""

    @patch("services.ai.pim_classifier_service.load_trained_model")
    def test_get_classifier_service_singleton(self, mock_load):
        """Test that get_classifier_service returns singleton"""
        mock_load.return_value = (Mock(), "cpu")

        # Get service twice
        service1 = get_classifier_service()
        service2 = get_classifier_service()

        # Should be same instance
        assert service1 is service2
