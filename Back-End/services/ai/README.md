# AI Services - PIM Movement Classification

Clean, modular AI services for automatic movement detection from video streams.

## 📁 Structure

```
Back-End/services/ai/
├── __init__.py                    # Package exports
├── pim_classifier_service.py      # Core ML service (model, prediction)
├── ai_detection_service.py        # Database operations
└── stream_processor.py            # Real-time stream processing

Back-End/tests/services/ai/
├── conftest.py                    # Pytest fixtures
├── test_pim_classifier_service.py # ML service tests
└── test_ai_detection_service.py   # Database service tests
```

## 🚀 Quick Start

### 1. Run Database Migration

```sql
-- Run this in your PostgreSQL database
\i DatabaseSQL/migration_add_movement_classification.sql
```

This adds movement classification columns to the existing `ai_detections` table.

### 2. Test the Services

```powershell
# Run all tests
cd "d:\DevProj\STEMSight\PIM\Back-End"
pytest tests/services/ai/ -v

# Run specific test
pytest tests/services/ai/test_pim_classifier_service.py::TestPIMClassifierService::test_predict_success -v
```

### 3. Use in Your Code

```python
from services.ai import get_classifier_service
from services.ai.stream_processor import get_processor_manager

# Get classifier service
classifier = get_classifier_service()

# Create stream processor
manager = get_processor_manager()
processor = manager.create_processor(
    session_id="session-123",
    camera_id="camera-456",
    video_id=1,
    patient_id=1
)
```

## 📊 How It Works

### Real-Time Stream Flow

```
1. Video Stream → MediaPipe
2. MediaPipe → Skeleton Landmarks (33 joints × 3 coords)
3. Stream Processor → Buffer 60 frames
4. PIM Classifier → Predict movement type
5. AI Detection Service → Save to database
6. Notification → If requires_review = true
```

### Example: Processing a Stream

```python
from services.ai.stream_processor import get_processor_manager

# Initialize processor
manager = get_processor_manager()
processor = manager.create_processor(
    session_id="abc-123",
    camera_id="cam-001",
    video_id=1,
    patient_id=1,
    room_id="room-101",
    window_size=60,
    min_confidence=0.70
)

# Process frames from MediaPipe
for frame in video_stream:
    # Extract skeleton (33 landmarks)
    landmarks = mediapipe_pose.process(frame)
    skeleton = [[lm.x, lm.y, lm.visibility] for lm in landmarks.landmark]

    # Add frame and auto-detect
    result = await processor.process_frame_and_detect(skeleton)

    if result:
        print(f"✅ Detected: {result['movement_type']}")
        print(f"   Confidence: {result['confidence_score']:.1%}")
        print(f"   Tier: {result['tier']}")
```

## 🧪 Testing

### Test Coverage

- ✅ **Classifier Service** (21 tests)

  - Configuration validation
  - Input validation (shape, NaN, inf)
  - Tier determination logic
  - Model loading & prediction
  - Batch processing
  - Singleton pattern

- ✅ **Detection Service** (9 tests)
  - Create detection
  - Query by video/patient
  - Review workflow
  - Statistics calculation
  - Error handling

### Run Tests

```powershell
# All AI tests
pytest tests/services/ai/ -v

# With coverage
pytest tests/services/ai/ --cov=services.ai --cov-report=html

# Specific test file
pytest tests/services/ai/test_pim_classifier_service.py -v

# Single test
pytest tests/services/ai/test_pim_classifier_service.py::TestPIMClassifierService::test_validate_input_valid -v
```

## 📖 API Reference

### PIMClassifierService

```python
from services.ai import get_classifier_service

service = get_classifier_service()

# Predict movement
prediction = service.predict(
    skeleton_data,  # (60, 33, 3) numpy array
    metadata={'patient_id': 1}
)

# Properties
prediction.predicted_class    # "tremor"
prediction.confidence          # 0.95
prediction.tier               # "excellent"
prediction.requires_review()  # False
prediction.to_db_record(video_id=1, patient_id=1)
```

### AIDetectionService

```python
from services.ai.ai_detection_service import AIDetectionService

# Create detection
detection = await AIDetectionService.create_detection(
    session_id="session-123",
    camera_id="camera-456",
    video_id=1,
    patient_id=1,
    movement_type="tremor",
    movement_id=8,
    confidence_score=0.95,
    model_accuracy=100.0,
    tier="excellent",
    recommendation="High confidence",
    all_probabilities={"tremor": 0.95, ...},
    requires_review=False
)

# Query detections
detections = await AIDetectionService.get_detections_by_patient(patient_id=1)
review_needed = await AIDetectionService.get_detections_requiring_review()

# Mark as reviewed
await AIDetectionService.mark_as_reviewed(
    detection_id=1,
    reviewed_by=doctor_id,
    physician_diagnosis="Confirmed tremor"
)
```

### StreamMovementProcessor

```python
from services.ai.stream_processor import StreamMovementProcessor

processor = StreamMovementProcessor(
    session_id="session-123",
    camera_id="camera-456",
    video_id=1,
    patient_id=1,
    window_size=60,
    stride=30,
    min_confidence=0.70
)

# Add frame
is_ready = processor.add_frame(skeleton_landmarks)

# Process when ready
if is_ready:
    result = await processor.process_buffer(save_to_db=True)

# Or combine both
result = await processor.process_frame_and_detect(skeleton_landmarks)
```

## 🗄️ Database Schema

### Existing Table: `ai_detections`

Original columns (streaming):

- `id`, `session_id`, `camera_id`, `room_id`
- `detection_type`, `confidence_score`, `detection_data`
- `frame_timestamp`, `model_used`, `created_at`

Added columns (movement classification):

- `video_id`, `patient_id` - References
- `movement_type`, `movement_id` - Movement classification
- `model_accuracy`, `tier`, `recommendation` - Performance metrics
- `all_probabilities` - Full prediction distribution
- `requires_review`, `reviewed`, `reviewed_by` - Review workflow
- `physician_diagnosis`, `physician_notes` - Clinical review
- `detected_at` - Detection timestamp

### View: `ai_movement_detections`

Filtered view containing only movement classification results (where `movement_type IS NOT NULL`).

## 📈 Model Performance

Current model (UNIK v1.0, trained on 506 samples):

| Movement Class | Accuracy | Tier         | Status                |
| -------------- | -------- | ------------ | --------------------- |
| Tremor         | 100.0%   | excellent    | ✅ Production ready   |
| Decorticate    | 100.0%   | excellent    | ✅ Production ready   |
| Fencer Posture | 98.4%    | excellent    | ✅ Production ready   |
| Dystonia       | 98.4%    | excellent    | ✅ Production ready   |
| Ballistic      | 95.3%    | excellent    | ✅ Production ready   |
| Versive Head   | 93.6%    | good         | ⚠️ Review recommended |
| Chorea         | 92.2%    | good         | ⚠️ Review recommended |
| Decerebrate    | 45.2%    | needs_review | ❌ Needs more data    |
| Myoclonus      | 37.5%    | needs_review | ❌ Needs more data    |

**Overall Accuracy:** 85.97% (435/506 correct)

## 🔄 Retraining Workflow

When new training data arrives:

### 1. Update Training Data

```powershell
# Add new samples to dataset
cd "d:\DevProj\STEMSight\PIM\AI_Training\UNIK"

# Update train_data.npy and train_label.pkl
# Retrain model
python run_unik.py
```

### 2. Evaluate New Model

```powershell
# Evaluate new checkpoint
python evaluate_best_model.py

# Check improvements in accuracy
```

### 3. Update Service Configuration

```python
# Edit services/ai/pim_classifier_service.py
class PIMClassifierConfig:
    MODEL_CHECKPOINT = UNIK_PATH / 'pim_unik_model-NEW.pt'
    MODEL_VERSION = 'v2.0'
    TRAINED_DATE = '2025-01-XX'
    OVERALL_ACCURACY = XX.XX  # New accuracy

    CLASS_METRICS = {
        'tremor': {'accuracy': XX.XX, 'tier': '...', 'id': 8},
        # ... update all classes
    }
```

### 4. Reload Service

```python
from services.ai import get_classifier_service

service = get_classifier_service()
service.reload_model('pim_unik_model-NEW.pt')
```

### 5. Restart Backend

```powershell
# Restart FastAPI server to load new model
# Or use hot-reload if configured
```

## 🎯 Data Collection Priorities

Classes needing more training data:

1. **Myoclonus** (37.5% accuracy)

   - Current: ~50 samples
   - Target: 100+ samples
   - Issue: Confused with tremor (40 errors)

2. **Decerebrate** (45.2% accuracy)
   - Current: 31 samples
   - Target: 100+ samples
   - Issue: Insufficient training data

## 🔍 Troubleshooting

### Model Not Loading

```python
from services.ai import get_classifier_service

service = get_classifier_service()
health = service.get_health_status()
print(health)  # Check status and error messages
```

### Low Prediction Confidence

- Check input data quality (no NaN/Inf)
- Verify skeleton has 33 landmarks
- Ensure 60 frames collected
- Review model accuracy for that class

### Database Errors

```python
# Check table exists
# SELECT * FROM ai_detections LIMIT 1;

# Run migration if needed
# \i DatabaseSQL/migration_add_movement_classification.sql
```

### Test Failures

```powershell
# Run with verbose output
pytest tests/services/ai/ -vv

# Check specific test
pytest tests/services/ai/test_pim_classifier_service.py::test_name -vv

# Run with print statements
pytest tests/services/ai/ -s
```

## 📝 Integration Checklist

- [x] Clean folder structure (`services/ai/`)
- [x] Core ML service with validation
- [x] Database service with async operations
- [x] Stream processor with sliding window
- [x] Comprehensive pytest tests (30+ tests)
- [x] Database migration script
- [x] Integration with existing `ai_detections` table
- [ ] Update API router to use new services
- [ ] Integrate with MediaPipe streamer
- [ ] Add real-time notifications
- [ ] Deploy and test with live streams

## 🔗 Next Steps

1. **Test Services**

   ```powershell
   pytest tests/services/ai/ -v
   ```

2. **Run Migration**

   ```sql
   \i DatabaseSQL/migration_add_movement_classification.sql
   ```

3. **Update API Router**

   - Modify `api_router/pim_classifier_api.py` to use services
   - Update endpoints to match new structure

4. **Integrate with Streaming**

   - Connect StreamProcessor to MediaPipe handler
   - Auto-create processors for new streams
   - Save detections automatically

5. **Monitor Performance**
   - Track detection accuracy
   - Identify classes needing more data
   - Collect feedback from physicians

---

**Version:** 1.0  
**Last Updated:** 2025-01-13  
**Model:** UNIK Transformer v1.0 (85.97% accuracy)
