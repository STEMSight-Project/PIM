#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Auto Startup
Detects configuration type and starts appropriate broadcaster
Supports both single-camera and multi-camera setups
"""

import json
import os
import sys
import subprocess


def check_configuration_type():
    """Check what type of configuration exists"""
    multi_config = "config/multi_camera_config.json"
    single_config = "config/network_config.json"
    
    if os.path.exists(multi_config):
        return "multi", multi_config
    elif os.path.exists(single_config):
        return "single", single_config
    else:
        return None, None


def validate_config(config_path):
    """Validate configuration file"""
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        
        # Validate multi-camera config
        if "cameras" in config:
            if not config.get("ambulance_number"):
                return False
            if not config.get("cameras"):
                return False
            return True
        
        # Validate single-camera config
        else:
            if not config.get("ambulance_number") or not config.get("room_number"):
                return False
            return True
            
    except (json.JSONDecodeError, IOError):
        return False


def main():
    """Main startup function"""
    
    # Change to script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Check configuration
    config_type, config_path = check_configuration_type()
    
    if config_type == "multi":
        print("🎥 STEMSight RPi - Multi-Camera Mode")
        print("=" * 50)
        
        if validate_config(config_path):
            print(f"📋 Using config: {config_path}")
            print("🚀 Starting multi-camera broadcaster...")
            
            try:
                # Import and run multi-camera broadcaster
                from rpi_multi_broadcaster import main as multi_broadcaster_main
                multi_broadcaster_main()
                
            except KeyboardInterrupt:
                print("\n🛑 Multi-camera broadcaster stopped by user")
            except Exception as e:
                print(f"❌ Multi-camera broadcaster error: {e}")
                import traceback
                traceback.print_exc()
                sys.exit(1)
        else:
            print("❌ Invalid multi-camera configuration!")
            print("Run: python3 setup_multi_camera.py")
            sys.exit(1)
    
    elif config_type == "single":
        print("� STEMSight RPi - Single Camera Mode")
        print("=" * 50)
        
        if validate_config(config_path):
            print(f"📋 Using config: {config_path}")
            print("🚀 Starting single-camera broadcaster...")
            
            try:
                # Import and run single-camera broadcaster
                from rpi_broadcaster import main as single_broadcaster_main
                import asyncio
                asyncio.run(single_broadcaster_main())
                
            except KeyboardInterrupt:
                print("\n🛑 Single-camera broadcaster stopped by user")
            except Exception as e:
                print(f"❌ Single-camera broadcaster error: {e}")
                import traceback
                traceback.print_exc()
                sys.exit(1)
        else:
            print("❌ Invalid single-camera configuration!")
            print("Run: python3 first_setup.py")
            sys.exit(1)
    
    else:
        # No configuration found
        print("🚑 STEMSight Raspberry Pi - Configuration Required")
        print("=" * 50)
        print()
        print("⚠️  No configuration found!")
        print()
        print("Choose setup type:")
        print("  � Single Camera: python3 first_setup.py")
        print("  🎥 Multi-Camera:  python3 setup_multi_camera.py")
        print()
        print("Or if running as a service:")
        print("  sudo systemctl stop stemsight-broadcaster")
        print("  cd /home/pi/stemsight")
        print("  python3 first_setup.py  (or setup_multi_camera.py)")
        print("  sudo systemctl start stemsight-broadcaster")
        print()
        sys.exit(1)


if __name__ == "__main__":
    main()
