#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Automated Broadcaster
Automatically connects to ambulance streaming using configuration settings
Based on the main broadcaster.py logic adapted for Raspberry Pi
"""

import argparse
import asyncio
import inspect
import logging
import platform
import signal
import sys
from typing import Optional

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer

from config_manager import ConfigManager

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("/var/log/stemsight/broadcaster.log"),
        logging.StreamHandler(),
    ],
)
LOGGER = logging.getLogger("rpi_broadcaster")


def get_rpi_media_player(config_manager: ConfigManager) -> MediaPlayer:
    """Create media player optimized for Raspberry Pi camera"""
    camera_config = config_manager.load_camera_config()

    # Raspberry Pi camera module device
    device = "/dev/video0"

    # Get settings from config
    resolution = camera_config.get("resolution", [640, 480])
    framerate = camera_config.get("framerate", 30)
    bitrate = camera_config.get("bitrate", "1000000")

    width, height = resolution

    options = {
        "video_size": f"{width}x{height}",
        "framerate": str(framerate),
        "input_format": "v4l2",
        "pixel_format": "yuv420p",
        "buffers": "4",
        "rtbufsize": "100M",
        "preset": "ultrafast",
        "tune": "zerolatency",
        "b:v": bitrate,
    }

    LOGGER.info(f"📹 Camera settings: {width}x{height} @ {framerate}fps")
    return MediaPlayer(device, format="v4l2", options=options)


def safe_close_player(player: MediaPlayer):
    """Safely close media player"""
    if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
        return player.stop()
    else:
        for track in (player.audio, player.video):
            if track:
                track.stop()
        return None


async def get_ambulance_by_number(
    base_url: str, ambulance_number: str
) -> Optional[dict]:
    """Get ambulance details by searching for ambulance number"""
    try:
        async with aiohttp.ClientSession() as session:
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


async def publish(
    ambulance_number: str,
    room_number: str,
    base_url: str,
    config_manager: ConfigManager,
    device_name: Optional[str] = None,
) -> None:
    """Main publishing function - same logic as main broadcaster.py"""

    LOGGER.info(f"aiortc version: {aiortc.__version__}")

    # Generate ambulance and room names
    ambulance_name = f"AMB-{ambulance_number}"
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"

    LOGGER.info(f"🚑 Ambulance: {ambulance_name}")
    LOGGER.info(f"🏠 Room: {room_name}")

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

    # Get media player with RPi camera
    player = get_rpi_media_player(config_manager)

    pc = RTCPeerConnection()

    if player.video:
        pc.addTrack(player.video)
        if player.audio:
            pc.addTrack(player.audio)
    else:
        LOGGER.error("No video track found on Raspberry Pi camera")
        safe_close_player(player)
        return

    await pc.setLocalDescription(await pc.createOffer())

    while pc.iceGatheringState != "complete":
        await asyncio.sleep(0.1)

    offer_payload = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

    async with aiohttp.ClientSession() as session:
        # Step 1: Create/connect to ambulance session
        session_id = None

        try:
            ambulance_payload = {
                "ambulance_id": ambulance_id,
                "session_name": f"RPi Session - {ambulance_name}",
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
            LOGGER.error(f"❌ Session creation failed: {e}")
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

        # Get camera for this ambulance
        camera_id = None
        streaming_url = None

        try:
            # Step 2a: Get existing cameras for this ambulance
            LOGGER.info(f"Fetching existing cameras for ambulance {ambulance_id}")
            get_cameras_url = f"{base_url}/ambulances/{ambulance_id}/cameras"
            async with session.get(get_cameras_url) as get_cameras_resp:
                if get_cameras_resp.status == 200:
                    cameras_result = await get_cameras_resp.json()
                    cameras = cameras_result.get("data", [])
                    LOGGER.info(f"Found {len(cameras)} existing cameras")

                    if cameras:
                        # Select camera based on room number
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
                "room_name": room_name,
                "device_name": device_name or f"RPi-{ambulance_name}",
            }
            create_camera_room_url = f"{base_url}/ambulance-streaming/camera-rooms"

            # First, check for existing camera rooms
            existing_room_id = None
            get_rooms_url = f"{base_url}/ambulance-streaming/camera-rooms"
            LOGGER.info(f"🔍 Checking for existing camera room: {room_name}")

            async with session.get(
                get_rooms_url, params={"session_id": session_id, "limit": 100}
            ) as get_resp:
                if get_resp.status == 200:
                    existing_rooms = await get_resp.json()
                    for room in existing_rooms:
                        if (
                            room.get("room_name") == room_name
                            and room.get("camera_id") == camera_id
                        ):
                            existing_room_id = room.get("id")
                            LOGGER.info(
                                f"✅ Found existing camera room (UUID: {existing_room_id})"
                            )
                            LOGGER.info(f"🔄 Rejoining existing room: {room_name}")
                            break

            if existing_room_id:
                # Room exists - rejoin it
                LOGGER.info(f"♻️  Rejoining existing camera room for camera {room_name}")
                streaming_url = (
                    f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                )
            else:
                # Room doesn't exist - create new one
                LOGGER.info(
                    f"🆕 Creating new camera room for camera ID {camera_id}: {room_name}"
                )
                async with session.post(
                    create_camera_room_url,
                    json=camera_room_payload,
                    params={"session_id": session_id},
                ) as resp:
                    if resp.status == 200:
                        camera_room = await resp.json()
                        LOGGER.info(f"✅ Ambulance camera room created: {camera_room}")
                        streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                    elif resp.status == 409:
                        # Camera room already exists
                        LOGGER.info(
                            f"🔄 Camera room already exists (409), rejoining camera ID: {camera_id}"
                        )
                        streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                    else:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"Camera room creation failed ({resp.status}): {error_text}"
                        )

                        # Check if it's a duplicate room_name error
                        if (
                            "already exists" in error_text.lower()
                            or "duplicate" in error_text.lower()
                        ):
                            LOGGER.info(
                                f"🔄 Room {room_name} already exists (duplicate key), rejoining"
                            )
                            streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                        else:
                            raise Exception(
                                f"Camera endpoint failed: {resp.status} - {error_text}"
                            )

        except Exception as e:
            LOGGER.error(f"❌ Camera setup failed: {e}")
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
                        LOGGER.warning(
                            f"⚠️  Streamer already connected (attempt {retry_count}/{max_retries})"
                        )

                        if retry_count < max_retries:
                            LOGGER.info("🔄 Waiting 2 seconds before retry...")
                            await asyncio.sleep(2)
                            continue
                        else:
                            LOGGER.error(
                                "❌ Max retries reached. Room may have active streamer."
                            )
                            LOGGER.info(
                                "💡 Try stopping other broadcasters or wait for timeout"
                            )
                            safe_close_player(player)
                            await pc.close()
                            return
                    elif resp.status != 200:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"❌ Streaming failed ({resp.status}): {error_text}"
                        )
                        safe_close_player(player)
                        await pc.close()
                        return
                    else:
                        answer_json = await resp.json()
                        LOGGER.info("✅ Successfully connected to streaming endpoint")
                        break

            except Exception as e:
                retry_count += 1
                LOGGER.error(
                    f"❌ Connection error (attempt {retry_count}/{max_retries}): {e}"
                )
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
    LOGGER.info("🎥 Raspberry Pi streaming started successfully!")
    LOGGER.info(f"🚑 Ambulance: {ambulance_name}")
    LOGGER.info(f"🏠 Room: {room_name}")
    LOGGER.info(f"📡 Session ID: {session_id}")
    LOGGER.info(f"🆔 Camera ID: {camera_id}")
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
        safe_close_player(player)
        await pc.close()
        LOGGER.info("🧹 Broadcaster cleanup completed")
        LOGGER.info("📋 Session Status: ACTIVE (can reconnect)")


def main() -> None:
    """Main entry point for RPi broadcaster"""
    parser = argparse.ArgumentParser(
        description="Raspberry Pi WebRTC camera broadcaster with ambulance integration"
    )
    parser.add_argument(
        "--config",
        action="store_true",
        help="Use configuration from config files",
    )
    parser.add_argument(
        "--ambulance",
        help="Ambulance number (e.g., 001, 002) - overrides config",
    )
    parser.add_argument(
        "--room",
        help="Room number (e.g., 001, 002) - overrides config",
    )
    parser.add_argument(
        "--server",
        help="Server URL (default: from config or http://localhost:8000)",
    )
    parser.add_argument(
        "--device_name",
        help="Name of the streaming device",
    )
    args = parser.parse_args()

    # Load configuration
    try:
        config_manager = ConfigManager()
        network_config = config_manager.load_network_config()
    except Exception as e:
        LOGGER.error(f"❌ Failed to load configuration: {e}")
        LOGGER.info("💡 Using default settings or command-line arguments")
        network_config = {
            "ambulance_number": "001",
            "room_number": "001",
            "server_url": "http://localhost:8000",
            "device_name": "RPi-Broadcaster",
        }

    # Use command-line args or config
    ambulance_number = (
        args.ambulance or network_config.get("ambulance_number", "001")
    ).zfill(3)
    room_number = (args.room or network_config.get("room_number", "001")).zfill(3)
    server_url = (
        args.server or network_config.get("server_url", "http://localhost:8000")
    ).rstrip("/")
    device_name = args.device_name or network_config.get(
        "device_name", f"RPi-AMB-{ambulance_number}"
    )

    LOGGER.info(f"\n{'='*60}")
    LOGGER.info(f"🎥 Raspberry Pi WebRTC Broadcaster")
    LOGGER.info(f"{'='*60}")
    LOGGER.info(f"🚑 Ambulance: AMB-{ambulance_number}")
    LOGGER.info(f"🏠 Room: AMB-{ambulance_number}-ROOM-{room_number}")
    LOGGER.info(f"🌐 Server: {server_url}")
    LOGGER.info(f"🏷️  Device Name: {device_name}")
    LOGGER.info(f"\n� Connection Strategy:")
    LOGGER.info(f"   1️⃣  Check if ambulance exists in database")
    LOGGER.info(f"   2️⃣  Create/reconnect to ambulance session")
    LOGGER.info(f"   3️⃣  Get existing camera or select from available")
    LOGGER.info(f"   4️⃣  Check if camera room exists, create/rejoin")
    LOGGER.info(f"   5️⃣  Connect to streaming endpoint (3 retry attempts)")
    LOGGER.info(f"\n🔄 Auto-reconnect: Room will be reused if it exists")
    LOGGER.info(f"⏱️  Stream Timeout: 30 seconds of inactivity")
    LOGGER.info(f"{'='*60}\n")

    try:
        asyncio.run(
            publish(
                ambulance_number,
                room_number,
                server_url,
                config_manager,
                device_name=device_name,
            )
        )
    except KeyboardInterrupt:
        LOGGER.info("\n🛑 Broadcaster stopped by user")
    except Exception as exc:
        LOGGER.exception("Fatal error: %s", exc)


if __name__ == "__main__":
    main()
