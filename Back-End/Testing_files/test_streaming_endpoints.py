#!/usr/bin/env python3
"""
Comprehensive test script for ambulance streaming endpoints.
Tests backend and database functionality without frontend dependencies.
"""

import asyncio
import json
import sys
import aiohttp
from typing import Dict, Any, List, Optional

# Add current directory to path
sys.path.append(".")

from services.streaming.database_service import StreamingDatabaseService
from core.common import supabase, logger

BASE_URL = "http://127.0.0.1:8000"
TEST_RESULTS = []

# Testing credentials from copilot instructions
TEST_EMAIL = "nguyenphuctran@csus.edu"
TEST_PASSWORD = "Patrick2911@1"
AUTH_TOKEN = None  # Will be populated after login
CREATED_SESSION_ID = None  # Will store session ID from creation test


def log_test(test_name: str, success: bool, message: str = "", data: Any = None):
    """Log test results"""
    status = "✅ PASS" if success else "❌ FAIL"
    print(f"{status} {test_name}: {message}")
    TEST_RESULTS.append(
        {"test": test_name, "success": success, "message": message, "data": data}
    )


async def test_server_connectivity():
    """Test if the backend server is running"""
    print("\n🌐 Testing Server Connectivity")
    print("=" * 50)

    # Try different endpoints to check server
    test_urls = [f"{BASE_URL}/", f"{BASE_URL}/docs", f"{BASE_URL}/health"]

    for url in test_urls:
        try:
            timeout = aiohttp.ClientTimeout(total=10)
            async with aiohttp.ClientSession(timeout=timeout) as session:
                async with session.get(url) as resp:
                    if resp.status in [200, 404, 422]:  # Server is running
                        log_test(
                            "Server Connectivity",
                            True,
                            f"Backend server is running at {BASE_URL}",
                        )
                        return True
        except Exception as e:
            continue  # Try next URL

    log_test("Server Connectivity", False, f"Cannot connect to server at any endpoint")
    return False


async def authenticate_user():
    """Authenticate user and get JWT token for testing protected endpoints"""
    global AUTH_TOKEN
    print("\n🔐 Authenticating Test User")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:
        try:
            url = f"{BASE_URL}/auth/login"
            payload = {"email": TEST_EMAIL, "password": TEST_PASSWORD}

            async with session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    # The auth response format has access_token at the root level
                    if data.get("access_token"):
                        AUTH_TOKEN = data["access_token"]
                        log_test(
                            "User Authentication",
                            True,
                            f"Successfully authenticated user: {TEST_EMAIL}",
                        )
                        return True
                    else:
                        log_test(
                            "User Authentication",
                            False,
                            f"No access token in response: {data}",
                        )
                        return False
                else:
                    error_data = await resp.text()
                    log_test(
                        "User Authentication",
                        False,
                        f"Status {resp.status}: {error_data}",
                    )
                    return False
        except Exception as e:
            log_test("User Authentication", False, str(e))
            return False


def get_auth_headers():
    """Get authorization headers for authenticated requests"""
    if AUTH_TOKEN:
        return {"Authorization": f"Bearer {AUTH_TOKEN}"}
    else:
        print("No auth token available - requests will be unauthorized")
        return {}


async def test_database_connectivity():
    """Test basic database connectivity"""
    print("\n🔍 Testing Database Connectivity")
    print("=" * 50)

    try:
        # Check ambulances table
        result = supabase.table("ambulances").select("*").limit(5).execute()
        log_test(
            "Ambulances Table Access", True, f"Found {len(result.data)} ambulances"
        )

        ambulances = result.data
        if ambulances:
            for amb in ambulances:
                print(
                    f"  - Ambulance ID: {amb['id']}, Status: {amb.get('status', 'N/A')}"
                )

        # Check cameras table
        result = supabase.table("cameras").select("*").limit(5).execute()
        log_test("Cameras Table Access", True, f"Found {len(result.data)} cameras")

        cameras = result.data
        if cameras:
            for cam in cameras:
                print(f"  - Camera ID: {cam['id']}, Name: {cam.get('name', 'N/A')}")

        # Check streaming sessions table
        result = (
            supabase.table("ambulance_streaming_sessions")
            .select("*")
            .limit(5)
            .execute()
        )
        log_test(
            "Ambulance Sessions Table Access",
            True,
            f"Found {len(result.data)} sessions",
        )

        # Check camera rooms table
        result = supabase.table("camera_streaming_rooms").select("*").limit(5).execute()
        log_test("Camera Rooms Table Access", True, f"Found {len(result.data)} rooms")

        return ambulances, cameras

    except Exception as e:
        log_test("Database Connectivity", False, str(e))
        return [], []


async def test_streaming_database_service():
    """Test StreamingDatabaseService methods directly"""
    print("\n🔧 Testing StreamingDatabaseService")
    print("=" * 50)

    try:
        db_service = StreamingDatabaseService()

        # Test getting ambulance cameras (use first real ambulance ID if available)
        try:
            # Get first ambulance ID from database
            ambulances_result = (
                supabase.table("ambulances").select("id").limit(1).execute()
            )
            if ambulances_result.data:
                test_ambulance_id = ambulances_result.data[0]["id"]
                cameras = await db_service.get_ambulance_cameras(test_ambulance_id)
                log_test(
                    "Get Ambulance Cameras",
                    True,
                    f"Method works, returned {len(cameras)} cameras for ambulance {test_ambulance_id[:8]}",
                )
            else:
                log_test(
                    "Get Ambulance Cameras",
                    True,
                    "No ambulances in database to test with",
                )
        except Exception as e:
            log_test("Get Ambulance Cameras", False, str(e))

        # Test getting ambulances streaming status
        try:
            status = await db_service.get_ambulances_streaming_status()
            log_test(
                "Get Ambulances Streaming Status",
                True,
                f"Returned {len(status)} ambulances",
            )
        except Exception as e:
            log_test("Get Ambulances Streaming Status", False, str(e))

        # Test getting all ambulance sessions
        try:
            sessions = await db_service.get_all_ambulance_sessions()
            log_test(
                "Get All Ambulance Sessions", True, f"Returned {len(sessions)} sessions"
            )
        except Exception as e:
            log_test("Get All Ambulance Sessions", False, str(e))

        # Test cleanup inactive camera rooms
        try:
            cleaned = await db_service.cleanup_inactive_camera_rooms()
            log_test("Cleanup Inactive Camera Rooms", True, f"Cleaned {cleaned} rooms")
        except Exception as e:
            log_test("Cleanup Inactive Camera Rooms", False, str(e))

    except Exception as e:
        log_test("StreamingDatabaseService Init", False, str(e))


async def test_ambulance_endpoints():
    """Test ambulance-related API endpoints"""
    print("\n🚑 Testing Ambulance API Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test get ambulances streaming status (with auth)
        try:
            url = f"{BASE_URL}/ambulance-streaming/ambulances/status"
            headers = get_auth_headers()
            async with session.get(url, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "GET Ambulances Status [AUTH]",
                        True,
                        f"Returned data: {len(data.get('data', []))} ambulances",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "GET Ambulances Status [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("GET Ambulances Status [AUTH]", False, str(e))

        # Test get ambulance cameras (with auth and real ID from database)
        try:
            # Get first ambulance ID from database
            ambulances_result = (
                supabase.table("ambulances").select("id").limit(1).execute()
            )
            if ambulances_result.data:
                real_ambulance_id = ambulances_result.data[0]["id"]
                url = f"{BASE_URL}/ambulance-streaming/ambulances/{real_ambulance_id}/cameras"
            else:
                url = (
                    f"{BASE_URL}/ambulance-streaming/ambulances/test_ambulance/cameras"
                )

            headers = get_auth_headers()
            async with session.get(url, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "GET Ambulance Cameras [AUTH]",
                        True,
                        f"Returned {len(data.get('data', []))} cameras",
                    )
                elif resp.status == 404:
                    log_test(
                        "GET Ambulance Cameras [AUTH]", True, "Ambulance not found"
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "GET Ambulance Cameras [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("GET Ambulance Cameras [AUTH]", False, str(e))


async def test_session_endpoints():
    """Test ambulance session API endpoints"""
    global CREATED_SESSION_ID
    print("\n📋 Testing Ambulance Session Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test get ambulance sessions (with auth)
        try:
            url = f"{BASE_URL}/ambulance-streaming/ambulance-sessions"
            headers = get_auth_headers()
            async with session.get(url, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "GET Ambulance Sessions [AUTH]",
                        True,
                        f"Returned {len(data.get('data', []))} sessions",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "GET Ambulance Sessions [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("GET Ambulance Sessions [AUTH]", False, str(e))

        # Test create ambulance session (with auth and real ambulance ID)
        try:
            # Get first ambulance ID from database
            ambulances_result = (
                supabase.table("ambulances").select("id").limit(1).execute()
            )
            if ambulances_result.data:
                real_ambulance_id = ambulances_result.data[0]["id"]
            else:
                real_ambulance_id = "test_ambulance_123"

            url = f"{BASE_URL}/ambulance-streaming/ambulance-sessions"
            payload = {
                "ambulance_id": real_ambulance_id,
                "session_type": "emergency",
                "priority_level": 3,
            }
            headers = get_auth_headers()
            async with session.post(url, json=payload, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    session_id = data.get("data", {}).get("id", "unknown")
                    CREATED_SESSION_ID = session_id  # Store for later tests
                    log_test(
                        "POST Create Ambulance Session [AUTH]",
                        True,
                        f"Created session: {session_id[:8]}...",
                    )
                elif resp.status == 404:
                    log_test(
                        "POST Create Ambulance Session [AUTH]",
                        True,
                        "Ambulance not found",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "POST Create Ambulance Session [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("POST Create Ambulance Session [AUTH]", False, str(e))


async def test_camera_room_endpoints():
    """Test camera room API endpoints"""
    print("\n📹 Testing Camera Room Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test create camera room (with auth)
        try:
            url = f"{BASE_URL}/ambulance-streaming/camera-rooms"
            # Use the actual session ID that was created earlier
            session_id_to_use = (
                CREATED_SESSION_ID
                if CREATED_SESSION_ID
                else "3e3b222d-e896-4d65-9935-b3949aa137ed"
            )
            params = {"session_id": session_id_to_use}
            payload = {
                "camera_id": "c1f91ff4-3425-4030-ac78-ef955806553d",
                "room_id": "test_room_123",
                "device_name": "Test Camera Device",
            }
            headers = get_auth_headers()
            async with session.post(
                url, json=payload, params=params, headers=headers
            ) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "POST Create Camera Room [AUTH]",
                        True,
                        f"Created room: {data.get('data', {}).get('id', 'unknown')}",
                    )
                elif resp.status == 404:
                    log_test(
                        "POST Create Camera Room [AUTH]",
                        True,
                        "Session/Camera not found (expected for test IDs)",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "POST Create Camera Room [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("POST Create Camera Room [AUTH]", False, str(e))

        # Test get camera room details (with auth)
        try:
            url = f"{BASE_URL}/ambulance-streaming/camera-rooms/test_room_123"
            headers = get_auth_headers()
            async with session.get(url, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "GET Camera Room Details [AUTH]",
                        True,
                        f"Room found: {data.get('data', {}).get('room_id', 'unknown')}",
                    )
                elif resp.status == 404:
                    log_test(
                        "GET Camera Room Details [AUTH]",
                        True,
                        "Room not found (expected for test ID)",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "GET Camera Room Details [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("GET Camera Room Details [AUTH]", False, str(e))


async def test_webrtc_endpoints():
    """Test WebRTC streaming endpoints"""
    print("\n🌐 Testing WebRTC Streaming Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test camera streamer endpoint
        try:
            url = f"{BASE_URL}/ambulance-streaming/camera/c1f91ff4-3425-4030-ac78-ef955806553d/streamer"
            payload = {"sdp": "test_sdp_offer", "type": "offer"}
            async with session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test("POST Camera Streamer", True, f"Status: {resp.status}")
                else:
                    log_test("POST Camera Streamer", False, f"Status: {resp.status}")
        except Exception as e:
            log_test("POST Camera Streamer", False, str(e))

        # Test camera viewer endpoint
        try:
            url = f"{BASE_URL}/ambulance-streaming/camera/c1f91ff4-3425-4030-ac78-ef955806553d/viewer"
            payload = {"sdp": "test_sdp_offer", "type": "offer"}
            async with session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test("POST Camera Viewer", True, f"Status: {resp.status}")
                else:
                    log_test("POST Camera Viewer", False, f"Status: {resp.status}")
        except Exception as e:
            log_test("POST Camera Viewer", False, str(e))


async def test_realtime_endpoints():
    """Test real-time SSE endpoints"""
    print("\n⚡ Testing Real-time SSE Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test ambulance sessions SSE
        try:
            url = f"{BASE_URL}/realtime/ambulance-sessions"
            async with session.get(url) as resp:
                if resp.status == 200:
                    log_test(
                        "GET Realtime Ambulance Sessions", True, "SSE stream accessible"
                    )
                    # Read first few bytes to confirm it's SSE
                    data = await resp.content.read(100)
                    if b"data:" in data:
                        log_test(
                            "SSE Ambulance Sessions Format", True, "Proper SSE format"
                        )
                    else:
                        log_test(
                            "SSE Ambulance Sessions Format",
                            False,
                            "Not proper SSE format",
                        )
                else:
                    log_test(
                        "GET Realtime Ambulance Sessions",
                        False,
                        f"Status: {resp.status}",
                    )
        except Exception as e:
            log_test("GET Realtime Ambulance Sessions", False, str(e))

        # Test camera rooms SSE
        try:
            url = f"{BASE_URL}/realtime/camera-rooms"
            async with session.get(url) as resp:
                if resp.status == 200:
                    log_test("GET Realtime Camera Rooms", True, "SSE stream accessible")
                else:
                    log_test(
                        "GET Realtime Camera Rooms", False, f"Status: {resp.status}"
                    )
        except Exception as e:
            log_test("GET Realtime Camera Rooms", False, str(e))


async def test_maintenance_endpoints():
    """Test maintenance API endpoints"""
    print("\n🔧 Testing Maintenance Endpoints")
    print("=" * 50)

    async with aiohttp.ClientSession() as session:

        # Test cleanup inactive rooms (with auth)
        try:
            url = f"{BASE_URL}/ambulance-streaming/maintenance/cleanup-inactive-rooms"
            params = {"threshold_minutes": 30}
            headers = get_auth_headers()
            async with session.post(url, params=params, headers=headers) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    log_test(
                        "POST Cleanup Inactive Rooms [AUTH]",
                        True,
                        f"Cleaned {data.get('data', {}).get('cleaned_rooms', 0)} rooms",
                    )
                else:
                    error_data = await resp.text()
                    log_test(
                        "POST Cleanup Inactive Rooms [AUTH]",
                        False,
                        f"Status {resp.status}: {error_data[:200]}",
                    )
        except Exception as e:
            log_test("POST Cleanup Inactive Rooms [AUTH]", False, str(e))


def print_test_summary():
    """Print final test summary"""
    print("\n📊 TEST SUMMARY")
    print("=" * 50)

    passed = len([r for r in TEST_RESULTS if r["success"]])
    failed = len([r for r in TEST_RESULTS if not r["success"]])
    total = len(TEST_RESULTS)

    print(f"Total Tests: {total}")
    print(f"✅ Passed: {passed}")
    print(f"❌ Failed: {failed}")
    print(f"Success Rate: {(passed/total*100):.1f}%")

    if failed > 0:
        print(f"\n❌ Failed Tests:")
        for result in TEST_RESULTS:
            if not result["success"]:
                print(f"  - {result['test']}: {result['message']}")


async def main():
    """Run all tests"""
    print("🚀 STEMSight PIM - Ambulance Streaming Backend Tests")
    print("=" * 60)
    print(f"Testing with credentials: {TEST_EMAIL}")

    # Test server connectivity first
    server_running = await test_server_connectivity()
    if not server_running:
        print("❌ Server is not running - most tests will fail")
        return

    # Authenticate user
    auth_success = await authenticate_user()
    if not auth_success:
        print("❌ Authentication failed - some tests may not work properly")

    # Test database connectivity
    ambulances, cameras = await test_database_connectivity()

    # Test streaming database service
    await test_streaming_database_service()

    # Test API endpoints (now with authentication)
    await test_ambulance_endpoints()
    await test_session_endpoints()
    await test_camera_room_endpoints()
    await test_webrtc_endpoints()
    await test_realtime_endpoints()
    await test_maintenance_endpoints()

    # Print summary
    print_test_summary()


if __name__ == "__main__":
    asyncio.run(main())
