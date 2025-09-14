# STEMSight Raspberry Pi Setup Script
#!/bin/bash

echo "STEMSight Raspberry Pi Setup Starting..."

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Python 3.9+ and pip
echo "Installing Python and pip..."
sudo apt install python3 python3-pip python3-venv -y

# Install system dependencies
echo "Installing system dependencies..."
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libjpeg-dev \
    libtiff5-dev \
    libpng-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libgdk-pixbuf2.0-dev \
    libpango1.0-dev \
    libgtk2.0-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    libhdf5-dev \
    libhdf5-serial-dev \
    libhdf5-103 \
    python3-pyqt5 \
    python3-h5py \
    libjasper-dev \
    libqtgui4 \
    libqt4-test

# Enable camera
echo "Enabling camera interface..."
sudo raspi-config nonint do_camera 0

# Create project directory
echo "Creating project directory..."
mkdir -p /home/pi/stemsight/data
mkdir -p /home/pi/stemsight/logs
mkdir -p /home/pi/stemsight/config

# Create virtual environment
echo "Creating Python virtual environment..."
python3 -m venv /home/pi/stemsight/venv

# Activate virtual environment and install requirements
echo "Installing Python dependencies..."
source /home/pi/stemsight/venv/bin/activate
pip install --upgrade pip

# Copy project files (assuming you've transferred them)
echo "Please transfer your project files to /home/pi/stemsight/"
echo "Then run: pip install -r requirements-rpi.txt"

# Set permissions
echo "Setting permissions..."
chmod +x /home/pi/stemsight/*.py
chown -R pi:pi /home/pi/stemsight/

# Create systemd service (optional)
echo "Creating systemd service..."
sudo tee /etc/systemd/system/stemsight.service > /dev/null <<EOF
[Unit]
Description=STEMSight Posture Detection Service
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/stemsight
Environment=PATH=/home/pi/stemsight/venv/bin
ExecStart=/home/pi/stemsight/venv/bin/python pose_model_capture.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "Setup complete!"
echo "Next steps:"
echo "1. Transfer your Python files to /home/pi/stemsight/"
echo "2. Copy config files to /home/pi/stemsight/config/"
echo "3. Activate virtual environment: source /home/pi/stemsight/venv/bin/activate"
echo "4. Install requirements: pip install -r requirements-rpi.txt"
echo "5. Enable service: sudo systemctl enable stemsight.service"
echo "6. Start service: sudo systemctl start stemsight.service"