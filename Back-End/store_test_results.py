"""Store model test results to database for tracking and comparison."""

import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from core.common import supabase, logger
import uuid


def store_model_test_results(
    model_name: str,
    model_path: str,
    test_type: str,
    predictions: List[Dict],
    accuracy: float,
    avg_confidence: float,
    collapse_ratio: float,
    metadata: Dict = None
):
    """
    Store model test results in ai_detections table.
    
    Args:
        model_name: Name of the model (e.g., "PoseTCN-SingleView")
        model_path: Path to model checkpoint
        test_type: Type of test ("synthetic", "real_data", "extreme_inputs")
        predictions: List of prediction dicts with class, confidence, etc.
        accuracy: Overall accuracy metric
        avg_confidence: Average confidence score
        collapse_ratio: Model collapse metric
        metadata: Additional test metadata
    """
    
    # Create a test session ID
    test_session_id = str(uuid.uuid4())
    test_camera_id = str(uuid.uuid4())  # Virtual camera for testing
    
    logger.info(f"Storing {len(predictions)} test predictions for {model_name}")
    
    # Store each prediction
    stored_count = 0
    for idx, pred in enumerate(predictions):
        try:
            detection_data = {
                'test_type': test_type,
                'predicted_class': pred.get('predicted_class'),
                'true_class': pred.get('true_label'),
                'confidence': pred.get('confidence'),
                'probabilities': pred.get('probabilities', {}),
                'correct': pred.get('correct', False),
                'sequence_file': pred.get('file', 'N/A'),
                'test_metrics': {
                    'overall_accuracy': accuracy,
                    'avg_confidence': avg_confidence,
                    'collapse_ratio': collapse_ratio
                },
                'model_info': {
                    'model_name': model_name,
                    'model_path': model_path,
                    'test_timestamp': datetime.now().isoformat(),
                    'metadata': metadata or {}
                }
            }
            
            result = supabase.table('ai_detections').insert({
                'session_id': test_session_id,
                'camera_id': test_camera_id,
                'detection_type': pred.get('predicted_class', 'unknown'),
                'confidence_score': pred.get('confidence', 0.0),
                'detection_data': detection_data,
                'frame_timestamp': datetime.now().isoformat(),
                'sequence_number': idx,
                'model_used': model_name,
                'processed_on': 'cloud'  # Test environment
            }).execute()
            
            stored_count += 1
            
        except Exception as e:
            logger.error(f"Failed to store prediction {idx}: {e}")
    
    logger.info(f"✅ Stored {stored_count}/{len(predictions)} predictions")
    
    # Store summary in session metadata
    _store_test_summary(test_session_id, model_name, {
        'test_type': test_type,
        'total_predictions': len(predictions),
        'stored_predictions': stored_count,
        'accuracy': accuracy,
        'avg_confidence': avg_confidence,
        'collapse_ratio': collapse_ratio,
        'model_path': model_path,
        'metadata': metadata
    })
    
    return test_session_id


def _store_test_summary(session_id: str, model_name: str, summary: Dict):
    """Store test session summary in ambulance_streaming_sessions table."""
    try:
        # Find or create a "test" ambulance
        ambulance = supabase.table('ambulances').select('id').eq(
            'ambulance_number', 'TEST-001'
        ).execute()
        
        if not ambulance.data:
            # Create test ambulance if it doesn't exist
            ambulance = supabase.table('ambulances').insert({
                'ambulance_number': 'TEST-001',
                'license_plate': 'TEST-001',
                'status': 'testing',
                'vehicle_model': 'Model Testing Platform'
            }).execute()
        
        ambulance_id = ambulance.data[0]['id']
        
        # Store session summary
        supabase.table('ambulance_streaming_sessions').insert({
            'id': session_id,
            'ambulance_id': ambulance_id,
            'session_name': f"{model_name} Test Session",
            'session_type': 'testing',
            'is_active': False,
            'notes': json.dumps(summary, indent=2),
            'started_at': datetime.now().isoformat(),
            'ended_at': datetime.now().isoformat()
        }).execute()
        
        logger.info(f"✅ Stored test summary for session {session_id}")
        
    except Exception as e:
        logger.error(f"Failed to store test summary: {e}")


def get_model_test_history(model_name: str, limit: int = 10) -> List[Dict]:
    """Retrieve historical test results for a model."""
    try:
        results = supabase.table('ai_detections').select(
            'detection_data, created_at, confidence_score'
        ).contains('detection_data', {'model_info': {'model_name': model_name}}).order(
            'created_at', desc=True
        ).limit(limit).execute()
        
        return results.data
    except Exception as e:
        logger.error(f"Failed to retrieve test history: {e}")
        return []


def compare_models(model_names: List[str], test_type: str = None) -> Dict:
    """Compare performance metrics across multiple models."""
    comparison = {}
    
    for model_name in model_names:
        history = get_model_test_history(model_name)
        
        if history:
            # Extract metrics from most recent test
            recent = history[0]['detection_data']
            metrics = recent.get('test_metrics', {})
            
            comparison[model_name] = {
                'accuracy': metrics.get('overall_accuracy'),
                'avg_confidence': metrics.get('avg_confidence'),
                'collapse_ratio': metrics.get('collapse_ratio'),
                'test_date': history[0]['created_at'],
                'num_tests': len(history)
            }
    
    return comparison


if __name__ == "__main__":
    # Example usage
    example_predictions = [
        {
            'predicted_class': 'tremor',
            'true_label': 'tremor',
            'confidence': 0.92,
            'correct': True,
            'file': 'tremor_sample_1.npz',
            'probabilities': {'tremor': 0.92, 'normal': 0.05, 'chorea': 0.03}
        },
        {
            'predicted_class': 'normal',
            'true_label': 'chorea',
            'confidence': 0.78,
            'correct': False,
            'file': 'chorea_sample_1.npz',
            'probabilities': {'normal': 0.78, 'chorea': 0.15, 'tremor': 0.07}
        }
    ]
    
    session_id = store_model_test_results(
        model_name="PoseTCN-SingleView",
        model_path="ai_models/best_single_view_f1_bn_t120_gamma175.pt",
        test_type="synthetic",
        predictions=example_predictions,
        accuracy=0.8288,
        avg_confidence=0.85,
        collapse_ratio=0.12,
        metadata={'test_date': '2025-11-14', 'dataset': 'synthetic'}
    )
    
    print(f"✅ Stored test results with session ID: {session_id}")
