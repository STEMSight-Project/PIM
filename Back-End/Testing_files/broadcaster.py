import argparse
import asyncio
import inspect
import logging
import platform
from typing import Optional

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger("publisher")


def default_device() -> str:
    os_name = platform.system()
    print(f"Detected OS: {os_name}")
    if os_name == "Windows":
        # Try multiple camera options with preference for lower buffer cameras
        return "video=Logitech BRIO"  # Remove audio to reduce buffer load
    elif os_name == "Darwin":  # macOS
        return "0:none"  # First camera, no audio
    else:  # Linux / *BSD
        return "/dev/video0"


def get_media_player(media_src: str) -> MediaPlayer:
    os_name = platform.system()
    format: str = None
    options: dict = None
    if os_name == "Windows":
        format = "dshow"
        options = {
            "input_format": "h264",
            "framerate": "30",
            "video_size": "640x480",
            "ar": "44100",
            "ac": "1",
            "rtbufsize": "2100M",
            "preset": "ultrafast",
            "tune": "zerolatency",
        }
    elif os_name == "Darwin":
        format = "avfoundation"
        options = {
            "video_size": "320x240",  # Low resolution
            "framerate": "10",  # Low framerate
            "pixel_format": "yuyv422",
        }
    return MediaPlayer(media_src, format=format, options=options)


def safe_close_player(player: MediaPlayer):
    if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
        return player.stop()
    else:
        for track in (player.audio, player.video):
            if track:
                track.stop()
        return None


def get_media_src(video_dev: Optional[str], audio_dev: Optional[str]) -> str:
    os_name = platform.system()
    if os_name == "Windows":
        if video_dev and audio_dev:
            return f"video={video_dev}:audio={audio_dev}"
        elif video_dev:
            return f"video={video_dev}"
        else:
            return f"video=default"
    if os_name == "Darwin":
        if video_dev and audio_dev:
            return f"{video_dev}:{audio_dev}"
        elif video_dev:
            return f"{video_dev}:none"
        else:
            return "0:none"
    else:
        return "/dev/video0"


def get_user_input() -> tuple[str, str]:
    """Prompt user for ambulance number and room number."""
    print("🚑 Ambulance WebRTC Broadcaster Setup")
    print("=" * 50)

    while True:
        ambulance_num = input("Enter Ambulance Number (e.g., 001, 002): ").strip()
        if ambulance_num.isdigit() and len(ambulance_num) <= 3:
            break
        print("❌ Please enter a valid number (up to 3 digits)")

    while True:
        room_num = input("Enter Room Number (e.g., 001, 002): ").strip()
        if room_num.isdigit() and len(room_num) <= 3:
            break
        print("❌ Please enter a valid number (up to 3 digits)")

    return ambulance_num.zfill(3), room_num.zfill(3)


async def get_ambulance_by_number(
    base_url: str, ambulance_number: str
) -> Optional[dict]:
    """Get ambulance details by searching for ambulance number."""
    try:
        async with aiohttp.ClientSession() as session:
            # Get all ambulances from the backend
            ambulances_url = f"{base_url}/ambulances/"
            LOGGER.info("Fetching ambulances from: %s", ambulances_url)

            async with session.get(ambulances_url) as resp:
                if resp.status == 200:
                    result = await resp.json()
                    ambulances = result.get("data", [])
                    LOGGER.info("Found %d ambulances in database", len(ambulances))

                    # Search for ambulance by ambulance_number
                    for ambulance in ambulances:
                        if ambulance.get("ambulance_number") == ambulance_number:
                            LOGGER.info(
                                "✅ Found ambulance: %s (ID: %s)",
                                ambulance.get("ambulance_number"),
                                ambulance.get("id"),
                            )
                            return ambulance

                    LOGGER.warning(
                        "❌ Ambulance %s not found in database", ambulance_number
                    )
                    return None
                else:
                    error_text = await resp.text()
                    LOGGER.error(
                        "Failed to fetch ambulances (%d): %s", resp.status, error_text
                    )
                    return None

    except Exception as e:
        LOGGER.error("Error fetching ambulances: %s", e)
        return None


async def check_room_status(base_url: str, room_id: str) -> None:
    """Check the status of rooms for debugging"""
    async with aiohttp.ClientSession() as session:
        try:
            status_url = f"{base_url}/ambulance-streaming/ambulances/status"
            async with session.get(status_url) as resp:
                if resp.status == 200:
                    status_json = await resp.json()
                    print(f"📊 Ambulance Status for {room_id}:")
                    ambulances = status_json if isinstance(status_json, list) else []
                    found_ambulance = None
                    for amb in ambulances:
                        if (
                            amb.get("ambulance_id") == room_id
                            or amb.get("ambulance_number") == room_id
                        ):
                            found_ambulance = amb
                            break

                    if found_ambulance:
                        print(f"   ✅ Ambulance found")
                        print(
                            f"   � Status: {found_ambulance.get('status', 'unknown')}"
                        )
                        print(
                            f"   📹 Total Camera Rooms: {found_ambulance.get('total_camera_rooms', 0)}"
                        )
                        print(
                            f"   � Connected Cameras: {found_ambulance.get('connected_camera_rooms', 0)}"
                        )
                        print(
                            f"   🆔 Session ID: {found_ambulance.get('session_id', 'Unknown')}"
                        )
                        if found_ambulance.get("camera_rooms"):
                            print(f"   📷 Camera Rooms:")
                            for room in found_ambulance["camera_rooms"]:
                                print(
                                    f"      - {room.get('camera_name', 'Unknown')}: {room.get('room_id', 'No ID')}"
                                )
                    else:
                        print(f"   ❌ Ambulance {room_id} not found")
                else:
                    print(f"❌ Failed to get room status: {resp.status}")
        except Exception as e:
            print(f"❌ Error checking room status: {e}")


async def publish(
    ambulance_number: str,
    room_number: str,
    base_url: str,
    video_device: Optional[str],
    audio_device: Optional[str],
    device_name: Optional[str] = None,
) -> None:
    print(f"aiortc version: {aiortc.__version__}")

    # Generate ambulance and room names
    ambulance_name = f"AMB-{ambulance_number}"  # e.g., AMB-001
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"  # e.g., AMB-001-ROOM-001

    print(f"🚑 Ambulance: {ambulance_name}")
    print(f"🏠 Room: {room_name}")

    # Step 1: Get ambulance from database by ambulance number
    LOGGER.info("🔍 Looking up ambulance %s in database...", ambulance_name)
    ambulance_data = await get_ambulance_by_number(base_url, ambulance_name)

    if not ambulance_data:
        LOGGER.error(
            "❌ Ambulance %s not found in database. Please check ambulance number.",
            ambulance_name,
        )
        return

    ambulance_id = ambulance_data.get("id")
    LOGGER.info("✅ Using Ambulance ID: %s for %s", ambulance_id, ambulance_name)

    media_src = default_device()
    if video_device or audio_device:
        media_src = get_media_src(video_device, audio_device)

    player = get_media_player(media_src)

    pc = RTCPeerConnection()

    if player.video:
        pc.addTrack(player.video)
        if player.audio:
            pc.addTrack(player.audio)
    else:
        LOGGER.error("No video track found on device %s", media_src)
        safe_close_player(player)
        return

    await pc.setLocalDescription(await pc.createOffer())

    while pc.iceGatheringState != "complete":
        await asyncio.sleep(0.1)

    offer_payload = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

    async with aiohttp.ClientSession() as session:
        # Step 1: Create/connect to ambulance session - try ambulance streaming first, fallback to regular streaming
        session_id = None

        # Try ambulance streaming endpoints first
        try:
            ambulance_payload = {
                "ambulance_id": ambulance_id,
                "session_name": f"Broadcaster Session - {ambulance_name}",
                "session_type": "emergency",
                "priority_level": 3,
            }
            create_ambulance_url = f"{base_url}/ambulance-streaming/ambulance-sessions"

            LOGGER.info(f"Trying ambulance streaming for: {ambulance_name}")
            async with session.post(
                create_ambulance_url, json=ambulance_payload
            ) as resp:
                if resp.status == 200:
                    ambulance_session = await resp.json()
                    LOGGER.info(f"✅ Ambulance session created: {ambulance_session}")
                    session_id = ambulance_session.get("id")
                    LOGGER.info(f"🔑 Extracted session_id: {session_id}")
                    if not session_id:
                        LOGGER.error(
                            f"❌ Session ID is empty! Full response: {ambulance_session}"
                        )
                        raise Exception("Session created but no ID returned")
                elif resp.status == 409:
                    # Ambulance session already exists, get existing session
                    LOGGER.info(f"🔄 Ambulance session exists, reconnecting")
                    get_session_url = (
                        f"{base_url}/ambulance-streaming/ambulance-sessions"
                    )
                    async with session.get(
                        get_session_url,
                        params={
                            "ambulance_id": ambulance_id,
                            "is_active": True,
                            "limit": 1,
                        },
                    ) as get_resp:
                        if get_resp.status == 200:
                            sessions = await get_resp.json()
                            if sessions:
                                ambulance_session = sessions[0]
                                LOGGER.info(
                                    f"✅ Retrieved existing session: {ambulance_session}"
                                )
                                session_id = ambulance_session.get("id")
                            else:
                                raise Exception("No active sessions found")
                else:
                    raise Exception(f"Ambulance endpoint failed: {resp.status}")

        except Exception as e:
            LOGGER.warning(f"Ambulance streaming not available: {e}")
            LOGGER.info("🔄 Falling back to regular streaming endpoints")

            # Fallback to regular streaming session creation
            regular_payload = {
                "patient_id": ambulance_id,  # Use ambulance ID as patient_id
                "device_name": device_name or "Ambulance Broadcaster",
                "session_name": f"Ambulance Session - {ambulance_name}",
            }
            create_session_url = f"{base_url}/streaming/sessions"

            async with session.post(create_session_url, json=regular_payload) as resp:
                if resp.status == 200:
                    session_json = await resp.json()
                    LOGGER.info(f"✅ Regular session created: {session_json}")
                    session_id = session_json.get("id")
                else:
                    error_text = await resp.text()
                    LOGGER.error(
                        f"Failed to create session ({resp.status}): {error_text}"
                    )
                    safe_close_player(player)
                    await pc.close()
                    return

        # Verify session_id was obtained
        LOGGER.info(f"📋 Session ID obtained: {session_id}")

        # Step 2: Create room and connect to streaming
        if session_id is None:
            LOGGER.error(
                "❌ No session ID available - session creation must have failed"
            )
            safe_close_player(player)
            await pc.close()
            return

        LOGGER.info(f"✅ Proceeding with session ID: {session_id}")

        # Try ambulance camera endpoints first, fallback to regular streaming room
        camera_id = None
        streaming_url = None

        try:
            # Step 2a: Get existing cameras for this ambulance (skip creation due to database schema issues)
            LOGGER.info(f"Fetching existing cameras for ambulance {ambulance_id}")
            get_cameras_url = f"{base_url}/ambulances/{ambulance_id}/cameras"
            async with session.get(get_cameras_url) as get_cameras_resp:
                if get_cameras_resp.status == 200:
                    cameras_result = await get_cameras_resp.json()
                    cameras = cameras_result.get("data", [])
                    LOGGER.info(f"Found {len(cameras)} existing cameras")

                    if cameras:
                        # Select camera based on room number (cycle through available cameras)
                        camera_index = (int(room_number) - 1) % len(cameras)
                        selected_camera = cameras[camera_index]
                        camera_id = selected_camera.get("id")
                        camera_name = selected_camera.get("camera_name", "Unknown")
                        LOGGER.info(
                            f"✅ Selected camera {camera_index + 1}: {camera_name} (ID: {camera_id})"
                        )
                    else:
                        raise Exception("No cameras found for this ambulance")
                else:
                    error_text = await get_cameras_resp.text()
                    LOGGER.error(
                        f"Failed to fetch cameras ({get_cameras_resp.status}): {error_text}"
                    )
                    raise Exception(
                        f"Failed to fetch cameras: {get_cameras_resp.status}"
                    )

            if not camera_id:
                raise Exception("Could not select a camera")

            # Step 2b: Check if camera room already exists, create if not
            camera_room_payload = {
                "camera_id": camera_id,
                "room_id": room_name,
                "device_name": device_name or "Ambulance Broadcaster",
            }
            create_camera_room_url = f"{base_url}/ambulance-streaming/camera-rooms"

            # First, try to get existing camera rooms for this session
            existing_room_id = None
            get_rooms_url = f"{base_url}/ambulance-streaming/camera-rooms"
            LOGGER.info(f"🔍 Checking for existing camera room: {room_name}")
            
            async with session.get(
                get_rooms_url,
                params={"session_id": session_id, "limit": 100}
            ) as get_resp:
                if get_resp.status == 200:
                    existing_rooms = await get_resp.json()
                    for room in existing_rooms:
                        if room.get("room_id") == room_name and room.get("camera_id") == camera_id:
                            existing_room_id = room.get("id")
                            LOGGER.info(f"✅ Found existing camera room (ID: {existing_room_id})")
                            LOGGER.info(f"🔄 Rejoining existing room: {room_name}")
                            break

            if existing_room_id:
                # Room exists - rejoin it
                LOGGER.info(f"♻️  Rejoining existing camera room for camera {room_name}")
                streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
            else:
                # Room doesn't exist - create new one
                LOGGER.info(f"🆕 Creating new camera room for camera ID {camera_id}: {room_name}")
                async with session.post(
                    create_camera_room_url,
                    json=camera_room_payload,
                    params={"session_id": session_id},
                ) as resp:
                    if resp.status == 200:
                        camera_room = await resp.json()
                        LOGGER.info(f"✅ Ambulance camera room created: {camera_room}")
                        streaming_url = (
                            f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                        )
                    elif resp.status == 409:
                        # Camera room already exists (race condition)
                        LOGGER.info(
                            f"🔄 Camera room already exists (409), rejoining camera ID: {camera_id}"
                        )
                        streaming_url = (
                            f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                        )
                    else:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"Camera room creation failed ({resp.status}): {error_text}"
                        )

                        # Check if it's a duplicate room_id error
                        if "already exists" in error_text.lower() or "duplicate" in error_text.lower():
                            LOGGER.info(
                                f"🔄 Room {room_name} already exists (duplicate key), rejoining"
                            )
                            streaming_url = f"{base_url}/ambulance-streaming/camera/{camera_id}/streamer"
                        else:
                            raise Exception(
                                f"Camera endpoint failed: {resp.status} - {error_text}"
                            )

        except Exception as e:
            LOGGER.warning(f"Ambulance camera not available: {e}")
            LOGGER.info("🔄 Using regular streaming room")

            # Fallback to regular streaming room
            room_payload = {
                "session_id": session_id,
                "room_id": room_name,
                "device_name": device_name or "Ambulance Device",
            }
            create_room_url = f"{base_url}/streaming/rooms"

            async with session.post(create_room_url, json=room_payload) as resp:
                if resp.status == 200:
                    room_json = await resp.json()
                    room_id_created = (
                        room_json.get("room_name") or room_payload["room_id"]
                    )
                    LOGGER.info(f"✅ Regular room created: {room_id_created}")
                    streaming_url = (
                        f"{base_url}/streaming/room/{room_id_created}/streamer"
                    )
                else:
                    error_text = await resp.text()
                    LOGGER.error(f"Failed to create room ({resp.status}): {error_text}")
                    safe_close_player(player)
                    await pc.close()
                    return

        # Step 3: Connect to streaming endpoint
        if not streaming_url:
            LOGGER.error("No streaming URL available")
            safe_close_player(player)
            await pc.close()
            return

        LOGGER.info(f"📡 Connecting to streaming endpoint: {streaming_url}")
        answer_json = None
        max_retries = 3
        retry_count = 0
        
        while retry_count < max_retries:
            try:
                async with session.post(streaming_url, json=offer_payload) as resp:
                    if resp.status == 404:
                        LOGGER.error("❌ Streaming endpoint not found")
                        safe_close_player(player)
                        await pc.close()
                        return
                    elif resp.status == 409:
                        retry_count += 1
                        LOGGER.warning(f"⚠️  Streamer already connected (attempt {retry_count}/{max_retries})")
                        
                        if retry_count < max_retries:
                            LOGGER.info("🔄 Waiting 2 seconds before retry...")
                            await asyncio.sleep(2)
                            continue
                        else:
                            LOGGER.error("❌ Max retries reached. Room may have active streamer.")
                            LOGGER.info("💡 Try stopping other broadcasters or wait for timeout")
                            safe_close_player(player)
                            await pc.close()
                            return
                    elif resp.status != 200:
                        error_text = await resp.text()
                        LOGGER.error(f"❌ Streaming failed ({resp.status}): {error_text}")
                        safe_close_player(player)
                        await pc.close()
                        return
                    else:
                        answer_json = await resp.json()
                        LOGGER.info("✅ Successfully connected to streaming endpoint")
                        break
                        
            except Exception as e:
                retry_count += 1
                LOGGER.error(f"❌ Connection error (attempt {retry_count}/{max_retries}): {e}")
                if retry_count < max_retries:
                    await asyncio.sleep(2)
                else:
                    safe_close_player(player)
                    await pc.close()
                    return
        
        if not answer_json:
            LOGGER.error("❌ Failed to get answer from streaming endpoint")
            safe_close_player(player)
            await pc.close()
            return

    # Filter answer to only include SDP fields
    sdp_answer = {"sdp": answer_json.get("sdp"), "type": answer_json.get("type")}
    LOGGER.info(f"📡 Received SDP answer: type={sdp_answer['type']}")
    await pc.setRemoteDescription(RTCSessionDescription(**sdp_answer))
    LOGGER.info("🎥 Ambulance streaming started successfully!")
    LOGGER.info(f"🚑 Ambulance: {ambulance_name}")
    LOGGER.info(f"🏠 Room: {room_name}")
    LOGGER.info(f"📡 Session ID: {session_id}")
    LOGGER.info(f"🆔 Camera ID: {camera_id or 'Regular Room'}")
    LOGGER.info("🔄 Reconnection: Automatic if connection exists")
    LOGGER.info("🛑 Press Ctrl+C to stop streaming...")

    try:
        # Monitor connection state
        while True:
            await asyncio.sleep(5)
            if pc.connectionState in ["failed", "closed", "disconnected"]:
                LOGGER.warning(
                    "Connection state: %s. Room will wait for reconnection...",
                    pc.connectionState,
                )
                LOGGER.info(
                    "💡 Session remains active - you can restart broadcaster to reconnect"
                )
                break
    except KeyboardInterrupt:
        LOGGER.info("🛑 Stopping stream...")
        LOGGER.info("💡 Session remains active - restart broadcaster to reconnect")
        LOGGER.info("💡 Use frontend to explicitly end session when done")
    finally:
        # Note: We do NOT end the session here - that's only done via frontend
        safe_close_player(player)
        await pc.close()
        LOGGER.info("🧹 Broadcaster cleanup completed")
        LOGGER.info("📋 Session Status: ACTIVE (can reconnect)")


async def end_session_manually(base_url: str, session_id: str) -> None:
    """Helper function to manually end a session (for testing purposes)."""
    try:
        end_session_url = f"{base_url}/streaming/sessions/{session_id}/end"
        async with aiohttp.ClientSession() as session:
            async with session.post(end_session_url) as resp:
                if resp.status == 200:
                    LOGGER.info("✅ Session %s ended successfully", session_id)
                else:
                    LOGGER.warning("❌ Failed to end session: %s", resp.status)
    except Exception as e:
        LOGGER.error("❌ Error ending session: %s", e)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="WebRTC camera publisher with smart session management"
    )
    parser.add_argument(
        "--signaling",
        default="http://localhost:8000",
        help="Base URL of signalling server (default: http://localhost:8000)",
    )
    parser.add_argument(
        "--video_device",
        required=False,
        help="Check your device available with: "
        '\n\tMacOS: ffmpeg -f avfoundation -list_devices true -i ""'
        "\n\tWindows: ffmpeg -list_devices true -f dshow -i dummy ",
    )
    parser.add_argument(
        "--audio_device",
        required=False,
        help="Check your device available with: "
        '\n\tMacOS: ffmpeg -f avfoundation -list_devices true -i ""'
        "\n\tWindows: ffmpeg -list_devices true -f dshow -i dummy ",
    )
    parser.add_argument(
        "--device_name",
        required=False,
        default="TestDevice-Broadcaster",
        help="Name of the streaming device (default: TestDevice-Broadcaster)",
    )
    parser.add_argument(
        "--end_session",
        required=False,
        help="End a specific session ID (for testing purposes)",
    )
    args = parser.parse_args()

    # Handle end session command
    if args.end_session:
        print(f"🛑 Ending session: {args.end_session}")
        asyncio.run(end_session_manually(args.signaling, args.end_session))
        return

    # Get ambulance and room numbers from user input
    ambulance_number, room_number = get_user_input()

    ambulance_name = f"AMB-{ambulance_number}"
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"

    print(f"\n🎥 Starting Ambulance WebRTC Broadcaster")
    print(f"{'='*60}")
    print(f"🚑 Ambulance: {ambulance_name}")
    print(f"🏠 Room: {room_name}")
    print(f"🌐 Server: {args.signaling}")
    print(f"📹 Video Device: {args.video_device or 'Default'}")
    print(f"🎤 Audio Device: {args.audio_device or 'Default'}")
    print(f"🏷️  Device Name: {args.device_name}")
    print(f"\n� Connection Strategy:")
    print(f"   1️⃣  Check if ambulance exists in database")
    print(f"   2️⃣  Create/reconnect to ambulance session")
    print(f"   3️⃣  Get existing camera or select from available")
    print(f"   4️⃣  Check if camera room exists, create/rejoin")
    print(f"   5️⃣  Connect to streaming endpoint (3 retry attempts)")
    print(f"\n🔄 Auto-reconnect: Room will be reused if it exists")
    print(f"⏱️  Stream Timeout: 30 seconds of inactivity")
    print(f"{'='*60}\n")

    try:
        asyncio.run(
            publish(
                ambulance_number,
                room_number,
                args.signaling.rstrip("/"),
                video_device=args.video_device,
                audio_device=args.audio_device,
                device_name=args.device_name,
            )
        )
    except KeyboardInterrupt:
        print("\n🛑 Broadcaster stopped by user")
    except Exception as exc:
        LOGGER.exception("Fatal error: %s", exc)


if __name__ == "__main__":
    main()
