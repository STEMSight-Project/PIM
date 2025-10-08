# 🎥 Raspberry Pi Broadcaster - Quick Reference

## Files Created & Cleaned Up

### ✅ Production Files

- **`rpi_broadcaster.py`** - Single camera broadcaster (matches main broadcaster logic)
- **`rpi_multi_broadcaster.py`** - Multi-camera broadcaster for concurrent streaming
- **`one_time_setup.sh`** - Automated Raspberry Pi setup script
- **`test_broadcaster.ps1`** - Pre-flight test script for Windows
- **`TESTING_GUIDE.md`** - Comprehensive testing documentation
- **`MULTI_CAMERA_SETUP.md`** - Multi-camera setup and architecture guide

### 🗑️ Removed Files

- **`rpi_broadcaster_old.py`** - Old backup (no longer needed)

## Quick Testing Guide

### 1. Pre-Flight Check (Windows)

```powershell
cd D:\DevProj\STEMSight\PIM\Raspberry-Pi
.\test_broadcaster.ps1
```

**What it checks:**

- ✅ Backend running (http://localhost:8000)
- ✅ Frontend running (http://localhost:3000)
- ✅ Python virtual environment exists
- ✅ FFMPEG installed

### 2. Setup Virtual Environment (First Time)

```powershell
# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements-rpi.txt
```

### 3. Test Single Camera Broadcaster

**Option A: Command line arguments**

```powershell
.\venv\Scripts\Activate.ps1
python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
```

**Option B: Using config file**

```powershell
# Create config
Copy-Item config\multi_camera_config.example.json config\camera_config.json
notepad config\camera_config.json

# Run broadcaster
python rpi_broadcaster.py --config config\camera_config.json
```

### 4. Test Multi-Camera Broadcaster

```powershell
# Setup config
Copy-Item config\multi_camera_config.example.json config\multi_camera_config.json
notepad config\multi_camera_config.json

# Edit config to match your cameras:
{
  "ambulance_number": "001",
  "server_url": "http://localhost:8000",
  "cameras": [
    {"device": "Logitech BRIO", "enabled": true, "description": "Camera 1"},
    {"device": "USB Camera", "enabled": true, "description": "Camera 2"}
  ]
}

# Run multi-camera broadcaster
python rpi_multi_broadcaster.py --config config\multi_camera_config.json
```

### 5. Verify on Frontend

1. Open http://localhost:3000/streamingDash
2. Look for rooms:
   - `AMB-001-ROOM-001` (single camera or first multi-camera)
   - `AMB-001-ROOM-002` (second camera if multi-camera)
3. Click room to view stream
4. Video should play without "waiting for data" message

## Expected Output

### Single Camera Success ✅

```
🚀 Starting broadcaster...
📋 Ambulance: AMB-001
📹 Camera settings: 640x480 @ 30fps on Logitech BRIO
✅ Ambulance AMB-001 found (ID: xxx)
✅ Session created (ID: xxx)
✅ Camera selected (ID: xxx)
✅ Room created: AMB-001-ROOM-001
📡 Connecting to streaming endpoint...
✅ Streaming started!
📊 Connection state: connected
```

### Multi-Camera Success ✅

```
============================================================
🎥 STEMSight Multi-Camera Broadcaster
============================================================
📋 Config: config/multi_camera_config.json

📹 Setting up 2 cameras...
✅ Camera 1 configured: Logitech BRIO
✅ Camera 2 configured: USB Camera
🚀 Starting 2 cameras...
📹 Camera 1 settings: 640x480 @ 25fps on Logitech BRIO
📹 Camera 2 settings: 640x480 @ 25fps on USB Camera
✅ Camera 1 streaming started!
✅ Camera 2 streaming started!
✅ All cameras started
```

## Common Issues & Fixes

### Issue: "No ambulance found"

```
❌ Ambulance AMB-001 not found
```

**Fix:** Create ambulance in backend:

1. Go to http://localhost:8000/docs
2. Use `/ambulances/` POST endpoint
3. Create ambulance with `ambulance_number: "001"`

### Issue: "No video track found"

```
❌ No video track found
```

**Fix:** Check camera name:

```powershell
# List available cameras
ffmpeg -list_devices true -f dshow -i dummy
```

Use exact camera name from the list.

### Issue: "Module not found"

```
ModuleNotFoundError: No module named 'aiortc'
```

**Fix:** Install dependencies:

```powershell
.\venv\Scripts\Activate.ps1
pip install -r requirements-rpi.txt
```

### Issue: "Backend connection refused"

```
❌ Error fetching ambulances: Cannot connect to host
```

**Fix:** Start backend:

```powershell
cd D:\DevProj\STEMSight\PIM\Back-End
uvicorn main:app --reload
```

## Raspberry Pi Deployment

### One-Time Setup

```bash
# SSH into Raspberry Pi
ssh pi@raspberrypi.local

# Upload and run setup script
chmod +x one_time_setup.sh
sudo ./one_time_setup.sh

# Follow the wizard to configure:
# - Ambulance number
# - Server URL
# - Camera device
```

### Manual Testing on RPi

```bash
# Check cameras
ls -l /dev/video*

# Test single camera
cd /home/pi/stemsight
source venv/bin/activate
python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device /dev/video0

# Test multi-camera
python rpi_multi_broadcaster.py --config config/multi_camera_config.json
```

### Enable Auto-Start

```bash
# Single camera service
sudo systemctl enable stemsight-broadcaster.service
sudo systemctl start stemsight-broadcaster.service

# Multi-camera service
sudo systemctl enable stemsight-multi-broadcaster.service
sudo systemctl start stemsight-multi-broadcaster.service

# Check status
sudo systemctl status stemsight-broadcaster.service
```

## Architecture Decision

### Use Single-Camera Broadcaster (`rpi_broadcaster.py`) when:

- ✅ One camera per Raspberry Pi
- ✅ Simple deployment
- ✅ Command-line control needed

### Use Multi-Camera Broadcaster (`rpi_multi_broadcaster.py`) when:

- ✅ 2-4 cameras on same Raspberry Pi
- ✅ All cameras streaming simultaneously
- ✅ Unified configuration preferred
- ✅ Lower system overhead desired

**Performance Limits (Raspberry Pi 4):**

- **1 camera:** 1280x720 @ 30fps ✅ Perfect
- **2 cameras:** 640x480 @ 30fps ✅ Good
- **3-4 cameras:** 640x480 @ 20fps ⚠️ Use Ethernet
- **5+ cameras:** ❌ Use multiple Raspberry Pi devices

## Documentation Files

- **`TESTING_GUIDE.md`** - Detailed testing procedures and troubleshooting
- **`MULTI_CAMERA_SETUP.md`** - Multi-camera architecture and configuration
- **`README.md`** - General Raspberry Pi setup (existing)
- **`BROADCASTER_USAGE.md`** - Main broadcaster usage (in Testing_files/)

## Next Steps

1. ✅ Run `.\test_broadcaster.ps1` to verify environment
2. ⬜ Create virtual environment if needed
3. ⬜ Test with single camera on Windows
4. ⬜ Test with multi-camera if you have multiple cameras
5. ⬜ Deploy to actual Raspberry Pi using `one_time_setup.sh`
6. ⬜ Enable systemd service for auto-start

---

**Questions?** Check `TESTING_GUIDE.md` or `MULTI_CAMERA_SETUP.md` for detailed information.
