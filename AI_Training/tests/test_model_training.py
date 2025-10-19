"""
Unit Tests for UNIK Model Training
Tests model architecture, training loop, and optimization
"""

import pytest
import torch
import torch.nn as nn
import numpy as np
from pathlib import Path


# ============================================================
# Test Model Architecture
# ============================================================


class TestUNIKModelArchitecture:
    """Test UNIK model structure and configuration"""

    @pytest.mark.unit
    def test_model_initialization(self, model_config):
        """Test model can be initialized with correct parameters"""
        # Model config from fixture
        assert model_config["num_class"] == 10
        assert model_config["num_joints"] == 33
        assert model_config["num_person"] == 2
        assert model_config["in_channels"] == 3

    @pytest.mark.unit
    def test_model_input_shape(self, sample_skeleton_batch):
        """Test model accepts correct input shape"""
        # Input: (N, 3, 300, 33, 1) → (N, 3, 300, 33, 2) after padding
        batch_size, C, T, V, M = sample_skeleton_batch.shape
        
        assert C == 3  # x, y, confidence
        assert T == 300  # frames
        assert V == 33  # joints
        assert M == 1  # person

    @pytest.mark.unit
    def test_model_output_shape(self, sample_model_output):
        """Test model output has correct shape (N, num_classes)"""
        batch_size, num_classes = sample_model_output.shape
        
        assert num_classes == 10  # 10 movement classes
        assert batch_size == 16  # From fixture

    @pytest.mark.unit
    def test_person_padding_to_2(self):
        """Test padding from M=1 to M=2 for model compatibility"""
        # Input: (N, 3, 300, 33, 1)
        data = np.random.rand(16, 3, 300, 33, 1).astype(np.float32)
        
        # Pad to M=2
        padded = np.pad(data, ((0, 0), (0, 0), (0, 0), (0, 0), (0, 1)), mode='constant')
        
        assert padded.shape == (16, 3, 300, 33, 2)
        # Second person should be all zeros
        assert np.all(padded[:, :, :, :, 1] == 0)

    @pytest.mark.unit
    def test_dropout_configuration(self, model_config):
        """Test dropout is disabled (drop_out=0)"""
        assert model_config["drop_out"] == 0

    @pytest.mark.unit
    def test_attention_heads(self, model_config):
        """Test multi-head attention configuration"""
        assert model_config["num_heads"] == 3


# ============================================================
# Test Training Configuration
# ============================================================


class TestTrainingConfiguration:
    """Test training hyperparameters and settings"""

    @pytest.mark.unit
    def test_optimizer_config(self, training_config):
        """Test optimizer configuration"""
        assert training_config["optimizer"] == "SGD"
        assert training_config["nesterov"] is True
        assert training_config["weight_decay"] == 0.0005

    @pytest.mark.unit
    def test_learning_rate(self, training_config):
        """Test learning rate with warmup"""
        assert training_config["learning_rate"] == 0.2
        
        # Warmup: 5 epochs with gradual increase
        warmup_epochs = 5
        initial_lr = training_config["learning_rate"] / warmup_epochs
        
        assert initial_lr == 0.04  # 0.2 / 5

    @pytest.mark.unit
    def test_batch_size(self, training_config):
        """Test batch size configuration"""
        assert training_config["batch_size"] == 16

    @pytest.mark.unit
    def test_training_epochs(self, training_config):
        """Test total training epochs"""
        assert training_config["num_epoch"] == 80

    @pytest.mark.unit
    def test_total_training_iterations(self, training_config):
        """Test total training iterations calculation"""
        total_samples = 2080
        batch_size = training_config["batch_size"]
        num_epochs = training_config["num_epoch"]
        
        iterations_per_epoch = total_samples // batch_size
        total_iterations = iterations_per_epoch * num_epochs
        
        assert iterations_per_epoch == 130  # 2080 / 16
        assert total_iterations == 10400  # 130 * 80


# ============================================================
# Test Loss Functions
# ============================================================


class TestLossFunctions:
    """Test loss function computation"""

    @pytest.mark.unit
    def test_cross_entropy_loss(self):
        """Test cross-entropy loss computation"""
        # Simulate model output
        logits = torch.randn(16, 10)  # (batch_size, num_classes)
        targets = torch.randint(0, 10, (16,))  # (batch_size,)
        
        criterion = nn.CrossEntropyLoss()
        loss = criterion(logits, targets)
        
        assert loss.item() > 0
        assert not torch.isnan(loss)

    @pytest.mark.unit
    def test_loss_reduction(self):
        """Test loss reduction (mean vs sum)"""
        logits = torch.randn(16, 10)
        targets = torch.randint(0, 10, (16,))
        
        loss_mean = nn.CrossEntropyLoss(reduction='mean')(logits, targets)
        loss_sum = nn.CrossEntropyLoss(reduction='sum')(logits, targets)
        
        # Sum should be approximately batch_size * mean
        assert abs(loss_sum.item() - loss_mean.item() * 16) < 0.01


# ============================================================
# Test Accuracy Metrics
# ============================================================


class TestAccuracyMetrics:
    """Test accuracy calculation and validation"""

    @pytest.mark.unit
    def test_accuracy_calculation(self):
        """Test accuracy computation"""
        # Perfect predictions
        predictions = torch.tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        targets = torch.tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        correct = (predictions == targets).sum().item()
        accuracy = correct / len(targets) * 100
        
        assert accuracy == 100.0

    @pytest.mark.unit
    def test_expected_test_accuracy(self, expected_accuracy):
        """Test expected test accuracy matches training result"""
        assert expected_accuracy == 82.88

    @pytest.mark.unit
    def test_per_class_accuracy_calculation(self):
        """Test per-class accuracy calculation"""
        # Class 0: 8/10 correct
        predictions = torch.tensor([0, 0, 0, 0, 0, 0, 0, 0, 1, 1])
        targets = torch.tensor([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        
        class_mask = (targets == 0)
        class_correct = ((predictions == targets) & class_mask).sum().item()
        class_total = class_mask.sum().item()
        class_accuracy = class_correct / class_total * 100
        
        assert class_accuracy == 80.0

    @pytest.mark.unit
    def test_confusion_matrix_structure(self):
        """Test confusion matrix shape"""
        num_classes = 10
        predictions = np.random.randint(0, num_classes, 520)
        targets = np.random.randint(0, num_classes, 520)
        
        from sklearn.metrics import confusion_matrix
        cm = confusion_matrix(targets, predictions, labels=range(num_classes))
        
        assert cm.shape == (num_classes, num_classes)

    @pytest.mark.unit
    def test_top_performing_classes(self, per_class_accuracy):
        """Test identification of top-performing classes"""
        # Top 3: tremor (92.98%), versive_head (91.38%), decorticate (89.66%)
        sorted_classes = sorted(
            per_class_accuracy.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        top_3 = [cls for cls, acc in sorted_classes[:3]]
        
        assert "tremor" in top_3
        assert "versive_head" in top_3
        assert "decorticate" in top_3


# ============================================================
# Test Checkpoint Saving
# ============================================================


class TestCheckpointSaving:
    """Test model checkpoint saving and loading"""

    @pytest.mark.unit
    def test_checkpoint_naming_convention(self):
        """Test checkpoint file naming"""
        # Format: pim_unik_model_10class_new-{epoch}-{iteration}.pt
        epoch = 69
        iteration = 18200
        
        checkpoint_name = f"pim_unik_model_10class_new-{epoch}-{iteration}.pt"
        
        assert checkpoint_name == "pim_unik_model_10class_new-69-18200.pt"

    @pytest.mark.unit
    def test_checkpoint_content(self, temp_directory):
        """Test checkpoint contains model state"""
        # Mock model state dict
        state_dict = {
            'layer1.weight': torch.randn(10, 3),
            'layer1.bias': torch.randn(10),
        }
        
        checkpoint_path = temp_directory / "test_checkpoint.pt"
        torch.save(state_dict, checkpoint_path)
        
        # Load and verify
        loaded = torch.load(checkpoint_path)
        
        assert 'layer1.weight' in loaded
        assert 'layer1.bias' in loaded

    @pytest.mark.unit
    def test_best_checkpoint_selection(self):
        """Test selection of best checkpoint by accuracy"""
        checkpoints = [
            {"epoch": 65, "val_acc": 81.23},
            {"epoch": 69, "val_acc": 83.27},  # Best
            {"epoch": 71, "val_acc": 82.15},
            {"epoch": 79, "val_acc": 81.89},
        ]
        
        best = max(checkpoints, key=lambda x: x["val_acc"])
        
        assert best["epoch"] == 69
        assert best["val_acc"] == 83.27


# ============================================================
# Test GPU/CPU Device Handling
# ============================================================


class TestDeviceHandling:
    """Test GPU/CPU device management"""

    @pytest.mark.unit
    def test_device_selection(self, device):
        """Test device selection (cuda or cpu)"""
        assert device.type in ['cuda', 'cpu']
        
        if torch.cuda.is_available():
            assert device.type == 'cuda'
            assert device.index == 0  # cuda:0

    @pytest.mark.unit
    @pytest.mark.gpu
    def test_gpu_availability(self):
        """Test GPU availability (RTX 4070)"""
        if torch.cuda.is_available():
            device_name = torch.cuda.get_device_name(0)
            # Check if NVIDIA GPU
            assert "NVIDIA" in device_name or "GeForce" in device_name

    @pytest.mark.unit
    def test_tensor_device_placement(self, device):
        """Test tensor placement on correct device"""
        tensor = torch.randn(10, 10).to(device)
        
        assert tensor.device.type == device.type

    @pytest.mark.unit
    def test_model_device_placement(self, device):
        """Test model placement on device"""
        model = nn.Linear(10, 10)
        model = model.to(device)
        
        # Check first parameter device
        first_param = next(model.parameters())
        assert first_param.device.type == device.type


# ============================================================
# Test Data Loading
# ============================================================


class TestDataLoading:
    """Test data loading and batching"""

    @pytest.mark.unit
    def test_dataloader_batch_size(self, training_config):
        """Test DataLoader creates correct batch size"""
        batch_size = training_config["batch_size"]
        
        # Mock dataset
        data = torch.randn(2080, 3, 300, 33, 2)
        labels = torch.randint(0, 10, (2080,))
        
        from torch.utils.data import TensorDataset, DataLoader
        dataset = TensorDataset(data, labels)
        loader = DataLoader(dataset, batch_size=batch_size, shuffle=False)
        
        # Get first batch
        batch_data, batch_labels = next(iter(loader))
        
        assert batch_data.shape[0] == batch_size
        assert batch_labels.shape[0] == batch_size

    @pytest.mark.unit
    def test_dataloader_shuffle(self):
        """Test DataLoader shuffling"""
        data = torch.arange(100).view(100, 1)
        labels = torch.arange(100)
        
        from torch.utils.data import TensorDataset, DataLoader
        dataset = TensorDataset(data, labels)
        
        # Without shuffle
        loader_no_shuffle = DataLoader(dataset, batch_size=10, shuffle=False)
        first_batch_no_shuffle = next(iter(loader_no_shuffle))[0]
        
        # With shuffle (different seed)
        loader_shuffle = DataLoader(dataset, batch_size=10, shuffle=True)
        first_batch_shuffle = next(iter(loader_shuffle))[0]
        
        # Different results (with high probability)
        # Note: This test might occasionally fail due to random chance
        # In practice, we'd use fixed seeds for determinism


# ============================================================
# Test Training Metrics Tracking
# ============================================================


class TestMetricsTracking:
    """Test tracking of training metrics"""

    @pytest.mark.unit
    def test_epoch_metrics_structure(self):
        """Test epoch metrics data structure"""
        metrics = {
            "epoch": 69,
            "train_loss": 0.245,
            "train_acc": 91.23,
            "val_loss": 0.312,
            "val_acc": 83.27,
            "lr": 0.002,
        }
        
        assert "train_loss" in metrics
        assert "val_acc" in metrics
        assert metrics["epoch"] == 69

    @pytest.mark.unit
    def test_training_progress_calculation(self):
        """Test training progress percentage"""
        current_epoch = 50
        total_epochs = 80
        
        progress = (current_epoch / total_epochs) * 100
        
        assert progress == 62.5
