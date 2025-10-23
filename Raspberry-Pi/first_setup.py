#!/usr/bin/env python3
"""
STEMSight Raspberry Pi First-Time Setup
Simple one-time configuration for ambulance and camera numbers
"""

import json
import os
from config_manager import ConfigManager


def print_banner():
    """Print setup banner"""
    print("🚑" * 20)
    print("🚑 STEMSight Raspberry Pi - ONE TIME SETUP")
    print("🚑" * 20)
    print()
    print("Welcome! This is a ONE-TIME setup for your Raspberry Pi camera.")
    print("You'll enter your ambulance and camera numbers ONCE, and the")
    print("device will remember them forever.")
    print()
    print("After setup, your device will automatically:")
    print("✅ Connect to the correct ambulance on boot")
    print("✅ Use the assigned camera number")
    print("✅ Start streaming without any user input")
    print("✅ Reconnect automatically if connection drops")
    print()


def get_simple_config():
    """Get ambulance and camera numbers from user"""
    print("📋 Enter Your Device Configuration:")
    print("-" * 40)

    # Get ambulance number
    while True:
        print()
        ambulance_input = input("🚑 Enter Ambulance Number (1-999): ").strip()

        if ambulance_input.isdigit():
            ambulance_num = int(ambulance_input)
            if 1 <= ambulance_num <= 999:
                ambulance_str = str(ambulance_num).zfill(3)
                print(f"   ✅ Ambulance: AMB-{ambulance_str}")
                break

        print("   ❌ Please enter a number between 1 and 999")

    # Get camera number
    while True:
        print()
        camera_input = input("📹 Enter Camera Number for this device (1-10): ").strip()

        if camera_input.isdigit():
            camera_num = int(camera_input)
            if 1 <= camera_num <= 10:
                camera_str = str(camera_num).zfill(3)
                print(f"   ✅ Camera: Camera {camera_num}")
                break

        print("   ❌ Please enter a number between 1 and 10")

    # Optional server URL
    print()
    server_url = input("🌐 Server URL [http://localhost:8000]: ").strip()
    if not server_url:
        server_url = "http://localhost:8000"
    print(f"   ✅ Server: {server_url}")

    return ambulance_str, camera_str, server_url


def create_configs(ambulance_num, camera_num, server_url):
    """Create configuration files"""

    # Network configuration
    network_config = {
        "device_id": f"rpi-amb{ambulance_num}-cam{camera_num}",
        "device_name": f"RPi Ambulance {ambulance_num} Camera {camera_num}",
        "server_url": server_url,
        "ambulance_number": ambulance_num,
        "room_number": camera_num,
        "auto_start": True,
        "reconnect_interval": 5,
        "retry_attempts": 3,
        "timeout": 10,
        "heartbeat_interval": 30,
        "upload_interval": 30,
        "ssl_verify": False,
        "compression": True,
        "log_level": "INFO",
        "max_video_length": 300,
        "auto_upload": True,
        "storage_path": "/home/pi/stemsight/data",
        "status_report_interval": 60,
    }

    # Camera configuration (optimized for Raspberry Pi)
    camera_config = {
        "resolution": [640, 480],
        "framerate": 30,
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
        "bitrate": "1000000",
    }

    return network_config, camera_config


def save_configs(network_config, camera_config):
    """Save configurations to files"""
    try:
        # Ensure config directory exists
        os.makedirs("config", exist_ok=True)

        # Save network config
        with open("config/network_config.json", "w") as f:
            json.dump(network_config, f, indent=2)

        # Save camera config
        with open("config/camera_config.json", "w") as f:
            json.dump(camera_config, f, indent=2)

        return True

    except Exception as e:
        print(f"❌ Error saving configuration: {e}")
        return False


def show_summary(network_config):
    """Show final configuration summary"""
    print()
    print("🎉" * 25)
    print("🎉 SETUP COMPLETE!")
    print("🎉" * 25)
    print()
    print("📋 Your Device Configuration:")
    print("-" * 40)
    print(f"🚑 Ambulance: AMB-{network_config['ambulance_number']}")
    print(f"📹 Camera: Camera {network_config['room_number']}")
    print(f"🏷️  Device ID: {network_config['device_id']}")
    print(f"🌐 Server: {network_config['server_url']}")
    print()
    print("✅ Configuration saved permanently!")
    print("✅ Auto-start on boot enabled!")
    print()
    print("🚀 What happens now:")
    print(f"   • Device will connect to AMB-{network_config['ambulance_number']}")
    print(f"   • Use camera number {network_config['room_number']}")
    print("   • Start streaming automatically on boot")
    print("   • Reconnect if connection drops")
    print("   • No more user input needed!")
    print()


def main():
    """Main setup function"""
    print_banner()

    # Check if already configured
    if os.path.exists("config/network_config.json"):
        print("⚠️  Configuration already exists!")
        print()

        # Show existing config
        try:
            with open("config/network_config.json", "r") as f:
                existing_config = json.load(f)
            print("📋 Current Configuration:")
            print(
                f"   🚑 Ambulance: AMB-{existing_config.get('ambulance_number', 'Unknown')}"
            )
            print(
                f"   📹 Camera: Camera {existing_config.get('room_number', 'Unknown')}"
            )
            print()
        except:
            pass

        reconfigure = input("Do you want to reconfigure? (y/N): ").strip().lower()
        if reconfigure not in ["y", "yes"]:
            print("Setup cancelled. Using existing configuration.")
            return
        print()

    try:
        # Get user input
        ambulance_num, camera_num, server_url = get_simple_config()

        # Create configuration
        network_config, camera_config = create_configs(
            ambulance_num, camera_num, server_url
        )

        # Confirm configuration
        print()
        print("📋 Review Your Configuration:")
        print("-" * 35)
        print(f"🚑 Ambulance: AMB-{ambulance_num}")
        print(f"📹 Camera: Camera {camera_num}")
        print(f"🌐 Server: {server_url}")
        print()

        confirm = input("Save this configuration? (Y/n): ").strip().lower()
        if confirm in ["n", "no"]:
            print("Setup cancelled.")
            return

        # Save configuration
        if save_configs(network_config, camera_config):
            show_summary(network_config)

            print("🔧 Next Steps:")
            print("-" * 15)
            print("1. Test: python3 rpi_broadcaster.py")
            print(
                "2. Enable service: sudo systemctl enable stemsight-broadcaster.service"
            )
            print("3. Reboot: sudo reboot")
            print()
            print("After reboot, streaming will start automatically! 🎥")

        else:
            print("❌ Failed to save configuration.")
            return

    except KeyboardInterrupt:
        print("\n\n🛑 Setup cancelled by user.")
    except Exception as e:
        print(f"\n❌ Setup error: {e}")


if __name__ == "__main__":
    main()
