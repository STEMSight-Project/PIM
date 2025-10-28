"""
HLS Recording Service for Ambulance Camera Streams
Direct FFmpeg Pipeline for WebRTC to HLS conversion
"""

import asyncio
import logging
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional

from aiortc import MediaStreamTrack

from core.common import logger, supabase
from supabase_settings.create_client import SUPABASE_ADMIN
from services.streaming.hls_segment_service import hls_segment_service

LOGGER = logging.getLogger(__name__)

# Recording configuration
RECORDINGS_BASE_PATH = Path("recordings")
HLS_SEGMENT_DURATION = 2  # 2-second segments


class SessionRecorder:
    """Manages HLS recording for a single camera room using direct FFmpeg pipeline"""

    def __init__(self, session_id: str, room_id: str, ambulance_number: str):
        self.session_id = session_id
        self.room_id = room_id
        self.ambulance_number = ambulance_number

        # Recording paths
        self.recording_path = RECORDINGS_BASE_PATH / f"room-{room_id}"
        self.playlist_path = self.recording_path / "playlist.m3u8"
        self.mp4_path = self.recording_path / "recording.mp4"

        # FFmpeg process
        self.ffmpeg_process: Optional[asyncio.subprocess.Process] = None
        self.recording_task: Optional[asyncio.Task] = None

        # State
        self.is_recording = False
        self.start_time: Optional[datetime] = None
        self.video_track: Optional[MediaStreamTrack] = None

        # Frame tracking
        self.frame_count = 0

        # Create recording directory
        self.recording_path.mkdir(parents=True, exist_ok=True)

    def get_duration(self) -> int:
        """Get recording duration in seconds"""
        if not self.start_time:
            return 0
        return int((datetime.utcnow() - self.start_time).total_seconds())

    def get_segment_count(self) -> int:
        """Get number of HLS segments created"""
        if not self.recording_path.exists():
            return 0
        return len(list(self.recording_path.glob("segment-*.ts")))

    def is_hls_ready(self) -> bool:
        """Check if HLS playlist is ready for playback"""
        return self.playlist_path.exists() and self.get_segment_count() >= 3

    def get_playlist_url(self) -> str:
        """Get HLS playlist URL"""
        return f"/videos/hls/{self.room_id}/playlist.m3u8"

    async def start_recording(self, video_track: MediaStreamTrack):
        """Start recording from WebRTC video track"""
        try:
            print(f"\n🔥🔥🔥 START_RECORDING CALLED FOR ROOM {self.room_id} 🔥🔥🔥\n")
            LOGGER.info(f"🔥 [RECORDING] START_RECORDING CALLED - room {self.room_id}")

            self.start_time = datetime.utcnow()
            self.video_track = video_track

            LOGGER.info(
                f"🎬 [RECORDING] Starting FFmpeg pipeline for room {self.room_id}"
            )

            # Start FFmpeg process
            await self._start_ffmpeg_process()

            # Start frame processing task
            self.is_recording = True
            self.recording_task = asyncio.create_task(self._process_frames())

            # Start HLS segment monitoring
            await hls_segment_service.start_monitoring_room(
                self.room_id, self.recording_path
            )

            # Create database entry
            await self._create_recording_entry()

            LOGGER.info(f"✅ [RECORDING] Recording started for room {self.room_id}")

        except Exception as e:
            LOGGER.error(f"Failed to start recording: {e}", exc_info=True)
            await self._cleanup_on_error()
            raise

    async def _start_ffmpeg_process(self):
        """Start FFmpeg subprocess with raw video input"""
        try:
            ffmpeg_cmd = [
                "ffmpeg",
                "-f",
                "rawvideo",
                "-pixel_format",
                "yuv420p",
                "-video_size",
                "640x480",
                "-framerate",
                "30",
                "-i",
                "pipe:0",
                # HLS output
                "-c:v",
                "libx264",
                "-preset",
                "ultrafast",
                "-tune",
                "zerolatency",
                "-b:v",
                "1M",
                "-g",
                "60",
                "-f",
                "hls",
                "-hls_time",
                str(HLS_SEGMENT_DURATION),
                "-hls_list_size",
                "0",
                "-hls_flags",
                "append_list+omit_endlist",
                "-hls_segment_filename",
                str(self.recording_path / "segment-%03d.ts"),
                str(self.playlist_path),
                # MP4 output
                "-c:v",
                "libx264",
                "-preset",
                "ultrafast",
                "-movflags",
                "+faststart",
                "-f",
                "mp4",
                "-y",
                str(self.mp4_path),
            ]

            LOGGER.info(f"🎬 Starting FFmpeg process...")

            # Use subprocess.Popen (works on all platforms, no asyncio event loop issues)
            self.ffmpeg_process = subprocess.Popen(
                ffmpeg_cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            LOGGER.info(f"✅ FFmpeg process started (PID: {self.ffmpeg_process.pid})")

            # Monitor stderr in background (non-blocking)
            asyncio.create_task(self._monitor_ffmpeg_stderr())

        except FileNotFoundError:
            LOGGER.error("❌ FFmpeg not found! Install FFmpeg")
            raise
        except Exception as e:
            LOGGER.error(f"❌ Failed to start FFmpeg: {e}", exc_info=True)
            raise

    async def _monitor_ffmpeg_stderr(self):
        """Monitor FFmpeg stderr for errors (read from synchronous subprocess)"""
        try:
            if not self.ffmpeg_process or not self.ffmpeg_process.stderr:
                return

            loop = asyncio.get_event_loop()

            # Read stderr in background thread
            while self.is_recording:
                try:
                    # Read line in executor to avoid blocking
                    line = await loop.run_in_executor(
                        None, self.ffmpeg_process.stderr.readline
                    )

                    if not line:
                        break

                    line_str = line.decode().strip()

                    if "error" in line_str.lower():
                        LOGGER.error(f"FFmpeg ERROR: {line_str}")
                    elif "warning" in line_str.lower():
                        LOGGER.warning(f"FFmpeg WARNING: {line_str}")

                except Exception as e:
                    LOGGER.debug(f"stderr read error: {e}")
                    break

        except Exception as e:
            LOGGER.error(f"Error monitoring FFmpeg stderr: {e}")

    async def _process_frames(self):
        """Read frames from WebRTC and write to FFmpeg"""
        try:
            LOGGER.info(f"🎥 Starting frame processing for room {self.room_id}")

            while self.is_recording:
                try:
                    # Receive frame from WebRTC
                    frame = await self.video_track.recv()

                    # Convert to YUV420p
                    yuv_frame = frame.to_ndarray(format="yuv420p")

                    # Write to FFmpeg stdin (synchronous write, non-blocking)
                    if self.ffmpeg_process and self.ffmpeg_process.stdin:
                        try:
                            self.ffmpeg_process.stdin.write(yuv_frame.tobytes())
                            # Flush to ensure data is sent
                            self.ffmpeg_process.stdin.flush()
                        except BrokenPipeError:
                            LOGGER.error(
                                "FFmpeg pipe broken - process may have crashed"
                            )
                            break

                        self.frame_count += 1

                        # Log every 10 seconds
                        if self.frame_count % 300 == 0:
                            duration = int(
                                (datetime.utcnow() - self.start_time).total_seconds()
                            )
                            LOGGER.info(
                                f"📹 Processed {self.frame_count} frames ({duration}s)"
                            )

                except asyncio.CancelledError:
                    break
                except Exception as e:
                    LOGGER.error(f"Error processing frame: {e}")
                    await asyncio.sleep(0.01)

            LOGGER.info(f"🛑 Frame processing stopped ({self.frame_count} frames)")

        except Exception as e:
            LOGGER.error(f"Frame processing failed: {e}", exc_info=True)

    async def stop_recording(self):
        """Stop recording and finalize"""
        if not self.is_recording:
            return

        try:
            LOGGER.info(f"🛑 Stopping recording for room {self.room_id}...")

            # Stop recording
            self.is_recording = False

            # Cancel frame task
            if self.recording_task:
                self.recording_task.cancel()
                try:
                    await self.recording_task
                except asyncio.CancelledError:
                    pass

            # Close FFmpeg stdin
            if self.ffmpeg_process and self.ffmpeg_process.stdin:
                try:
                    self.ffmpeg_process.stdin.close()
                    LOGGER.info(f"✅ Closed FFmpeg stdin")
                except Exception as e:
                    LOGGER.warning(f"Error closing FFmpeg stdin: {e}")

            # Wait for FFmpeg to finish (synchronous wait with timeout)
            if self.ffmpeg_process:
                try:
                    # Wait in background thread to not block asyncio
                    await asyncio.get_event_loop().run_in_executor(
                        None, self.ffmpeg_process.wait
                    )
                    LOGGER.info(
                        f"✅ FFmpeg finished (code: {self.ffmpeg_process.returncode})"
                    )
                except Exception as e:
                    LOGGER.warning(f"Error waiting for FFmpeg: {e}")
                    try:
                        self.ffmpeg_process.terminate()
                        self.ffmpeg_process.wait(timeout=5)
                    except:
                        self.ffmpeg_process.kill()

            # Stop segment monitoring
            await hls_segment_service.stop_monitoring_room(self.room_id)

            # Upload to Supabase
            await self._upload_to_supabase_storage()

            # Finalize database
            await self._finalize_recording_entry()

            LOGGER.info(f"🎬 Recording stopped for room {self.room_id}")

        except Exception as e:
            LOGGER.error(f"Error stopping recording: {e}", exc_info=True)

    async def _cleanup_on_error(self):
        """Clean up on error"""
        self.is_recording = False

        if self.recording_task:
            self.recording_task.cancel()

        if self.ffmpeg_process:
            try:
                self.ffmpeg_process.kill()
                await self.ffmpeg_process.wait()
            except:
                pass

    async def _create_recording_entry(self):
        """Create recording entry in database"""
        try:
            recording_data = {
                "session_id": self.session_id,
                "room_id": self.room_id,
                "hls_playlist_url": f"/videos/hls/{self.room_id}/playlist.m3u8",
                "recording_path": str(self.recording_path),
                "session_start": self.start_time.isoformat(),
                "status": "recording",
            }

            result = (
                supabase.table("ambulance_session_recordings")
                .insert(recording_data)
                .execute()
            )

            if result.data:
                LOGGER.info(f"Recording entry created: {result.data[0]['id']}")

        except Exception as e:
            LOGGER.error(f"Failed to create recording entry: {e}")

    async def _finalize_recording_entry(self):
        """Update recording entry"""
        try:
            duration = int((datetime.utcnow() - self.start_time).total_seconds())

            total_size = 0
            if self.mp4_path.exists():
                total_size = self.mp4_path.stat().st_size
            else:
                total_size = sum(
                    f.stat().st_size for f in self.recording_path.glob("segment-*.ts")
                )

            storage_url = await self._upload_to_supabase_storage()

            update_data = {
                "session_end": datetime.utcnow().isoformat(),
                "duration": duration,
                "file_size": total_size,
                "status": "completed",
            }

            if storage_url:
                update_data["storage_url"] = storage_url

            result = (
                supabase.table("ambulance_session_recordings")
                .update(update_data)
                .eq("session_id", self.session_id)
                .execute()
            )

            LOGGER.info(f"✅ Recording entry finalized")

        except Exception as e:
            LOGGER.error(f"Failed to finalize recording: {e}")

    async def _upload_to_supabase_storage(self) -> Optional[str]:
        """Upload MP4 to Supabase Storage"""
        try:
            if not self.mp4_path.exists():
                LOGGER.error(f"MP4 file not found: {self.mp4_path}")
                return None

            file_size_mb = self.mp4_path.stat().st_size / (1024 * 1024)
            LOGGER.info(f"Uploading {file_size_mb:.2f} MB...")

            with open(self.mp4_path, "rb") as f:
                storage_path = f"recordings/room-{self.room_id}/recording.mp4"
                result = SUPABASE_ADMIN.storage.from_("ambulance-recordings").upload(
                    storage_path, f, file_options={"content-type": "video/mp4"}
                )

            public_url = SUPABASE_ADMIN.storage.from_(
                "ambulance-recordings"
            ).get_public_url(storage_path)

            LOGGER.info(f"✅ Upload complete: {public_url}")
            return public_url

        except Exception as e:
            LOGGER.error(f"Failed to upload: {e}")
            return None


class RecordingManager:
    """Manages all active camera room recordings"""

    def __init__(self):
        self.active_recorders: dict[str, SessionRecorder] = {}
        RECORDINGS_BASE_PATH.mkdir(parents=True, exist_ok=True)

    async def start_session_recording(
        self,
        session_id: str,
        room_id: str,
        ambulance_number: str,
        video_track: MediaStreamTrack,
    ) -> SessionRecorder:
        """Start recording for a camera room"""
        if room_id in self.active_recorders:
            LOGGER.warning(f"Recording already active for room {room_id}")
            return self.active_recorders[room_id]

        recorder = SessionRecorder(session_id, room_id, ambulance_number)
        await recorder.start_recording(video_track)

        self.active_recorders[room_id] = recorder
        return recorder

    async def stop_session_recording(self, room_id: str):
        """Stop recording for a camera room"""
        recorder = self.active_recorders.get(room_id)
        if not recorder:
            LOGGER.warning(f"No active recording for room {room_id}")
            return

        await recorder.stop_recording()
        del self.active_recorders[room_id]

    def get_recorder(self, room_id: str) -> Optional[SessionRecorder]:
        """Get active recorder"""
        return self.active_recorders.get(room_id)

    async def stop_all_recordings(self):
        """Stop all recordings"""
        for room_id in list(self.active_recorders.keys()):
            await self.stop_session_recording(room_id)


# Global instance
recording_manager = RecordingManager()
