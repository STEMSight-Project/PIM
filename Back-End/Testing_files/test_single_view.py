#!/usr/bin/env python3
"""
Quick test to verify test_live.py can load single-view models
"""
import torch
import sys
import os

# Add parent dir to path
sys.path.insert(0, os.path.dirname(__file__))

# Mock a single-view checkpoint structure
def create_mock_single_view_checkpoint():
    """Create a mock checkpoint that matches train_single_view.py output."""
    from test_live import PoseTCNSingleView, NUM_POSE
    
    # Create model
    model = PoseTCNSingleView(
        num_classes=10,
        width=384,
        drop=0.1,
        dilations=[1, 2, 4, 8, 16, 32],
        in_features=NUM_POSE * 3,
        t_heads=4,
        attn_dropout=0.0
    )
    
    # Mock checkpoint
    ckpt = {
        'epoch': 1,
        'model_state_dict': model.state_dict(),
        'classes': ['ballistic', 'chorea', 'decerebrate', 'decorticate', 'dystonia',
                    'fencer posture', 'myoclonus', 'normal', 'tremor', 'versive head'],
        'best_macro_f1': 0.75,
        'best_temperature': 1.5,
        'args': {
            'width': 384,
            'dropout': 0.1,
            'dilations': '1,2,4,8,16,32',
            't_heads': 4,
            'attn_dropout': 0.0,
        }
    }
    
    return ckpt

def test_single_view_loading():
    """Test that test_live.py can load single-view checkpoints."""
    from test_live import load_ckpt
    
    print("=" * 60)
    print("Testing Single-View Checkpoint Loading")
    print("=" * 60)
    
    # Create mock checkpoint
    print("\n1. Creating mock single-view checkpoint...")
    ckpt = create_mock_single_view_checkpoint()
    temp_path = "test_single_view_ckpt.pt"
    torch.save(ckpt, temp_path)
    print(f"   Saved to: {temp_path}")
    
    # Test loading
    print("\n2. Testing load_ckpt() function...")
    try:
        device = torch.device("cpu")
        model, classes, num_views, landmarks_per_view, model_type, expects_hands, temperature = load_ckpt(temp_path, device)
        
        print(f"\n✅ Successfully loaded checkpoint!")
        print(f"   Model type: {model_type}")
        print(f"   Num views: {num_views}")
        print(f"   Landmarks per view: {landmarks_per_view}")
        print(f"   Temperature: {temperature:.4f}")
        print(f"   Classes: {len(classes)}")
        print(f"   Expected hands: {expects_hands}")
        
        # Verify it's single-view
        assert num_views == 1, f"Expected num_views=1, got {num_views}"
        assert model_type == "single-view-mha", f"Expected 'single-view-mha', got '{model_type}'"
        assert landmarks_per_view == 33, f"Expected 33 landmarks, got {landmarks_per_view}"
        
        # Test inference
        print("\n3. Testing inference...")
        model.eval()
        T = 60
        batch = torch.randn(1, T, 99)  # (B, T, 99) where 99 = 33 * 3
        with torch.no_grad():
            logits = model(batch)
        
        assert logits.shape == (1, 10), f"Expected shape (1, 10), got {logits.shape}"
        print(f"   ✅ Inference successful! Output shape: {logits.shape}")
        
        print("\n" + "=" * 60)
        print("✅ ALL TESTS PASSED!")
        print("=" * 60)
        print("\ntest_live.py is ready to use with single-view models!")
        print("Train a model with: python train_single_view.py --data_dir npz_output --out runs/single_view")
        print("Then test with: python test_live.py --ckpt runs/single_view/best_single_view.pt --T 60")
        
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # Cleanup
        if os.path.exists(temp_path):
            os.remove(temp_path)
            print(f"\nCleaned up: {temp_path}")
    
    return True

if __name__ == "__main__":
    success = test_single_view_loading()
    sys.exit(0 if success else 1)
