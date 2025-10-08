# Multi-Camera Streaming Setup Guide

## Overview

This guide explains how to stream **multiple cameras simultaneously** from a single Raspberry Pi device in the STEMSight PIM system.

## Architecture Options

### 1. **Multi-Camera Broadcaster (Recommended)**

Stream multiple cameras concurrently from one Raspberry Pi process.

**Pros:**
- ✅ Single process manages all cameras
- ✅ Unified configuration and logging
- ✅ Lower system overhead
- ✅ Easier management and monitoring

**Cons:**
- ⚠️ All cameras go down if process crashes
- ⚠️ Shared system resources

**When to Use:**
- Ambulance with 2-4 cameras (front, side, rear, equipment)
- All cameras need to stream simultaneously
- Centralized control preferred

### 2. **Multiple Single-Camera Instances**

Run separate broadcaster processes for each camera.

**Pros:**
- ✅ Camera isolation - one crash doesn't affect others
- ✅ Independent restart/control per camera
- ✅ Can use existing single-camera broadcaster

**Cons:**
- ⚠️ Higher system overhead (multiple processes)
- ⚠️ More complex systemd service management
- ⚠️ Separate configurations needed

**When to Use:**
- Critical cameras that must stay independent
- Different streaming schedules per camera
- Testing/development scenarios

## Multi-Camera Broadcaster Setup

### Step 1: Hardware Preparation

#### Connect Multiple USB Cameras

```bash
# Check connected cameras
ls -l /dev/video*

# Expected output for 3 cameras:
# /dev/video0
# /dev/video1
# /dev/video2

# Test each camera
v4l2-ctl --list-devices

# Verify camera capabilities
v4l2-ctl --device=/dev/video0 --list-formats-ext
v4l2-ctl --device=/dev/video1 --list-formats-ext
```

#### Camera Detection Issues

If cameras don't appear:

```bash
# Check USB devices
lsusb

# Check kernel messages
dmesg | grep -i video

# Reboot if needed
sudo reboot
```

### Step 2: Configuration

#### Create Multi-Camera Config

```bash
cd /home/pi/stemsight/config
cp multi_camera_config.example.json multi_camera_config.json
nano multi_camera_config.json
```

#### Configuration Format

```json
{
  "ambulance_number": "001",  // Your ambulance number
  "server_url": "http://your-backend-server:8000",
  "cameras": [
    {
      "device": "/dev/video0",
      "enabled": true,
      "description": "Front camera - Patient view"
    },
    {
      "device": "/dev/video1",
      "enabled": true,
      "description": "Side camera - Equipment view"
    },
    {
      "device": "/dev/video2",
      "enabled": false,  // Disabled - won't stream
      "description": "Rear camera - Reserved"
    }
  ]
}
```

**Configuration Fields:**
- `ambulance_number`: The ambulance this RPi belongs to (e.g., "001" for AMB-001)
- `server_url`: Your FastAPI backend URL
- `cameras`: Array of camera configurations
  - `device`: Device path (e.g., /dev/video0)
  - `enabled`: Whether to stream this camera (true/false)
  - `description`: Human-readable description (optional, for documentation)

### Step 3: Camera Settings

Edit camera settings in `camera_config.json`:

```json
{
  "resolution": [640, 480],  // Lower resolution for multi-camera
  "framerate": 25,           // Reduced framerate (25fps instead of 30fps)
  "bitrate": "400000"        // Lower bitrate per camera (400kbps)
}
```

**Performance Guidelines:**

| Cameras | Resolution | FPS | Bitrate/Camera | Total Bandwidth |
|---------|------------|-----|----------------|-----------------|
| 1       | 1280x720   | 30  | 1000kbps       | 1 Mbps          |
| 2       | 640x480    | 30  | 500kbps        | 1 Mbps          |
| 3       | 640x480    | 25  | 400kbps        | 1.2 Mbps        |
| 4       | 640x480    | 20  | 300kbps        | 1.2 Mbps        |

### Step 4: Systemd Service

#### Create Multi-Camera Service

```bash
sudo nano /etc/systemd/system/stemsight-multi-broadcaster.service
```

```ini
[Unit]
Description=STEMSight Multi-Camera Broadcaster
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/stemsight
ExecStart=/home/pi/stemsight/venv/bin/python rpi_multi_broadcaster.py --config /home/pi/stemsight/config/multi_camera_config.json
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

#### Enable and Start Service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable auto-start on boot
sudo systemctl enable stemsight-multi-broadcaster.service

# Start service
sudo systemctl start stemsight-multi-broadcaster.service

# Check status
sudo systemctl status stemsight-multi-broadcaster.service

# View logs
sudo journalctl -u stemsight-multi-broadcaster.service -f
```

### Step 5: Testing

#### Manual Test

```bash
# Activate virtual environment
source /home/pi/stemsight/venv/bin/activate

# Run broadcaster
python rpi_multi_broadcaster.py --config config/multi_camera_config.json
```

**Expected Output:**

```
============================================================
🎥 STEMSight Multi-Camera Broadcaster
============================================================
📋 Config: config/multi_camera_config.json

📹 Setting up 2 cameras...
✅ Camera 1 configured: /dev/video0
✅ Camera 2 configured: /dev/video1
🚀 Starting 2 cameras...
📹 Camera 1 settings: 640x480 @ 25fps on /dev/video0
📹 Camera 2 settings: 640x480 @ 25fps on /dev/video1
✅ Camera 1 streaming started!
✅ Camera 2 streaming started!
✅ All cameras started
```

#### Frontend Verification

1. Go to **Live Cameras** dashboard (`/streamingDash`)
2. You should see multiple rooms for your ambulance:
   - `AMB-001-ROOM-001` (Camera 1)
   - `AMB-001-ROOM-002` (Camera 2)
3. Click each room to view the streams
4. Verify all cameras show as "connected"

## Multiple Single-Camera Instances Setup

### Option A: Using Systemd Templates

#### Create Template Service

```bash
sudo nano /etc/systemd/system/stemsight-broadcaster@.service
```

```ini
[Unit]
Description=STEMSight Broadcaster for Camera %i
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/stemsight
Environment="CAMERA_NUMBER=%i"
ExecStart=/home/pi/stemsight/venv/bin/python rpi_broadcaster.py --room %i --video_device /dev/video%i
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

#### Enable Multiple Instances

```bash
# Start camera 0, 1, 2
sudo systemctl enable stemsight-broadcaster@0.service
sudo systemctl enable stemsight-broadcaster@1.service
sudo systemctl enable stemsight-broadcaster@2.service

# Start all
sudo systemctl start stemsight-broadcaster@0.service
sudo systemctl start stemsight-broadcaster@1.service
sudo systemctl start stemsight-broadcaster@2.service

# Check status
sudo systemctl status 'stemsight-broadcaster@*'
```

### Option B: Separate Configuration Files

Create individual configs:

```bash
# Camera 1 config
cat > config/camera1.json << EOF
{
  "ambulance_number": "001",
  "server_url": "http://backend:8000",
  "camera_device": "/dev/video0",
  "room_number": "001"
}
EOF

# Camera 2 config
cat > config/camera2.json << EOF
{
  "ambulance_number": "001",
  "server_url": "http://backend:8000",
  "camera_device": "/dev/video1",
  "room_number": "002"
}
EOF
```

## Troubleshooting

### Cameras Not Detected

```bash
# Check USB devices
lsusb

# Check video devices
ls -l /dev/video*

# Check kernel modules
lsmod | grep uvcvideo

# Reload USB camera module
sudo modprobe -r uvcvideo
sudo modprobe uvcvideo
```

### Camera Access Denied

```bash
# Add user to video group
sudo usermod -a -G video pi

# Check permissions
ls -l /dev/video*

# Logout and login for group changes to take effect
```

### High CPU Usage

**Solution 1: Lower Resolution**
```json
{
  "resolution": [320, 240],  // Very low for testing
  "framerate": 15
}
```

**Solution 2: Reduce Framerate**
```json
{
  "framerate": 15  // Lower framerate
}
```

**Solution 3: Lower Bitrate**
```json
{
  "bitrate": "200000"  // 200kbps per camera
}
```

### Network Bandwidth Issues

**Check Bandwidth:**
```bash
# Install iftop
sudo apt-get install iftop

# Monitor bandwidth
sudo iftop -i wlan0  # or eth0 for ethernet
```

**Solutions:**
1. **Reduce Total Cameras**: Disable some cameras in config
2. **Lower Quality**: Reduce resolution/framerate/bitrate
3. **Upgrade Network**: Use Ethernet instead of WiFi
4. **Stagger Streams**: Use multiple single-camera instances with different start times

### Service Won't Start

```bash
# Check service status
sudo systemctl status stemsight-multi-broadcaster.service

# View detailed logs
sudo journalctl -u stemsight-multi-broadcaster.service -n 100 --no-pager

# Check Python environment
source /home/pi/stemsight/venv/bin/activate
python --version
pip list | grep aiortc

# Test manually
python rpi_multi_broadcaster.py --config config/multi_camera_config.json
```

## Performance Optimization

### Raspberry Pi 4 Recommended Settings

**For 2 Cameras:**
```json
{
  "resolution": [640, 480],
  "framerate": 30,
  "bitrate": "500000"
}
```

**For 3-4 Cameras:**
```json
{
  "resolution": [640, 480],
  "framerate": 20,
  "bitrate": "300000"
}
```

### Hardware Requirements

| Cameras | Min RPi Model | RAM    | Network      | Storage  |
|---------|---------------|--------|--------------|----------|
| 1       | RPi 3B+       | 1GB    | WiFi/Eth     | 8GB      |
| 2       | RPi 4         | 2GB    | Eth Recommended | 16GB |
| 3-4     | RPi 4         | 4GB    | Ethernet Required | 32GB |
| 5+      | Not Recommended | -    | -            | -        |

### USB Camera Power

**Power Issues:**
- USB cameras can draw significant power
- Raspberry Pi USB ports limited to 1.2A total
- Use powered USB hub for 3+ cameras

```bash
# Check USB power
lsusb -t

# Use powered USB hub
# Connect hub to RPi
# Connect cameras to hub
```

## Best Practices

### 1. Camera Naming Convention

Use descriptive room names in config:
```json
{
  "cameras": [
    {"device": "/dev/video0", "description": "Front-Patient"},
    {"device": "/dev/video1", "description": "Side-Equipment"},
    {"device": "/dev/video2", "description": "Rear-Monitor"}
  ]
}
```

### 2. Gradual Rollout

1. **Test with 1 camera** first
2. **Add 2nd camera** and verify performance
3. **Add more cameras** incrementally
4. **Monitor CPU/bandwidth** at each step

### 3. Monitoring

```bash
# CPU usage
htop

# Temperature
vcgencmd measure_temp

# Bandwidth
sudo iftop -i eth0

# Logs
sudo journalctl -u stemsight-multi-broadcaster.service -f
```

### 4. Backup Configuration

```bash
# Backup configs before changes
cp config/multi_camera_config.json config/multi_camera_config.backup.json

# Version control
git add config/
git commit -m "Updated camera configuration"
```

## Migration from Single to Multi-Camera

### Step-by-Step Migration

1. **Stop existing single-camera service**
   ```bash
   sudo systemctl stop stemsight-broadcaster.service
   sudo systemctl disable stemsight-broadcaster.service
   ```

2. **Create multi-camera config**
   ```bash
   cp config/multi_camera_config.example.json config/multi_camera_config.json
   nano config/multi_camera_config.json
   ```

3. **Test multi-camera broadcaster manually**
   ```bash
   python rpi_multi_broadcaster.py --config config/multi_camera_config.json
   ```

4. **Setup new service**
   ```bash
   sudo systemctl enable stemsight-multi-broadcaster.service
   sudo systemctl start stemsight-multi-broadcaster.service
   ```

5. **Verify frontend shows all cameras**

## Summary

### Quick Decision Guide

**Choose Multi-Camera Broadcaster (`rpi_multi_broadcaster.py`) when:**
- ✅ You have 2-4 cameras on the same ambulance
- ✅ All cameras should stream simultaneously
- ✅ Unified management preferred
- ✅ Lower system overhead desired

**Choose Multiple Single-Camera Instances when:**
- ✅ You need camera isolation
- ✅ Different streaming schedules per camera
- ✅ Independent restart control required
- ✅ Testing/development environment

### Resource Limits

**Raspberry Pi 4 (4GB RAM):**
- **Maximum Recommended:** 4 cameras at 640x480, 20fps
- **Optimal:** 2 cameras at 640x480, 30fps
- **Network:** Ethernet strongly recommended for 3+ cameras

For more cameras, consider **multiple Raspberry Pi devices** instead of overloading one device.
