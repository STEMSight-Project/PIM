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
        return "video=Logitech BRIO:audio=Microphone (3- AT2020USB+)"
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
            "video_size": "1280x720",
            "framerate": "30",
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


async def check_room_status(base_url: str, room_id: str) -> None:
    """Check the status of rooms for debugging"""
    async with aiohttp.ClientSession() as session:
        try:
            status_url = f"{base_url}/streaming/rooms/status"
            async with session.get(status_url) as resp:
                if resp.status == 200:
                    status_json = await resp.json()
                    print(f"📊 Room Status for {room_id}:")
                    rooms = status_json.get("rooms", {})
                    if room_id in rooms:
                        room_info = rooms[room_id]
                        print(f"   ✅ Room exists")
                        print(f"   🔄 Active: {room_info.get('is_active', False)}")
                        print(
                            f"   📹 Has Streamer: {room_info.get('has_streamer', False)}"
                        )
                        print(f"   👥 Viewers: {room_info.get('viewer_count', 0)}")
                        print(
                            f"   🔁 Reconnection Attempts: {room_info.get('reconnection_attempts', 0)}"
                        )
                        print(
                            f"   🆔 Session ID: {room_info.get('session_id', 'Unknown')}"
                        )
                    else:
                        print(f"   ❌ Room {room_id} not found")
                else:
                    print(f"❌ Failed to get room status: {resp.status}")
        except Exception as e:
            print(f"❌ Error checking room status: {e}")


async def publish(
    room_id: str,
    base_url: str,
    video_device: Optional[str],
    audio_device: Optional[str],
    device_name: Optional[str] = None,
) -> None:
    print(f"aiortc version: {aiortc.__version__}")
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

    # Updated to use the new create_room endpoint with device_name parameter
    device_param = f"?device_name={device_name}" if device_name else ""
    create_room_url = f"{base_url}/streaming/create_room/{room_id}{device_param}"

    async with aiohttp.ClientSession() as session:
        # Create room (this will also create a streaming session automatically)
        async with session.post(create_room_url) as resp:
            if resp.status != 200:
                error_text = await resp.text()
                LOGGER.error("Create room failed (%s): %s", resp.status, error_text)

                # Check if it's because of existing non-ended session
                if "non-ended session" in error_text.lower():
                    LOGGER.warning(
                        "Patient has an existing active session. Please end it first via frontend."
                    )
                    safe_close_player(player)
                    await pc.close()
                    return
                else:
                    safe_close_player(player)
                    await pc.close()
                    return

            room_json = await resp.json()
            LOGGER.info("Room created/connected: %s", room_json)

            # Extract session info and updated room_id
            session_id = room_json.get("session_id")
            returned_room_id = room_json.get("room_id")
            if session_id:
                LOGGER.info("Streaming session ID: %s", session_id)

            # Use the returned room_id for subsequent calls (includes device name suffix)
            if returned_room_id:
                room_id = returned_room_id
                LOGGER.info("Using returned room ID: %s", room_id)

            if room_json.get("reconnected"):
                LOGGER.info("✅ Reconnected to existing room")
            elif room_json.get("already_exists"):
                LOGGER.info("✅ Room already exists and is active")
            elif room_json.get("created"):
                LOGGER.info("✅ New room and session created")

        # Connect streamer to room
        streaming_url = f"{base_url}/streaming/streamer/{room_id}"
        async with session.post(streaming_url, json=offer_payload) as resp:
            if resp.status == 404:
                LOGGER.error("Room not found. Please create room first.")
                safe_close_player(player)
                await pc.close()
                return
            elif resp.status == 409:
                LOGGER.warning("Streamer already exists. Retrying...")
                await asyncio.sleep(1)
                # Retry once
                async with session.post(
                    streaming_url, json=offer_payload
                ) as retry_resp:
                    if retry_resp.status != 200:
                        LOGGER.error(
                            "Publish retry failed (%s): %s",
                            retry_resp.status,
                            await retry_resp.text(),
                        )
                        safe_close_player(player)
                        await pc.close()
                        return
                    answer_json = await retry_resp.json()
            elif resp.status != 200:
                LOGGER.error("Publish failed (%s): %s", resp.status, await resp.text())
                safe_close_player(player)
                await pc.close()
                return
            else:
                answer_json = await resp.json()

    await pc.setRemoteDescription(RTCSessionDescription(**answer_json))
    LOGGER.info("🎥 Streaming started successfully!")
    LOGGER.info("📡 Session ID: %s", session_id or "Unknown")
    LOGGER.info(
        "⚠️  NOTE: Session will remain active until explicitly ended via frontend"
    )
    LOGGER.info(
        "🛑 Press Ctrl+C to stop streaming (session stays active for reconnection)..."
    )

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
        "--room", required=True, help="Room ID (patient ID) for streaming"
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
        "--check_status",
        action="store_true",
        help="Check room status before starting stream",
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

    print(f"🎥 Starting WebRTC Broadcaster")
    print(f"📡 Room ID: {args.room}")
    print(f"🌐 Server: {args.signaling}")
    print(f"📹 Video Device: {args.video_device or 'Default'}")
    print(f"🎤 Audio Device: {args.audio_device or 'Default'}")
    print(f"🏷️  Device Name: {args.device_name}")
    print(f"💡 Session Management: Only ends via frontend")
    print(f"{'='*50}")

    try:
        # Check room status if requested
        if args.check_status:
            asyncio.run(check_room_status(args.signaling.rstrip("/"), args.room))
            print(f"{'='*50}")

        asyncio.run(
            publish(
                args.room,
                args.signaling.rstrip("/"),
                video_device=args.video_device,
                audio_device=args.audio_device,
                device_name=args.device_name,
            )
        )
    except Exception as exc:
        LOGGER.exception("Fatal error: %s", exc)


if __name__ == "__main__":
    main()
