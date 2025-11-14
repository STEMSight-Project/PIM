# Testing Files Directory

This directory contains testing utilities and scripts for validating AI models, streaming infrastructure, and database integration.

## 📁 File Overview

### Live Inference & Database Integration

- **`test_live.py`** - Real-time webcam inference with database storage
  - MediaPipe pose detection
  - PoseTCN model inference
  - Optional database storage (ai_detections table)
  - Session tracking and summary statistics
  - See: [DATABASE_STORAGE_GUIDE.md](./DATABASE_STORAGE_GUIDE.md)

### WebRTC Streaming

- **`broadcaster.py`** - WebRTC video broadcaster for testing streaming infrastructure
  - Simulates Raspberry Pi camera streams
  - Connects to backend `/ambulance-streaming/camera/{room_id}/streamer` endpoint
  - Platform-specific camera device selection (Windows/macOS/RPi)
  - Example: `python broadcaster.py --room AMB-001-ROOM-001 --video_device "Logitech BRIO"`

### Test Data & Utilities

- **`test_hls_player.html`** - HTML5 player for testing HLS video streams
- **Additional scripts** - Various testing and validation utilities

## 🚀 Quick Start

### Test Live Inference (No Database)

```bash
cd Back-End
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120
```

### Test Live Inference (With Database Storage)

```bash
cd Back-End
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db
```

### Test WebRTC Streaming (Windows)

```bash
cd Back-End
python Testing_files/broadcaster.py \
  --room AMB-001-ROOM-001 \
  --video_device "Logitech BRIO"
```

### Test WebRTC Streaming (macOS)

```bash
cd Back-End
python Testing_files/broadcaster.py \
  --room AMB-001-ROOM-001 \
  --video_device 0
```

## 📊 Database Integration

The `test_live.py` script now supports storing detection predictions to the database:

### Features

- ✅ Throttled storage (every 2 seconds)
- ✅ Full metadata capture (all class probabilities)
- ✅ Session tracking (session_id, camera_id, room_id)
- ✅ Auto-generated UUIDs if not provided
- ✅ Session summary on exit
- ✅ Graceful fallback if database unavailable

### Storage Arguments

| Argument       | Type   | Description                              |
| -------------- | ------ | ---------------------------------------- |
| `--store_db`   | flag   | Enable database storage                  |
| `--session_id` | string | Session UUID (auto-generated if omitted) |
| `--camera_id`  | string | Camera UUID (auto-generated if omitted)  |
| `--room_id`    | string | WebRTC room ID (optional)                |

### Example with Custom IDs

```bash
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --T 120 \
  --store_db \
  --session_id "550e8400-e29b-41d4-a716-446655440000" \
  --camera_id "7c9e6679-7425-40de-944b-e07fc1f90ae7" \
  --room_id "AMB-001-ROOM-001"
```

## 🧪 Testing Checklist

### Pre-Flight Checks

- [ ] Backend running: `http://localhost:8000/docs`
- [ ] Frontend running: `http://localhost:3000`
- [ ] Database accessible (Supabase connection)
- [ ] Model checkpoints exist in `ai_models/`
- [ ] Camera available (test with `--cam 0`)

### Test Scenarios

#### 1. Basic Live Inference

```bash
python Testing_files/test_live.py --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt
```

**Expected**: Video window opens, pose detected, predictions displayed

#### 2. Database Storage Enabled

```bash
python Testing_files/test_live.py \
  --ckpt ai_models/best_single_view_f1_bn_t120_gamma175.pt \
  --store_db
```

**Expected**: "DB: X stored" count on video, session summary on exit

#### 3. WebRTC Broadcaster

```bash
python Testing_files/broadcaster.py --room TEST-ROOM-001 --video_device 0
```

**Expected**: Connects to backend, streams video to `/streamingDash`

## 📖 Documentation

- **[DATABASE_STORAGE_GUIDE.md](./DATABASE_STORAGE_GUIDE.md)** - Comprehensive guide for database integration
  - Command-line arguments
  - Data structure and schema
  - Integration patterns
  - SQL queries
  - Troubleshooting

## 🔗 Related Documentation

- **Model Testing**: `../test_model.py` - Architecture-agnostic model testing suite
- **Training Tests**: `../training_tests.py` - Training pipeline validation
- **Backend README**: `../README.md` - Backend architecture overview
- **Raspberry Pi Setup**: `../../Raspberry-Pi/README.md` - Edge device deployment

## 🛠️ Development

### Adding New Test Scripts

1. Place script in `Testing_files/` directory
2. Follow naming convention: `test_*.py` or `*_test.py`
3. Add documentation to this README
4. Include example usage and expected output

### Common Import Patterns

```python
# For database access
from core.common import supabase, logger

# For MediaPipe
import mediapipe as mp

# For PyTorch models
import torch
from models.pose_tcn import PoseTCNSingleView

# For WebRTC
from aiortc import RTCPeerConnection, VideoStreamTrack
```

## ⚠️ Troubleshooting

### Issue: Camera Not Found

**Error**: `cv2.error: Failed to open video device`

**Solution**:

- Windows: Use device name `"Logitech BRIO"` or similar
- macOS/Linux: Use device index `0`, `1`, etc.
- Check available devices: `python -c "import cv2; print(cv2.VideoCapture(0).isOpened())"`

### Issue: Model Not Loading

**Error**: `FileNotFoundError: Model checkpoint not found`

**Solution**:

- Verify checkpoint exists: `ls ai_models/`
- Use absolute path: `--ckpt /full/path/to/model.pt`
- Check Git LFS: `git lfs pull` to download large files

### Issue: Database Connection Failed

**Error**: `ImportError: No module named 'core.common'`

**Solution**:

- Ensure running from `Back-End/` directory: `cd Back-End`
- Check Python path includes backend: `export PYTHONPATH=$PWD`
- Verify `.env` file has database credentials

### Issue: WebRTC Connection Failed

**Error**: `Failed to connect to signaling server`

**Solution**:

- Ensure backend running: `http://localhost:8000`
- Check room ID format: `AMB-{number}-ROOM-{number}`
- Verify CORS settings allow localhost

## 📦 Dependencies

Key dependencies used by testing scripts:

```
opencv-python>=4.8.0
mediapipe>=0.10.0
torch>=2.0.0
aiortc>=1.5.0
numpy>=1.24.0
supabase>=2.0.0
```

Install all dependencies:

```bash
pip install -r ../requirements.txt
```

## 🎯 Use Cases

### For Developers

- **Test models locally** before deployment
- **Validate database integration** with live data
- **Debug WebRTC streaming** without Raspberry Pi
- **Prototype new features** with real-time inference

### For QA/Testing

- **Regression testing** after model updates
- **Performance benchmarking** (FPS, latency)
- **End-to-end validation** (camera → inference → database)
- **Stress testing** streaming infrastructure

### For Data Scientists

- **Model evaluation** on live camera feeds
- **Collect training data** from real-world scenarios
- **Tune hyperparameters** (temperature, confidence thresholds)
- **Compare model architectures** side-by-side

---

**Last Updated**: January 2025  
**Maintained by**: STEMSight Development Team
