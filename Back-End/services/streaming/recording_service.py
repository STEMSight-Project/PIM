"""
HLS Recording Service for Ambulance Camera Streams
Manages server-side recording of WebRTC streams to HLS format
"""

import asyncio
import logging
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional
from uuid import UUID

from aiortc import MediaStreamTrack
from aiortc.contrib.media import MediaRecorder
from core.common import supabase, logger
from supabase_settings.create_client import SUPABASE_ADMIN

# Configure logging
LOGGER = logging.getLogger(__name__)

# Recording configuration
RECORDINGS_BASE_PATH = Path("recordings")
HLS_SEGMENT_DURATION = 2  # 2-second segments
HLS_LIST_SIZE = 0  # Keep all segments (0 = unlimited)


class SessionRecorder:
    """Manages HLS recording for a single session"""

    def __init__(self, session_id: str, ambulance_number: str):
        self.session_id = session_id
        self.ambulance_number = ambulance_number
        self.recording_path = RECORDINGS_BASE_PATH / f"session-{session_id}"
        self.temp_video_path = self.recording_path / "recording.mp4"
        self.playlist_path = self.recording_path / "playlist.m3u8"
        self.recorder: Optional[MediaRecorder] = None
        self.hls_process: Optional[subprocess.Popen] = None
        self.is_recording = False
        self.start_time: Optional[datetime] = None
        self.video_track: Optional[MediaStreamTrack] = None

        # Create recording directory
        self.recording_path.mkdir(parents=True, exist_ok=True)

    async def start_recording(self, video_track: MediaStreamTrack):
        """
        Start HLS recording from a WebRTC video track

        Args:
            video_track: WebRTC video track to record
        """
        try:
            self.start_time = datetime.utcnow()
            self.video_track = video_track

            # Step 1: Use aiortc MediaRecorder to save WebRTC stream to MP4
            LOGGER.info(f"Starting MediaRecorder for session {self.session_id}")
            self.recorder = MediaRecorder(str(self.temp_video_path))
            self.recorder.addTrack(video_track)
            await self.recorder.start()

            # Step 2: Start background task to convert MP4 to HLS segments
            asyncio.create_task(self._convert_to_hls())

            self.is_recording = True

            # Create recording entry in database
            await self._create_recording_entry()

            LOGGER.info(f"✅ Recording started for session {self.session_id}")

        except Exception as e:
            LOGGER.error(f"Failed to start recording: {e}")
            raise

    async def _convert_to_hls(self):
        """Background task to convert recording to HLS in real-time"""
        try:
            # Wait a bit for some video data to be written
            await asyncio.sleep(5)

            # FFmpeg command to convert MP4 to HLS in real-time
            ffmpeg_cmd = [
                "ffmpeg",
                "-loglevel",
                "warning",
                "-y",  # Overwrite output files
                "-i",
                str(self.temp_video_path),
                "-c:v",
                "copy",  # Copy video codec (no re-encoding)
                "-f",
                "hls",
                "-hls_time",
                str(HLS_SEGMENT_DURATION),
                "-hls_list_size",
                str(HLS_LIST_SIZE),
                "-hls_flags",
                "append_list+omit_endlist",
                "-hls_segment_filename",
                str(self.recording_path / "segment-%03d.ts"),
                str(self.playlist_path),
            ]

            LOGGER.info(f"Starting HLS conversion for session {self.session_id}")

            self.hls_process = subprocess.Popen(
                ffmpeg_cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            # Keep process running
            stdout, stderr = self.hls_process.communicate()
            if stderr:
                LOGGER.debug(f"FFmpeg HLS output: {stderr.decode()}")

        except Exception as e:
            LOGGER.error(f"HLS conversion error: {e}")

    async def stop_recording(self):
        """Stop HLS recording and finalize playlist"""
        if not self.is_recording:
            LOGGER.warning(f"Recording not active for session {self.session_id}")
            return

        try:
            LOGGER.info(f"Stopping recording for session {self.session_id}")

            # Stop MediaRecorder
            if self.recorder:
                await self.recorder.stop()
                self.recorder = None

            # Stop HLS conversion process
            if self.hls_process:
                try:
                    self.hls_process.terminate()
                    self.hls_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    LOGGER.warning("HLS process didn't stop gracefully, killing")
                    self.hls_process.kill()
                    self.hls_process.wait()

            self.is_recording = False

            # Run final HLS conversion to finalize playlist
            await self._finalize_hls_playlist()

            # Update recording entry in database
            await self._finalize_recording_entry()

            LOGGER.info(f"✅ Recording stopped for session {self.session_id}")

        except Exception as e:
            LOGGER.error(f"Error stopping recording: {e}")
            raise

    async def _finalize_hls_playlist(self):
        """Run final FFmpeg pass to complete HLS playlist"""
        try:
            ffmpeg_cmd = [
                "ffmpeg",
                "-loglevel",
                "warning",
                "-y",
                "-i",
                str(self.temp_video_path),
                "-c:v",
                "copy",
                "-f",
                "hls",
                "-hls_time",
                str(HLS_SEGMENT_DURATION),
                "-hls_list_size",
                "0",  # Include all segments
                "-hls_segment_filename",
                str(self.recording_path / "segment-%03d.ts"),
                str(self.playlist_path),
            ]

            LOGGER.info(f"Finalizing HLS playlist for session {self.session_id}")

            process = subprocess.run(
                ffmpeg_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30
            )

            if process.returncode == 0:
                LOGGER.info(f"HLS playlist finalized successfully")
            else:
                LOGGER.error(f"HLS finalization failed: {process.stderr.decode()}")

        except Exception as e:
            LOGGER.error(f"Error finalizing HLS playlist: {e}")

    async def write_frame(self, frame_data: bytes):
        """
        Deprecated: Frames are now captured via MediaRecorder
        """
        pass  # No longer needed with MediaRecorder approach

    async def _create_recording_entry(self):
        """Create recording entry in database"""
        try:
            recording_data = {
                "session_id": self.session_id,
                "hls_playlist_url": f"/recordings/session-{self.session_id}/playlist.m3u8",
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
                LOGGER.info(
                    f"Recording entry created in database: {result.data[0]['id']}"
                )
            else:
                LOGGER.warning("No data returned from recording insert")

        except Exception as e:
            LOGGER.error(f"Failed to create recording entry: {e}")

    async def _finalize_recording_entry(self):
        """Update recording entry with final information and upload to Supabase Storage"""
        try:
            # Calculate duration
            if self.start_time:
                duration = int((datetime.utcnow() - self.start_time).total_seconds())
            else:
                duration = 0

            # Get file size from MP4 file
            if self.temp_video_path.exists():
                total_size = self.temp_video_path.stat().st_size
            else:
                # Fallback: sum HLS segments if MP4 doesn't exist
                total_size = sum(
                    f.stat().st_size for f in self.recording_path.glob("segment-*.ts")
                )

            # Upload to Supabase Storage
            storage_url = await self._upload_to_supabase_storage()

            # Clean up local HLS files to save disk space (keep MP4)
            if storage_url:
                await self._cleanup_local_hls_files()

            # Update database
            update_data = {
                "session_end": datetime.utcnow().isoformat(),
                "duration": duration,
                "file_size": total_size,
                "status": "completed",
            }

            # Add storage URL if upload succeeded
            if storage_url:
                update_data["storage_url"] = storage_url

            result = (
                supabase.table("ambulance_session_recordings")
                .update(update_data)
                .eq("session_id", self.session_id)
                .execute()
            )

            LOGGER.info(
                f"Recording entry updated: {duration}s, {total_size} bytes, storage_url: {storage_url}"
            )

        except Exception as e:
            LOGGER.error(f"Failed to finalize recording entry: {e}")

    async def _upload_to_supabase_storage(self) -> Optional[str]:
        """
        Upload MP4 recording to Supabase Storage using admin/service_role client.

        Strategy:
        - During live session: HLS segments stored locally for DVR playback
        - After session ends: Only upload the complete MP4 file to Supabase
        - HLS segments can be deleted locally after upload (save disk space)
        """
        try:
            LOGGER.info(
                f"Starting Supabase Storage upload for session {self.session_id}"
            )

            # Upload the MP4 recording file (single file, easier to manage)
            if not self.temp_video_path.exists():
                LOGGER.error(f"MP4 file not found: {self.temp_video_path}")
                return None

            file_size = self.temp_video_path.stat().st_size
            LOGGER.info(
                f"Uploading MP4 file ({file_size / 1024 / 1024:.2f} MB) to Supabase Storage..."
            )

            with open(self.temp_video_path, "rb") as f:
                storage_path = f"recordings/session-{self.session_id}/recording.mp4"
                result = SUPABASE_ADMIN.storage.from_("ambulance-recordings").upload(
                    storage_path, f, file_options={"content-type": "video/mp4"}
                )

            # Get public URL for the MP4 file
            public_url = SUPABASE_ADMIN.storage.from_(
                "ambulance-recordings"
            ).get_public_url(f"recordings/session-{self.session_id}/recording.mp4")

            LOGGER.info(f"✅ Upload complete. Public URL: {public_url}")
            LOGGER.info(
                f"💡 HLS segments can now be deleted locally to save disk space"
            )

            return public_url

        except Exception as e:
            LOGGER.error(f"Failed to upload to Supabase Storage: {e}")
            return None

    async def _cleanup_local_hls_files(self):
        """
        Delete local HLS segments and playlist after successful upload.
        Keep the MP4 file for backup/future use.
        """
        try:
            deleted_count = 0

            # Delete HLS segments
            for segment_file in self.recording_path.glob("segment-*.ts"):
                segment_file.unlink()
                deleted_count += 1

            # Delete playlist
            if self.playlist_path.exists():
                self.playlist_path.unlink()
                deleted_count += 1

            LOGGER.info(f"🗑️ Cleaned up {deleted_count} local HLS files (MP4 retained)")

        except Exception as e:
            LOGGER.error(f"Error cleaning up local HLS files: {e}")

    def get_playlist_url(self) -> str:
        """Get the HLS playlist URL"""
        return f"/recordings/session-{self.session_id}/playlist.m3u8"

    def get_duration(self) -> int:
        """Get current recording duration in seconds"""
        if not self.start_time:
            return 0
        return int((datetime.utcnow() - self.start_time).total_seconds())


class RecordingManager:
    """Manages all active session recordings"""

    def __init__(self):
        self.active_recorders: dict[str, SessionRecorder] = {}
        LOGGER.info("RecordingManager initialized")

        # Ensure recordings directory exists
        RECORDINGS_BASE_PATH.mkdir(parents=True, exist_ok=True)

    async def start_session_recording(
        self, session_id: str, ambulance_number: str, video_track: MediaStreamTrack
    ) -> SessionRecorder:
        """
        Start recording for a session

        Args:
            session_id: Session UUID
            ambulance_number: Ambulance number for logging
            video_track: WebRTC video track to record

        Returns:
            SessionRecorder instance
        """
        if session_id in self.active_recorders:
            LOGGER.warning(f"Recording already active for session {session_id}")
            return self.active_recorders[session_id]

        recorder = SessionRecorder(session_id, ambulance_number)
        await recorder.start_recording(video_track)

        self.active_recorders[session_id] = recorder
        LOGGER.info(f"Started recording for session {session_id}")

        return recorder

    async def stop_session_recording(self, session_id: str):
        """Stop recording for a session"""
        recorder = self.active_recorders.get(session_id)
        if not recorder:
            LOGGER.warning(f"No active recording for session {session_id}")
            return

        await recorder.stop_recording()
        del self.active_recorders[session_id]
        LOGGER.info(f"Stopped recording for session {session_id}")

    def get_recorder(self, session_id: str) -> Optional[SessionRecorder]:
        """Get active recorder for a session"""
        return self.active_recorders.get(session_id)

    async def stop_all_recordings(self):
        """Stop all active recordings (cleanup on shutdown)"""
        LOGGER.info(f"Stopping all {len(self.active_recorders)} active recordings")
        for session_id in list(self.active_recorders.keys()):
            await self.stop_session_recording(session_id)


# Global recording manager instance
recording_manager = RecordingManager()
