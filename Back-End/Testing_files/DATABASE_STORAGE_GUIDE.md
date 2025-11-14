# Database Storage Integration Guide

## Overview

The live inference system (`test_live.py`) now supports storing AI detection predictions to the `ai_detections` database table. This enables tracking, analysis, and visualization of real-time movement detection data.

## Features

- ✅ **2-second throttled storage** - Prevents database overload
- ✅ **Full metadata capture** - All class probabilities, confidence scores, temperature settings
- ✅ **Session tracking** - Links detections to streaming sessions, cameras, and rooms
- ✅ **Performance metrics** - Inference timing, frame counts, sequence numbers
- ✅ **Session summaries** - Aggregated statistics at end of session
- ✅ **Auto-generated IDs** - Automatic UUID generation if not provided
- ✅ **Graceful degradation** - Works even if database unavailable

## Quick Start

### Basic Usage (No Database)

```bash
# Run live inference without database storage
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120
```

### Enable Database Storage

```bash
# Run with database storage enabled (auto-generated IDs)
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db
```

### Provide Session/Camera IDs

```bash
# Use specific session and camera IDs (for integration with ambulance streaming)
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db \
  --session_id "550e8400-e29b-41d4-a716-446655440000" \
  --camera_id "7c9e6679-7425-40de-944b-e07fc1f90ae7" \
  --room_id "AMB-001-ROOM-001"
```

## Command-Line Arguments

### Database Storage Options

| Argument       | Type   | Default        | Description               |
| -------------- | ------ | -------------- | ------------------------- |
| `--store_db`   | flag   | disabled       | Enable database storage   |
| `--session_id` | string | auto-generated | Ambulance session UUID    |
| `--camera_id`  | string | auto-generated | Camera UUID               |
| `--room_id`    | string | None           | WebRTC room ID (optional) |

### Model & Inference Options

| Argument        | Type   | Default      | Description                  |
| --------------- | ------ | ------------ | ---------------------------- |
| `--ckpt`        | string | **required** | Path to model checkpoint     |
| `--T`           | int    | 60           | Window length (frames)       |
| `--cam`         | int    | 0            | Webcam index                 |
| `--width`       | int    | 640          | Webcam width                 |
| `--height`      | int    | 480          | Webcam height                |
| `--fps`         | int    | 30           | Webcam FPS                   |
| `--pose_every`  | int    | 1            | Run MediaPipe every N frames |
| `--infer_every` | int    | 1            | Run model every N frames     |
| `--smooth_k`    | int    | 15           | Prediction smoother window   |
| `--cpu`         | flag   | disabled     | Force CPU inference          |

## Data Structure

### Stored in `ai_detections` Table

Each detection record includes:

```python
{
    'id': uuid,                    # Auto-generated
    'session_id': uuid,            # Session identifier
    'camera_id': uuid,             # Camera identifier
    'room_id': uuid,               # Room identifier (optional)
    'detection_type': str,         # Predicted class name (e.g., "tremor")
    'confidence_score': float,     # 0.0-1.0 confidence
    'detection_data': {            # JSONB field
        'all_probabilities': {
            'ballistic': 0.02,
            'chorea': 0.05,
            'tremor': 0.93,
            ...
        },
        'temperature': 2.0,
        'frame_count': 120,
        'model_architecture': 'PoseTCN-SingleView'
    },
    'frame_timestamp': datetime,   # When detected
    'sequence_number': int,        # Detection sequence (1, 2, 3...)
    'model_used': str,             # "PoseTCN-T2.00"
    'processing_time_ms': int,     # Inference latency
    'processed_on': str            # "edge"
}
```

### Session Summary Record

At end of session:

```python
{
    'detection_type': 'session_summary',
    'detection_data': {
        'detection_counts': {
            'tremor': 45,
            'normal': 12,
            'chorea': 3
        },
        'avg_confidence': 0.8756,
        'total_frames': 60,
        'duration_seconds': 120.5,
        'detections_per_second': 0.498
    }
}
```

## Visual Feedback

### Video Overlay Display

When database storage is enabled, the live video shows:

```
┌─────────────────────────────────────┐
│ PoseTCN-pose(V=1)                   │
│ Tremor 92.3%                        │
│ T:120 (filled) • T=2.00             │
│ DB: 45 stored ← Storage count       │
└─────────────────────────────────────┘
```

### Console Output

**On startup:**

```
Model type: PoseTCN, Views: 1, Temperature: 2.0000
🔑 Session ID: 550e8400-e29b-41d4-a716-446655440000
📷 Camera ID: 7c9e6679-7425-40de-944b-e07fc1f90ae7
🚪 Room ID: AMB-001-ROOM-001
📊 Database storage: ENABLED (storing every 2.0s)
```

**On exit:**

```
=== Detection Session Summary ===
Duration: 120.5s
Total frames processed: 1805
Detections stored: 60

Detection distribution:
  tremor: 45 (75.0%)
  normal: 12 (20.0%)
  chorea: 3 (5.0%)

Average confidence: 87.56%
✅ Session summary stored to database
```

## Integration with Broadcaster

For production use with `broadcaster.py`:

```python
from Testing_files.test_live import DetectionStorage

# Initialize with WebRTC session context
storage = DetectionStorage(
    session_id=ambulance_session_id,  # From ambulance_streaming_sessions
    camera_id=camera_id,               # From ambulance_cameras
    room_id=room_id,                   # WebRTC room ID
    model_name="PoseTCN-T2.00"
)

# During streaming
if storage.should_store():
    storage.store_detection(
        predicted_class=pred_class,
        confidence=conf_score,
        all_probs=probability_dict,
        temperature=2.0,
        frame_count=120,
        processing_time_ms=infer_time
    )

# On session end
storage.store_batch_summary(
    detection_counts=counts_dict,
    avg_confidence=avg_conf,
    total_frames=frame_count,
    duration_seconds=elapsed_time
)
```

## Database Queries

### Get Recent Detections

```sql
SELECT
    detection_type,
    confidence_score,
    frame_timestamp,
    processing_time_ms,
    detection_data->'all_probabilities' as probabilities
FROM ai_detections
WHERE session_id = '550e8400-e29b-41d4-a716-446655440000'
    AND detection_type != 'session_summary'
ORDER BY frame_timestamp DESC
LIMIT 20;
```

### Get Session Summary

```sql
SELECT
    detection_data->'detection_counts' as counts,
    detection_data->'avg_confidence' as avg_conf,
    detection_data->'duration_seconds' as duration
FROM ai_detections
WHERE session_id = '550e8400-e29b-41d4-a716-446655440000'
    AND detection_type = 'session_summary';
```

### Detection Frequency Timeline

```sql
SELECT
    detection_type,
    COUNT(*) as count,
    AVG(confidence_score) as avg_confidence,
    MIN(frame_timestamp) as first_seen,
    MAX(frame_timestamp) as last_seen
FROM ai_detections
WHERE session_id = '550e8400-e29b-41d4-a716-446655440000'
    AND detection_type != 'session_summary'
GROUP BY detection_type
ORDER BY count DESC;
```

## Testing Checklist

### ✅ Pre-Test Verification

1. **Backend running**: `http://localhost:8000/docs`
2. **Database accessible**: Check Supabase connection
3. **Model checkpoint exists**: Verify `.pt` file path
4. **Camera available**: Test with `--cam 0`

### ✅ Test Scenarios

#### Test 1: Basic Storage

```bash
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db
```

**Expected**: Auto-generated IDs, detections stored every 2s, session summary on exit

#### Test 2: Custom IDs

```bash
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db \
  --session_id "550e8400-e29b-41d4-a716-446655440000" \
  --camera_id "7c9e6679-7425-40de-944b-e07fc1f90ae7"
```

**Expected**: Uses provided IDs, links to existing session

#### Test 3: No Database (Graceful Fallback)

```bash
# Temporarily rename .env to simulate missing database config
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db
```

**Expected**: "Database not available" warning, continues without crashing

#### Test 4: High-Frequency Detection

```bash
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 60 \
  --infer_every 1 \
  --store_db
```

**Expected**: 2-second throttling prevents DB overload (max ~0.5 inserts/sec)

### ✅ Database Verification

After running tests:

```sql
-- Check total records inserted
SELECT COUNT(*) FROM ai_detections;

-- Verify detection types
SELECT detection_type, COUNT(*)
FROM ai_detections
GROUP BY detection_type;

-- Check data integrity
SELECT
    CASE
        WHEN detection_data IS NOT NULL THEN 'Valid'
        ELSE 'Invalid'
    END as data_status,
    COUNT(*)
FROM ai_detections
GROUP BY data_status;

-- View latest detections
SELECT * FROM ai_detections
ORDER BY frame_timestamp DESC
LIMIT 10;
```

## Troubleshooting

### Issue: No Data Stored

**Symptoms**: `DB: 0 stored` on video overlay

**Check**:

1. `--store_db` flag present?
2. Database connection working? (Check `.env` file)
3. `ai_detections` table exists?
4. Check console for error messages

**Solution**: Enable verbose logging in `DetectionStorage` class

### Issue: Database Connection Errors

**Symptoms**: Console shows `ImportError` or connection errors

**Solution**:

```python
# Check if DATABASE_AVAILABLE flag is True
# Verify Supabase credentials in core/env.py
# Test connection: python -c "from core.common import supabase; print(supabase)"
```

### Issue: Performance Degradation

**Symptoms**: FPS drops when `--store_db` enabled

**Solution**:

1. Check `store_interval` (default 2.0s) - increase if needed
2. Verify database not rate-limiting
3. Consider async storage (future enhancement)

### Issue: Missing Session Summary

**Symptoms**: No summary stored on exit

**Check**:

1. Did script exit cleanly? (Not killed with Ctrl+C multiple times)
2. Check `finally` block executed
3. Review logs for exceptions

**Solution**: Ensure graceful shutdown (single `q` keypress or single Ctrl+C)

## Future Enhancements

### Planned Features

- [ ] **Async database writes** - Non-blocking storage using asyncio
- [ ] **Batch inserts** - Store multiple detections in single query
- [ ] **Configurable interval** - CLI arg for `--store_interval`
- [ ] **Detection alerts** - Trigger webhooks on high-confidence abnormal movements
- [ ] **Real-time dashboard** - WebSocket stream of detections to frontend
- [ ] **Historical comparison** - Compare current session to baseline
- [ ] **Export utilities** - CSV/JSON export of session data

### Integration Roadmap

1. **Week 1**: Test `test_live.py` integration ✅ **DONE**
2. **Week 2**: Integrate `DetectionStorage` into `broadcaster.py`
3. **Week 3**: Frontend dashboard queries and visualization
4. **Week 4**: Real-time alerts and notification system

## Related Files

- **Implementation**: `Back-End/Testing_files/test_live.py`
- **Database Schema**: `DatabaseSQL/backup.sql` (lines 3203-3243)
- **Batch Storage Utility**: `Back-End/store_test_results.py`
- **API Endpoints**: Future - `api_router/pim_classifier_api.py`
- **Frontend Queries**: Future - `Front-End/src/services/detectionService.ts`

## Support

For questions or issues:

1. Check console logs for error messages
2. Verify database schema matches expected structure
3. Test with `--cpu` flag to rule out GPU issues
4. Review `ai_detections` table permissions in Supabase

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
