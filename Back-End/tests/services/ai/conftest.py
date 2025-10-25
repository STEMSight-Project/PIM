"""
Pytest configuration and fixtures for AI service tests
"""

import pytest
import numpy as np
from unittest.mock import Mock, AsyncMock, patch
import sys
from pathlib import Path

# Add Back-End to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))


@pytest.fixture
def valid_skeleton_data():
    """Generate valid skeleton data (60 frames, 33 joints, 3 coords)"""
    return np.random.rand(60, 33, 3)


@pytest.fixture
def invalid_skeleton_data_shape():
    """Generate invalid skeleton data (wrong shape)"""
    return np.random.rand(60, 25, 3)  # Wrong number of joints


@pytest.fixture
def skeleton_data_with_nan():
    """Generate skeleton data with NaN values"""
    data = np.random.rand(60, 33, 3)
    data[0, 0, 0] = np.nan
    return data


@pytest.fixture
def skeleton_data_too_few_frames():
    """Generate skeleton data with too few frames"""
    return np.random.rand(20, 33, 3)


@pytest.fixture
def mock_prediction_result():
    """Mock prediction result from model"""
    return {
        "class": "tremor",
        "confidence": 0.95,
        "all_probabilities": {
            "tremor": 0.95,
            "myoclonus": 0.03,
            "ballistic": 0.01,
            "chorea": 0.005,
            "decerebrate": 0.003,
            "decorticate": 0.001,
            "dystonia": 0.001,
            "fencer_posture": 0.0,
            "versive_head": 0.0,
        },
    }


@pytest.fixture
def mock_supabase():
    """Mock Supabase client"""
    mock = Mock()

    # Mock table operations
    mock_table = Mock()
    mock_table.insert = Mock(return_value=mock_table)
    mock_table.select = Mock(return_value=mock_table)
    mock_table.update = Mock(return_value=mock_table)
    mock_table.delete = Mock(return_value=mock_table)
    mock_table.eq = Mock(return_value=mock_table)
    mock_table.order = Mock(return_value=mock_table)
    mock_table.limit = Mock(return_value=mock_table)

    # Mock execute
    mock_execute_result = Mock()
    mock_execute_result.data = [
        {
            "id": 1,
            "video_id": 1,
            "patient_id": 1,
            "movement_type": "tremor",
            "confidence_score": 0.95,
        }
    ]
    mock_table.execute = Mock(return_value=mock_execute_result)

    mock.table = Mock(return_value=mock_table)

    return mock


@pytest.fixture
def sample_skeleton_landmarks():
    """Sample skeleton landmarks for one frame (33 joints)"""
    return [[0.5 + i * 0.01, 0.5 + i * 0.01, 0.9] for i in range(33)]


@pytest.fixture
def sample_detection_record():
    """Sample detection record from database"""
    return {
        "id": 1,
        "video_id": 1,
        "patient_id": 1,
        "movement_type": "tremor",
        "movement_id": 8,
        "confidence_score": 0.95,
        "model_accuracy": 100.0,
        "tier": "excellent",
        "recommendation": "High confidence prediction",
        "all_probabilities": {
            "tremor": 0.95,
            "myoclonus": 0.03,
            "ballistic": 0.01,
        },
        "requires_review": False,
        "reviewed": False,
        "detected_at": "2025-01-13T10:00:00",
        "metadata": {},
    }
