# PIM Broadcaster Clean - Usage Documentation

## Overview

The **PIM Broadcaster Clean** (`pim_broadcaster_clean.py`) is the final, production-ready implementation that combines:

- **Proven WebRTC Framework**: Uses the established `broadcaster.py` aiortc patterns
- **Working PIM AI Model**: Integrates the corrected JointBoneEnsembleLSTM architecture
- **Real-time Detection**: MediaPipe pose detection with AI movement classification
- **Backend Integration**: Seamless room creation and session management via FastAPI

## Quick Start

### 1. Prerequisites

Ensure your environment is set up:

```bash
# Activate virtual environment
cd "C:\Users\Mike\PIM Detector\PIM"
.\.venv\Scripts\Activate.ps1

# Verify backend is running
# Backend should be running on http://localhost:8000

# Verify frontend is running
# Frontend should be running on http://localhost:3000
```

### 2. Start PIM Broadcasting

```bash
cd "Back-End\Testing_files"

# Basic usage
python pim_broadcaster_clean.py --room "your-room-id" --video_device "Logitech HD Webcam C525"

# With custom device name
python pim_broadcaster_clean.py --room "patient-123" --video_device "Logitech HD Webcam C525" --device_name "CleanPIM-Broadcaster"
```

### 3. Connect from Frontend

1. Open: `http://localhost:3000/streaming-test`
2. Click: **"Connect via Backend API"** (not direct connection)
3. View live video with PIM detection overlays

## Command Line Arguments

| Argument         | Required | Default                     | Description                                      |
| ---------------- | -------- | --------------------------- | ------------------------------------------------ |
| `--room`         | ✅ Yes   | -                           | Unique room identifier for the streaming session |
| `--video_device` | ❌ No    | `"Logitech HD Webcam C525"` | Camera device name or index                      |
| `--device_name`  | ❌ No    | `"CleanPIM-Broadcaster"`    | Device identifier for the broadcaster            |
| `--signaling`    | ❌ No    | `"http://localhost:8000"`   | Backend API base URL                             |

### Examples

```bash
# Patient monitoring session
python pim_broadcaster_clean.py --room "patient-456" --device_name "ICU-Camera-01"

# Research session
python pim_broadcaster_clean.py --room "research-session-789" --video_device "0" --device_name "Research-Cam"

# Custom backend server
python pim_broadcaster_clean.py --room "remote-session" --signaling "https://your-server.com"
```

## System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  PIM Broadcaster │    │   FastAPI        │    │   Frontend      │
│  Clean          │◄──►│   Backend        │◄──►│   Dashboard     │
│                 │    │                  │    │                 │
│ • Camera Input  │    │ • Room Mgmt      │    │ • Live Video    │
│ • MediaPipe     │    │ • WebRTC Signal  │    │ • PIM Overlays  │
│ • PIM AI Model  │    │ • Session Track  │    │ • Detection UI  │
│ • Video Stream  │    │ • Database       │    │ • Controls      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## PIM Detection Features

### Movement Classifications

The system detects **9 different movement types**:

1. **Decorticate** - Abnormal flexor posturing
2. **Decerebrate** - Abnormal extensor posturing
3. **Dystonia** - Involuntary muscle contractions
4. **Chorea** - Rapid, jerky movements
5. **Myoclonus** - Sudden muscle jerks
6. **Fencer Posture** - Asymmetric tonic neck reflex
7. **Ballistic** - Large amplitude, flinging movements
8. **Tremor** - Rhythmic oscillatory movements
9. **Versive Head** - Head turning movements

### Detection Process

1. **MediaPipe Processing**: Extracts 33 pose landmarks from video frames
2. **Sequence Buffering**: Maintains 30-frame rolling window (1 second at 30 FPS)
3. **AI Classification**: JointBoneEnsembleLSTM processes joint + bone features
4. **Confidence Scoring**: Dual output (classification + confidence)
5. **Prediction Stabilization**: 5-frame history for stable results
6. **Visual Overlay**: Real-time detection display on video stream

## Startup Sequence

When you run the clean broadcaster, you'll see this initialization sequence:

```
INFO:pim_broadcaster:🎯 Clean PIM Broadcaster Starting
INFO:pim_broadcaster:Room: your-room-id
INFO:pim_broadcaster:Server: http://localhost:8000
INFO:pim_broadcaster:Video Device: Logitech HD Webcam C525
INFO:pim_broadcaster:Device Name: CleanPIM-Broadcaster
INFO:pim_broadcaster:aiortc version: 1.11.0
INFO:pim_broadcaster:✅ PIM Model loaded: ['decorticate', 'dystonia', ...]
INFO:pim_broadcaster:✅ PIM Video Stream initialized with device: ...
INFO:pim_broadcaster:✅ PIM video track added
INFO:pim_broadcaster:🔗 Creating room: http://localhost:8000/streaming/...
INFO:pim_broadcaster:✅ Room created: {'room_id': '...', 'session_id': '...'}
INFO:pim_broadcaster:✅ Streaming started
INFO:pim_broadcaster:🎥 PIM Broadcasting active - press Ctrl+C to stop
```

## Frontend Integration

### Connection Methods

The system supports **Backend API connection** (recommended):

```typescript
// In your React component
const { startStreaming, stopStreaming, isConnected, error } =
  useStreamingEnhanced();

// Connect via Backend API (recommended)
const handleConnect = () => {
  startStreaming(patientId, false); // false = use Backend API
};

// Monitor connection status
useEffect(() => {
  if (isConnected) {
    console.log("✅ Connected to PIM broadcaster");
  }
  if (error) {
    console.error("❌ Connection error:", error);
  }
}, [isConnected, error]);
```

### Room ID Management

The broadcaster creates rooms with this format:

- **Input**: `--room "patient-123"`
- **Created**: `"patient-123-CleanPIM-Broadcaster"`
- **Frontend**: Looks for active sessions with patient ID `"patient-123"`

## Troubleshooting

### Common Issues

#### 1. "No active room found"

```
Error: No active room found for patient 0cabaa76-b0cb-4785-ae2a-9b5e96739ae3
```

**Solution**: Ensure the broadcaster is running and has successfully created a room.

#### 2. Camera Access Errors

```
ERROR: Failed to open camera device: Logitech HD Webcam C525
```

**Solutions**:

- Check camera is not in use by other applications
- Try using device index: `--video_device "0"`
- List available cameras: `python -c "import cv2; print([cv2.VideoCapture(i).getBackendName() for i in range(5)])"`

#### 3. Model Loading Errors

```
ERROR: Failed to load PIM model: ...
```

**Solutions**:

- Verify model file exists: `ls "../models/pim_model_joint_bone.pth"`
- Check file permissions
- Ensure model architecture matches (should be automatic)

#### 4. Backend Connection Errors

```
ERROR: Could not connect to backend: http://localhost:8000
```

**Solutions**:

- Verify FastAPI backend is running on port 8000
- Check firewall settings
- Try custom signaling URL: `--signaling "http://your-server:port"`

### Debug Mode

For detailed logging, modify the logging level in the broadcaster:

```python
# In pim_broadcaster_clean.py, change:
logging.basicConfig(level=logging.DEBUG)  # Instead of INFO
```

### Performance Optimization

#### Camera Settings

The broadcaster optimizes camera settings for performance:

- **Resolution**: 640x480 (good balance of quality vs performance)
- **FPS**: 30 (matches AI model sequence requirements)
- **Buffer**: Minimal to reduce latency

#### AI Processing

- **Sequence Length**: 30 frames (1 second)
- **Confidence Threshold**: 0.7 (adjustable in code)
- **Prediction Stabilization**: 5-frame rolling average

## Integration with Existing System

### Backend API Endpoints Used

```
POST /streaming/create_room/{room_id}?device_name={name}
GET  /streaming/rooms
POST /streaming/sessions
GET  /streaming/sessions?is_live=true
```

### Database Integration

The broadcaster automatically:

- Creates streaming rooms in Supabase
- Manages session lifecycle
- Stores detection metadata
- Handles room cleanup on disconnect

### Authentication

The broadcaster uses the same authentication system as the main application:

- OAuth2 Bearer tokens
- Supabase Row Level Security
- Session management

## Production Deployment

### Raspberry Pi Deployment

For edge deployment (as per project architecture):

```bash
# Copy to Raspberry Pi
scp pim_broadcaster_clean.py pi@your-rpi:/home/pi/
scp -r ../models/ pi@your-rpi:/home/pi/

# Run on Pi
python pim_broadcaster_clean.py --room "icu-bed-1" --video_device "0" --device_name "RPi-ICU-01"
```

### Docker Deployment

```dockerfile
FROM python:3.11
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "pim_broadcaster_clean.py", "--room", "$ROOM_ID", "--device_name", "$DEVICE_NAME"]
```

### Systemd Service

```ini
[Unit]
Description=PIM Broadcaster Clean
After=network.target

[Service]
Type=simple
User=pim
WorkingDirectory=/opt/pim-detector/Back-End/Testing_files
ExecStart=/opt/pim-detector/.venv/bin/python pim_broadcaster_clean.py --room "default" --device_name "SystemService"
Restart=always

[Install]
WantedBy=multi-user.target
```

## API Reference

### Configuration Constants

```python
# Camera settings
CAMERA_WIDTH = 640
CAMERA_HEIGHT = 480
CAMERA_FPS = 30

# AI Model settings
SEQUENCE_LENGTH = 30  # frames
CONFIDENCE_THRESHOLD = 0.7
PREDICTION_HISTORY_SIZE = 5

# Network settings
DEFAULT_SIGNALING_SERVER = "http://localhost:8000"
DEFAULT_VIDEO_DEVICE = "Logitech HD Webcam C525"
```

### Key Classes

- **`JointBoneEnsembleLSTM`**: PIM AI model architecture
- **`PIMVideoStreamTrack`**: Custom aiortc video track with AI processing
- **`MediaPipe Pose`**: Pose landmark extraction

## Monitoring and Logging

### Log Levels

- **INFO**: Normal operation, connections, room creation
- **ERROR**: Critical errors, connection failures
- **DEBUG**: Detailed AI processing, frame-by-frame analysis

### Key Metrics

Monitor these for system health:

- Frame processing rate (target: 30 FPS)
- AI inference time (target: <33ms per frame)
- Detection confidence scores
- WebRTC connection quality
- Memory usage (model + video buffers)

## Support and Maintenance

### Regular Maintenance

1. **Model Updates**: Replace `pim_model_joint_bone.pth` as needed
2. **Dependency Updates**: Keep aiortc, MediaPipe, PyTorch current
3. **Log Rotation**: Manage log file sizes in production
4. **Performance Monitoring**: Track detection accuracy and latency

### Getting Help

1. **Check Logs**: Always start with the broadcaster console output
2. **Test Components**: Use `ultra_simple_pim_broadcast.py` to isolate AI issues
3. **Network Testing**: Use frontend streaming-test page for connection debugging
4. **Model Verification**: Ensure PIM model loads and produces varied predictions

---

**Created**: September 18, 2025  
**Version**: Clean Implementation v1.0  
**Compatibility**: Windows 11, Python 3.11, PyTorch 2.x, aiortc 1.11+
