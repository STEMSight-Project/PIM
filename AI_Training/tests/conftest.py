"""
Pytest Configuration for AI Training Tests
Fixtures and shared test utilities
"""

import pytest
import numpy as np
import torch
from pathlib import Path
from typing import Dict, Tuple
import tempfile
import shutil


# ============================================================
# Test Data Fixtures
# ============================================================


@pytest.fixture
def sample_skeleton_data():
    """Generate sample skeleton data in UNIK format (3, 300, 33, 1)"""
    # Channels: x, y, confidence
    # Frames: 300
    # Joints: 33
    # Person: 1
    skeleton = np.random.rand(3, 300, 33, 1).astype(np.float32)
    
    # Make realistic confidence values (0.5 to 1.0)
    skeleton[2, :, :, :] = np.random.uniform(0.5, 1.0, (300, 33, 1)).astype(np.float32)
    
    return skeleton


@pytest.fixture
def sample_skeleton_batch():
    """Generate batch of skeleton data (N, 3, 300, 33, 1)"""
    batch_size = 16
    skeleton_batch = np.random.rand(batch_size, 3, 300, 33, 1).astype(np.float32)
    
    # Realistic confidence values
    skeleton_batch[:, 2, :, :, :] = np.random.uniform(0.5, 1.0, (batch_size, 300, 33, 1)).astype(np.float32)
    
    return skeleton_batch


@pytest.fixture
def sample_landmarks():
    """Generate sample MediaPipe landmarks (300, 33, 3)"""
    # Shape: (frames, joints, coordinates)
    # Coordinates: x, y, confidence
    landmarks = np.random.rand(300, 33, 3).astype(np.float32)
    
    # Make realistic: x,y in [0, 1], confidence in [0.5, 1.0]
    landmarks[:, :, 0:2] = np.random.uniform(0, 1, (300, 33, 2)).astype(np.float32)  # x, y
    landmarks[:, :, 2] = np.random.uniform(0.5, 1.0, (300, 33)).astype(np.float32)  # confidence
    
    return landmarks


@pytest.fixture
def sample_labels():
    """Generate sample labels for 10 classes"""
    num_samples = 100
    filenames = [f"video_{i:04d}.mp4" for i in range(num_samples)]
    labels = np.random.randint(0, 10, size=num_samples)  # 10 classes (0-9)
    return filenames, labels


@pytest.fixture
def class_index():
    """Movement class index mapping"""
    return {
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


@pytest.fixture
def temp_directory():
    """Create temporary directory for test files"""
    temp_dir = tempfile.mkdtemp()
    yield Path(temp_dir)
    # Cleanup after test
    shutil.rmtree(temp_dir, ignore_errors=True)


@pytest.fixture
def mock_video_file(temp_directory):
    """Create a mock video file path"""
    video_path = temp_directory / "test_video.mp4"
    video_path.touch()  # Create empty file
    return video_path


@pytest.fixture
def sample_model_output():
    """Generate sample model output (logits for 10 classes)"""
    batch_size = 16
    num_classes = 10
    logits = torch.randn(batch_size, num_classes)
    return logits


@pytest.fixture
def device():
    """Get available device (cuda or cpu)"""
    return torch.device("cuda:0" if torch.cuda.is_available() else "cpu")


# ============================================================
# Test Data Validation Fixtures
# ============================================================


@pytest.fixture
def valid_unik_shape():
    """Return expected UNIK data shape"""
    return (3, 300, 33, 1)


@pytest.fixture
def valid_batch_shape():
    """Return expected batch shape"""
    return (16, 3, 300, 33, 1)


@pytest.fixture
def valid_landmarks_shape():
    """Return expected landmarks shape"""
    return (300, 33, 3)


# ============================================================
# Configuration Fixtures
# ============================================================


@pytest.fixture
def model_config():
    """Model configuration for testing"""
    return {
        "num_class": 10,
        "num_joints": 33,
        "num_person": 2,
        "tau": 1,
        "num_heads": 3,
        "in_channels": 3,
        "drop_out": 0,
    }


@pytest.fixture
def training_config():
    """Training configuration for testing"""
    return {
        "batch_size": 16,
        "learning_rate": 0.2,
        "num_epoch": 80,
        "optimizer": "SGD",
        "weight_decay": 0.0005,
        "nesterov": True,
    }


# ============================================================
# Mock Data Files
# ============================================================


@pytest.fixture
def mock_npy_file(temp_directory, sample_skeleton_batch):
    """Create mock .npy data file"""
    npy_path = temp_directory / "test_data.npy"
    np.save(npy_path, sample_skeleton_batch)
    return npy_path


@pytest.fixture
def mock_label_file(temp_directory, sample_labels):
    """Create mock .pkl label file"""
    import pickle
    
    pkl_path = temp_directory / "test_labels.pkl"
    with open(pkl_path, 'wb') as f:
        pickle.dump(sample_labels, f)
    return pkl_path


# ============================================================
# Accuracy Metrics Fixtures
# ============================================================


@pytest.fixture
def expected_accuracy():
    """Expected test accuracy from training"""
    return 82.88  # Actual test accuracy from training


@pytest.fixture
def per_class_accuracy():
    """Per-class accuracy from training"""
    return {
        "ballistic": 80.70,
        "chorea": 78.95,
        "decerebrate": 79.31,
        "decorticate": 89.66,
        "dystonia": 84.48,
        "fencer_posture": 81.03,
        "myoclonus": 77.59,
        "normal": 74.58,
        "tremor": 92.98,
        "versive_head": 91.38,
    }


# ============================================================
# Skip Markers
# ============================================================


def pytest_configure(config):
    """Register custom markers"""
    config.addinivalue_line(
        "markers", "slow: marks tests as slow (deselect with '-m \"not slow\"')"
    )
    config.addinivalue_line(
        "markers", "gpu: marks tests requiring GPU (deselect with '-m \"not gpu\"')"
    )
    config.addinivalue_line(
        "markers", "integration: marks tests as integration tests"
    )
    config.addinivalue_line(
        "markers", "unit: marks tests as unit tests"
    )
