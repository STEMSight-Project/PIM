#!/bin/bash
# STEMSight Raspberry Pi Auto Broadcaster Setup Script
# This script sets up the Raspberry Pi for automated ambulance streaming

set -e  # Exit on any error

echo "🚑 STEMSight Raspberry Pi Auto Broadcaster Setup"
echo "================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script should not be run as root. Please run as pi user."
   exit 1
fi

# Set up directory structure
STEMSIGHT_DIR="/home/pi/stemsight"
PROJECT_DIR="$STEMSIGHT_DIR/PIM"
RPI_DIR="$PROJECT_DIR/Raspberry-Pi"

log_info "Setting up directory structure..."
mkdir -p "$STEMSIGHT_DIR"/{logs,data,config}
mkdir -p "$PROJECT_DIR"
cd "$STEMSIGHT_DIR"

# Check if project already exists
if [ ! -d "$RPI_DIR" ]; then
    log_info "Cloning STEMSight PIM repository..."
    if command -v git &> /dev/null; then
        git clone https://github.com/STEMSight-Project/PIM.git
    else
        log_warning "Git not found. Please manually copy the project files to $PROJECT_DIR"
        exit 1
    fi
fi

cd "$RPI_DIR"

log_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

log_info "Installing system dependencies..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
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
    libqt5gui5 \
    libqt5webkit5 \
    libqt5test5 \
    python3-pyqt5 \
    ffmpeg \
    v4l-utils

log_info "Enabling camera interface..."
sudo raspi-config nonint do_camera 0

log_info "Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

log_info "Upgrading pip and installing Python dependencies..."
pip install --upgrade pip setuptools wheel

log_info "Installing Python packages from requirements..."
pip install -r requirements-rpi.txt

log_info "Installing PyTorch for Raspberry Pi..."
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

log_success "Dependencies installed successfully!"

# Create default configurations if they don't exist
log_info "Creating default configurations..."
python3 setup_config.py --create-defaults 2>/dev/null || python3 -c "
from config_manager import ConfigManager
cm = ConfigManager()
cm.create_default_configs()
print('Default configurations created')
"

# Set up log rotation
log_info "Setting up log rotation..."
sudo tee /etc/logrotate.d/stemsight > /dev/null <<EOF
/home/pi/stemsight/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    su pi pi
}
EOF

# Set up camera permissions
log_info "Setting up camera permissions..."
sudo usermod -a -G video pi

# Create startup script
log_info "Creating startup script..."
cat > "$STEMSIGHT_DIR/start_broadcaster.sh" << 'EOF'
#!/bin/bash
# STEMSight Auto Broadcaster Startup Script

cd /home/pi/stemsight/PIM/Raspberry-Pi
source venv/bin/activate

echo "🚑 Starting STEMSight Auto Broadcaster..."
python3 rpi_broadcaster.py
EOF

chmod +x "$STEMSIGHT_DIR/start_broadcaster.sh"

# Set up systemd service (optional)
log_info "Setting up systemd service..."
sudo cp stemsight-broadcaster.service /etc/systemd/system/
sudo systemctl daemon-reload

log_success "System setup completed successfully!"
echo ""
echo "🎯 NEXT: Configure Your Device (ONE TIME ONLY)"
echo "==============================================="
echo ""
log_info "Run the first-time setup to configure ambulance and camera:"
echo "   cd $RPI_DIR"
echo "   python3 first_setup.py"
echo ""
echo "📋 After first-time setup:"
echo "========================="
echo "1. Test manually:"
echo "   python3 rpi_broadcaster.py"
echo ""
echo "2. Enable auto-start:"
echo "   sudo systemctl enable stemsight-broadcaster.service"
echo "   sudo systemctl start stemsight-broadcaster.service"
echo ""
echo "3. Reboot (streaming will start automatically):"
echo "   sudo reboot"
echo ""
echo "4. Monitor logs:"
echo "   tail -f /home/pi/stemsight/logs/broadcaster.log"
echo ""
log_warning "Remember: You only need to configure ambulance/camera ONCE!"
log_success "After that, the device will work automatically forever! 🎉"