#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Multi-Camera Broadcaster
Streams multiple cameras/rooms simultaneously from a single Raspberry Pi
"""

import argparse
import asyncio
import inspect
import logging
from typing import Optional, List, Dict
import json

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer

from config_manager import ConfigManager

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - [%(name)s] - %(levelname)s - %(message)s",
)
LOGGER = logging.getLogger("multi_broadcaster")


class CameraBroadcaster:
    """Handles broadcasting for a single camera/room"""

    def __init__(
        self,
        camera_number: int,
        device_path: str,
        ambulance_number: str,
        base_url: str,
        config_manager: ConfigManager,
    ):
        self.camera_number = camera_number
        self.device_path = device_path
        self.ambulance_number = ambulance_number
        self.base_url = base_url
        self.config_manager = config_manager

        self.room_number = str(camera_number).zfill(3)
        self.ambulance_name = f"AMB-{ambulance_number}"
        self.room_name = f"AMB-{ambulance_number}-ROOM-{self.room_number}"
        self.device_name = f"RPi-Camera-{camera_number}"

        self.pc: Optional[RTCPeerConnection] = None
        self.player: Optional[MediaPlayer] = None
        self.session_id: Optional[str] = None
        self.camera_id: Optional[str] = None
        self.running = False

        self.logger = logging.getLogger(f"Camera-{camera_number}")

    def get_media_player(self) -> MediaPlayer:
        """Create media player for this camera"""
        camera_config = self.config_manager.load_camera_config()

        resolution = camera_config.get("resolution", [640, 480])
        framerate = camera_config.get("framerate", 30)
        bitrate = camera_config.get("bitrate", "500000")  # Lower bitrate for multi-camera

        width, height = resolution

        options = {
            "video_size": f"{width}x{height}",
            "framerate": str(framerate),
            "input_format": "v4l2",
            "pixel_format": "yuv420p",
            "buffers": "4",
            "rtbufsize": "50M",  # Smaller buffer for multi-camera
            "preset": "ultrafast",
            "tune": "zerolatency",
            "b:v": bitrate,
        }

        self.logger.info(
            f"📹 Camera {self.camera_number} settings: {width}x{height} @ {framerate}fps on {self.device_path}"
        )
        return MediaPlayer(self.device_path, format="v4l2", options=options)

    def safe_close_player(self, player: MediaPlayer):
        """Safely close media player"""
        if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
            return player.stop()
        else:
            for track in (player.audio, player.video):
                if track:
                    track.stop()
            return None

    async def get_ambulance_by_number(self, ambulance_number: str) -> Optional[dict]:
        """Get ambulance details by searching for ambulance number"""
        try:
            async with aiohttp.ClientSession() as session:
                ambulances_url = f"{self.base_url}/ambulances/"

                async with session.get(ambulances_url) as resp:
                    if resp.status == 200:
                        result = await resp.json()
                        ambulances = result.get("data", [])

                        for ambulance in ambulances:
                            if ambulance.get("ambulance_number") == ambulance_number:
                                return ambulance
                        return None
        except Exception as e:
            self.logger.error(f"Error fetching ambulances: {e}")
            return None

    async def start_broadcasting(self) -> bool:
        """Start broadcasting this camera"""
        try:
            self.logger.info(f"🚀 Starting camera {self.camera_number}...")

            # Get ambulance
            ambulance_data = await self.get_ambulance_by_number(self.ambulance_name)
            if not ambulance_data:
                self.logger.error(f"❌ Ambulance {self.ambulance_name} not found")
                return False

            ambulance_id = ambulance_data.get("id")

            # Create media player
            self.player = self.get_media_player()

            # Create peer connection
            self.pc = RTCPeerConnection()

            if self.player.video:
                self.pc.addTrack(self.player.video)
                if self.player.audio:
                    self.pc.addTrack(self.player.audio)
            else:
                self.logger.error("No video track found")
                self.safe_close_player(self.player)
                return False

            await self.pc.setLocalDescription(await self.pc.createOffer())

            while self.pc.iceGatheringState != "complete":
                await asyncio.sleep(0.1)

            offer_payload = {
                "sdp": self.pc.localDescription.sdp,
                "type": self.pc.localDescription.type,
            }

            # Create session and connect
            async with aiohttp.ClientSession() as session:
                # Create ambulance session
                ambulance_payload = {
                    "ambulance_id": ambulance_id,
                    "session_name": f"Multi-Cam Session - {self.ambulance_name}",
                    "session_type": "emergency",
                    "priority_level": 3,
                }
                create_session_url = (
                    f"{self.base_url}/ambulance-streaming/ambulance-sessions"
                )

                async with session.post(
                    create_session_url, json=ambulance_payload
                ) as resp:
                    if resp.status == 200:
                        ambulance_session = await resp.json()
                        self.session_id = ambulance_session.get("id")
                    elif resp.status == 409:
                        # Get existing session
                        get_session_url = (
                            f"{self.base_url}/ambulance-streaming/ambulance-sessions"
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
                                    self.session_id = sessions[0].get("id")

                if not self.session_id:
                    raise Exception("Could not create or get session")

                # Get cameras
                get_cameras_url = f"{self.base_url}/ambulances/{ambulance_id}/cameras"
                async with session.get(get_cameras_url) as get_cameras_resp:
                    if get_cameras_resp.status == 200:
                        cameras_result = await get_cameras_resp.json()
                        cameras = cameras_result.get("data", [])

                        if cameras:
                            camera_index = (self.camera_number - 1) % len(cameras)
                            selected_camera = cameras[camera_index]
                            self.camera_id = selected_camera.get("id")
                        else:
                            raise Exception("No cameras found")

                # Create/join camera room
                camera_room_payload = {
                    "camera_id": self.camera_id,
                    "room_id": self.room_name,
                    "device_name": self.device_name,
                }
                create_room_url = f"{self.base_url}/ambulance-streaming/camera-rooms"

                async with session.post(
                    create_room_url,
                    json=camera_room_payload,
                    params={"session_id": self.session_id},
                ) as resp:
                    if resp.status not in [200, 409]:
                        error_text = await resp.text()
                        if "already exists" not in error_text.lower():
                            self.logger.warning(f"Room creation warning: {error_text}")

                # Connect to streaming endpoint
                streaming_url = (
                    f"{self.base_url}/ambulance-streaming/camera/{self.room_name}/streamer"
                )

                async with session.post(streaming_url, json=offer_payload) as resp:
                    if resp.status == 200:
                        answer_json = await resp.json()
                        sdp_answer = {
                            "sdp": answer_json.get("sdp"),
                            "type": answer_json.get("type"),
                        }
                        await self.pc.setRemoteDescription(
                            RTCSessionDescription(**sdp_answer)
                        )
                        self.logger.info(
                            f"✅ Camera {self.camera_number} streaming started!"
                        )
                        self.running = True
                        return True
                    else:
                        error_text = await resp.text()
                        self.logger.error(
                            f"❌ Streaming failed ({resp.status}): {error_text}"
                        )
                        return False

        except Exception as e:
            self.logger.error(f"❌ Failed to start camera {self.camera_number}: {e}")
            if self.player:
                self.safe_close_player(self.player)
            if self.pc:
                await self.pc.close()
            return False

    async def monitor_connection(self):
        """Monitor connection state"""
        try:
            while self.running:
                await asyncio.sleep(5)
                if self.pc and self.pc.connectionState in [
                    "failed",
                    "closed",
                    "disconnected",
                ]:
                    self.logger.warning(
                        f"Camera {self.camera_number} connection state: {self.pc.connectionState}"
                    )
                    break
        except asyncio.CancelledError:
            self.logger.info(f"Camera {self.camera_number} monitoring cancelled")

    async def stop_broadcasting(self):
        """Stop broadcasting this camera"""
        self.running = False
        if self.player:
            self.safe_close_player(self.player)
        if self.pc:
            await self.pc.close()
        self.logger.info(f"🛑 Camera {self.camera_number} stopped")


class MultiCameraBroadcaster:
    """Manages multiple camera broadcasters"""

    def __init__(self, config_path: str):
        self.config_manager = ConfigManager()
        self.broadcasters: List[CameraBroadcaster] = []
        self.tasks: List[asyncio.Task] = []

        # Load multi-camera config
        with open(config_path, "r") as f:
            self.config = json.load(f)

        self.ambulance_number = self.config.get("ambulance_number", "001")
        self.base_url = self.config.get("server_url", "http://localhost:8000").rstrip(
            "/"
        )

    def setup_cameras(self):
        """Setup all cameras from configuration"""
        cameras_config = self.config.get("cameras", [])

        LOGGER.info(f"📹 Setting up {len(cameras_config)} cameras...")

        for idx, camera_config in enumerate(cameras_config, 1):
            device_path = camera_config.get("device", f"/dev/video{idx-1}")
            enabled = camera_config.get("enabled", True)

            if enabled:
                broadcaster = CameraBroadcaster(
                    camera_number=idx,
                    device_path=device_path,
                    ambulance_number=self.ambulance_number,
                    base_url=self.base_url,
                    config_manager=self.config_manager,
                )
                self.broadcasters.append(broadcaster)
                LOGGER.info(f"✅ Camera {idx} configured: {device_path}")
            else:
                LOGGER.info(f"⏭️  Camera {idx} disabled, skipping")

    async def start_all(self):
        """Start all camera broadcasters"""
        LOGGER.info(f"🚀 Starting {len(self.broadcasters)} cameras...")

        # Start all broadcasters concurrently
        start_tasks = [b.start_broadcasting() for b in self.broadcasters]
        results = await asyncio.gather(*start_tasks, return_exceptions=True)

        # Create monitoring tasks for successful starts
        for broadcaster, result in zip(self.broadcasters, results):
            if result is True:
                task = asyncio.create_task(broadcaster.monitor_connection())
                self.tasks.append(task)

        LOGGER.info("✅ All cameras started")

        # Wait for all monitoring tasks
        try:
            await asyncio.gather(*self.tasks)
        except KeyboardInterrupt:
            LOGGER.info("🛑 Stopping all cameras...")
            await self.stop_all()

    async def stop_all(self):
        """Stop all camera broadcasters"""
        LOGGER.info("🛑 Stopping all cameras...")

        # Cancel monitoring tasks
        for task in self.tasks:
            if not task.done():
                task.cancel()

        # Stop all broadcasters
        stop_tasks = [b.stop_broadcasting() for b in self.broadcasters]
        await asyncio.gather(*stop_tasks, return_exceptions=True)

        LOGGER.info("✅ All cameras stopped")


def main():
    parser = argparse.ArgumentParser(
        description="Multi-camera Raspberry Pi broadcaster"
    )
    parser.add_argument(
        "--config",
        default="/home/pi/stemsight/config/multi_camera_config.json",
        help="Path to multi-camera configuration file",
    )
    args = parser.parse_args()

    LOGGER.info("=" * 60)
    LOGGER.info("🎥 STEMSight Multi-Camera Broadcaster")
    LOGGER.info("=" * 60)
    LOGGER.info(f"📋 Config: {args.config}")
    LOGGER.info("")

    broadcaster = MultiCameraBroadcaster(args.config)
    broadcaster.setup_cameras()

    try:
        asyncio.run(broadcaster.start_all())
    except KeyboardInterrupt:
        LOGGER.info("\n🛑 Stopped by user")
    except Exception as e:
        LOGGER.exception(f"❌ Fatal error: {e}")


if __name__ == "__main__":
    main()
