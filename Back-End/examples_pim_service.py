"""
Examples of Using PIM Classifier Service

This file demonstrates different ways to use the PIM classifier:
1. Direct service usage (recommended for backend logic)
2. API usage (for external clients)
3. Retraining and model updates (for when new data arrives)
"""

import numpy as np
from pathlib import Path
import sys

# Add path
sys.path.insert(0, str(Path(__file__).parent))

# ============================================================
# Example 1: Direct Service Usage (Backend Logic)
# ============================================================


def example_direct_service():
    """
    Use the service directly in your backend code
    Best for: Internal processing, background jobs, data pipelines
    """
    from services.pim_classifier_service import get_classifier_service

    print("=" * 60)
    print("Example 1: Direct Service Usage")
    print("=" * 60)

    # Get service instance (singleton)
    service = get_classifier_service()

    # Check health
    health = service.get_health_status()
    print(f"\n✅ Service Status: {health['status']}")
    print(f"   Predictions made: {health['predictions_made']}")

    # Create dummy skeleton data (frames, 33 joints, 3 coords)
    dummy_data = np.random.rand(60, 33, 3)

    # Single prediction
    print("\n📊 Making prediction...")
    prediction = service.predict(
        dummy_data, metadata={"patient_id": "P001", "recording_id": "R001"}
    )

    print(f"\n🎯 Results:")
    print(f"   Class: {prediction.predicted_class}")
    print(f"   Confidence: {prediction.confidence:.1%}")
    print(f"   Tier: {prediction.tier}")
    print(f"   Model Accuracy: {prediction.model_accuracy:.1f}%")
    print(f"   Recommendation: {prediction.recommendation}")
    print(f"   Requires Review: {prediction.requires_review()}")

    # Top-3 predictions
    print("\n📈 Top-3 Predictions:")
    top_k = service.get_top_k_predictions(dummy_data, k=3)
    for i, (class_name, prob) in enumerate(top_k, 1):
        print(f"   {i}. {class_name}: {prob:.1%}")

    # Batch prediction
    print("\n📦 Batch Prediction (3 sequences)...")
    batch_data = [np.random.rand(60, 33, 3) for _ in range(3)]
    batch_metadata = [
        {"patient_id": "P001", "recording_id": "R001"},
        {"patient_id": "P001", "recording_id": "R002"},
        {"patient_id": "P002", "recording_id": "R001"},
    ]

    batch_predictions = service.predict_batch(batch_data, batch_metadata)
    print(f"   Processed: {len(batch_predictions)} sequences")
    for pred in batch_predictions:
        print(
            f"   - {pred.metadata['recording_id']}: {pred.predicted_class} ({pred.confidence:.1%})"
        )


# ============================================================
# Example 2: API Usage (External Clients)
# ============================================================


def example_api_usage():
    """
    Use the REST API from external clients
    Best for: Web apps, mobile apps, external integrations
    """
    print("\n" + "=" * 60)
    print("Example 2: API Usage")
    print("=" * 60)

    # Example API requests (using requests library)
    print("\n📡 API Endpoint Examples:")

    # 1. Health Check
    print("\n1️⃣ Health Check:")
    print("   GET /api/pim/health")
    print("   Response: {'status': 'healthy', 'model_loaded': true, ...}")

    # 2. Model Info
    print("\n2️⃣ Model Info:")
    print("   GET /api/pim/model-info")
    print("   Response: {")
    print("     'model_name': 'UNIK Transformer',")
    print("     'overall_accuracy': '85.97%',")
    print("     'classes': {...}")
    print("   }")

    # 3. Single Classification
    print("\n3️⃣ Classify Movement:")
    print("   POST /api/pim/classify-movement")
    print("   Body: {")
    print("     'frames': [")
    print("       {'landmarks': [[x, y, vis], ...]}  // 33 joints")
    print("       ...  // 60 frames")
    print("     ],")
    print("     'patient_id': 'P001',")
    print("     'recording_id': 'R001'")
    print("   }")

    # 4. Batch Classification
    print("\n4️⃣ Batch Classification:")
    print("   POST /api/pim/classify-batch")
    print("   Body: {")
    print("     'sequences': [")
    print("       {'frames': [...], 'patient_id': 'P001'},")
    print("       {'frames': [...], 'patient_id': 'P002'}")
    print("     ]")
    print("   }")

    # Python requests example
    print("\n🐍 Python Client Example:")
    print(
        """
    import requests
    
    # API base URL
    BASE_URL = "http://localhost:8000/api/pim"
    
    # Prepare skeleton data
    skeleton_sequence = {
        "frames": [
            {"landmarks": [[0.5, 0.5, 0.9]] * 33}  # 33 joints
            for _ in range(60)  # 60 frames
        ],
        "patient_id": "P001",
        "recording_id": "R001"
    }
    
    # Make request
    response = requests.post(
        f"{BASE_URL}/classify-movement",
        json=skeleton_sequence
    )
    
    result = response.json()
    print(f"Predicted: {result['predicted_movement']}")
    print(f"Confidence: {result['confidence']}")
    print(f"Tier: {result['tier']}")
    """
    )


# ============================================================
# Example 3: Retraining & Model Updates
# ============================================================


def example_model_update():
    """
    Update model when new training data arrives
    Best for: Retraining workflows, model versioning
    """
    from services.pim_classifier_service import get_classifier_service

    print("\n" + "=" * 60)
    print("Example 3: Model Updates (New Training Data)")
    print("=" * 60)

    service = get_classifier_service()

    print("\n📚 Current Model Info:")
    info = service.get_model_info()
    print(f"   Version: {info['version']}")
    print(f"   Trained: {info['trained_date']}")
    print(f"   Accuracy: {info['performance']['overall_accuracy']}")
    print(f"   Predictions: {info['predictions_made']}")

    print("\n🔄 When New Training Data Arrives:")
    print("   1. Retrain model with updated dataset")
    print("   2. Evaluate new checkpoint")
    print("   3. Reload service with new model:")
    print("")
    print("      # Path to new checkpoint")
    print("      new_checkpoint = 'pim_unik_model-NEW.pt'")
    print("")
    print("      # Reload service")
    print("      success = service.reload_model(new_checkpoint)")
    print("")
    print("      if success:")
    print("          print('✅ Model updated!')")
    print("          # Update config version and date")
    print("   4. Test with validation data")
    print("   5. Deploy to production")

    print("\n📊 Model Performance Tracking:")
    print("   - Keep logs of all predictions")
    print("   - Track accuracy per class")
    print("   - Identify classes needing more data")
    print("   - Monitor confidence distributions")

    print("\n⚠️  Classes Needing More Data:")
    print("   - Myoclonus: 37.5% accuracy (collect 50+ more samples)")
    print("   - Decerebrate: 45.2% accuracy (collect 50+ more samples)")


# ============================================================
# Example 4: Integration with MediaPipe Pipeline
# ============================================================


def example_mediapipe_integration():
    """
    Integrate with real-time MediaPipe processing
    Best for: Live video analysis, patient monitoring
    """
    print("\n" + "=" * 60)
    print("Example 4: MediaPipe Integration")
    print("=" * 60)

    print("\n📹 Real-Time Video Processing Pipeline:")
    print(
        """
    1. Capture video frame
    2. MediaPipe extracts skeleton (33 landmarks)
    3. Collect 60 frames in sliding window
    4. Send to classifier service
    5. Display result with confidence
    
    Code Example:
    
    from services.pim_classifier_service import get_classifier_service
    import mediapipe as mp
    import cv2
    from collections import deque
    
    # Initialize
    service = get_classifier_service()
    mp_pose = mp.solutions.pose.Pose()
    frame_buffer = deque(maxlen=60)
    
    # Process video
    cap = cv2.VideoCapture(0)  # Webcam
    
    while cap.isOpened():
        ret, frame = cap.read()
        
        # Extract skeleton
        results = mp_pose.process(frame)
        if results.pose_landmarks:
            landmarks = [[lm.x, lm.y, lm.visibility] 
                        for lm in results.pose_landmarks.landmark]
            frame_buffer.append(landmarks)
        
        # Predict when buffer full
        if len(frame_buffer) == 60:
            skeleton_data = np.array(frame_buffer)
            prediction = service.predict(skeleton_data)
            
            # Display result
            cv2.putText(frame, 
                       f"{prediction.predicted_class} ({prediction.confidence:.1%})",
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
        
        cv2.imshow('PIM Detection', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    """
    )


# ============================================================
# Example 5: Error Handling & Validation
# ============================================================


def example_error_handling():
    """
    Proper error handling when using the service
    """
    from services.pim_classifier_service import get_classifier_service

    print("\n" + "=" * 60)
    print("Example 5: Error Handling")
    print("=" * 60)

    service = get_classifier_service()

    print("\n✅ Proper Error Handling:")
    print(
        """
    try:
        # Make prediction
        prediction = service.predict(skeleton_data, metadata)
        
        # Check if review needed
        if prediction.requires_review():
            print("⚠️ Manual review required")
            # Send to physician queue
            send_to_review_queue(prediction)
        
        # Check confidence
        if prediction.is_high_confidence():
            print("✅ High confidence - auto-approve")
            auto_approve(prediction)
        else:
            print("📋 Standard review process")
            standard_review(prediction)
    
    except ValueError as e:
        # Invalid input data
        print(f"❌ Input validation failed: {e}")
        # Log error, request data correction
    
    except RuntimeError as e:
        # Model not loaded or prediction failed
        print(f"❌ Service error: {e}")
        # Alert DevOps, use fallback
    
    except Exception as e:
        # Unexpected error
        print(f"❌ Unexpected error: {e}")
        # Log for investigation
    """
    )

    print("\n🔍 Input Validation:")
    print("   - Shape: (30-300 frames, 33 joints, 3 coords)")
    print("   - No NaN or Inf values")
    print("   - Coordinates in [0, 1] range")
    print("   - Visibility in [0, 1] range")


# ============================================================
# Run All Examples
# ============================================================

if __name__ == "__main__":
    print("\n🎯 PIM Classifier Service Usage Examples\n")

    try:
        # Example 1: Direct service usage
        example_direct_service()

        # Example 2: API usage
        example_api_usage()

        # Example 3: Model updates
        example_model_update()

        # Example 4: MediaPipe integration
        example_mediapipe_integration()

        # Example 5: Error handling
        example_error_handling()

        print("\n" + "=" * 60)
        print("✅ All examples completed!")
        print("=" * 60)

    except Exception as e:
        print(f"\n❌ Error running examples: {e}")
        import traceback

        traceback.print_exc()
