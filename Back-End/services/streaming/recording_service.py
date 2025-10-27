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
    """Manages HLS recording for a single camera room"""

    def __init__(self, session_id: str, room_id: str, ambulance_number: str):
        self.session_id = session_id
        self.room_id = room_id
        self.ambulance_number = ambulance_number
        # Use room_id for unique recording paths (one recording per camera)
        self.recording_path = RECORDINGS_BASE_PATH / f"room-{room_id}"
        self.mp4_path = self.recording_path / "recording.mp4"
        self.recorder: Optional[MediaRecorder] = None
        self.is_recording = False
        self.start_time: Optional[datetime] = None
        self.video_track: Optional[MediaStreamTrack] = None

        # Create recording directory
        self.recording_path.mkdir(parents=True, exist_ok=True)

    async def start_recording(self, video_track: MediaStreamTrack):
        """
        Start recording from a WebRTC video track

        Strategy:
        1. Record to MP4 using MediaRecorder
        2. Upload to Supabase when recording stops
        3. Keep local MP4 for playback

        Live viewing: WebRTC viewer connections
        Playback: MP4 file (both local and Supabase)

        Args:
            video_track: WebRTC video track to record
        """
        try:
            self.start_time = datetime.utcnow()
            self.video_track = video_track

            # Record directly to MP4
            self.recorder = MediaRecorder(str(self.mp4_path))
            self.recorder.addTrack(video_track)
            await self.recorder.start()

            self.is_recording = True

            LOGGER.info(
                f"🎥 Recording started for room {self.room_id} → {self.mp4_path}"
            )

            # Create recording entry in database
            await self._create_recording_entry()

        except Exception as e:
            LOGGER.error(f"Failed to start recording: {e}")
            raise

    async def _start_hls_from_mp4(self):
        """
        Start FFmpeg to create HLS segments from ongoing MP4 recording
        Uses segment muxer to create HLS while MediaRecorder is writing
        """
        try:
            ffmpeg_cmd = [
                "ffmpeg",
                "-re",  # Read at native framerate
                "-i",
                str(self.mp4_path),  # Input from MediaRecorder
                "-c",
                "copy",  # Copy codec (no re-encode)
                "-f",
                "segment",  # Segment muxer
                "-segment_time",
                "4",  # 4-second segments
                "-segment_format",
                "mpegts",  # MPEG-TS format for HLS
                "-segment_list",
                str(self.playlist_path),  # Create playlist
                "-segment_list_flags",
                "+live",  # Live streaming flags
                "-segment_list_type",
                "m3u8",  # M3U8 playlist format
                str(self.recording_path / "segment-%03d.ts"),
            ]

            LOGGER.info(f"Starting FFmpeg HLS segmentation for room {self.room_id}")

            # Start FFmpeg process
            self.ffmpeg_process = await asyncio.create_subprocess_exec(
                *ffmpeg_cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )

            # Monitor FFmpeg in background
            asyncio.create_task(self._monitor_ffmpeg())

            LOGGER.info(f"✅ FFmpeg HLS segmentation started for room {self.room_id}")

        except Exception as e:
            LOGGER.error(f"Failed to start HLS segmentation: {e}")
            raise

    async def stop_recording(self):
        """
        Stop recording and upload MP4

        Flow:
        1. Stop MediaRecorder (MP4 complete)
        2. Upload MP4 to Supabase Storage
        3. Keep local MP4 for playback
        4. Update database
        """
        if not self.is_recording:
            LOGGER.warning(f"No recording to stop for room {self.room_id}")
            return

        try:
            # Step 1: Stop MediaRecorder
            if self.recorder:
                await self.recorder.stop()
                self.recorder = None
                LOGGER.info(f"✅ MediaRecorder stopped for room {self.room_id}")

            # Small delay to ensure file write complete
            await asyncio.sleep(1)

            # Step 2: Upload MP4 to Supabase
            LOGGER.info(f"☁️ Uploading MP4 to Supabase for room {self.room_id}...")
            await self._upload_to_supabase_storage()

            # Step 3: Update database
            await self._finalize_recording_entry()

            # Step 4: Keep MP4 locally for playback (don't delete)

            self.is_recording = False
            LOGGER.info(f"🎬 Recording stopped and uploaded for room {self.room_id}")

        except Exception as e:
            LOGGER.error(f"Error stopping recording: {e}")
            raise

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
                "room_id": self.room_id,
                "hls_playlist_url": f"/videos/mp4/{self.room_id}/recording.mp4",  # MP4 URL for playback
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
                    f"Recording entry created in database for room {self.room_id}: {result.data[0]['id']}"
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
            if self.mp4_path.exists():
                total_size = self.mp4_path.stat().st_size
            else:
                # Fallback: sum HLS segments if MP4 doesn't exist
                total_size = sum(
                    f.stat().st_size for f in self.recording_path.glob("segment-*.ts")
                )

            # Upload to Supabase Storage
            storage_url = await self._upload_to_supabase_storage()

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

            # Clean up local files after successful upload AND database update
            if storage_url and result.data:
                LOGGER.info(
                    f"Recording uploaded successfully, cleaning up local files for session {self.session_id}"
                )
                await self._cleanup_local_files()
                LOGGER.info(f"✅ Local files deleted for session {self.session_id}")

        except Exception as e:
            LOGGER.error(f"Failed to finalize recording entry: {e}")

    async def _upload_to_supabase_storage(self) -> Optional[str]:
        """
        Upload MP4 recording to Supabase Storage

        Returns:
            Public URL of uploaded file, or None if upload failed
        """
        try:
            # Upload the MP4 recording file
            if not self.mp4_path.exists():
                LOGGER.error(f"MP4 file not found: {self.mp4_path}")
                return None

            LOGGER.info(
                f"Uploading {self.mp4_path.stat().st_size / 1024 / 1024:.2f} MB to Supabase Storage..."
            )

            with open(self.mp4_path, "rb") as f:
                storage_path = f"recordings/room-{self.room_id}/recording.mp4"
                result = SUPABASE_ADMIN.storage.from_("ambulance-recordings").upload(
                    storage_path, f, file_options={"content-type": "video/mp4"}
                )

            # Get public URL for the MP4 file
            public_url = SUPABASE_ADMIN.storage.from_(
                "ambulance-recordings"
            ).get_public_url(f"recordings/room-{self.room_id}/recording.mp4")

            LOGGER.info(f"✅ Upload complete: {public_url}")
            return public_url

        except Exception as e:
            LOGGER.error(f"Failed to upload to Supabase Storage: {e}")
            LOGGER.warning(
                f"Recording files will be kept locally at: {self.recording_path}"
            )
            return None

    def get_mp4_url(self) -> str:
        """Get the MP4 video URL for playback"""
        return f"/videos/mp4/{self.room_id}/recording.mp4"

    def get_duration(self) -> int:
        """Get current recording duration in seconds"""
        if not self.start_time:
            return 0
        return int((datetime.utcnow() - self.start_time).total_seconds())

    def is_mp4_ready(self) -> bool:
        """Check if MP4 file is available for playback"""
        return self.mp4_path.exists() and self.mp4_path.stat().st_size > 0


class RecordingManager:
    """Manages all active camera room recordings"""

    def __init__(self):
        # Use room_id as key since each camera gets its own recording
        self.active_recorders: dict[str, SessionRecorder] = {}

        # Ensure recordings directory exists
        RECORDINGS_BASE_PATH.mkdir(parents=True, exist_ok=True)

    async def start_session_recording(
        self,
        session_id: str,
        room_id: str,
        ambulance_number: str,
        video_track: MediaStreamTrack,
    ) -> SessionRecorder:
        """
        Start recording for a camera room

        Args:
            session_id: Session UUID (ambulance session)
            room_id: Room ID (specific camera)
            ambulance_number: Ambulance number for logging
            video_track: WebRTC video track to record

        Returns:
            SessionRecorder instance
        """
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
        """Get active recorder for a camera room"""
        return self.active_recorders.get(room_id)

    async def stop_all_recordings(self):
        """Stop all active recordings (cleanup on shutdown)"""
        for room_id in list(self.active_recorders.keys()):
            await self.stop_session_recording(room_id)


# Global recording manager instance
recording_manager = RecordingManager()
