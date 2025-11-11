#!/bin/bash
################################################################################
# STEMSight Raspberry Pi One-Time Setup Script
# This script sets up a Raspberry Pi 4 for ambulance camera streaming
################################################################################

set -e  # Exit on error

echo "============================================================"
echo "🚑 STEMSight Raspberry Pi One-Time Setup"
echo "============================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Get the actual user who invoked sudo
ACTUAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$ACTUAL_USER)

echo "📋 Setup Information:"
echo "   User: $ACTUAL_USER"
echo "   Home: $USER_HOME"
echo ""

# Step 1: Update system
echo "1️⃣  Updating system packages..."
apt-get update
apt-get upgrade -y
echo "✅ System updated"
echo ""

# Step 2: Install system dependencies
echo "2️⃣  Installing system dependencies..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    libavformat-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev \
    libavfilter-dev \
    libopus-dev \
    libvpx-dev \
    pkg-config \
    libsrtp2-dev \
    git \
    v4l-utils

echo "✅ System dependencies installed"
echo ""

# Step 3: Enable camera
echo "3️⃣  Enabling Raspberry Pi camera..."
if ! grep -q "^start_x=1" /boot/config.txt; then
    echo "start_x=1" >> /boot/config.txt
    echo "gpu_mem=128" >> /boot/config.txt
    echo "⚠️  Camera enabled - REBOOT REQUIRED after setup completes"
    REBOOT_NEEDED=true
else
    echo "✅ Camera already enabled"
fi
echo ""

# Step 4: Create project directory
echo "4️⃣  Creating project directory..."
PROJECT_DIR="$USER_HOME/stemsight"
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/logs"
mkdir -p "$PROJECT_DIR/config"
chown -R $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR"
echo "✅ Project directory created: $PROJECT_DIR"
echo ""

# Step 5: Create Python virtual environment
echo "5️⃣  Creating Python virtual environment..."
cd "$PROJECT_DIR"
sudo -u $ACTUAL_USER python3 -m venv venv
echo "✅ Virtual environment created"
echo ""

# Step 6: Install Python dependencies
echo "6️⃣  Installing Python dependencies..."
cat > "$PROJECT_DIR/requirements.txt" << 'EOF'
# STEMSight Raspberry Pi Requirements
aiortc==1.6.0
aiohttp==3.9.1
opencv-python-headless==4.8.1.78
numpy==1.24.3
av==10.0.0
asyncio==3.4.3
websockets==12.0
requests==2.31.0
EOF

sudo -u $ACTUAL_USER "$PROJECT_DIR/venv/bin/pip" install --upgrade pip
sudo -u $ACTUAL_USER "$PROJECT_DIR/venv/bin/pip" install -r "$PROJECT_DIR/requirements.txt"
echo "✅ Python dependencies installed"
echo ""

# Step 7: Create default configuration files
echo "7️⃣  Creating default configuration files..."

# Network configuration
cat > "$PROJECT_DIR/config/network_config.json" << 'EOF'
{
  "ambulance_number": "001",
  "room_number": "001",
  "server_url": "http://localhost:8000",
  "device_name": "RPi-Front-Camera",
  "auto_start": true,
  "reconnect_interval": 5,
  "retry_attempts": 3
}
EOF

# Camera configuration
cat > "$PROJECT_DIR/config/camera_config.json" << 'EOF'
{
  "resolution": [640, 480],
  "framerate": 30,
  "bitrate": "1000000",
  "pixel_format": "yuv420p",
  "enable_audio": false
}
EOF

chown -R $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/config"
echo "✅ Configuration files created"
echo ""

# Step 8: Create systemd service
echo "8️⃣  Creating systemd service..."
cat > /etc/systemd/system/stemsight-broadcaster.service << EOF
[Unit]
Description=STEMSight Ambulance Camera Broadcaster
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$ACTUAL_USER
WorkingDirectory=$PROJECT_DIR
Environment="PATH=$PROJECT_DIR/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$PROJECT_DIR/venv/bin/python3 $PROJECT_DIR/rpi_broadcaster.py --config
Restart=always
RestartSec=10
StandardOutput=append:$PROJECT_DIR/logs/broadcaster.log
StandardError=append:$PROJECT_DIR/logs/broadcaster-error.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
echo "✅ Systemd service created"
echo ""

# Step 9: Create configuration wizard script
echo "9️⃣  Creating configuration wizard..."
cat > "$PROJECT_DIR/configure.py" << 'EOFPY'
#!/usr/bin/env python3
"""
Configuration wizard for STEMSight Raspberry Pi broadcaster
"""
import json
import os

def configure_network():
    print("\n🌐 Network Configuration")
    print("=" * 50)
    
    ambulance = input("Enter Ambulance Number (e.g., 001): ").strip().zfill(3)
    room = input("Enter Room/Camera Number (e.g., 001): ").strip().zfill(3)
    server = input("Enter Server URL (e.g., http://192.168.1.100:8000): ").strip()
    device_name = input(f"Enter Device Name [RPi-AMB-{ambulance}]: ").strip() or f"RPi-AMB-{ambulance}"
    
    config = {
        "ambulance_number": ambulance,
        "room_number": room,
        "server_url": server,
        "device_name": device_name,
        "auto_start": True,
        "reconnect_interval": 5,
        "retry_attempts": 3
    }
    
    config_path = os.path.expanduser("~/stemsight/config/network_config.json")
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"\n✅ Configuration saved to {config_path}")
    print(f"🚑 Ambulance: AMB-{ambulance}")
    print(f"📹 Room: AMB-{ambulance}-ROOM-{room}")
    print(f"🌐 Server: {server}")

def configure_camera():
    print("\n📹 Camera Configuration")
    print("=" * 50)
    
    print("Available resolutions:")
    print("  1. 640x480 (Default)")
    print("  2. 1280x720 (HD)")
    print("  3. 1920x1080 (Full HD)")
    
    choice = input("Select resolution [1]: ").strip() or "1"
    resolutions = {
        "1": [640, 480],
        "2": [1280, 720],
        "3": [1920, 1080]
    }
    resolution = resolutions.get(choice, [640, 480])
    
    framerate = input("Enter framerate (10-30) [30]: ").strip() or "30"
    
    config = {
        "resolution": resolution,
        "framerate": int(framerate),
        "bitrate": "1000000",
        "pixel_format": "yuv420p",
        "enable_audio": False
    }
    
    config_path = os.path.expanduser("~/stemsight/config/camera_config.json")
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"\n✅ Camera configuration saved to {config_path}")
    print(f"📹 Resolution: {resolution[0]}x{resolution[1]} @ {framerate}fps")

if __name__ == "__main__":
    print("🎥 STEMSight Configuration Wizard")
    print("=" * 50)
    
    configure_network()
    configure_camera()
    
    print("\n" + "=" * 50)
    print("✅ Configuration complete!")
    print("\nNext steps:")
    print("  1. Test broadcaster: ~/stemsight/venv/bin/python3 ~/stemsight/rpi_broadcaster.py --config")
    print("  2. Enable auto-start: sudo systemctl enable stemsight-broadcaster")
    print("  3. Start service: sudo systemctl start stemsight-broadcaster")
    print("  4. View logs: sudo journalctl -u stemsight-broadcaster -f")
EOFPY

chmod +x "$PROJECT_DIR/configure.py"
chown $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR/configure.py"
echo "✅ Configuration wizard created"
echo ""

# Step 10: Create helper scripts
echo "🔟 Creating helper scripts..."

# Start script
cat > "$PROJECT_DIR/start.sh" << EOF
#!/bin/bash
echo "🎥 Starting STEMSight broadcaster..."
$PROJECT_DIR/venv/bin/python3 $PROJECT_DIR/rpi_broadcaster.py --config
EOF
chmod +x "$PROJECT_DIR/start.sh"

# Status script
cat > "$PROJECT_DIR/status.sh" << 'EOF'
#!/bin/bash
echo "📊 STEMSight Broadcaster Status"
echo "================================"
systemctl status stemsight-broadcaster --no-pager
echo ""
echo "📹 Recent logs (last 20 lines):"
echo "================================"
sudo journalctl -u stemsight-broadcaster -n 20 --no-pager
EOF
chmod +x "$PROJECT_DIR/status.sh"

chown -R $ACTUAL_USER:$ACTUAL_USER "$PROJECT_DIR"/*.sh
echo "✅ Helper scripts created"
echo ""

# Summary
echo "============================================================"
echo "✅ One-Time Setup Complete!"
echo "============================================================"
echo ""
echo "📁 Installation Directory: $PROJECT_DIR"
echo ""
echo "🎯 Next Steps - Choose Your Setup Mode:"
echo ""
echo "📹 SINGLE CAMERA MODE:"
echo "   Configure one camera for this Raspberry Pi"
echo "   1️⃣  Configure: cd $PROJECT_DIR && ./configure.py"
echo "   2️⃣  Test: ./start.sh"
echo "   3️⃣  Enable auto-start: sudo systemctl enable stemsight-broadcaster"
echo "   4️⃣  Start service: sudo systemctl start stemsight-broadcaster"
echo ""
echo "🎥 MULTI-CAMERA MODE:"
echo "   Configure multiple cameras for this Raspberry Pi"
echo "   1️⃣  Configure: cd $PROJECT_DIR && python3 setup_multi_camera.py"
echo "   2️⃣  Test: ./venv/bin/python3 rpi_multi_broadcaster.py --config config/multi_camera_config.json"
echo "   3️⃣  Install service: sudo cp stemsight-multi-broadcaster.service /etc/systemd/system/"
echo "   4️⃣  Enable auto-start: sudo systemctl enable stemsight-multi-broadcaster"
echo "   5️⃣  Start service: sudo systemctl start stemsight-multi-broadcaster"
echo ""
echo "📊 Monitor Status (either mode):"
echo "   Check status: ./status.sh"
echo "   View logs: sudo journalctl -u stemsight-broadcaster -f"
echo "            OR sudo journalctl -u stemsight-multi-broadcaster -f"
echo ""
echo "📚 Quick Commands:"
echo "   Start:   sudo systemctl start stemsight-[broadcaster|multi-broadcaster]"
echo "   Stop:    sudo systemctl stop stemsight-[broadcaster|multi-broadcaster]"
echo "   Restart: sudo systemctl restart stemsight-[broadcaster|multi-broadcaster]"
echo "   Status:  ./status.sh"
echo ""

if [ "$REBOOT_NEEDED" = true ]; then
    echo "⚠️  IMPORTANT: Reboot required to enable camera!"
    echo "   Run: sudo reboot"
    echo ""
fi

echo "============================================================"
echo "🎉 Setup Complete! Ready for configuration."
echo "============================================================"
