#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Setup Configuration
Interactive setup tool for configuring ambulance and room settings
"""

import json
import os
import sys
from config_manager import ConfigManager

def print_banner():
    """Print setup banner"""
    print("=" * 60)
    print("🚑 STEMSight Raspberry Pi Configuration Setup")
    print("=" * 60)
    print("This tool will help you configure your Raspberry Pi for")
    print("automatic ambulance streaming.")
    print()

def get_user_input():
    """Get ONE-TIME configuration from user (ambulance and camera only)"""
    config = {}
    
    print("� ONE-TIME SETUP - Ambulance & Camera Configuration")
    print("=" * 55)
    print("Enter these details ONCE - they will be saved permanently")
    print()
    
    # Ambulance number (required)
    while True:
        ambulance_num = input("🚑 Enter Ambulance Number (1-999): ").strip()
        if ambulance_num.isdigit() and 1 <= int(ambulance_num) <= 999:
            config["ambulance_number"] = ambulance_num.zfill(3)
            break
        print("❌ Please enter a valid ambulance number (1-999)")
    
    # Camera number (required)
    while True:
        camera_num = input("📹 Enter Camera Number for this device (1-10): ").strip()
        if camera_num.isdigit() and 1 <= int(camera_num) <= 10:
            config["room_number"] = camera_num.zfill(3)
            break
        print("❌ Please enter a valid camera number (1-10)")
    
    # Auto-generate device details based on ambulance and camera
    config["device_id"] = f"rpi-amb{config['ambulance_number']}-cam{config['room_number']}"
    config["device_name"] = f"RPi Ambulance {config['ambulance_number']} Camera {config['room_number']}"
    
    # Network configuration (optional - use defaults)
    print(f"\n🌐 Optional Settings (press Enter to use defaults):")
    print("-" * 50)
    
    server_url = input("Server URL [http://localhost:8000]: ").strip()
    config["server_url"] = server_url or "http://localhost:8000"
    
    # Auto-start is always enabled for autonomous operation
    config["auto_start"] = True
    print("✅ Auto-start on boot: ENABLED (automatic)")
    
    # Use optimized defaults for Raspberry Pi autonomous operation
    config["reconnect_interval"] = 5
    config["retry_attempts"] = 3  
    config["heartbeat_interval"] = 30
    
    # Add remaining default settings
    config.update({
        "upload_interval": 30,
        "timeout": 10,
        "ssl_verify": False,
        "compression": True,
        "log_level": "INFO",
        "max_video_length": 300,
        "auto_upload": True,
        "storage_path": "/home/pi/stemsight/data",
        "status_report_interval": 60,
    })
    
    return config

def get_camera_config():
    """Get camera configuration"""
    print("\n📹 Camera Configuration:")
    print("-" * 30)
    
    # Resolution options
    print("Select video resolution:")
    print("1. 640x480 (Low - Recommended for slow networks)")
    print("2. 1280x720 (Medium)")
    print("3. 1920x1080 (High - Requires good network)")
    
    while True:
        choice = input("Enter choice [1]: ").strip()
        if choice in ['1', ''] :
            resolution = [640, 480]
            break
        elif choice == '2':
            resolution = [1280, 720]
            break
        elif choice == '3':
            resolution = [1920, 1080]
            break
        else:
            print("❌ Please enter 1, 2, or 3")
    
    # Framerate
    framerate = input("Enter framerate (10-30) [30]: ").strip()
    try:
        framerate = int(framerate) if framerate else 30
        framerate = max(10, min(30, framerate))
    except ValueError:
        framerate = 30
    
    # Bitrate based on resolution
    if resolution == [640, 480]:
        default_bitrate = "500000"  # 500 kbps
    elif resolution == [1280, 720]:
        default_bitrate = "1000000"  # 1 Mbps
    else:
        default_bitrate = "2000000"  # 2 Mbps
    
    bitrate = input(f"Enter bitrate in bps [{default_bitrate}]: ").strip()
    bitrate = bitrate or default_bitrate
    
    camera_config = {
        "resolution": resolution,
        "framerate": framerate,
        "exposure_mode": "auto",
        "white_balance": "auto",
        "rotation": 0,
        "preview_enabled": False,
        "capture_timeout": 5000,
        "image_quality": 85,
        "video_stabilization": True,
        "sensor_mode": 0,
        "awb_mode": "auto",
        "meter_mode": "average",
        "video_format": "h264",
        "streaming_quality": "medium",
        "buffer_size": "2M",
        "bitrate": bitrate,
    }
    
    return camera_config

def save_configurations(network_config, camera_config):
    """Save configurations to files"""
    try:
        # Ensure config directory exists
        config_dir = "config"
        os.makedirs(config_dir, exist_ok=True)
        
        # Save network config
        network_config_path = os.path.join(config_dir, "network_config.json")
        with open(network_config_path, "w", encoding="utf-8") as f:
            json.dump(network_config, f, indent=2)
        print(f"✅ Network configuration saved to {network_config_path}")
        
        # Save camera config
        camera_config_path = os.path.join(config_dir, "camera_config.json")
        with open(camera_config_path, "w", encoding="utf-8") as f:
            json.dump(camera_config, f, indent=2)
        print(f"✅ Camera configuration saved to {camera_config_path}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error saving configurations: {e}")
        return False

def display_summary(network_config, camera_config):
    """Display configuration summary"""
    print("\n📋 SAVED CONFIGURATION:")
    print("=" * 50)
    print(f"🚑 Ambulance Number: {network_config['ambulance_number']}")
    print(f"📹 Camera Number: {network_config['room_number']}")
    print(f"🏷️  Device ID: {network_config['device_id']}")
    print(f"📡 Will connect to: AMB-{network_config['ambulance_number']}-ROOM-{network_config['room_number']}")
    print(f"🌐 Server URL: {network_config['server_url']}")
    print(f"🎥 Camera: {camera_config['resolution'][0]}x{camera_config['resolution'][1]} @ {camera_config['framerate']}fps")
    print(f"🚀 Auto-start on boot: YES")
    print()
    print("💾 This configuration will be saved permanently.")
    print("🔄 The device will automatically connect using these settings on every boot.")

def setup_systemd_service(network_config):
    """Setup systemd service for auto-start"""
    if not network_config.get('auto_start'):
        return
    
    print("\n🔧 Setting up systemd service...")
    
    service_content = f"""[Unit]
Description=STEMSight Raspberry Pi Auto Broadcaster
After=network.target
Wants=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/stemsight/PIM/Raspberry-Pi
ExecStart=/usr/bin/python3 /home/pi/stemsight/PIM/Raspberry-Pi/rpi_broadcaster.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
"""
    
    service_path = "/tmp/stemsight-broadcaster.service"
    try:
        with open(service_path, "w") as f:
            f.write(service_content)
        
        print(f"✅ Service file created at {service_path}")
        print("\n📝 To install the service, run these commands as root:")
        print(f"sudo cp {service_path} /etc/systemd/system/")
        print("sudo systemctl daemon-reload")
        print("sudo systemctl enable stemsight-broadcaster.service")
        print("sudo systemctl start stemsight-broadcaster.service")
        print("\n📊 To check service status:")
        print("sudo systemctl status stemsight-broadcaster.service")
        
    except Exception as e:
        print(f"❌ Error creating service file: {e}")

def test_configuration():
    """Test if configuration is valid"""
    try:
        config_manager = ConfigManager()
        
        # Load configs
        camera_config = config_manager.load_camera_config()
        network_config = config_manager.load_network_config()
        
        if config_manager.validate_config():
            print("✅ Configuration test passed!")
            return True
        else:
            print("❌ Configuration validation failed!")
            return False
            
    except Exception as e:
        print(f"❌ Configuration test error: {e}")
        return False

def main():
    """Main setup function"""
    print_banner()
    
    # Check if already configured
    config_manager = ConfigManager()
    if (os.path.exists("config/network_config.json") and 
        os.path.exists("config/camera_config.json")):
        
        overwrite = input("⚠️ Configuration already exists. Overwrite? [y/N]: ").strip().lower()
        if overwrite not in ['y', 'yes']:
            print("Setup cancelled.")
            return
    
    try:
        # Get configurations
        network_config = get_user_input()
        camera_config = get_camera_config()
        
        # Display summary
        display_summary(network_config, camera_config)
        
        # Confirm
        confirm = input("💾 Save this configuration? [Y/n]: ").strip().lower()
        if confirm in ['n', 'no']:
            print("Setup cancelled.")
            return
        
        # Save configurations
        if save_configurations(network_config, camera_config):
            print("✅ Configuration saved successfully!")
            
            # Test configuration
            print("\n🧪 Testing configuration...")
            test_configuration()
            
            # Setup systemd service
            setup_systemd_service(network_config)
            
            print("\n🎉 Setup completed successfully!")
            print("\n🚀 To start broadcasting:")
            print("python3 rpi_broadcaster.py")
            print("\n📚 Or check the README for more options.")
            
        else:
            print("❌ Failed to save configuration.")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n\n🛑 Setup cancelled by user.")
    except Exception as e:
        print(f"\n❌ Setup error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()