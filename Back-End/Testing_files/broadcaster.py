"""
streamer.py
===========

Run on the device that owns the camera.

Usage
-----
    # 1.  Make sure the FastAPI server is running (uvicorn main:app …)
    # 2.  Create a room   →  curl -X POST http://localhost:8080/rooms
    # 3.  Start publishing video into that room:
    #
    #       python streamer.py --room 8f9b6cc0-…  \
    #                          --signaling http://localhost:8080 \
    #                          --device /dev/video0        # or "video=Integrated Camera"
"""

import argparse
import asyncio
import inspect
import logging
import platform
import shlex
from typing import Optional

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger("publisher")


# ---------------------------------------------------------------------
#  Helper: pick a sensible default capture device per OS
# ---------------------------------------------------------------------
def default_device() -> str:
    os_name = platform.system()
    if os_name == "Windows":
        return "video=Logitech BRIO"
    elif os_name == "Darwin":            # macOS (AVFoundation)
        # Uses first video device.  Change index if you have multiples.
        return "default:none"
    else:                                # Linux / *BSD
        return "/dev/video0"

def safe_close_player(player: MediaPlayer):
    """
    Works whether MediaPlayer.stop() exists or not.
    """
    if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
        # modern aiortc ≥ 1.5
        return player.stop()                  # caller should await this
    else:
        # older aiortc – stop the individual tracks
        for track in (player.audio, player.video):
            if track:
                track.stop()                  # synchronous
        return None   

async def publish(room_id: str, base_url: str, device: Optional[str]) -> None:
    print(aiortc.__version__)              # should show 1.5.0 or later
    print("stop" in dir(aiortc.contrib.media.MediaPlayer))
    media_src = device or default_device()
    LOGGER.info("Opening media source %s", media_src)
    if platform.system() == "Windows" and media_src.startswith("video="):
        # strip any wrapping quotes so FFmpeg doesn't get confused
        player = MediaPlayer(
            media_src,
            format="dshow",
            options={
                "video_size": "1280x720",    # pick a mode your Brio supports
                "framerate": "30",
                "vcodec": "mjpeg",
            }
        )
    else:
        player = MediaPlayer(media_src)
    pc = RTCPeerConnection()

    # Add the camera video track as *send-only*
    if player.video:
        pc.addTrack(player.video)
    else:
        LOGGER.error("No video track found on device %s", media_src)
        safe_close_player(player)
        return

    await pc.setLocalDescription(await pc.createOffer())

    # Wait until ICE gathering is complete so we send a single, complete SDP
    while pc.iceGatheringState != "complete":
        await asyncio.sleep(0.1)

    offer_payload = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

    create_room_url = f"{base_url}/streaming/create_room/test_patient"
    LOGGER.info("POST %s", create_room_url)

    async with aiohttp.ClientSession() as session:
        async with session.post(create_room_url) as resp:
            if resp.status != 200:
                LOGGER.error("Create room failed (%s): %s", resp.status, await resp.text())
                safe_close_player(player)
                await pc.close()
                return
            room_json = await resp.json()
            LOGGER.info("Room created: %s", room_json)
            streaming_url = f"{base_url}/streaming/rooms/{room_id}/streamer"
            async with session.post(streaming_url, json=offer_payload) as resp:
                if resp.status != 200:
                    LOGGER.error("Publish failed (%s): %s", resp.status, await resp.text())
                    safe_close_player(player)
                    await pc.close()
                    return
                answer_json = await resp.json()

    await pc.setRemoteDescription(RTCSessionDescription(**answer_json))
    LOGGER.info("Streaming…  (Ctrl+C to stop)")

    try:
        while True:
            await asyncio.sleep(30)
    except KeyboardInterrupt:
        LOGGER.info("Stopping…")
    finally:
        safe_close_player(player)
        await pc.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="WebRTC camera publisher")
    parser.add_argument("--room", required=True, help="Room ID returned by POST /rooms")
    parser.add_argument(
        "--signaling",
        default="http://localhost:8000",
        help="Base URL of signalling server (default: http://localhost:8000)",
    )
    parser.add_argument(
        "--device",
        help=(
            "Camera device or media file path. "
            "Examples: /dev/video0  |  video=Integrated Camera  |  sample.mp4"
        ),
    )
    args = parser.parse_args()

    try:
        asyncio.run(publish(args.room, args.signaling.rstrip("/"), args.device))
    except Exception as exc:
        LOGGER.exception("Fatal error: %s", exc)


if __name__ == "__main__":
    main()
