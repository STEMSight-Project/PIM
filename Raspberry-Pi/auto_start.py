#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Auto Startup
Checks configuration and starts broadcaster or prompts for setup
"""

import json
import os
import sys
import subprocess


def check_configuration():
    """Check if device is properly configured"""
    config_files = ["config/network_config.json", "config/camera_config.json"]

    for config_file in config_files:
        if not os.path.exists(config_file):
            return False

        try:
            with open(config_file, "r") as f:
                config = json.load(f)

            if config_file.endswith("network_config.json"):
                if not config.get("ambulance_number") or not config.get("room_number"):
                    return False

        except (json.JSONDecodeError, IOError):
            return False

    return True


def main():
    """Main startup function"""

    # Change to script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    if check_configuration():
        # Configuration exists, start broadcaster
        print("🚑 STEMSight RPi - Starting Auto Broadcaster...")
        try:
            # Import and run the broadcaster
            from rpi_broadcaster import main as broadcaster_main
            import asyncio

            asyncio.run(broadcaster_main())
        except KeyboardInterrupt:
            print("\n🛑 Broadcaster stopped by user")
        except Exception as e:
            print(f"❌ Broadcaster error: {e}")
            sys.exit(1)
    else:
        # No configuration, prompt for first-time setup
        print("🚑 STEMSight Raspberry Pi - Configuration Required")
        print("=" * 50)
        print()
        print("⚠️  No configuration found!")
        print()
        print("This device needs to be configured with:")
        print("  🚑 Ambulance Number")
        print("  📹 Camera Number")
        print()
        print("To configure now, run:")
        print("  python3 first_setup.py")
        print()
        print("Or if running as a service, configure first:")
        print("  sudo systemctl stop stemsight-broadcaster")
        print("  cd /home/pi/stemsight/PIM/Raspberry-Pi")
        print("  python3 first_setup.py")
        print("  sudo systemctl start stemsight-broadcaster")
        print()
        sys.exit(1)


if __name__ == "__main__":
    main()
