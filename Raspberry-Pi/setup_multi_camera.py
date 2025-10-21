#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Multi-Camera Setup
Configuration wizard for multi-camera ambulance setup
"""

import json
import os
import sys


def print_banner():
    """Print setup banner"""
    print("=" * 60)
    print("🚑 STEMSight Multi-Camera Setup")
    print("=" * 60)
    print()
    print("This wizard will help you configure multiple cameras on this")
    print("Raspberry Pi for ambulance streaming.")
    print()


def detect_cameras():
    """Detect available camera devices"""
    devices = []
    for i in range(10):
        device_path = f"/dev/video{i}"
        if os.path.exists(device_path):
            devices.append(device_path)
    return devices


def get_ambulance_number():
    """Get ambulance number"""
    while True:
        print()
        ambulance_input = input("🚑 Enter Ambulance Number (1-999): ").strip()

        if ambulance_input.isdigit():
            ambulance_num = int(ambulance_input)
            if 1 <= ambulance_num <= 999:
                ambulance_str = str(ambulance_num).zfill(3)
                print(f"   ✅ Ambulance: AMB-{ambulance_str}")
                return ambulance_str

        print("   ❌ Please enter a number between 1 and 999")


def get_server_url():
    """Get server URL"""
    print()
    default_url = "http://localhost:8000"
    server_url = input(f"🌐 Server URL [{default_url}]: ").strip()
    if not server_url:
        server_url = default_url

    # Remove trailing slash
    server_url = server_url.rstrip("/")
    print(f"   ✅ Server: {server_url}")
    return server_url


def configure_cameras(available_devices):
    """Configure multiple cameras"""
    cameras_config = []

    print()
    print(f"📹 Found {len(available_devices)} available camera devices:")
    for idx, device in enumerate(available_devices, 1):
        print(f"   {idx}. {device}")
    print()

    # Ask how many cameras to use
    while True:
        num_input = input(
            f"How many cameras to configure (1-{len(available_devices)}): "
        ).strip()
        if num_input.isdigit():
            num_cameras = int(num_input)
            if 1 <= num_cameras <= len(available_devices):
                break
        print(f"   ❌ Please enter a number between 1 and {len(available_devices)}")

    print()
    print(f"✅ Configuring {num_cameras} camera(s)")
    print()

    # Configure each camera
    for i in range(num_cameras):
        print(f"📹 Camera {i+1} Configuration:")
        print("-" * 40)

        # Select device
        if len(available_devices) > 1:
            print(f"   Available devices:")
            for idx, device in enumerate(available_devices, 1):
                print(f"     {idx}. {device}")

            while True:
                device_input = (
                    input(f"   Select device for Camera {i+1} [1]: ").strip() or "1"
                )
                if device_input.isdigit():
                    device_idx = int(device_input) - 1
                    if 0 <= device_idx < len(available_devices):
                        selected_device = available_devices[device_idx]
                        break
                print(
                    f"   ❌ Please select a valid device (1-{len(available_devices)})"
                )
        else:
            selected_device = available_devices[0]

        # Enable/disable camera
        enabled_input = input(f"   Enable Camera {i+1}? (Y/n): ").strip().lower()
        enabled = enabled_input not in ["n", "no"]

        # Camera position (optional)
        position = (
            input(f"   Camera position (front/side/rear) [front]: ").strip() or "front"
        )

        camera_config = {
            "camera_number": i + 1,
            "device": selected_device,
            "position": position,
            "enabled": enabled,
        }

        cameras_config.append(camera_config)
        print(
            f"   ✅ Camera {i+1}: {selected_device} ({position}) - {'Enabled' if enabled else 'Disabled'}"
        )
        print()

    return cameras_config


def create_multi_camera_config(ambulance_number, server_url, cameras_config):
    """Create multi-camera configuration"""
    config = {
        "ambulance_number": ambulance_number,
        "server_url": server_url,
        "cameras": cameras_config,
        "auto_start": True,
        "reconnect_interval": 5,
        "retry_attempts": 3,
    }
    return config


def create_camera_settings_config():
    """Create camera settings configuration"""
    print()
    print("📹 Camera Settings Configuration:")
    print("-" * 40)

    print("Select resolution:")
    print("  1. 640x480 (Default - Low bandwidth)")
    print("  2. 1280x720 (HD - Medium bandwidth)")
    print("  3. 1920x1080 (Full HD - High bandwidth)")

    choice = input("Select resolution [1]: ").strip() or "1"
    resolutions = {"1": [640, 480], "2": [1280, 720], "3": [1920, 1080]}
    resolution = resolutions.get(choice, [640, 480])

    framerate_input = input("Enter framerate (10-30) [30]: ").strip() or "30"
    framerate = int(framerate_input)

    # Lower bitrate for multi-camera to prevent bandwidth issues
    bitrate_input = input("Enter bitrate in bps [500000]: ").strip() or "500000"

    config = {
        "resolution": resolution,
        "framerate": framerate,
        "bitrate": bitrate_input,
        "pixel_format": "yuv420p",
        "enable_audio": False,
    }

    print(f"   ✅ Resolution: {resolution[0]}x{resolution[1]} @ {framerate}fps")
    return config


def save_multi_camera_config(multi_config, camera_settings):
    """Save multi-camera configuration"""
    try:
        # Ensure config directory exists
        os.makedirs("config", exist_ok=True)

        # Save multi-camera config
        config_path = "config/multi_camera_config.json"
        with open(config_path, "w") as f:
            json.dump(multi_config, f, indent=2)

        # Save camera settings
        settings_path = "config/camera_config.json"
        with open(settings_path, "w") as f:
            json.dump(camera_settings, f, indent=2)

        print()
        print("✅ Configuration saved successfully!")
        print(f"   📁 Multi-camera config: {config_path}")
        print(f"   📁 Camera settings: {settings_path}")

        return True

    except Exception as e:
        print(f"❌ Error saving configuration: {e}")
        return False


def create_systemd_service():
    """Create systemd service file for multi-camera"""
    service_content = """[Unit]
Description=STEMSight Multi-Camera Broadcaster
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/stemsight
Environment="PATH=/home/pi/stemsight/venv/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/pi/stemsight/venv/bin/python3 /home/pi/stemsight/rpi_multi_broadcaster.py --config /home/pi/stemsight/config/multi_camera_config.json
Restart=always
RestartSec=10
StandardOutput=append:/home/pi/stemsight/logs/multi-broadcaster.log
StandardError=append:/home/pi/stemsight/logs/multi-broadcaster-error.log

[Install]
WantedBy=multi-user.target
"""

    service_path = "stemsight-multi-broadcaster.service"

    try:
        with open(service_path, "w") as f:
            f.write(service_content)

        print()
        print("✅ Systemd service file created: stemsight-multi-broadcaster.service")
        print()
        print("To install the service:")
        print("  sudo cp stemsight-multi-broadcaster.service /etc/systemd/system/")
        print("  sudo systemctl daemon-reload")
        print("  sudo systemctl enable stemsight-multi-broadcaster")
        print("  sudo systemctl start stemsight-multi-broadcaster")

        return True

    except Exception as e:
        print(f"❌ Error creating service file: {e}")
        return False


def show_summary(config):
    """Show configuration summary"""
    print()
    print("=" * 60)
    print("🎉 MULTI-CAMERA SETUP COMPLETE!")
    print("=" * 60)
    print()
    print("📋 Configuration Summary:")
    print("-" * 40)
    print(f"🚑 Ambulance: AMB-{config['ambulance_number']}")
    print(f"🌐 Server: {config['server_url']}")
    print(f"📹 Cameras: {len(config['cameras'])} configured")
    print()

    for cam in config["cameras"]:
        status = "✅ Enabled" if cam["enabled"] else "⏸️  Disabled"
        print(
            f"   Camera {cam['camera_number']}: {cam['device']} ({cam['position']}) - {status}"
        )

    print()
    print("🚀 Next Steps:")
    print("-" * 40)
    print("1. Test the broadcaster:")
    print(
        "   ./venv/bin/python3 rpi_multi_broadcaster.py --config config/multi_camera_config.json"
    )
    print()
    print("2. Install systemd service (if not already done):")
    print("   sudo cp stemsight-multi-broadcaster.service /etc/systemd/system/")
    print("   sudo systemctl daemon-reload")
    print("   sudo systemctl enable stemsight-multi-broadcaster")
    print()
    print("3. Start the service:")
    print("   sudo systemctl start stemsight-multi-broadcaster")
    print()
    print("4. Check status:")
    print("   sudo systemctl status stemsight-multi-broadcaster")
    print()
    print("5. View logs:")
    print("   sudo journalctl -u stemsight-multi-broadcaster -f")
    print()
    print("=" * 60)


def main():
    """Main setup function"""
    print_banner()

    # Check for existing configuration
    if os.path.exists("config/multi_camera_config.json"):
        print("⚠️  Multi-camera configuration already exists!")
        reconfigure = input("Reconfigure? (y/N): ").strip().lower()
        if reconfigure not in ["y", "yes"]:
            print("Setup cancelled.")
            return
        print()

    try:
        # Detect available cameras
        available_devices = detect_cameras()

        if not available_devices:
            print("❌ No camera devices found!")
            print("   Make sure cameras are connected and detected by the system.")
            print("   Run: ls -l /dev/video*")
            sys.exit(1)

        # Get configuration
        ambulance_number = get_ambulance_number()
        server_url = get_server_url()
        cameras_config = configure_cameras(available_devices)
        camera_settings = create_camera_settings_config()

        # Create full configuration
        multi_config = create_multi_camera_config(
            ambulance_number, server_url, cameras_config
        )

        # Save configuration
        if save_multi_camera_config(multi_config, camera_settings):
            create_systemd_service()
            show_summary(multi_config)
        else:
            print("❌ Setup failed!")
            sys.exit(1)

    except KeyboardInterrupt:
        print("\n\n⚠️  Setup cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Setup error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
