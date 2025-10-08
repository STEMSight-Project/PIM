#!/usr/bin/env python3
"""
STEMSight Raspberry Pi Automated Broadcaster
Automatically connects to ambulance streaming using configuration settings
"""

import asyncio
import inspect
import json
import logging
import os
import platform
import signal
import sys
import time
from typing import Optional

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaPlayer

from config_manager import ConfigManager

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("/home/pi/stemsight/logs/broadcaster.log"),
        logging.StreamHandler(),
    ],
)
LOGGER = logging.getLogger("rpi_broadcaster")


class RPiAutoBroadcaster:
    """Automated Raspberry Pi broadcaster with configuration-based setup"""

    def __init__(self, config_manager: ConfigManager):
        self.config_manager = config_manager
        self.pc: Optional[RTCPeerConnection] = None
        self.player: Optional[MediaPlayer] = None
        self.session_id: Optional[str] = None
        self.camera_id: Optional[str] = None
        self.running = False
        self.reconnecting = False

        # Load configuration
        self.camera_config = config_manager.load_camera_config()
        self.network_config = config_manager.load_network_config()

        # Extract key settings
        self.ambulance_number = self.network_config.get("ambulance_number", "001")
        self.room_number = self.network_config.get("room_number", "001")
        self.server_url = self.network_config.get(
            "server_url", "http://localhost:8000"
        ).rstrip("/")
        self.device_name = self.network_config.get(
            "device_name", f"RPi-AMB-{self.ambulance_number}"
        )
        self.auto_start = self.network_config.get("auto_start", True)
        self.reconnect_interval = self.network_config.get("reconnect_interval", 5)
        self.retry_attempts = self.network_config.get("retry_attempts", 3)

        # Generate names
        self.ambulance_name = f"AMB-{self.ambulance_number.zfill(3)}"
        self.room_name = (
            f"AMB-{self.ambulance_number.zfill(3)}-ROOM-{self.room_number.zfill(3)}"
        )

        LOGGER.info("🤖 RPi Auto-Broadcaster Started")
        LOGGER.info(f"🚑 Ambulance: {self.ambulance_name}")
        LOGGER.info(f"📹 Camera: {self.room_number}")
        LOGGER.info(f"🏠 Room: {self.room_name}")
        LOGGER.info(f"🌐 Server: {self.server_url}")
        LOGGER.info(f"🔄 Configuration: Loaded from saved settings")

    def get_rpi_media_player(self) -> MediaPlayer:
        """Create media player optimized for Raspberry Pi camera"""
        # Raspberry Pi camera module settings
        device = "/dev/video0"  # Default RPi camera

        # Get resolution and framerate from config
        resolution = self.camera_config.get("resolution", [640, 480])
        framerate = self.camera_config.get("framerate", 30)
        bitrate = self.camera_config.get("bitrate", "1000000")

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

    def safe_close_player(self, player: MediaPlayer):
        """Safely close media player"""
        try:
            if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
                return player.stop()
            else:
                for track in (player.audio, player.video):
                    if track:
                        track.stop()
                return None
        except Exception as e:
            LOGGER.warning(f"Error closing player: {e}")
            return None

    async def get_ambulance_by_number(self, ambulance_number: str) -> Optional[dict]:
        """Get ambulance details by searching for ambulance number"""
        try:
            async with aiohttp.ClientSession() as session:
                ambulances_url = f"{self.server_url}/ambulances/"
                LOGGER.info(f"🔍 Fetching ambulances from: {ambulances_url}")

                async with session.get(ambulances_url) as resp:
                    if resp.status == 200:
                        result = await resp.json()
                        ambulances = result.get("data", [])
                        LOGGER.info(f"Found {len(ambulances)} ambulances in database")

                        # Search for ambulance by ambulance_number
                        for ambulance in ambulances:
                            if ambulance.get("ambulance_number") == ambulance_number:
                                LOGGER.info(
                                    f"✅ Found ambulance: {ambulance.get('ambulance_number')} (ID: {ambulance.get('id')})"
                                )
                                return ambulance

                        LOGGER.warning(
                            f"❌ Ambulance {ambulance_number} not found in database"
                        )
                        return None
                    else:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"Failed to fetch ambulances ({resp.status}): {error_text}"
                        )
                        return None

        except Exception as e:
            LOGGER.error(f"Error fetching ambulances: {e}")
            return None

    async def create_session_and_camera(
        self, ambulance_id: str
    ) -> tuple[Optional[str], Optional[str]]:
        """Create ambulance session and get camera for streaming"""
        session_id = None
        camera_id = None

        async with aiohttp.ClientSession() as session:
            try:
                # Step 1: Create/get ambulance session
                ambulance_payload = {
                    "ambulance_id": ambulance_id,
                    "session_name": f"RPi Auto Session - {self.ambulance_name}",
                    "session_type": "emergency",
                    "priority_level": 3,
                }
                create_ambulance_url = (
                    f"{self.server_url}/ambulance-streaming/ambulance-sessions"
                )

                LOGGER.info(f"📋 Creating ambulance session for: {self.ambulance_name}")
                async with session.post(
                    create_ambulance_url, json=ambulance_payload
                ) as resp:
                    if resp.status == 200:
                        ambulance_session = await resp.json()
                        session_id = ambulance_session.get("id")
                        LOGGER.info(f"✅ Ambulance session created: {session_id}")
                    elif resp.status == 409:
                        # Session already exists, get existing
                        LOGGER.info(f"🔄 Ambulance session exists, getting existing...")
                        get_session_url = (
                            f"{self.server_url}/ambulance-streaming/ambulance-sessions"
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
                                    session_id = sessions[0].get("id")
                                    LOGGER.info(
                                        f"✅ Retrieved existing session: {session_id}"
                                    )
                    else:
                        raise Exception(f"Ambulance session failed: {resp.status}")

                if not session_id:
                    raise Exception("Could not create or get ambulance session")

                # Step 2: Get existing cameras for this ambulance
                LOGGER.info(f"🎥 Fetching cameras for ambulance {ambulance_id}")
                get_cameras_url = f"{self.server_url}/ambulances/{ambulance_id}/cameras"
                async with session.get(get_cameras_url) as get_cameras_resp:
                    if get_cameras_resp.status == 200:
                        cameras_result = await get_cameras_resp.json()
                        cameras = cameras_result.get("data", [])
                        LOGGER.info(f"Found {len(cameras)} existing cameras")

                        if cameras:
                            # Select camera based on room number
                            camera_index = (int(self.room_number) - 1) % len(cameras)
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
                        raise Exception(
                            f"Failed to fetch cameras: {get_cameras_resp.status} - {error_text}"
                        )

                # Step 3: Create/get camera room
                if camera_id:
                    camera_room_payload = {
                        "camera_id": camera_id,
                        "room_id": self.room_name,
                        "device_name": self.device_name,
                    }
                    create_camera_room_url = (
                        f"{self.server_url}/ambulance-streaming/camera-rooms"
                    )

                    LOGGER.info(f"🏠 Creating camera room: {self.room_name}")
                    async with session.post(
                        create_camera_room_url,
                        json=camera_room_payload,
                        params={"session_id": session_id},
                    ) as resp:
                        if resp.status in [
                            200,
                            409,
                        ]:  # 200 = created, 409 = already exists
                            LOGGER.info(f"✅ Camera room ready: {self.room_name}")
                        else:
                            error_text = await resp.text()
                            if (
                                "already exists" in error_text
                                or "duplicate key" in error_text
                            ):
                                LOGGER.info(
                                    f"🔄 Room {self.room_name} already exists, continuing..."
                                )
                            else:
                                LOGGER.warning(
                                    f"Camera room creation warning ({resp.status}): {error_text}"
                                )

                return session_id, camera_id

            except Exception as e:
                LOGGER.error(f"❌ Error in session/camera setup: {e}")
                return None, None

    async def start_streaming(self) -> bool:
        """Start the WebRTC streaming connection"""
        try:
            # Step 1: Get ambulance from database
            ambulance_data = await self.get_ambulance_by_number(self.ambulance_name)
            if not ambulance_data:
                LOGGER.error(
                    f"❌ Ambulance {self.ambulance_name} not found in database"
                )
                return False

            ambulance_id = ambulance_data.get("id")
            LOGGER.info(f"✅ Using Ambulance ID: {ambulance_id}")

            # Step 2: Create session and get camera
            session_id, camera_id = await self.create_session_and_camera(ambulance_id)
            if not session_id or not camera_id:
                LOGGER.error("❌ Failed to setup session and camera")
                return False

            self.session_id = session_id
            self.camera_id = camera_id

            # Step 3: Initialize media player
            self.player = self.get_rpi_media_player()
            if not self.player.video:
                LOGGER.error("❌ No video track found on camera")
                return False

            # Step 4: Create WebRTC peer connection
            self.pc = RTCPeerConnection()
            self.pc.addTrack(self.player.video)
            if self.player.audio:
                self.pc.addTrack(self.player.audio)

            # Step 5: Create offer and wait for ICE gathering
            await self.pc.setLocalDescription(await self.pc.createOffer())
            while self.pc.iceGatheringState != "complete":
                await asyncio.sleep(0.1)

            offer_payload = {
                "sdp": self.pc.localDescription.sdp,
                "type": self.pc.localDescription.type,
            }

            # Step 6: Connect to streaming endpoint
            streaming_url = (
                f"{self.server_url}/ambulance-streaming/camera/{camera_id}/streamer"
            )
            LOGGER.info(f"📡 Connecting to streaming endpoint: {streaming_url}")

            async with aiohttp.ClientSession() as session:
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
                        LOGGER.info("🎥 Streaming started successfully!")
                        return True
                    elif resp.status == 409:
                        LOGGER.warning(
                            "⚠️ Streamer already connected, attempting reconnection..."
                        )
                        await asyncio.sleep(2)
                        # Retry once
                        async with session.post(
                            streaming_url, json=offer_payload
                        ) as retry_resp:
                            if retry_resp.status == 200:
                                answer_json = await retry_resp.json()
                                sdp_answer = {
                                    "sdp": answer_json.get("sdp"),
                                    "type": answer_json.get("type"),
                                }
                                await self.pc.setRemoteDescription(
                                    RTCSessionDescription(**sdp_answer)
                                )
                                LOGGER.info("🎥 Reconnection successful!")
                                return True
                            else:
                                LOGGER.error(
                                    f"❌ Reconnection failed: {retry_resp.status}"
                                )
                                return False
                    else:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"❌ Streaming connection failed ({resp.status}): {error_text}"
                        )
                        return False

        except Exception as e:
            LOGGER.error(f"❌ Error starting stream: {e}")
            return False

    async def monitor_connection(self):
        """Monitor WebRTC connection and handle reconnections"""
        while self.running:
            try:
                if self.pc and self.pc.connectionState in [
                    "failed",
                    "closed",
                    "disconnected",
                ]:
                    LOGGER.warning(f"⚠️ Connection state: {self.pc.connectionState}")
                    if not self.reconnecting:
                        LOGGER.info("🔄 Starting reconnection process...")
                        await self.reconnect()

                # Send heartbeat
                await self.send_heartbeat()

                await asyncio.sleep(self.reconnect_interval)

            except asyncio.CancelledError:
                break
            except Exception as e:
                LOGGER.error(f"❌ Error in connection monitoring: {e}")
                await asyncio.sleep(self.reconnect_interval)

    async def send_heartbeat(self):
        """Send heartbeat to server to indicate device is alive"""
        try:
            heartbeat_interval = self.network_config.get("heartbeat_interval", 30)
            if not hasattr(self, "_last_heartbeat"):
                self._last_heartbeat = 0

            current_time = time.time()
            if current_time - self._last_heartbeat < heartbeat_interval:
                return

            self._last_heartbeat = current_time

            if self.session_id:
                heartbeat_url = f"{self.server_url}/ambulance-streaming/heartbeat"
                heartbeat_data = {
                    "session_id": self.session_id,
                    "device_name": self.device_name,
                    "ambulance_name": self.ambulance_name,
                    "room_name": self.room_name,
                    "status": (
                        "streaming"
                        if self.pc and self.pc.connectionState == "connected"
                        else "connecting"
                    ),
                }

                async with aiohttp.ClientSession() as session:
                    async with session.post(heartbeat_url, json=heartbeat_data) as resp:
                        if resp.status == 200:
                            LOGGER.debug("💓 Heartbeat sent successfully")
                        else:
                            LOGGER.warning(f"⚠️ Heartbeat failed: {resp.status}")

        except Exception as e:
            LOGGER.warning(f"⚠️ Heartbeat error: {e}")

    async def reconnect(self):
        """Handle reconnection logic"""
        if self.reconnecting:
            return

        self.reconnecting = True
        LOGGER.info("🔄 Attempting to reconnect...")

        try:
            # Cleanup current connection
            await self.cleanup()

            # Wait before reconnecting
            await asyncio.sleep(self.reconnect_interval)

            # Attempt to restart streaming
            for attempt in range(self.retry_attempts):
                LOGGER.info(
                    f"🔄 Reconnection attempt {attempt + 1}/{self.retry_attempts}"
                )

                if await self.start_streaming():
                    LOGGER.info("✅ Reconnection successful!")
                    self.reconnecting = False
                    return

                await asyncio.sleep(self.reconnect_interval * 2)

            LOGGER.error("❌ All reconnection attempts failed")

        except Exception as e:
            LOGGER.error(f"❌ Reconnection error: {e}")
        finally:
            self.reconnecting = False

    async def cleanup(self):
        """Cleanup resources"""
        try:
            if self.player:
                safe_close = self.safe_close_player(self.player)
                if safe_close:
                    await safe_close
                self.player = None

            if self.pc:
                await self.pc.close()
                self.pc = None

            LOGGER.info("🧹 Cleanup completed")

        except Exception as e:
            LOGGER.warning(f"⚠️ Cleanup error: {e}")

    async def run(self):
        """Main run loop"""
        LOGGER.info("🚀 Starting RPi Auto-Broadcaster...")

        if not self.config_manager.validate_config():
            LOGGER.error("❌ Configuration validation failed")
            return

        self.running = True

        try:
            # Initial connection
            if await self.start_streaming():
                LOGGER.info("✅ Initial streaming connection established")

                # Start monitoring
                monitor_task = asyncio.create_task(self.monitor_connection())

                # Wait for shutdown signal
                await monitor_task

            else:
                LOGGER.error("❌ Failed to establish initial connection")

        except KeyboardInterrupt:
            LOGGER.info("🛑 Shutdown signal received")
        except Exception as e:
            LOGGER.error(f"❌ Fatal error: {e}")
        finally:
            self.running = False
            await self.cleanup()
            LOGGER.info("🏁 RPi Auto-Broadcaster stopped")

    def stop(self):
        """Stop the broadcaster"""
        LOGGER.info("🛑 Stopping broadcaster...")
        self.running = False


def check_first_time_setup():
    """Check if this is the first time running and needs setup"""
    config_files = ["config/network_config.json", "config/camera_config.json"]

    # Check if config files exist and are valid
    for config_file in config_files:
        if not os.path.exists(config_file):
            return True

        try:
            with open(config_file, "r") as f:
                config = json.load(f)

            # Check for required fields
            if config_file.endswith("network_config.json"):
                if not config.get("ambulance_number") or not config.get("room_number"):
                    return True

        except (json.JSONDecodeError, IOError):
            return True

    return False


async def main():
    """Main entry point"""
    # Ensure log directory exists
    os.makedirs("/home/pi/stemsight/logs", exist_ok=True)

    # Check if first-time setup is needed
    if check_first_time_setup():
        print("🚑 STEMSight Raspberry Pi - First Time Setup Required")
        print("=" * 55)
        print()
        print("This appears to be the first time running the broadcaster.")
        print("You need to configure your ambulance and camera numbers.")
        print()
        print("Run: python3 first_setup.py")
        print()
        print("After setup, the device will start automatically!")
        return

    # Initialize configuration
    config_manager = ConfigManager()

    # Validate configuration
    if not config_manager.validate_config():
        LOGGER.error("❌ Configuration validation failed!")
        print()
        print("Configuration error detected. Please run setup:")
        print("python3 first_setup.py")
        return

    # Create broadcaster
    broadcaster = RPiAutoBroadcaster(config_manager)

    # Setup signal handlers
    def signal_handler(signum, frame):
        LOGGER.info(f"📡 Received signal {signum}")
        broadcaster.stop()

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Run broadcaster
    await broadcaster.run()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n🛑 RPi Broadcaster stopped by user")
    except Exception as exc:
        LOGGER.exception("💥 Fatal error: %s", exc)
        sys.exit(1)
