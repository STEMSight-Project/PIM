# STEMSight PIM - Raspberry Pi Edge Device

## 🤖 Overview

The **Raspberry Pi 4 edge device** is the cornerstone of the STEMSight PIM system, providing real-time patient monitoring with local AI processing. Each RPi 4 unit is equipped with a camera module and runs advanced computer vision models to detect abnormal postures and involuntary movements directly at the point of care.

## 🏗️ Hardware Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Raspberry Pi 4 Unit                    │
├─────────────────────────────────────────────────────────┤
│  📹 Camera Module v2/v3 (8MP, 1080p60)                │
│  🧠 Edge AI Processing (MediaPipe + PyTorch)          │
│  📡 WiFi/Ethernet Connectivity                        │
│  💾 64GB+ MicroSD Card (OS + Models)                  │
│  🔌 USB-C Power (5V, 3A minimum)                      │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
Raspberry-Pi/
├── 📚 README.md                    # This file - RPi setup guide
├── 🤖 pose_model_capture.py        # Main camera capture & AI processing
├── 🔍 PostureMovementDetector.py   # MediaPipe pose detection engine
├──
├── 🧠 UNIK/                        # AI/ML Models (Edge deployment)
│   ├── run_unik.py                # Main UNIK model runner
│   ├── ensemble.py                # Model ensemble logic
│   ├── evaluation-cs.py           # Cross-section evaluation
│   ├── evaluation-cv.py           # Cross-validation evaluation
│   ├── unik_executable.py         # Standalone executable
│   ├── model/                     # PyTorch model definitions
│   ├── feeders/                   # Data feeding utilities
│   └── data_gen/                  # Data generation tools
│
├── 📋 requirements-rpi.txt         # RPi-specific Python dependencies
├── 🔧 setup_rpi.sh                # Automated setup script
├── ⚙️ config/                     # Configuration files
│   ├── camera_config.json         # Camera settings
│   ├── ai_config.json             # AI model parameters
│   └── network_config.json        # Backend connection settings
│
└── 📊 logs/                       # Runtime logs and diagnostics
    ├── pose_detection.log         # AI detection logs
    ├── camera_feed.log            # Camera operation logs
    └── network_connection.log     # Backend connectivity logs
```

## 🚀 Quick Setup Guide

### Prerequisites

- **Hardware**: Raspberry Pi 4 (4GB RAM recommended)
- **Camera**: Official RPi Camera Module v2 or v3
- **Storage**: 64GB+ Class 10 MicroSD card
- **Power**: Official RPi 4 USB-C power supply (5V, 3A)
- **OS**: Raspberry Pi OS Lite (64-bit) - Latest version

### 1. OS Installation & Initial Setup

```bash
# Flash Raspberry Pi OS to SD card using RPi Imager
# Enable SSH and WiFi during imaging process

# First boot - update system
sudo apt update && sudo apt upgrade -y

# Enable camera interface
sudo raspi-config
# Navigate to: Interface Options > Camera > Enable

# Reboot to apply camera settings
sudo reboot
```

### 2. Python Environment Setup

```bash
# Install Python dependencies
sudo apt install -y python3-pip python3-venv git

# Create virtual environment
python3 -m venv ~/stemsight-env
source ~/stemsight-env/bin/activate

# Install basic dependencies
pip install --upgrade pip setuptools wheel
```

### 3. Project Installation

```bash
# Clone the repository
git clone <repository-url>
cd PIM/Raspberry-Pi

# Install RPi-specific dependencies
pip install -r requirements-rpi.txt

# Install additional camera dependencies
sudo apt install -y python3-picamera2 libcamera-apps

# Test camera functionality
libcamera-hello --preview-timeout 5000
```

### 4. AI Models Setup

```bash
# Download pre-trained UNIK models (if not included)
# Models should be placed in UNIK/model/ directory

# Test AI processing
python3 -c "
from UNIK.run_unik import test_model
test_model()
print('AI models loaded successfully!')
"
```

### 5. Configuration

```bash
# Create configuration files
cp config/camera_config.json.example config/camera_config.json
cp config/ai_config.json.example config/ai_config.json
cp config/network_config.json.example config/network_config.json

# Edit network config to point to your backend
nano config/network_config.json
# Set backend_url to your FastAPI server
```

### 6. Start Monitoring

```bash
# Run the main pose detection system
python3 pose_model_capture.py --config config/

# For automatic startup, add to systemd or crontab
```

## 🔧 Core Components

### 1. **Pose Model Capture** (`pose_model_capture.py`)

The main orchestrator that:

- Initializes camera hardware
- Loads AI models into memory
- Captures video frames at 30 FPS
- Processes frames through pose detection pipeline
- Transmits results to backend API

```python
# Usage examples
python3 pose_model_capture.py --device camera_module
python3 pose_model_capture.py --config config/ --debug
python3 pose_model_capture.py --room_id patient_001 --backend_url http://your-server:8000
```

### 2. **Posture Movement Detector** (`PostureMovementDetector.py`)

MediaPipe-based pose analysis engine:

- Real-time landmark detection (33 pose points)
- Confidence scoring and filtering
- Abnormal posture classification
- Movement pattern analysis

```python
from PostureMovementDetector import PostureMovementDetector

detector = PostureMovementDetector()
results = detector.process_frame(camera_frame)

if results.abnormal_posture_detected:
    print(f"Alert: {results.detection_type} - Confidence: {results.confidence}")
```

### 3. **UNIK AI Models** (`UNIK/`)

Custom PyTorch models for medical pose classification:

- **Ensemble Model**: Combines multiple detection approaches
- **Real-time Inference**: Optimized for ARM64 architecture
- **Confidence Thresholds**: Adjustable sensitivity (default: 0.7)
- **Model Updates**: Hot-swappable for continuous improvement

## 🌐 Network Integration

### Backend Communication

```python
# Automatic data transmission to FastAPI backend
{
    "patient_id": "patient_001",
    "timestamp": "2025-09-13T10:30:00Z",
    "detection_type": "abnormal_posture",
    "confidence": 0.85,
    "camera_frame": "base64_encoded_image",
    "pose_landmarks": [...],
    "device_id": "rpi4_unit_001"
}
```

### WebRTC Streaming

- **Live Video Feed**: Direct streaming to healthcare dashboard
- **Low Latency**: < 100ms for real-time monitoring
- **Bandwidth Adaptive**: Automatic quality adjustment
- **Secure Connection**: Encrypted peer-to-peer communication

### Data Synchronization

- **Real-time Events**: Immediate alert transmission
- **Batch Processing**: Periodic bulk data uploads
- **Offline Mode**: Local storage during connectivity issues
- **Health Monitoring**: Device status reporting

## ⚙️ Configuration Options

### Camera Settings (`config/camera_config.json`)

```json
{
  "resolution": [1920, 1080],
  "framerate": 30,
  "exposure_mode": "auto",
  "white_balance": "auto",
  "rotation": 0,
  "preview_enabled": false,
  "capture_timeout": 5000
}
```

### AI Parameters (`config/ai_config.json`)

```json
{
  "confidence_threshold": 0.7,
  "detection_interval": 100,
  "landmark_visibility_threshold": 0.5,
  "model_ensemble_weights": [0.4, 0.3, 0.3],
  "enable_movement_tracking": true,
  "alert_cooldown_seconds": 30
}
```

### Network Settings (`config/network_config.json`)

```json
{
  "backend_url": "http://your-backend:8000",
  "room_id": "patient_room_001",
  "device_id": "rpi4_unit_001",
  "retry_attempts": 3,
  "heartbeat_interval": 60,
  "stream_quality": "high"
}
```

## 📊 Performance Optimization

### Hardware Optimization

```bash
# Increase GPU memory split for camera processing
sudo raspi-config
# Advanced Options > Memory Split > 128

# Enable hardware acceleration
echo 'gpu_mem=128' | sudo tee -a /boot/config.txt

# Optimize CPU governor for performance
echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Software Optimization

```python
# Multi-threading for parallel processing
import threading
from concurrent.futures import ThreadPoolExecutor

# Frame processing pipeline
with ThreadPoolExecutor(max_workers=4) as executor:
    future_camera = executor.submit(capture_frame)
    future_ai = executor.submit(process_pose, frame)
    future_network = executor.submit(transmit_data, results)
```

### Model Optimization

- **TensorRT**: GPU acceleration for inference
- **Quantization**: INT8 models for faster processing
- **Model Pruning**: Remove unnecessary parameters
- **Caching**: Pre-load models into memory

## 🔍 Monitoring & Debugging

### System Health Checks

```bash
# Check camera functionality
python3 -c "
from picamera2 import Picamera2
cam = Picamera2()
cam.start()
print('Camera: OK')
cam.stop()
"

# Monitor system resources
htop
# Watch: CPU, Memory, Temperature

# Check AI model status
python3 -c "
from UNIK.run_unik import verify_models
verify_models()
"
```

### Log Analysis

```bash
# View pose detection logs
tail -f logs/pose_detection.log

# Monitor camera operations
tail -f logs/camera_feed.log

# Check network connectivity
tail -f logs/network_connection.log

# System-wide logging
journalctl -u stemsight-monitor -f
```

### Performance Metrics

- **Frame Rate**: Target 30 FPS, minimum 20 FPS
- **CPU Usage**: < 80% average load
- **Memory Usage**: < 3GB of available 4GB
- **Temperature**: < 70°C under load
- **Network Latency**: < 50ms to backend

## 🛠️ Troubleshooting

### Common Issues

**Camera not detected:**

```bash
# Check camera connection
vcgencmd get_camera

# Expected output: supported=1 detected=1
# If detected=0, check ribbon cable connection
```

**AI models not loading:**

```bash
# Check PyTorch installation
python3 -c "import torch; print(torch.__version__)"

# Verify model files exist
ls -la UNIK/model/

# Check memory availability
free -h
```

**Network connectivity issues:**

```bash
# Test backend connection
curl -X GET http://your-backend:8000/health

# Check WiFi signal strength
iwconfig wlan0

# Monitor network traffic
iftop -i wlan0
```

### Performance Issues

**Low frame rate:**

- Reduce camera resolution
- Lower AI processing frequency
- Check CPU temperature
- Optimize model parameters

**High CPU usage:**

- Enable GPU acceleration
- Reduce detection interval
- Use model quantization
- Check for memory leaks

**Network delays:**

- Optimize streaming quality
- Check bandwidth usage
- Use local caching
- Monitor backend load

## 🔄 Automatic Startup

### Systemd Service

Create service file:

```bash
sudo nano /etc/systemd/system/stemsight-monitor.service
```

Service configuration:

```ini
[Unit]
Description=STEMSight PIM Patient Monitoring
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/PIM/Raspberry-Pi
Environment=PATH=/home/pi/stemsight-env/bin
ExecStart=/home/pi/stemsight-env/bin/python pose_model_capture.py --config config/
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable service:

```bash
sudo systemctl enable stemsight-monitor.service
sudo systemctl start stemsight-monitor.service
sudo systemctl status stemsight-monitor.service
```

## 📈 Deployment at Scale

### Hospital Ward Setup

```
Ward Layout:
┌─────────┬─────────┬─────────┬─────────┐
│ Bed 1   │ Bed 2   │ Bed 3   │ Bed 4   │
│ RPi #1  │ RPi #2  │ RPi #3  │ RPi #4  │
└─────────┴─────────┴─────────┴─────────┘
         │         │         │         │
         └─────────┼─────────┼─────────┘
                   │ Ethernet Switch │
                   └─────────────────┘
                           │
                    ┌─────────────────┐
                    │ Central Backend │
                    │   Dashboard     │
                    └─────────────────┘
```

### Device Management

- **Centralized Configuration**: Remote config updates
- **OTA Updates**: Automatic software deployment
- **Health Monitoring**: Real-time device status
- **Alert Management**: Centralized alarm system

## 🔮 Future Enhancements

- [ ] **5G Connectivity**: Ultra-low latency streaming
- [ ] **Edge Computing**: Distributed AI processing
- [ ] **Wearable Integration**: Multi-sensor fusion
- [ ] **Predictive Analytics**: ML-powered patient outcomes
- [ ] **AR Overlay**: Real-time visualization on mobile devices

## 📚 Additional Resources

- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [PyTorch ARM Installation](https://pytorch.org/get-started/locally/)
- [MediaPipe Pose](https://google.github.io/mediapipe/solutions/pose.html)
- [Camera Module Setup](https://www.raspberrypi.org/documentation/accessories/camera.html)

---

**For backend integration details, see [Backend Documentation](../Back-End/README.md)**  
**For dashboard access, see [Frontend Documentation](../Front-End/README.md)**
