#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Configuration Test
Test configuration and connectivity before starting the broadcaster
"""

import asyncio
import json
import os
import sys
import aiohttp
from config_manager import ConfigManager


async def test_network_connectivity(server_url):
    """Test basic network connectivity to the server"""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{server_url}/docs", timeout=10) as resp:
                if resp.status == 200:
                    print("✅ Server connectivity: SUCCESS")
                    return True
                else:
                    print(f"⚠️  Server responded with status: {resp.status}")
                    return False
    except Exception as e:
        print(f"❌ Server connectivity: FAILED - {e}")
        return False


async def test_ambulance_lookup(server_url, ambulance_number):
    """Test if ambulance exists in database"""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{server_url}/ambulances/") as resp:
                if resp.status == 200:
                    result = await resp.json()
                    ambulances = result.get("data", [])

                    for ambulance in ambulances:
                        if (
                            ambulance.get("ambulance_number")
                            == f"AMB-{ambulance_number.zfill(3)}"
                        ):
                            print(
                                f"✅ Ambulance lookup: SUCCESS - Found AMB-{ambulance_number}"
                            )
                            return True

                    print(
                        f"❌ Ambulance lookup: FAILED - AMB-{ambulance_number} not found"
                    )
                    return False
                else:
                    print(f"❌ Ambulance lookup: FAILED - Server error {resp.status}")
                    return False
    except Exception as e:
        print(f"❌ Ambulance lookup: FAILED - {e}")
        return False


def test_camera_access():
    """Test camera device access"""
    camera_devices = ["/dev/video0", "/dev/video1", "/dev/video2"]

    for device in camera_devices:
        if os.path.exists(device):
            try:
                # Try to access the device
                with open(device, "r") as f:
                    pass
                print(f"✅ Camera access: SUCCESS - Found {device}")
                return True
            except PermissionError:
                print(f"⚠️  Camera access: Permission denied for {device}")
                print("   Run: sudo usermod -a -G video pi && sudo reboot")
                return False
            except Exception:
                continue

    print("❌ Camera access: FAILED - No camera devices found")
    print("   Check: ls /dev/video*")
    print("   Enable camera: sudo raspi-config -> Interface Options -> Camera")
    return False


def test_configuration_files():
    """Test if configuration files exist and are valid"""
    config_files = ["config/network_config.json", "config/camera_config.json"]

    all_good = True

    for config_file in config_files:
        if not os.path.exists(config_file):
            print(f"❌ Configuration: {config_file} not found")
            all_good = False
            continue

        try:
            with open(config_file, "r") as f:
                json.load(f)
            print(f"✅ Configuration: {config_file} is valid")
        except json.JSONDecodeError as e:
            print(f"❌ Configuration: {config_file} has invalid JSON - {e}")
            all_good = False
        except Exception as e:
            print(f"❌ Configuration: Error reading {config_file} - {e}")
            all_good = False

    return all_good


async def main():
    """Main test function"""
    print("🧪 STEMSight Raspberry Pi Configuration Test")
    print("=" * 50)

    # Test configuration files
    print("\n📁 Testing configuration files...")
    config_ok = test_configuration_files()

    if not config_ok:
        print("\n❌ Configuration test failed!")
        print("Run: python3 setup_config.py")
        return False

    # Load configuration
    try:
        config_manager = ConfigManager()
        camera_config = config_manager.load_camera_config()
        network_config = config_manager.load_network_config()

        if not config_manager.validate_config():
            print("❌ Configuration validation failed!")
            return False

        print("✅ Configuration validation: SUCCESS")

    except Exception as e:
        print(f"❌ Configuration loading failed: {e}")
        return False

    # Test camera access
    print("\n📹 Testing camera access...")
    camera_ok = test_camera_access()

    # Test network connectivity
    print("\n🌐 Testing network connectivity...")
    server_url = network_config.get("server_url")
    network_ok = await test_network_connectivity(server_url)

    # Test ambulance lookup
    print("\n🚑 Testing ambulance lookup...")
    ambulance_number = network_config.get("ambulance_number")
    ambulance_ok = await test_ambulance_lookup(server_url, ambulance_number)

    # Summary
    print("\n📊 Test Summary:")
    print("=" * 20)

    tests = [
        ("Configuration", config_ok),
        ("Camera Access", camera_ok),
        ("Network Connectivity", network_ok),
        ("Ambulance Lookup", ambulance_ok),
    ]

    all_passed = True
    for test_name, passed in tests:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{test_name:20} : {status}")
        if not passed:
            all_passed = False

    print()
    if all_passed:
        print("🎉 All tests passed! Ready to start broadcasting.")
        print("\nNext steps:")
        print("1. Test manually: python3 rpi_broadcaster.py")
        print(
            "2. Enable auto-start: sudo systemctl enable stemsight-broadcaster.service"
        )
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        print("\nCommon fixes:")
        print("1. Configuration: python3 setup_config.py")
        print("2. Camera: sudo raspi-config -> Interface Options -> Camera")
        print("3. Permissions: sudo usermod -a -G video pi && sudo reboot")
        print("4. Server: Check if backend is running and accessible")

    return all_passed


if __name__ == "__main__":
    try:
        result = asyncio.run(main())
        sys.exit(0 if result else 1)
    except KeyboardInterrupt:
        print("\n🛑 Test cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Test error: {e}")
        sys.exit(1)
