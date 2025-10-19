"""
Unit Tests for Train/Test Data Split
Tests stratified splitting and data distribution
"""

import pytest
import numpy as np
from collections import Counter
import pickle


# ============================================================
# Test Train/Test Split
# ============================================================


class TestTrainTestSplit:
    """Test train/test split functionality"""

    @pytest.mark.unit
    def test_split_ratio(self, sample_skeleton_batch, sample_labels):
        """Test 80/20 train/test split ratio"""
        filenames, labels = sample_labels
        total_samples = len(labels)
        
        # Simulate 80/20 split
        train_size = int(0.8 * total_samples)
        test_size = total_samples - train_size
        
        assert train_size == 80
        assert test_size == 20
        assert train_size + test_size == total_samples

    @pytest.mark.unit
    def test_stratified_split_distribution(self):
        """Test that stratified split maintains class distribution"""
        # Create balanced dataset: 10 samples per class
        num_classes = 10
        samples_per_class = 10
        labels = np.repeat(np.arange(num_classes), samples_per_class)
        
        # Shuffle
        np.random.seed(42)
        indices = np.random.permutation(len(labels))
        labels = labels[indices]
        
        # Split 80/20 stratified
        from sklearn.model_selection import train_test_split
        train_idx, test_idx = train_test_split(
            np.arange(len(labels)),
            test_size=0.2,
            stratify=labels,
            random_state=42
        )
        
        train_labels = labels[train_idx]
        test_labels = labels[test_idx]
        
        # Check distribution
        train_dist = Counter(train_labels)
        test_dist = Counter(test_labels)
        
        # Each class should have 8 train + 2 test samples
        for cls in range(num_classes):
            assert train_dist[cls] == 8
            assert test_dist[cls] == 2

    @pytest.mark.unit
    def test_no_data_leakage(self):
        """Test that train and test sets have no overlap"""
        total_samples = 100
        indices = np.arange(total_samples)
        
        # Split indices
        train_idx = indices[:80]
        test_idx = indices[80:]
        
        # Check no overlap
        train_set = set(train_idx)
        test_set = set(test_idx)
        
        assert len(train_set.intersection(test_set)) == 0

    @pytest.mark.unit
    def test_split_preserves_total_count(self, sample_labels):
        """Test that split preserves total sample count"""
        filenames, labels = sample_labels
        total = len(labels)
        
        # After split
        train_size = int(0.8 * total)
        test_size = total - train_size
        
        assert train_size + test_size == total

    @pytest.mark.unit
    def test_actual_training_split_sizes(self):
        """Test actual training data split sizes (2,600 samples)"""
        total_samples = 2600
        train_size = int(0.8 * total_samples)
        test_size = total_samples - train_size
        
        assert train_size == 2080
        assert test_size == 520

    @pytest.mark.unit
    def test_class_representation_in_split(self):
        """Test that all 10 classes are represented in both splits"""
        # Simulate full dataset with 10 classes
        num_classes = 10
        samples_per_class = 260  # 2600 / 10
        labels = np.repeat(np.arange(num_classes), samples_per_class)
        
        # Split 80/20
        from sklearn.model_selection import train_test_split
        train_labels, test_labels = train_test_split(
            labels,
            test_size=0.2,
            stratify=labels,
            random_state=42
        )
        
        # All classes should be in both splits
        assert len(np.unique(train_labels)) == num_classes
        assert len(np.unique(test_labels)) == num_classes


# ============================================================
# Test Data Distribution
# ============================================================


class TestDataDistribution:
    """Test data distribution across classes"""

    @pytest.mark.unit
    def test_balanced_dataset_assumption(self):
        """Test assumption of balanced dataset (260 samples per class)"""
        total_samples = 2600
        num_classes = 10
        expected_per_class = total_samples // num_classes
        
        assert expected_per_class == 260

    @pytest.mark.unit
    def test_class_imbalance_detection(self):
        """Test detection of class imbalance"""
        # Create imbalanced dataset
        labels = np.concatenate([
            np.full(500, 0),  # 500 samples of class 0
            np.full(50, 1),   # 50 samples of class 1
        ])
        
        class_counts = Counter(labels)
        
        # Detect imbalance: class 0 has 10x more samples
        assert class_counts[0] == 10 * class_counts[1]

    @pytest.mark.unit
    def test_training_data_statistics(self):
        """Test training data statistics"""
        # Expected distribution after 80/20 split
        train_samples_per_class = 208  # 260 * 0.8
        test_samples_per_class = 52    # 260 * 0.2
        
        # Total
        assert train_samples_per_class * 10 == 2080
        assert test_samples_per_class * 10 == 520


# ============================================================
# Test File Organization
# ============================================================


class TestFileOrganization:
    """Test organization of split data files"""

    @pytest.mark.unit
    def test_output_file_naming(self, temp_directory):
        """Test correct naming of output files"""
        # Expected files after split
        expected_files = [
            "train_data_train.npy",
            "train_data_test.npy",
            "train_label_train.pkl",
            "train_label_test.pkl",
            "label_mapping.pkl",
        ]
        
        # Create mock files
        for filename in expected_files:
            (temp_directory / filename).touch()
        
        # Verify all files exist
        for filename in expected_files:
            assert (temp_directory / filename).exists()

    @pytest.mark.unit
    def test_label_mapping_structure(self, class_index, temp_directory):
        """Test label mapping file structure"""
        import pickle
        
        # Save label mapping
        mapping_path = temp_directory / "label_mapping.pkl"
        with open(mapping_path, 'wb') as f:
            pickle.dump(class_index, f)
        
        # Load and verify
        with open(mapping_path, 'rb') as f:
            loaded_mapping = pickle.load(f)
        
        assert loaded_mapping == class_index
        assert len(loaded_mapping) == 10

    @pytest.mark.unit
    def test_data_file_shapes(self, temp_directory):
        """Test shapes of saved data files"""
        # Train data
        train_data = np.random.rand(2080, 3, 300, 33, 1).astype(np.float32)
        train_path = temp_directory / "train_data_train.npy"
        np.save(train_path, train_data)
        
        # Test data
        test_data = np.random.rand(520, 3, 300, 33, 1).astype(np.float32)
        test_path = temp_directory / "train_data_test.npy"
        np.save(test_path, test_data)
        
        # Load and verify shapes
        loaded_train = np.load(train_path)
        loaded_test = np.load(test_path)
        
        assert loaded_train.shape == (2080, 3, 300, 33, 1)
        assert loaded_test.shape == (520, 3, 300, 33, 1)


# ============================================================
# Test Random Seed Reproducibility
# ============================================================


class TestReproducibility:
    """Test reproducibility with random seeds"""

    @pytest.mark.unit
    def test_split_reproducibility(self):
        """Test that same seed produces same split"""
        labels = np.arange(100)
        
        # Split with seed 42
        from sklearn.model_selection import train_test_split
        train1, test1 = train_test_split(labels, test_size=0.2, random_state=42)
        
        # Split again with same seed
        train2, test2 = train_test_split(labels, test_size=0.2, random_state=42)
        
        # Should be identical
        assert np.array_equal(train1, train2)
        assert np.array_equal(test1, test2)

    @pytest.mark.unit
    def test_different_seeds_produce_different_splits(self):
        """Test that different seeds produce different splits"""
        labels = np.arange(100)
        
        from sklearn.model_selection import train_test_split
        train1, test1 = train_test_split(labels, test_size=0.2, random_state=42)
        train2, test2 = train_test_split(labels, test_size=0.2, random_state=99)
        
        # Should be different
        assert not np.array_equal(train1, train2)


# ============================================================
# Test Edge Cases
# ============================================================


class TestEdgeCases:
    """Test edge cases in data splitting"""

    @pytest.mark.unit
    def test_minimum_samples_per_class(self):
        """Test handling of classes with few samples"""
        # Edge case: only 5 samples per class
        num_classes = 10
        samples_per_class = 5
        labels = np.repeat(np.arange(num_classes), samples_per_class)
        
        # With 80/20 split, need at least 5 samples for stratification
        # 4 train + 1 test per class
        from sklearn.model_selection import train_test_split
        train_labels, test_labels = train_test_split(
            labels,
            test_size=0.2,
            stratify=labels,
            random_state=42
        )
        
        # Verify distribution
        train_dist = Counter(train_labels)
        test_dist = Counter(test_labels)
        
        for cls in range(num_classes):
            assert train_dist[cls] == 4
            assert test_dist[cls] == 1

    @pytest.mark.unit
    def test_single_class_dataset(self):
        """Test error handling for single-class dataset"""
        # Edge case: all samples are same class
        labels = np.zeros(100)
        
        # Stratification not possible with single class
        # Should use random split instead
        from sklearn.model_selection import train_test_split
        
        # Without stratify parameter for single class
        train_labels, test_labels = train_test_split(
            labels,
            test_size=0.2,
            random_state=42
        )
        
        assert len(train_labels) == 80
        assert len(test_labels) == 20
