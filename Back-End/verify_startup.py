"""
Backend Startup Verification Script
Checks that all critical services are properly configured before starting
"""

import sys
from pathlib import Path


def check_imports():
    """Verify all critical imports work"""
    print("🔍 Checking imports...")

    try:
        import asyncio

        print("  ✅ asyncio")
    except ImportError as e:
        print(f"  ❌ asyncio: {e}")
        return False

    try:
        from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
        from aiortc.contrib.media import MediaRelay, MediaRecorder
        from aiortc.mediastreams import MediaStreamError

        print("  ✅ aiortc (WebRTC)")
    except ImportError as e:
        print(f"  ❌ aiortc: {e}")
        print("  💡 Install: pip install aiortc")
        return False

    try:
        from fastapi import FastAPI, WebSocket

        print("  ✅ FastAPI")
    except ImportError as e:
        print(f"  ❌ FastAPI: {e}")
        print("  💡 Install: pip install fastapi")
        return False

    try:
        from supabase import create_client

        print("  ✅ Supabase")
    except ImportError as e:
        print(f"  ❌ Supabase: {e}")
        print("  💡 Install: pip install supabase")
        return False

    try:
        import cv2

        print("  ✅ OpenCV (for camera testing)")
    except ImportError as e:
        print(f"  ⚠️  OpenCV: {e} (optional for testing)")

    return True


def check_directories():
    """Verify required directories exist"""
    print("\n📁 Checking directories...")

    required_dirs = [
        "recordings",
        "services/streaming",
        "services/realtime",
        "api_router",
        "core",
    ]

    all_exist = True
    for dir_path in required_dirs:
        path = Path(dir_path)
        if path.exists():
            print(f"  ✅ {dir_path}/")
        else:
            print(f"  ❌ {dir_path}/ (missing)")
            all_exist = False

    return all_exist


def check_services():
    """Verify service files exist and are importable"""
    print("\n🔧 Checking services...")

    try:
        from services.streaming.webrtc_service import webrtc_service

        print("  ✅ WebRTC Service")
    except Exception as e:
        print(f"  ❌ WebRTC Service: {e}")
        return False

    try:
        from services.streaming.recording_service import recording_manager

        print("  ✅ Recording Service")
    except Exception as e:
        print(f"  ❌ Recording Service: {e}")
        return False

    try:
        from services.streaming.room_service import room_manager

        print("  ✅ Room Service")
    except Exception as e:
        print(f"  ❌ Room Service: {e}")
        return False

    try:
        from services.realtime.realtime_service import realtime_service

        print("  ✅ Realtime Service")
    except Exception as e:
        print(f"  ❌ Realtime Service: {e}")
        return False

    return True


def check_config():
    """Verify configuration"""
    print("\n⚙️  Checking configuration...")

    try:
        from core.common import logger, supabase

        print("  ✅ Core configuration loaded")
    except Exception as e:
        print(f"  ❌ Core configuration: {e}")
        return False

    # Check recordings directory
    recordings_path = Path("recordings")
    if not recordings_path.exists():
        print("  ⚠️  Creating recordings directory...")
        recordings_path.mkdir(parents=True, exist_ok=True)
        print("  ✅ Recordings directory created")
    else:
        print("  ✅ Recordings directory exists")

    return True


def main():
    """Run all verification checks"""
    print("=" * 60)
    print("🚀 STEMSight Backend Verification")
    print("=" * 60)

    checks = [
        ("Imports", check_imports),
        ("Directories", check_directories),
        ("Services", check_services),
        ("Configuration", check_config),
    ]

    all_passed = True
    for name, check_func in checks:
        try:
            if not check_func():
                all_passed = False
        except Exception as e:
            print(f"\n❌ {name} check failed with exception: {e}")
            all_passed = False

    print("\n" + "=" * 60)
    if all_passed:
        print("✅ All checks passed! Backend is ready to start.")
        print("\nStart backend with:")
        print("  python -m uvicorn main:app --reload --log-level debug")
    else:
        print("❌ Some checks failed. Fix issues before starting.")
        return 1
    print("=" * 60)

    return 0


if __name__ == "__main__":
    sys.exit(main())
