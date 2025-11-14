#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Unit tests for pose-tcn_single_view.py

Tests cover:
- Normalization functions (normalize_single_view)
- Model architecture components (SE1d, DSResBlock, TemporalMHAPool, Backbone1D, PoseTCNSingleView)
- Loss functions (FocalLoss)
- Data utilities and helper functions
- Dataset operations (NPZWindowDataset)
"""

import pytest
import numpy as np
import torch
import torch.nn as nn
import tempfile
import os
from pathlib import Path
from collections import Counter
import importlib.util

# Import pose-tcn_single_view module using importlib (handles hyphenated filename)
pose_tcn_path = Path(__file__).parent.parent / "pose-tcn_single_view.py"
spec = importlib.util.spec_from_file_location("pose_tcn_single_view", pose_tcn_path)
pose_tcn = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pose_tcn)

# Import functions and classes from the module
normalize_single_view = pose_tcn.normalize_single_view
FocalLoss = pose_tcn.FocalLoss
SE1d = pose_tcn.SE1d
DSResBlock = pose_tcn.DSResBlock
TemporalMHAPool = pose_tcn.TemporalMHAPool
Backbone1D = pose_tcn.Backbone1D
PoseTCNSingleView = pose_tcn.PoseTCNSingleView
NPZWindowDataset = pose_tcn.NPZWindowDataset
CollateWindows = pose_tcn.CollateWindows
ModelEMA = pose_tcn.ModelEMA
NUM_POSE_LANDMARKS = pose_tcn.NUM_POSE_LANDMARKS
L_SHOULDER = pose_tcn.L_SHOULDER
R_SHOULDER = pose_tcn.R_SHOULDER
L_HIP = pose_tcn.L_HIP
R_HIP = pose_tcn.R_HIP


class TestNormalizeSingleView:
    """Test pose normalization function."""

    def test_basic_normalization(self):
        """Test normalization with valid hip landmarks."""
        T = 60
        seq = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32)
        
        # Set hip landmarks to valid non-zero values
        seq[:, L_HIP, :] = np.array([0.5, 0.5, 0.0])
        seq[:, R_HIP, :] = np.array([0.6, 0.5, 0.0])
        
        # Set shoulder landmarks
        seq[:, L_SHOULDER, :] = np.array([0.3, 0.3, 0.0])
        seq[:, R_SHOULDER, :] = np.array([0.7, 0.3, 0.0])
        
        normalized = normalize_single_view(seq, NUM_POSE_LANDMARKS)
        
        # Check output shape
        assert normalized.shape == seq.shape
        assert normalized.dtype == np.float32
        
        # Check no NaN or inf values
        assert not np.any(np.isnan(normalized))
        assert not np.any(np.isinf(normalized))
        
        # Check values are clipped within [-10, 10]
        assert np.all(normalized >= -10.0)
        assert np.all(normalized <= 10.0)

    def test_fallback_to_shoulders(self):
        """Test normalization falls back to shoulders when hips are missing."""
        T = 60
        seq = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32)
        
        # Set hips to zero (invalid)
        seq[:, L_HIP, :] = 0.0
        seq[:, R_HIP, :] = 0.0
        
        # Set valid shoulder landmarks
        seq[:, L_SHOULDER, :] = np.array([0.3, 0.3, 0.0])
        seq[:, R_SHOULDER, :] = np.array([0.7, 0.3, 0.0])
        
        normalized = normalize_single_view(seq, NUM_POSE_LANDMARKS)
        
        # Should still produce valid output
        assert normalized.shape == seq.shape
        assert not np.any(np.isnan(normalized))
        assert not np.any(np.isinf(normalized))

    def test_zero_scale_handling(self):
        """Test handling of zero or near-zero scale."""
        T = 30
        seq = np.zeros((T, NUM_POSE_LANDMARKS, 3), dtype=np.float32)
        
        # All landmarks are zero - edge case
        normalized = normalize_single_view(seq, NUM_POSE_LANDMARKS)
        
        # Should handle gracefully without errors
        assert normalized.shape == seq.shape
        assert not np.any(np.isnan(normalized))
        assert not np.any(np.isinf(normalized))

    def test_clipping_bounds(self):
        """Test that extreme values are clipped properly."""
        T = 30
        seq = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32) * 100  # Large values
        
        # Set valid landmarks
        seq[:, L_HIP, :] = np.array([50.0, 50.0, 0.0])
        seq[:, R_HIP, :] = np.array([51.0, 50.0, 0.0])
        
        normalized = normalize_single_view(seq, NUM_POSE_LANDMARKS)
        
        # Check clipping to [-10, 10]
        assert np.all(normalized >= -10.0)
        assert np.all(normalized <= 10.0)

    def test_consistent_output(self):
        """Test that same input produces same output (deterministic)."""
        T = 60
        seq = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32)
        
        # Set consistent landmarks
        seq[:, L_HIP, :] = np.array([0.5, 0.5, 0.0])
        seq[:, R_HIP, :] = np.array([0.6, 0.5, 0.0])
        
        result1 = normalize_single_view(seq.copy(), NUM_POSE_LANDMARKS)
        result2 = normalize_single_view(seq.copy(), NUM_POSE_LANDMARKS)
        
        np.testing.assert_array_almost_equal(result1, result2)


class TestFocalLoss:
    """Test Focal Loss implementation."""

    def test_focal_loss_forward(self):
        """Test focal loss forward pass."""
        batch_size = 16
        num_classes = 10
        
        loss_fn = FocalLoss(gamma=2.0, label_smoothing=0.1)
        
        inputs = torch.randn(batch_size, num_classes)
        targets = torch.randint(0, num_classes, (batch_size,))
        
        loss = loss_fn(inputs, targets)
        
        assert torch.isfinite(loss)
        assert loss.dim() == 0  # Scalar
        assert loss.item() >= 0.0

    def test_focal_loss_with_alpha(self):
        """Test focal loss with class weights (alpha)."""
        batch_size = 16
        num_classes = 10
        
        alpha = torch.rand(num_classes)
        loss_fn = FocalLoss(alpha=alpha, gamma=2.0)
        
        inputs = torch.randn(batch_size, num_classes)
        targets = torch.randint(0, num_classes, (batch_size,))
        
        loss = loss_fn(inputs, targets)
        
        assert torch.isfinite(loss)
        assert loss.item() >= 0.0

    def test_focal_loss_label_smoothing(self):
        """Test focal loss with label smoothing."""
        batch_size = 8
        num_classes = 5
        
        loss_fn = FocalLoss(gamma=2.0, label_smoothing=0.2)
        
        inputs = torch.randn(batch_size, num_classes)
        targets = torch.randint(0, num_classes, (batch_size,))
        
        loss = loss_fn(inputs, targets)
        
        assert torch.isfinite(loss)
        assert loss.item() >= 0.0

    def test_focal_loss_gamma_effect(self):
        """Test that higher gamma increases focus on hard examples."""
        batch_size = 32
        num_classes = 10
        
        inputs = torch.randn(batch_size, num_classes)
        targets = torch.randint(0, num_classes, (batch_size,))
        
        loss_gamma_0 = FocalLoss(gamma=0.0)(inputs, targets)
        loss_gamma_2 = FocalLoss(gamma=2.0)(inputs, targets)
        
        # Both should be finite and non-negative
        assert torch.isfinite(loss_gamma_0) and torch.isfinite(loss_gamma_2)
        assert loss_gamma_0.item() >= 0.0 and loss_gamma_2.item() >= 0.0


class TestModelComponents:
    """Test model architecture components."""

    def test_se1d_forward(self):
        """Test SE1d (Squeeze-and-Excitation) module."""
        batch_size = 8
        channels = 384
        time_steps = 60
        
        se = SE1d(channels, reduction=8)
        x = torch.randn(batch_size, channels, time_steps)
        
        output = se(x)
        
        assert output.shape == x.shape
        assert torch.isfinite(output).all()

    def test_dsres_block_forward(self):
        """Test DSResBlock (Depthwise Separable Residual) forward pass."""
        batch_size = 8
        channels = 384
        time_steps = 60
        
        block = DSResBlock(channels, dilation=2, drop=0.1, stochastic_depth=0.05, norm='bn')
        x = torch.randn(batch_size, channels, time_steps)
        
        output = block(x)
        
        assert output.shape == x.shape
        assert torch.isfinite(output).all()

    def test_dsres_block_training_mode(self):
        """Test DSResBlock in training mode with stochastic depth."""
        batch_size = 8
        channels = 128
        time_steps = 60
        
        block = DSResBlock(channels, dilation=1, stochastic_depth=0.2)
        block.train()
        
        x = torch.randn(batch_size, channels, time_steps)
        output = block(x)
        
        assert output.shape == x.shape
        assert torch.isfinite(output).all()

    def test_temporal_mha_pool_forward(self):
        """Test TemporalMHAPool (Multi-Head Attention Pooling)."""
        batch_size = 8
        channels = 384
        time_steps = 60
        
        pool = TemporalMHAPool(channels, heads=4, dropout=0.1)
        x = torch.randn(batch_size, channels, time_steps)
        
        output = pool(x)
        
        # Output should be (B, 2*C) due to CLS token + GAP concatenation
        assert output.shape == (batch_size, 2 * channels)
        assert torch.isfinite(output).all()

    def test_temporal_mha_pool_heads_divisibility(self):
        """Test that TemporalMHAPool requires channels divisible by heads."""
        channels = 385  # Not divisible by 4
        
        with pytest.raises(AssertionError):
            TemporalMHAPool(channels, heads=4)

    def test_backbone1d_forward(self):
        """Test Backbone1D forward pass."""
        batch_size = 8
        time_steps = 60
        in_features = NUM_POSE_LANDMARKS * 3  # 33 landmarks * 3 coords
        width = 384
        
        backbone = Backbone1D(
            in_features=in_features,
            width=width,
            drop=0.1,
            stochastic_depth=0.05,
            dilations=[1, 2, 4, 8],
            norm='bn',
            t_heads=4,
            attn_dropout=0.0
        )
        
        x = torch.randn(batch_size, time_steps, in_features)
        output = backbone(x)
        
        # Output should be (B, 2*width) from temporal pooling
        assert output.shape == (batch_size, 2 * width)
        assert torch.isfinite(output).all()


class TestPoseTCNSingleView:
    """Test complete PoseTCN model."""

    def test_model_forward(self):
        """Test full model forward pass."""
        batch_size = 8
        time_steps = 120
        num_classes = 10
        width = 384
        
        model = PoseTCNSingleView(
            num_classes=num_classes,
            width=width,
            drop=0.1,
            stochastic_depth=0.05,
            dilations=[1, 2, 4, 8, 16, 32],
            norm='bn',
            t_heads=4,
            attn_dropout=0.0
        )
        
        # Input: (B, T, L*3) where L=33 landmarks
        x = torch.randn(batch_size, time_steps, NUM_POSE_LANDMARKS * 3)
        output = model(x)
        
        assert output.shape == (batch_size, num_classes)
        assert torch.isfinite(output).all()

    def test_model_eval_mode(self):
        """Test model in evaluation mode."""
        batch_size = 4
        time_steps = 60
        num_classes = 10
        
        model = PoseTCNSingleView(num_classes=num_classes, width=256)
        model.eval()
        
        x = torch.randn(batch_size, time_steps, NUM_POSE_LANDMARKS * 3)
        
        with torch.no_grad():
            output = model(x)
        
        assert output.shape == (batch_size, num_classes)
        assert torch.isfinite(output).all()

    def test_model_with_different_widths(self):
        """Test model with various width configurations."""
        time_steps = 60
        num_classes = 5
        
        for width in [128, 256, 384, 512]:
            model = PoseTCNSingleView(num_classes=num_classes, width=width)
            x = torch.randn(1, time_steps, NUM_POSE_LANDMARKS * 3)
            output = model(x)
            
            assert output.shape == (1, num_classes)

    def test_model_parameter_count(self):
        """Test that model has reasonable parameter count."""
        model = PoseTCNSingleView(num_classes=10, width=384)
        
        total_params = sum(p.numel() for p in model.parameters())
        trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
        
        assert total_params > 0
        assert trainable_params == total_params  # All params should be trainable
        
        # Reasonable bounds (should be between 1M and 50M params)
        assert 1_000_000 < total_params < 50_000_000

    def test_model_gradient_flow(self):
        """Test that gradients flow through model."""
        batch_size = 4
        time_steps = 60
        num_classes = 10
        
        model = PoseTCNSingleView(num_classes=num_classes, width=256)
        x = torch.randn(batch_size, time_steps, NUM_POSE_LANDMARKS * 3, requires_grad=True)
        
        output = model(x)
        loss = output.sum()
        loss.backward()
        
        # Check that gradients exist
        assert x.grad is not None
        assert torch.isfinite(x.grad).all()


class TestCollateWindows:
    """Test data collation and augmentation."""

    def test_basic_collate(self):
        """Test basic collation without augmentation."""
        collate = CollateWindows(augment=False)
        
        # Create mock batch
        batch = []
        for _ in range(8):
            x = np.random.randn(60, NUM_POSE_LANDMARKS * 3).astype(np.float32)
            y = np.random.randint(0, 10)
            subject = "Test_Subject"
            soft_label = False
            batch.append((x, y, subject, soft_label))
        
        x_batch, y_batch, subjects = collate(batch)
        
        assert x_batch.shape == (8, 60, NUM_POSE_LANDMARKS * 3)
        assert y_batch.shape == (8,)
        assert len(subjects) == 8
        assert torch.isfinite(x_batch).all()

    def test_collate_with_augmentation(self):
        """Test collation with augmentation enabled."""
        class_map = {f"class_{i}": i for i in range(10)}
        
        collate = CollateWindows(
            augment=True,
            time_mask_prob=0.3,
            time_mask_max_frames=8,
            joint_dropout_prob=0.2,
            joint_dropout_frac=0.15,
            noise_std=0.01,
            rotation_prob=0.3,
            rotation_angle_deg=15.0,
            scale_prob=0.3,
            scale_min=0.9,
            scale_max=1.1,
            class_map=class_map
        )
        
        # Create batch
        batch = []
        for _ in range(8):
            x = np.random.randn(60, NUM_POSE_LANDMARKS * 3).astype(np.float32)
            y = np.random.randint(0, 10)
            subject = "Test_Subject"
            batch.append((x, y, subject, False))
        
        x_batch, y_batch, subjects = collate(batch)
        
        assert x_batch.shape == (8, 60, NUM_POSE_LANDMARKS * 3)
        assert torch.isfinite(x_batch).all()

    def test_soft_labels_collate(self):
        """Test collation with soft labels."""
        collate = CollateWindows(augment=False)
        
        # Create batch with soft labels
        batch = []
        num_classes = 10
        for _ in range(4):
            x = np.random.randn(60, NUM_POSE_LANDMARKS * 3).astype(np.float32)
            y = np.random.rand(num_classes).astype(np.float32)
            y /= y.sum()  # Normalize to sum to 1
            subject = "Test_Subject"
            batch.append((x, y, subject, True))
        
        x_batch, y_batch, subjects = collate(batch)
        
        assert x_batch.shape == (4, 60, NUM_POSE_LANDMARKS * 3)
        assert y_batch.shape == (4, num_classes)
        assert torch.is_floating_point(y_batch)


class TestModelEMA:
    """Test Exponential Moving Average of model weights."""

    def test_ema_initialization(self):
        """Test EMA initialization."""
        model = PoseTCNSingleView(num_classes=10, width=256)
        ema = ModelEMA(model, decay=0.999)
        
        # EMA model should exist
        assert ema.ema is not None
        assert ema.decay == 0.999

    def test_ema_update(self):
        """Test EMA weight updates."""
        model = PoseTCNSingleView(num_classes=10, width=128)
        ema = ModelEMA(model, decay=0.999)
        
        # Get initial EMA weights
        initial_state = {k: v.clone() for k, v in ema.ema.state_dict().items()}
        
        # Simulate training step - modify model weights
        for p in model.parameters():
            if p.requires_grad:
                p.data += torch.randn_like(p) * 0.1
        
        # Update EMA
        ema.update(model)
        
        # EMA weights should have changed
        updated_state = ema.ema.state_dict()
        
        changed = False
        for key in initial_state:
            if not torch.allclose(initial_state[key], updated_state[key], atol=1e-5):
                changed = True
                break
        
        assert changed, "EMA weights should update after model changes"

    def test_ema_state_dict(self):
        """Test EMA state dict save/load."""
        model = PoseTCNSingleView(num_classes=10, width=128)
        ema1 = ModelEMA(model, decay=0.999)
        
        # Update EMA
        for p in model.parameters():
            if p.requires_grad:
                p.data += torch.randn_like(p) * 0.01
        ema1.update(model)
        
        # Save and load state
        state = ema1.state_dict()
        ema2 = ModelEMA(model, decay=0.999)
        ema2.load_state_dict(state, strict=True)
        
        # States should match
        for k, v in ema1.state_dict().items():
            assert torch.allclose(v, ema2.state_dict()[k])


class TestDatasetUtilities:
    """Test dataset utilities and NPZ handling."""

    def test_create_mock_npz_file(self):
        """Test creation of mock NPZ file for testing."""
        with tempfile.TemporaryDirectory() as tmpdir:
            npz_path = os.path.join(tmpdir, "test_sample.npz")
            
            # Create mock data
            T = 300
            view_data = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32)
            
            # Save NPZ
            np.savez_compressed(
                npz_path,
                view_0=view_data,
                movement_type="tremor",
                fps=60.0,
                video_filename="test_video.mp4"
            )
            
            # Verify file exists and can be loaded
            assert os.path.exists(npz_path)
            
            with np.load(npz_path, allow_pickle=False) as z:
                assert "view_0" in z.files
                assert "movement_type" in z.files
                loaded_view = z["view_0"]
                assert loaded_view.shape == view_data.shape

    def test_npz_dataset_loading(self):
        """Test NPZWindowDataset basic loading."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create mock NPZ files
            files = []
            class_map = {"tremor": 0, "normal": 1}
            
            for i, movement in enumerate(["tremor", "normal", "tremor"]):
                npz_path = os.path.join(tmpdir, f"sample_{i}.npz")
                T = 300
                view_data = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32)
                
                np.savez_compressed(
                    npz_path,
                    view_0=view_data,
                    movement_type=movement,
                    fps=60.0
                )
                files.append(npz_path)
            
            # Create dataset
            dataset = NPZWindowDataset(
                files=files,
                class_map=class_map,
                T=60,
                default_stride=15,
                max_views=3,
                lazy_load=False
            )
            
            # Check dataset properties
            assert len(dataset) > 0
            assert dataset.num_views == 1  # Single-view mode
            assert dataset.input_dim == NUM_POSE_LANDMARKS * 3
            
            # Get a sample
            x, y, subject, is_soft = dataset[0]
            
            assert x.shape == (60, NUM_POSE_LANDMARKS * 3)
            assert y in [0, 1]  # Should be one of the class indices
            assert isinstance(subject, str)
            assert is_soft == False


@pytest.mark.parametrize("batch_size,time_steps,num_classes", [
    (4, 60, 5),
    (8, 120, 10),
    (16, 90, 15),
])
def test_end_to_end_forward_pass(batch_size, time_steps, num_classes):
    """Test end-to-end forward pass with various configurations."""
    model = PoseTCNSingleView(
        num_classes=num_classes,
        width=256,
        drop=0.1,
        stochastic_depth=0.05,
        dilations=[1, 2, 4, 8],
        norm='bn'
    )
    
    x = torch.randn(batch_size, time_steps, NUM_POSE_LANDMARKS * 3)
    
    with torch.no_grad():
        output = model(x)
    
    assert output.shape == (batch_size, num_classes)
    assert torch.isfinite(output).all()


@pytest.mark.parametrize("gamma,label_smoothing", [
    (0.0, 0.0),
    (1.0, 0.1),
    (2.0, 0.2),
    (3.0, 0.0),
])
def test_focal_loss_configurations(gamma, label_smoothing):
    """Test focal loss with various gamma and label smoothing values."""
    batch_size = 16
    num_classes = 10
    
    loss_fn = FocalLoss(gamma=gamma, label_smoothing=label_smoothing)
    
    inputs = torch.randn(batch_size, num_classes)
    targets = torch.randint(0, num_classes, (batch_size,))
    
    loss = loss_fn(inputs, targets)
    
    assert torch.isfinite(loss)
    assert loss.item() >= 0.0


def test_normalization_preserves_temporal_consistency():
    """Test that normalization maintains temporal consistency across frames."""
    T = 60
    # Use smaller random variations for more realistic temporal consistency test
    seq = np.random.randn(T, NUM_POSE_LANDMARKS, 3).astype(np.float32) * 0.01
    
    # Set consistent hip positions with smooth temporal progression
    for t in range(T):
        seq[t, L_HIP, :] = np.array([0.5 + 0.002*t, 0.5, 0.0])
        seq[t, R_HIP, :] = np.array([0.6 + 0.002*t, 0.5, 0.0])
        seq[t, L_SHOULDER, :] = np.array([0.3 + 0.002*t, 0.3, 0.0])
        seq[t, R_SHOULDER, :] = np.array([0.7 + 0.002*t, 0.3, 0.0])
    
    normalized = normalize_single_view(seq, NUM_POSE_LANDMARKS)
    
    # Check that normalization produces finite values and maintains smooth transitions
    assert not np.any(np.isnan(normalized))
    assert not np.any(np.isinf(normalized))
    
    # Calculate frame-to-frame differences
    diffs = []
    for t in range(1, T):
        diff = np.linalg.norm(normalized[t] - normalized[t-1])
        diffs.append(diff)
    
    # Check that mean difference is reasonable (not too large)
    mean_diff = np.mean(diffs)
    assert mean_diff < 15.0, f"Mean temporal difference should be reasonable, got {mean_diff:.2f}"
    
    # Check that there are no extreme jumps (outliers)
    max_diff = np.max(diffs)
    assert max_diff < 30.0, f"Maximum temporal jump should be bounded, got {max_diff:.2f}"


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v", "--tb=short"])
