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
        return "video=Logitech BRIO"
    elif os_name == "Darwin":  # macOS
        return "0:none"  # First camera, no audio
    else:  # Linux / *BSD
        return "/dev/video0"


def safe_close_player(player: MediaPlayer):
    if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
        return player.stop()
    else:
        for track in (player.audio, player.video):
            if track:
                track.stop()
        return None


async def publish(room_id: str, base_url: str, device: Optional[str]) -> None:
    print(f"aiortc version: {aiortc.__version__}")
    media_src = device or default_device()
    LOGGER.info("Opening media source %s", media_src)

    os_name = platform.system()
    if os_name == "Windows" and media_src.startswith("video="):
        player = MediaPlayer(
            media_src,
            format="dshow",
            options={
                "video_size": "1280x720",
                "framerate": "30",
                "vcodec": "mjpeg",
            },
        )
    elif os_name == "Darwin":
        player = MediaPlayer(
            media_src,
            format="avfoundation",
            options={
                "video_size": "1280x720",
                "framerate": "30",
            },
        )
    else:
        player = MediaPlayer(media_src)

    pc = RTCPeerConnection()

    if player.video:
        pc.addTrack(player.video)
    else:
        LOGGER.error("No video track found on device %s", media_src)
        safe_close_player(player)
        return

    await pc.setLocalDescription(await pc.createOffer())

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
    LOGGER.info("Streaming… (Ctrl+C to stop)")

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
