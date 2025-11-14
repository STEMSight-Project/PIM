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
# HELPER FUNCTIONS
# ============================================================================

def _generate_synthetic_sequences():
    """Generate synthetic test sequences when real data is not available.
    
    Creates realistic pose sequences with variation for each class.
    Returns the same format as sample_sequences fixture.
    """
    print(f"  Generating 20 synthetic sequences (2 per class)...")
    
    sequences = []
    classes = EXPECTED_CLASS_ORDER
    samples_per_class = 2
    
    for class_idx, class_name in enumerate(classes):
        for sample_idx in range(samples_per_class):
            # Generate realistic pose sequence
            T = 120  # Standard temporal length
            L = 33   # MediaPipe pose landmarks
            
            # Create base pose with natural variations
            np.random.seed(class_idx * 100 + sample_idx)
            
            # Start with normalized skeleton (centered at origin, scaled to ~1.0)
            base_pose = np.random.randn(L, 3) * 0.3
            
            # Add temporal variation (movement patterns)
            temporal_noise = np.random.randn(T, L, 3) * 0.05
            
            # Create sequence with smooth transitions
            sequence = np.zeros((T, L, 3), dtype=np.float32)
            for t in range(T):
                # Smooth temporal evolution
                alpha = t / T
                sequence[t] = base_pose + temporal_noise[t] + np.sin(alpha * 2 * np.pi) * 0.1
            
            # Add class-specific patterns
            if class_name == 'tremor':
                # Add high-frequency oscillation
                for t in range(T):
                    sequence[t] += np.sin(t * 0.5) * 0.2
            elif class_name == 'chorea':
                # Add irregular jerky movements
                jerk_frames = np.random.choice(T, size=T//5, replace=False)
                sequence[jerk_frames] += np.random.randn(len(jerk_frames), L, 3) * 0.5
            elif class_name in ['decorticate', 'decerebrate', 'fencer posture']:
                # Add sustained abnormal posture
                posture_offset = np.random.randn(L, 3) * 0.4
                sequence += posture_offset[np.newaxis, :, :]
            
            sequences.append({
                'file': Path(f"synthetic_{class_name.replace(' ', '_')}_{sample_idx}.npz"),
                'sequence': sequence,
                'label': class_name
            })
    
    print(f"  ✅ Generated {len(sequences)} synthetic sequences")
    return sequences


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
    """Find all model checkpoint directories including ai_models, models, and runs_*."""
    root = Path(".")
    dirs_to_search = []
    
    # Add ai_models directory if it exists
    ai_models = root / "ai_models"
    if ai_models.exists():
        dirs_to_search.append(ai_models)
    
    # Add models directory if it exists
    models_dir = root / "models"
    if models_dir.exists():
        dirs_to_search.append(models_dir)
    
    # Add runs_* directories
    dirs_to_search.extend(list(root.glob("runs_*")) + list(root.glob("runs")))
    
    # Also check C:\runs if on Windows
    if platform.system() == "Windows" and Path("C:/runs").exists():
        dirs_to_search.append(Path("C:/runs"))
    
    return [d for d in dirs_to_search if d.is_dir()]


@pytest.fixture
def sample_sequences(data_dir):
    """Load sample sequences for testing - stratified sampling across all classes.
    If no real data is available, generates synthetic sequences for testing."""
    
    # Check if real data exists
    if not data_dir.exists() or not list(data_dir.glob("*.npz")):
        print(f"\n⚠️  No real data found in {data_dir}, generating synthetic test data...")
        return _generate_synthetic_sequences()
    
    all_files = list(data_dir.glob("*.npz"))
    
    # Group files by class (extracted from filename)
    files_by_class = defaultdict(list)
    for npz_file in all_files:
        parts = npz_file.name.split('_')
        label = parts[0].lower()
        if label == "fencer":
            label = "fencer posture"
        elif label == "versive":
            label = "versive head"
        files_by_class[label].append(npz_file)
    
    # Sample 2-3 files per class to get diverse representation
    samples_per_class = 2
    sampled_files = []
    for label in sorted(files_by_class.keys()):
        class_files = files_by_class[label]
        # Take evenly spaced samples from each class
        step = max(1, len(class_files) // samples_per_class)
        sampled = class_files[::step][:samples_per_class]
        sampled_files.extend(sampled)
    
    print(f"\n📊 Sampling {len(sampled_files)} sequences from {len(files_by_class)} classes:")
    for label in sorted(files_by_class.keys()):
        count = sum(1 for f in sampled_files if f.name.startswith(label.replace(" ", "_")))
        print(f"  {label:20s}: {count} samples")
    
    sequences = []
    for npz_file in sampled_files:
        try:
            data = np.load(npz_file)
            
            # Get sequence data (handle different formats)
            # For multi-view models, load all 3 views; for single-view, just use view_0
            if 'view_0' in data.files:
                view_0 = data['view_0'][:, :, :3]  # Drop visibility channel
                
                # Check if other views exist for multi-view support
                if 'view_1' in data.files and 'view_2' in data.files:
                    view_1 = data['view_1'][:, :, :3]
                    view_2 = data['view_2'][:, :, :3]
                    # Stack views: shape becomes (T, 3, 33, 3) = (T, views, landmarks, coords)
                    seq = np.stack([view_0, view_1, view_2], axis=1)
                else:
                    # Only one view available
                    seq = view_0
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
    
    print(f"✅ Loaded {len(sequences)} sequences for testing\n")
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
        
        # Check if this is a PoseTCN-SingleView model
        if 'backbone.stem.0.weight' in state_dict and 'head.weight' in state_dict:
            try:
                # This is likely a PoseTCN-SingleView model
                import importlib.util
                
                # Load the pose-tcn_single_view.py module dynamically
                module_path = Path(__file__).parent / "pose-tcn_single_view.py"
                if not module_path.exists():
                    print(f"  Warning: pose-tcn_single_view.py not found at {module_path}")
                    return None
                
                spec = importlib.util.spec_from_file_location("pose_tcn_single", str(module_path))
                if spec is None or spec.loader is None:
                    print("  Warning: Could not load pose-tcn_single_view.py spec")
                    return None
                
                pose_tcn_module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(pose_tcn_module)
                PoseTCNSingleView = pose_tcn_module.PoseTCNSingleView
                
                # Get architecture parameters from checkpoint
                args = checkpoint.get('args', {})
                num_classes = len(classes) if isinstance(classes, list) else 10
                
                # Parse dilations if stored as string
                dilations = args.get('dilations', [1, 2, 4, 8, 16, 32])
                if isinstance(dilations, str):
                    dilations = [int(x.strip()) for x in dilations.split(',')]
                
                # Handle both 'drop' and 'dropout' parameter names
                drop_val = args.get('drop', args.get('dropout', 0.1))
                
                # Reconstruct model with same architecture
                model = PoseTCNSingleView(
                    num_classes=num_classes,
                    width=args.get('width', 384),
                    dilations=dilations,
                    drop=drop_val,
                    stochastic_depth=args.get('stochastic_depth', 0.05),
                    norm=args.get('norm', 'bn'),
                    t_heads=args.get('t_heads', 4),
                    attn_dropout=args.get('attn_dropout', 0.0)
                )
                
                # Load state dict
                model.load_state_dict(state_dict)
                model.to(device)
                model.eval()
                
                # Get temperature if available
                temperature = checkpoint.get('best_temperature', 1.0)
                
                return {
                    'model': model,
                    'type': 'PoseTCN-SingleView',
                    'classes': classes if isinstance(classes, list) else EXPECTED_CLASS_ORDER[:num_classes],
                    'input_format': 'live_format',  # [B, T, L*3]
                    'architecture': f"PoseTCN-SingleView (width={args.get('width', 384)})",
                    'temperature': temperature
                }
            except Exception as e:
                print(f"  Failed to load as PoseTCN-SingleView: {e}")
                return None
        
        # Try to infer model type from state dict keys
        if 'lstm' in str(list(state_dict.keys())).lower():
            return ModelLoader._load_bilstm_attention(checkpoint_path, state_dict, device)
        elif 'transformer' in str(list(state_dict.keys())).lower():
            return ModelLoader._load_transformer(checkpoint_path, state_dict, device)
        
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
        
        # Check if sequence has multiple views: shape (T, V, L, 3) or single view: (T, L, 3)
        has_multiple_views = (sequence.ndim == 4 and sequence.shape[1] == 3)
        
        if has_multiple_views:
            # Multi-view data: (T, 3, 33, 3)
            T, V, L, C = sequence.shape
            
            # If model expects only 1 view, extract just the first view
            if num_views == 1:
                sequence = sequence[:, 0, :, :]  # Extract first view: (T, 33, 3)
                has_multiple_views = False  # Process as single-view below
            else:
                # Model expects multiple views
                # Ensure we have enough frames
                if T < target_length:
                    pad_length = target_length - T
                    sequence = np.pad(sequence, ((0, pad_length), (0, 0), (0, 0), (0, 0)), mode='edge')
                else:
                    sequence = sequence[:target_length]
                
                # Normalize each view separately (required for train.py models)
                if input_format == 'live_format':
                    for v in range(V):
                        sequence[:, v, :, :] = ModelTester._normalize_pose(sequence[:, v, :, :])
                
                # Flatten each view and concatenate: [T, V, L, 3] -> [T, V*L*3]
                T = sequence.shape[0]
                sequence_flat = sequence.reshape(T, -1)  # [T, V*L*3]
                tensor = torch.FloatTensor(sequence_flat).unsqueeze(0)  # [1, T, V*L*3]
                return tensor
        
        if not has_multiple_views:
            # Single-view data: (T, L, 3)
            # Ensure we have enough frames
            if len(sequence) < target_length:
                pad_length = target_length - len(sequence)
                sequence = np.pad(sequence, ((0, pad_length), (0, 0), (0, 0)), mode='edge')
            else:
                sequence = sequence[:target_length]
            
            # Normalize the pose data (required for train.py models)
            if input_format == 'live_format':
                sequence = ModelTester._normalize_pose(sequence)
            
            if input_format == 'live_format':
                # Flatten landmarks: [T, L, 3] -> [T, L*3]
                sequence_flat = sequence.reshape(len(sequence), -1)  # [T, L*3]
                
                # Multi-view models expect [B, T, D*num_views] (views concatenated along feature dim)
                if num_views > 1:
                    # FALLBACK: Tile single view with noise (suboptimal, but data only has 1 view)
                    print(f"  ⚠️  Model expects {num_views} views but data has only 1 - tiling with noise")
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
        """
        Normalize pose sequence using EXACT same method as train.py.
        Centers by hips (or shoulders), scales by robust median of key distances.
        seq shape: (T, 33, 3)
        """
        # Landmark indices (matching train.py)
        L_SHOULDER, R_SHOULDER = 11, 12
        L_HIP, R_HIP = 23, 24
        
        num_pose_landmarks = 33
        pose = seq[:, :num_pose_landmarks, :]
        
        # Center by hips (fallback to shoulders if hips not visible)
        hips_ok = (np.any(pose[:, L_HIP] != 0, axis=1) & np.any(pose[:, R_HIP] != 0, axis=1))
        ctr = np.where(hips_ok[:, None],
                       0.5 * (pose[:, L_HIP] + pose[:, R_HIP]),
                       0.5 * (pose[:, L_SHOULDER] + pose[:, R_SHOULDER]))
        seq = seq - ctr[:, None, :]
        
        # Compute scale from specific landmark pairs (more robust)
        def safe_pair(a, b):
            va, vb = pose[:, a], pose[:, b]
            valid = (np.any(va != 0, axis=1) & np.any(vb != 0, axis=1))
            d = np.full(len(va), np.nan, np.float32)
            if valid.any():
                d[valid] = np.linalg.norm(va[valid] - vb[valid], axis=1).astype(np.float32)
            return d
        
        vals = np.concatenate([
            safe_pair(L_SHOULDER, R_SHOULDER),
            safe_pair(L_HIP, R_HIP),
            safe_pair(L_SHOULDER, L_HIP)
        ])
        vals = vals[np.isfinite(vals)]
        scale = float(np.median(vals)) if vals.size else 1.0
        if (not np.isfinite(scale)) or scale < 1e-3:
            scale = 1.0
        
        # Scale, clip, and handle NaN (exactly as train.py does)
        seq = seq / scale
        seq = np.clip(seq, -10.0, 10.0)
        seq = np.nan_to_num(seq, nan=0.0).astype(np.float32)
        
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
        true_labels = []
        prediction_details = []  # Store full prediction info for database
        
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
            true_labels.append(true_label)
            matches.append(pred_class == true_label)
            
            # Store detailed prediction for database
            all_probs = {
                classes[i]: float(probs[0, i].item()) 
                for i in range(min(len(classes), probs.size(1)))
            }
            prediction_details.append({
                'predicted_class': pred_class,
                'true_label': true_label,
                'confidence': conf.item(),
                'correct': pred_class == true_label,
                'probabilities': all_probs,
                'file': str(seq_info['file'].name) if 'file' in seq_info else 'unknown'
            })
        
        # Analysis
        counter = Counter(predictions)
        accuracy = sum(matches) / len(matches) if matches else 0
        
        # Per-class accuracy
        per_class_correct = defaultdict(int)
        per_class_total = defaultdict(int)
        for true, pred in zip(true_labels, predictions):
            per_class_total[true] += 1
            if true == pred:
                per_class_correct[true] += 1
        
        per_class_acc = {
            cls: per_class_correct[cls] / per_class_total[cls] 
            for cls in per_class_total
        }
        
        return {
            'predictions': predictions,
            'true_labels': true_labels,
            'counter': counter,
            'accuracy': accuracy,
            'avg_confidence': np.mean(confidences),
            'collapse_ratio': counter.most_common(1)[0][1] / len(predictions),
            'per_class_accuracy': per_class_acc,
            'per_class_total': dict(per_class_total),
            'prediction_details': prediction_details  # Add for database storage
        }


# ============================================================================
# PYTEST TEST CLASSES
# ============================================================================

class TestModelArchitectures:
    """Test that models can be loaded and have correct architecture."""
    
    def test_discover_all_models(self, discover_run_dirs):
        """Discover all model checkpoints in runs folders."""
        if not discover_run_dirs:
            pytest.skip("No runs_* directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for .pt and .pth files
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        print(f"\n{'='*80}")
        print(f"DISCOVERED MODELS IN RUNS FOLDERS")
        print(f"{'='*80}")
        
        for ckpt in sorted(checkpoints):
            print(f"  {ckpt.relative_to(ckpt.parents[1])}")
        
        assert len(checkpoints) > 0, "No model checkpoints found in runs_* directories"
        print(f"\nTotal: {len(checkpoints)} checkpoints")
    
    def test_load_all_models(self, discover_run_dirs, device):
        """Test that all models in runs folders can be loaded."""
        if not discover_run_dirs:
            pytest.skip("No runs_* directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for .pt and .pth files
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        print(f"\n{'='*80}")
        print(f"LOADING ALL MODELS FROM RUNS FOLDERS")
        print(f"{'='*80}")
        
        results = {}
        
        for ckpt in sorted(checkpoints):
            rel_path = f"{ckpt.parent.name}/{ckpt.name}"
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
        """Test all models with real sequences (or synthetic if real data unavailable)."""
        if not discover_run_dirs:
            pytest.skip("No runs_* directories found")
        
        checkpoints = []
        for run_dir in discover_run_dirs:
            # Search recursively for checkpoints
            checkpoints.extend(run_dir.glob("**/*.pt"))
            checkpoints.extend(run_dir.glob("**/*.pth"))
        
        # Determine if using real or synthetic data
        data_type = "REAL" if Path("npz_output").exists() and list(Path("npz_output").glob("*.npz")) else "SYNTHETIC"
        
        print(f"\n{'='*80}")
        print(f"{data_type} DATA TESTING")
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
            
            # Show per-class accuracy if not collapsed
            if test_results['collapse_ratio'] < 0.8 and len(test_results['per_class_accuracy']) > 1:
                print(f"\n  Per-class accuracy:")
                for cls in sorted(test_results['per_class_accuracy'].keys()):
                    acc = test_results['per_class_accuracy'][cls]
                    total = test_results['per_class_total'][cls]
                    correct = int(acc * total)
                    print(f"    {cls:20s}: {correct}/{total} ({acc*100:5.1f}%)")
            
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
                'collapse_ratio': test_results['collapse_ratio'],
                'model_info': model_info,
                'predictions': test_results.get('predictions', [])
            }
        
        print(f"\n{'='*80}")
        print(f"{data_type} DATA SUMMARY")
        print(f"{'='*80}")
        
        if data_type == "SYNTHETIC":
            print(f"\n💡 Note: Using synthetic test data. Run with real npz_output data for accurate metrics.")
        
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