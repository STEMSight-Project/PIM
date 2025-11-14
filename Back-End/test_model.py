"""Comprehensive model testing suite - architecture agnostic."""

import pytest
import torch
import torch.nn as nn
import numpy as np
import sys
import platform
from pathlib import Path
from collections import Counter, defaultdict
from typing import Dict, List, Tuple, Optional, Any

# Fix Windows console encoding
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')

# Expected class order (CRITICAL: must match training!)
EXPECTED_CLASS_ORDER = [
    'normal', 'decorticate', 'dystonia', 'chorea', 'myoclonus',
    'decerebrate', 'fencer posture', 'ballistic', 'tremor', 'versive head'
]


# ============================================================================
# FIXTURES
# ============================================================================

@pytest.fixture
def device():
    """Get available device."""
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")


@pytest.fixture
def data_dir():
    """Path to dataset directory."""
    return Path("npz_output")


@pytest.fixture
def models_dir():
    """Path to models directory."""
    return Path("models")


@pytest.fixture
def discover_run_dirs():
    """Find all directories with model checkpoints (runs_*, ai_models, models)."""
    root = Path(".")
    dirs_to_search = []
    
    # Add runs_* directories
    dirs_to_search.extend(list(root.glob("runs_*")))
    dirs_to_search.extend(list(root.glob("runs")))
    
    # Add ai_models directory
    ai_models = root / "ai_models"
    if ai_models.exists() and ai_models.is_dir():
        dirs_to_search.append(ai_models)
    
    # Add models directory
    models_dir = root / "models"
    if models_dir.exists() and models_dir.is_dir():
        dirs_to_search.append(models_dir)
    
    # Also check C:\runs if on Windows
    if platform.system() == "Windows" and Path("C:/runs").exists():
        dirs_to_search.append(Path("C:/runs"))
    
    return [d for d in dirs_to_search if d.is_dir()]


@pytest.fixture
def sample_sequences(data_dir):
    """Load sample sequences for testing."""
    if not data_dir.exists():
        pytest.skip(f"Data directory not found: {data_dir}")
    
    files = list(data_dir.glob("*.npz"))[:20]
    if not files:
        pytest.skip(f"No .npz files found in {data_dir}")
    
    sequences = []
    for npz_file in files:
        try:
            data = np.load(npz_file)
            
            # Get sequence data (handle different formats)
            if 'view_0' in data.files:
                seq = data['view_0'][:, :, :3]  # Drop visibility
            elif 'sequences' in data.files:
                seq = data['sequences'][:, :, :3]
            else:
                continue
            
            # Extract true label
            parts = npz_file.name.split('_')
            label = parts[0].lower()
            if label == "fencer":
                label = "fencer posture"
            elif label == "versive":
                label = "versive head"
            
            sequences.append({
                'file': npz_file,
                'sequence': seq,
                'label': label
            })
        except Exception as e:
            print(f"Warning: Could not load {npz_file.name}: {e}")
            continue
    
    if not sequences:
        pytest.skip("No valid sequences loaded")
    
    return sequences


# ============================================================================
# MODEL LOADER - ARCHITECTURE AGNOSTIC
# ============================================================================

class ModelLoader:
    """Universal model loader that handles different architectures."""
    
    @staticmethod
    def load_model(checkpoint_path: Path, device: torch.device) -> Optional[Dict[str, Any]]:
        """
        Load a model checkpoint and return model info.
        
        Returns:
            Dict with 'model', 'type', 'classes', 'input_format' or None if failed
        """
        try:
            checkpoint = torch.load(checkpoint_path, map_location=device, weights_only=False)
            
            # Try different loading strategies
            loader_methods = [
                ModelLoader._load_with_test_live,  # Try train.py models first (multi/single-view)
                ModelLoader._load_bilstm_attention,
                ModelLoader._load_transformer,
                ModelLoader._load_standard_checkpoint,
                ModelLoader._load_with_pim_system,
            ]
            
            for method in loader_methods:
                result = method(checkpoint_path, checkpoint, device)
                if result is not None:
                    return result
            
            print(f"  ⚠️  Unknown checkpoint format")
            print(f"  Keys: {list(checkpoint.keys())[:10]}")
            return None
            
        except Exception as e:
            print(f"  ❌ Error loading: {type(e).__name__}: {e}")
            return None
    
    @staticmethod
    def _load_bilstm_attention(checkpoint_path: Path, checkpoint: dict, device: torch.device) -> Optional[Dict]:
        """Load BiLSTM with Attention model."""
        # Check if it's BiLSTM format
        if not ('lstm.weight_ih_l0' in checkpoint and 'attn.0.weight' in checkpoint):
            return None
        
        try:
            from mediapipe_processor import BiLSTMWithAttention
        except ImportError:
            return None
        
        try:
            # Detect architecture
            num_classes = checkpoint['head.3.weight'].shape[0]
            lstm_layer_nums = [int(k.split('_l')[1][0]) for k in checkpoint.keys() if 'lstm' in k and '_l' in k]
            num_layers = max(lstm_layer_nums) + 1
            input_dim = checkpoint['lstm.weight_ih_l0'].shape[1]
            hidden_dim = checkpoint['head.0.weight'].shape[1] // 2
            
            # Create model
            model = BiLSTMWithAttention(
                input_dim=input_dim,
                hidden_dim=hidden_dim,
                num_layers=num_layers,
                num_classes=num_classes
            )
            model.load_state_dict(checkpoint)
            model.to(device)
            model.eval()
            
            return {
                'model': model,
                'type': 'BiLSTM-Attention',
                'classes': EXPECTED_CLASS_ORDER[:num_classes],
                'input_format': 'flat',  # [B, T, 99]
                'architecture': f"input={input_dim}, hidden={hidden_dim}, layers={num_layers}"
            }
        except Exception as e:
            print(f"  Failed to load as BiLSTM: {e}")
            return None
    
    @staticmethod
    def _load_transformer(checkpoint_path: Path, checkpoint: dict, device: torch.device) -> Optional[Dict]:
        """Load Transformer model."""
        # Check for transformer-specific keys
        if not any('transformer' in k.lower() or 'attention' in k.lower() for k in checkpoint.keys()):
            return None
        
        try:
            from train_big_mv import BigTransformer
        except ImportError:
            return None
        
        try:
            # Try to detect architecture from keys
            # This is a placeholder - adjust based on your actual architecture
            num_classes = len(EXPECTED_CLASS_ORDER)
            
            model = BigTransformer(
                num_classes=num_classes,
                d_model=512, nhead=8, layers=6, ff_dim=2048
            )
            model.load_state_dict(checkpoint)
            model.to(device)
            model.eval()
            
            return {
                'model': model,
                'type': 'Transformer',
                'classes': EXPECTED_CLASS_ORDER[:num_classes],
                'input_format': 'structured',  # [B, T, L, 3]
                'architecture': 'BigTransformer(d=512, h=8, l=6)'
            }
        except Exception as e:
            print(f"  Failed to load as Transformer: {e}")
            return None
    
    @staticmethod
    def _load_standard_checkpoint(checkpoint_path: Path, checkpoint: dict, device: torch.device) -> Optional[Dict]:
        """Load standard checkpoint with model_state_dict."""
        if 'model_state_dict' not in checkpoint and 'model' not in checkpoint:
            return None
        
        state_dict = checkpoint.get('model_state_dict', checkpoint.get('model'))
        classes = checkpoint.get('classes', checkpoint.get('active_classes', EXPECTED_CLASS_ORDER))
        
        # Get model type if available
        model_type = checkpoint.get('model_type', 'Unknown')
        
        # Check if this is a PoseTCN single-view model (from pose-tcn_single_view.py)
        if 'backbone.stem.0.weight' in state_dict and 'head.weight' in state_dict:
            try:
                # Import PoseTCNSingleView from pose-tcn_single_view.py
                import importlib.util
                pose_tcn_path = Path(__file__).parent / "pose-tcn_single_view.py"
                if pose_tcn_path.exists():
                    spec = importlib.util.spec_from_file_location("pose_tcn_single_view", pose_tcn_path)
                    if spec and spec.loader:
                        pose_tcn_module = importlib.util.module_from_spec(spec)
                        spec.loader.exec_module(pose_tcn_module)
                        
                        # Reconstruct model from checkpoint args
                        args = checkpoint.get('args', {})
                        num_classes = len(classes)
                        width = args.get('width', 384)
                        dilations = args.get('dilations', [1, 2, 4, 8, 16, 32])
                        if isinstance(dilations, str):
                            dilations = [int(x.strip()) for x in dilations.split(',')]
                        
                        model = pose_tcn_module.PoseTCNSingleView(
                            num_classes=num_classes,
                            width=width,
                            drop=args.get('dropout', 0.1),
                            stochastic_depth=args.get('stochastic_depth', 0.05),
                            dilations=dilations,
                            norm=args.get('norm', 'bn'),
                            t_heads=args.get('t_heads', 4),
                            attn_dropout=args.get('attn_dropout', 0.0)
                        )
                        
                        model.load_state_dict(state_dict)
                        model.to(device)
                        model.eval()
                        
                        temperature = checkpoint.get('best_temperature', 1.0)
                        
                        return {
                            'model': model,
                            'type': 'PoseTCN-SingleView',
                            'classes': classes,
                            'num_views': 1,
                            'landmarks_per_view': 33,
                            'temperature': temperature,
                            'input_format': 'live_format',
                            'architecture': f'PoseTCN-SingleView (width={width})'
                        }
            except Exception as e:
                print(f"  Failed to load as PoseTCN-SingleView: {e}")
        
        # Check for LSTM models
        if any('lstm' in key.lower() for key in state_dict.keys()):
            try:
                from mediapipe_processor import BiLSTMWithAttention
                
                # Detect architecture from state dict
                num_classes = state_dict['head.3.weight'].shape[0] if 'head.3.weight' in state_dict else len(classes)
                lstm_layer_nums = [int(k.split('_l')[1][0]) for k in state_dict.keys() if 'lstm' in k and '_l' in k]
                num_layers = max(lstm_layer_nums) + 1 if lstm_layer_nums else 2
                input_dim = state_dict['lstm.weight_ih_l0'].shape[1] if 'lstm.weight_ih_l0' in state_dict else 99
                hidden_dim = state_dict['head.0.weight'].shape[1] // 2 if 'head.0.weight' in state_dict else 256
                
                model = BiLSTMWithAttention(
                    input_dim=input_dim,
                    hidden_dim=hidden_dim,
                    num_layers=num_layers,
                    num_classes=num_classes
                )
                model.load_state_dict(state_dict)
                model.to(device)
                model.eval()
                
                return {
                    'model': model,
                    'type': model_type if model_type != 'Unknown' else 'BiLSTM-Attention',
                    'classes': classes,
                    'input_format': 'flat',
                    'architecture': f"BiLSTM(input={input_dim}, hidden={hidden_dim}, layers={num_layers})"
                }
            except Exception as e:
                print(f"  Failed to load as BiLSTM: {e}")
        
        return None
    
    @staticmethod
    def _load_with_test_live(checkpoint_path: Path, checkpoint: dict, device: torch.device) -> Optional[Dict]:
        """Load using test_live.py loader (supports train.py models)."""
        try:
            from test_live import load_ckpt
        except ImportError:
            return None
        
        try:
            model, classes, num_views, landmarks_per_view, model_type, expects_hands, temperature = load_ckpt(
                str(checkpoint_path), device
            )
            
            return {
                'model': model,
                'type': model_type,
                'classes': classes,
                'num_views': num_views,
                'landmarks_per_view': landmarks_per_view,
                'temperature': temperature,
                'input_format': 'live_format',  # (B, T, num_views * landmarks * 3)
                'architecture': f'{model_type} (train.py)'
            }
        except Exception as e:
            print(f"  Failed to load with test_live: {e}")
            return None
    
    @staticmethod
    def _load_with_pim_system(checkpoint_path: Path, checkpoint: dict, device: torch.device) -> Optional[Dict]:
        """Load using pim_detection_system if available."""
        try:
            from pim_detection_system import load_trained_model
        except ImportError:
            return None
        
        try:
            model, movements, model_type = load_trained_model(str(checkpoint_path))
            model.to(device)
            model.eval()
            
            return {
                'model': model,
                'type': model_type,
                'classes': movements,
                'input_format': 'auto',
                'architecture': 'loaded via pim_detection_system'
            }
        except Exception as e:
            print(f"  Failed to load with pim_detection_system: {e}")
            return None


# ============================================================================
# MODEL TESTER - ARCHITECTURE AGNOSTIC
# ============================================================================

class ModelTester:
    """Test model behavior regardless of architecture."""
    
    @staticmethod
    def prepare_input(sequence: np.ndarray, model_info: Dict, target_length: int = 120) -> torch.Tensor:
        """Prepare input tensor based on model's expected format."""
        input_format = model_info.get('input_format', 'auto')
        num_views = model_info.get('num_views', 1)
        
        # Ensure we have enough frames
        if len(sequence) < target_length:
            # Pad if too short
            pad_length = target_length - len(sequence)
            sequence = np.pad(sequence, ((0, pad_length), (0, 0), (0, 0)), mode='edge')
        else:
            # Truncate if too long
            sequence = sequence[:target_length]
        
        # Normalize the pose data (required for train.py models)
        if input_format == 'live_format':
            sequence = ModelTester._normalize_pose(sequence)
        
        if input_format == 'live_format':
            # Models from train.py or train_single_view.py
            # Flatten landmarks: [T, L, 3] -> [T, L*3]
            sequence_flat = sequence.reshape(len(sequence), -1)  # [T, L*3]
            
            # Multi-view models expect [B, T, D*num_views] (views concatenated along feature dim)
            if num_views > 1:
                # Tile the single view to match expected views (concatenate along feature dimension)
                # Add small noise to differentiate views (like test_live.py does)
                views = [sequence_flat]
                for v in range(1, num_views):
                    noise = np.random.randn(*sequence_flat.shape).astype(np.float32) * 0.02
                    views.append(sequence_flat + noise)
                sequence_flat = np.concatenate(views, axis=1)  # [T, L*3*num_views]
                tensor = torch.FloatTensor(sequence_flat).unsqueeze(0)  # [1, T, L*3*num_views]
            else:
                # Single-view models expect [B, T, D]
                tensor = torch.FloatTensor(sequence_flat).unsqueeze(0)  # [1, T, L*3]
            
            return tensor
        
        elif input_format == 'flat':
            # Flatten landmarks: [T, L, 3] -> [T, L*3]
            sequence_flat = sequence.reshape(len(sequence), -1)
            return torch.FloatTensor(sequence_flat).unsqueeze(0)  # [1, T, L*3]
        
        elif input_format == 'structured':
            # Keep structure: [T, L, 3]
            return torch.FloatTensor(sequence).unsqueeze(0)  # [1, T, L, 3]
        
        else:  # 'auto'
            # Try to infer from sequence shape
            if sequence.shape[1] > 50:  # Likely flattened already
                return torch.FloatTensor(sequence).unsqueeze(0)
            else:
                return torch.FloatTensor(sequence).unsqueeze(0)
    
    @staticmethod
    def _normalize_pose(seq: np.ndarray) -> np.ndarray:
        """Normalize pose sequence to unit scale (matching train.py normalization)."""
        # seq shape: (T, 33, 3)
        # Compute all pairwise distances across all frames
        distances = []
        for t in range(seq.shape[0]):
            frame = seq[t]  # (33, 3)
            for i in range(len(frame)):
                for j in range(i + 1, len(frame)):
                    d = np.linalg.norm(frame[i] - frame[j])
                    distances.append(d)
        
        # Use median distance as scale
        if len(distances) > 0:
            scale = np.median(distances)
            if scale > 1e-6:
                seq = seq / scale
        
        return seq
    
    @staticmethod
    def test_extreme_inputs(model_info: Dict, device: torch.device) -> Dict[str, Any]:
        """Test model with extreme inputs to detect collapse."""
        model = model_info['model']
        input_format = model_info['input_format']
        classes = model_info['classes']
        num_views = model_info.get('num_views', 1)
        
        # Determine input shape based on format
        if input_format == 'live_format':
            if num_views > 1:
                # Multi-view: [B, num_views, T, D]
                shape = (1, num_views, 120, 99)
            else:
                # Single-view: [B, T, D]
                shape = (1, 120, 99)
        elif input_format == 'flat':
            shape = (1, 120, 99)  # [B, T, L*3]
        else:
            shape = (1, 120, 33, 3)  # [B, T, L, 3]
        
        test_cases = [
            ("All zeros", torch.zeros(shape)),
            ("All ones", torch.ones(shape)),
            ("Small noise", torch.randn(shape) * 0.01),
            ("Large noise", torch.randn(shape) * 100),
            ("Negative", torch.ones(shape) * -10),
            ("Positive", torch.ones(shape) * 10),
            ("Sequential", torch.arange(np.prod(shape)).reshape(shape).float() * 0.01),
            ("Alternating", torch.tensor(([1, -1] * (np.prod(shape)//2 + 1))[:np.prod(shape)]).reshape(shape).float()),
        ]
        
        predictions = []
        all_logits = []
        
        for name, input_data in test_cases:
            input_data = input_data.to(device)
            
            with torch.no_grad():
                result = model(input_data)
                
                # Handle tuple output (some models return (output, attention))
                if isinstance(result, tuple):
                    output = result[0]
                else:
                    output = result
                
                probs = torch.softmax(output, dim=1)
                confidence, predicted = torch.max(probs, 1)
            
            pred_class = classes[predicted.item()] if predicted.item() < len(classes) else f"class_{predicted.item()}"
            predictions.append(pred_class)
            all_logits.append(output[0].cpu().numpy())
        
        # Analysis
        all_logits_array = np.array(all_logits)
        logit_variance = all_logits_array.std(axis=0).mean()
        unique_preds = set(predictions)
        counter = Counter(predictions)
        max_class_count = counter.most_common(1)[0][1]
        
        return {
            'predictions': predictions,
            'unique_classes': len(unique_preds),
            'logit_variance': logit_variance,
            'collapse_ratio': max_class_count / len(predictions),
            'counter': counter
        }
    
    @staticmethod
    def test_real_data(model_info: Dict, sequences: List[Dict], device: torch.device) -> Dict[str, Any]:
        """Test model with real data sequences."""
        model = model_info['model']
        input_format = model_info['input_format']
        classes = model_info['classes']
        
        predictions = []
        confidences = []
        matches = []
        
        for seq_info in sequences:
            sequence = seq_info['sequence']
            true_label = seq_info['label']
            
            # Prepare input
            tensor = ModelTester.prepare_input(sequence, model_info).to(device)
            
            with torch.no_grad():
                result = model(tensor)
                if isinstance(result, tuple):
                    output = result[0]
                else:
                    output = result
                
                probs = torch.softmax(output, dim=1)
                conf, pred = torch.max(probs, 1)
            
            pred_idx = pred.item()
            pred_class = classes[pred_idx] if pred_idx < len(classes) else f"class_{pred_idx}"
            
            predictions.append(pred_class)
            confidences.append(conf.item())
            matches.append(pred_class == true_label)
        
        # Analysis
        counter = Counter(predictions)
        accuracy = sum(matches) / len(matches) if matches else 0
        
        return {
            'predictions': predictions,
            'counter': counter,
            'accuracy': accuracy,
            'avg_confidence': np.mean(confidences),
            'collapse_ratio': counter.most_common(1)[0][1] / len(predictions)
        }


# ============================================================================
# PYTEST TEST CLASSES
# ============================================================================

class TestModelArchitectures:
    """Test that models can be loaded and have correct architecture."""
    
    def test_discover_all_models(self, discover_run_dirs):
        """Discover all model checkpoints in runs, ai_models, and models folders."""
        if not discover_run_dirs:
            pytest.skip("No model directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for .pt and .pth files
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        print(f"\n{'='*80}")
        print(f"DISCOVERED MODELS")
        print(f"{'='*80}")
        print(f"\nSearching in: {[str(d) for d in discover_run_dirs]}\n")
        
        for ckpt in sorted(checkpoints):
            # Show relative path from Back-End directory
            try:
                rel = ckpt.relative_to(Path.cwd())
            except ValueError:
                rel = ckpt
            print(f"  {rel}")
        
        assert len(checkpoints) > 0, f"No model checkpoints found in: {discover_run_dirs}"
        print(f"\nTotal: {len(checkpoints)} checkpoints")
    
    def test_load_all_models(self, discover_run_dirs, device):
        """Test that all models in ai_models, models, and runs folders can be loaded."""
        if not discover_run_dirs:
            pytest.skip("No model directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for .pt and .pth files
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        print(f"\n{'='*80}")
        print(f"LOADING ALL MODELS")
        print(f"{'='*80}")
        print(f"Searching in: {[str(d.name) for d in discover_run_dirs]}\n")
        
        results = {}
        
        for ckpt in sorted(checkpoints):
            # Create readable path
            try:
                rel_path = ckpt.relative_to(Path.cwd())
            except ValueError:
                rel_path = ckpt
            
            print(f"\n{rel_path}")
            print("-" * 80)
            
            model_info = ModelLoader.load_model(ckpt, device)
            
            if model_info:
                print(f"  ✅ Type: {model_info['type']}")
                print(f"  Architecture: {model_info['architecture']}")
                print(f"  Classes: {len(model_info['classes'])}")
                print(f"  Input format: {model_info['input_format']}")
                
                if model_info['classes'] != EXPECTED_CLASS_ORDER[:len(model_info['classes'])]:
                    print(f"  ⚠️  WARNING: Class order mismatch!")
                    print(f"     Expected: {EXPECTED_CLASS_ORDER[:len(model_info['classes'])]}")
                    print(f"     Got: {model_info['classes']}")
                
                results[rel_path] = 'success'
            else:
                print(f"  ❌ Failed to load")
                results[rel_path] = 'failed'
        
        print(f"\n{'='*80}")
        print(f"SUMMARY")
        print(f"{'='*80}")
        
        success = sum(1 for r in results.values() if r == 'success')
        failed = sum(1 for r in results.values() if r == 'failed')
        
        print(f"Successfully loaded: {success}/{len(results)}")
        print(f"Failed to load: {failed}/{len(results)}")
        
        assert success > 0, "No models could be loaded"


class TestModelSanity:
    
    def test_all_models_extreme_inputs(self, discover_run_dirs, device):
        """Test all models with extreme inputs."""
        if not discover_run_dirs:
            pytest.skip("No runs_* directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            checkpoints.extend(run_dir.glob("*.pt"))
            checkpoints.extend(run_dir.glob("*.pth"))
        
        print(f"\n{'='*80}")
        print(f"MODEL SANITY CHECK - EXTREME INPUTS")
        print(f"{'='*80}")
        
        results = {}
        
        for ckpt in sorted(checkpoints):
            rel_path = f"{ckpt.parent.name}/{ckpt.name}"
            print(f"\n{rel_path}")
            print("-" * 80)
            
            model_info = ModelLoader.load_model(ckpt, device)
            
            if not model_info:
                print("  ⏭️  Skipped (could not load)")
                results[rel_path] = 'skipped'
                continue
            
            test_results = ModelTester.test_extreme_inputs(model_info, device)
            
            print(f"  Unique predictions: {test_results['unique_classes']}/{len(model_info['classes'])}")
            print(f"  Logit variance: {test_results['logit_variance']:.6f}")
            print(f"  Collapse ratio: {test_results['collapse_ratio']*100:.1f}%")
            
            issues = 0
            
            if test_results['unique_classes'] == 1:
                print(f"  ❌ CRITICAL: Same class for all inputs!")
                issues += 3
            elif test_results['unique_classes'] < len(model_info['classes']) * 0.3:
                print(f"  ⚠️  WARNING: Only uses {test_results['unique_classes']} classes")
                issues += 1
            else:
                print(f"  ✅ Uses {test_results['unique_classes']} classes")
            
            if test_results['logit_variance'] < 0.1:
                print(f"  ❌ CRITICAL: Frozen weights (variance={test_results['logit_variance']:.6f})")
                issues += 3
            elif test_results['logit_variance'] < 1.0:
                print(f"  ⚠️  WARNING: Low variance ({test_results['logit_variance']:.3f})")
                issues += 1
            else:
                print(f"  ✅ Good variance ({test_results['logit_variance']:.3f})")
            
            if test_results['collapse_ratio'] >= 1.0:
                print(f"  ❌ CRITICAL: 100% one class")
                issues += 2
            elif test_results['collapse_ratio'] > 0.8:
                print(f"  ⚠️  WARNING: {test_results['collapse_ratio']*100:.1f}% one class")
                issues += 1
            else:
                print(f"  ✅ Distributed predictions")
            
            # Overall verdict
            if issues >= 5:
                verdict = 'collapsed'
                print(f"\n  🔥 VERDICT: COLLAPSED")
            elif issues >= 3:
                verdict = 'severe'
                print(f"\n  ⚠️  VERDICT: SEVERE ISSUES")
            elif issues >= 1:
                verdict = 'moderate'
                print(f"\n  ⚠️  VERDICT: MODERATE ISSUES")
            else:
                verdict = 'good'
                print(f"\n  ✅ VERDICT: FUNCTIONAL")
            
            results[ckpt.name] = verdict
        
        # Summary
        print(f"\n{'='*80}")
        print(f"SANITY CHECK SUMMARY")
        print(f"{'='*80}")
        
        for verdict in ['good', 'moderate', 'severe', 'collapsed']:
            models = [name for name, v in results.items() if v == verdict]
            if models:
                icon = {'good': '✅', 'moderate': '⚠️ ', 'severe': '⚠️ ', 'collapsed': '❌'}[verdict]
                print(f"\n{icon} {verdict.upper()} ({len(models)}):")
                for name in models:
                    print(f"  - {name}")


class TestModelRealData:
    
    def test_all_models_real_data(self, discover_run_dirs, sample_sequences, device):
        """Test all models with real sequences."""
        if not discover_run_dirs:
            pytest.skip("No runs_* directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for checkpoints
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        print(f"\n{'='*80}")
        print(f"REAL DATA TESTING")
        print(f"{'='*80}")
        print(f"Testing with {len(sample_sequences)} sequences\n")
        
        results = {}
        
        for ckpt in sorted(checkpoints):
            rel_path = f"{ckpt.parent.name}/{ckpt.name}"
            print(f"\n{rel_path}")
            print("-" * 80)
            
            model_info = ModelLoader.load_model(ckpt, device)
            
            if not model_info:
                print("  ⏭️  Skipped (could not load)")
                results[rel_path] = {'status': 'skipped'}
                continue
            
            test_results = ModelTester.test_real_data(model_info, sample_sequences, device)
            
            print(f"  Accuracy: {test_results['accuracy']*100:.1f}%")
            print(f"  Avg confidence: {test_results['avg_confidence']:.3f}")
            print(f"  Collapse ratio: {test_results['collapse_ratio']*100:.1f}%")
            
            print(f"\n  Prediction distribution:")
            for cls, count in test_results['counter'].most_common():
                pct = 100 * count / len(sample_sequences)
                print(f"    {cls:20s}: {count:3d} ({pct:5.1f}%)")
            
            if test_results['collapse_ratio'] > 0.8:
                print(f"\n  ❌ COLLAPSED on real data")
                verdict = 'collapsed'
            elif test_results['accuracy'] < 0.2:
                print(f"\n  ⚠️  Very low accuracy")
                verdict = 'poor'
            elif test_results['accuracy'] < 0.5:
                print(f"\n  ⚠️  Low accuracy")
                verdict = 'moderate'
            else:
                print(f"\n  ✅ Reasonable performance")
                verdict = 'good'
            
            results[rel_path] = {
                'status': verdict,
                'accuracy': test_results['accuracy'],
                'collapse_ratio': test_results['collapse_ratio']
            }
        
        print(f"\n{'='*80}")
        print(f"REAL DATA SUMMARY")
        print(f"{'='*80}")
        
        working = [(n, r) for n, r in results.items() if r.get('status') == 'good']
        moderate = [(n, r) for n, r in results.items() if r.get('status') == 'moderate']
        poor = [(n, r) for n, r in results.items() if r.get('status') == 'poor']
        collapsed = [(n, r) for n, r in results.items() if r.get('status') == 'collapsed']
        
        if working:
            print(f"\n✅ WORKING MODELS ({len(working)}):")
            for name, res in sorted(working, key=lambda x: x[1].get('accuracy', 0), reverse=True):
                acc = res.get('accuracy', 0)
                print(f"  - {name:50s} (acc: {acc*100:.1f}%)")
        
        if moderate:
            print(f"\n⚠️  MODERATE MODELS ({len(moderate)}):")
            for name, res in sorted(moderate, key=lambda x: x[1].get('accuracy', 0), reverse=True):
                acc = res.get('accuracy', 0)
                print(f"  - {name:50s} (acc: {acc*100:.1f}%)")
        
        if poor:
            print(f"\n⚠️  POOR MODELS ({len(poor)}):")
            for name, res in sorted(poor, key=lambda x: x[1].get('accuracy', 0), reverse=True):
                acc = res.get('accuracy', 0)
                print(f"  - {name:50s} (acc: {acc*100:.1f}%)")
        
        if collapsed:
            print(f"\n❌ COLLAPSED MODELS ({len(collapsed)}):")
            for name, res in list(sorted(collapsed, key=lambda x: x[1].get('collapse_ratio', 1)))[:5]:
                collapse_ratio = res.get('collapse_ratio', 1)
                print(f"  - {name:50s} (collapse: {collapse_ratio*100:.1f}%)")
            if len(collapsed) > 5:
                print(f"  ... and {len(collapsed) - 5} more")
        
        if not working:
            print("\n⚠️  No models with >50% accuracy found. This test reveals model quality issues.")
            print("    Consider: 1) Training new models, 2) Checking data/normalization, 3) Reviewing architecture")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])