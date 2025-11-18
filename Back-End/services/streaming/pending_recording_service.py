"""Background task that retries uploads for recordings stuck in "Pending Upload" state.

A recording is considered pending if:
- `ambulance_session_recordings.storage_url` is NULL
- the entry was created several minutes ago (upload should have finished already)

This service periodically looks for those rows, checks whether the local MP4 file
still exists under the `recordings/` directory, and if it does it pushes the file
up to Supabase storage and updates the database row with the public URL. This
removes the need to manually patch rows through SQL when uploads fail.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Tuple
import subprocess

from core.common import logger
from supabase_settings.create_client import SUPABASE_ADMIN


class PendingRecordingUploader:
    """Automatically retries uploads for orphaned recordings."""

    CHECK_INTERVAL_SECONDS = 120  # Run every 2 minutes
    PENDING_GRACE_MINUTES = 3  # Give new recordings a few minutes to finish
    MAX_BATCH = 5  # Avoid hammering Supabase/storage during recovery
    MAX_UPLOAD_BYTES = 50 * 1024 * 1024  # Supabase free-tier per-object limit (~50MB)
    RECORDINGS_DIR = Path("recordings")

    def __init__(self) -> None:
        self._task: Optional[asyncio.Task] = None

    async def start(self) -> None:
        """Start the periodic background task."""
        if self._task and not self._task.done():
            return

        self._task = asyncio.create_task(self._run_loop())
        logger.info("Pending recording uploader started")

    async def stop(self) -> None:
        """Stop the periodic background task."""
        if not self._task:
            return

        self._task.cancel()
        try:
            await self._task
        except asyncio.CancelledError:
            pass
        finally:
            self._task = None
            logger.info("Pending recording uploader stopped")

    async def _run_loop(self) -> None:
        """Background loop that keeps retrying pending uploads."""
        try:
            while True:
                try:
                    await self.process_pending_recordings()
                except asyncio.CancelledError:
                    raise
                except Exception as exc:  # pragma: no cover - defensive logging
                    logger.error("Pending recording uploader error: %s", exc)

                await asyncio.sleep(self.CHECK_INTERVAL_SECONDS)
        except asyncio.CancelledError:
            logger.info("Pending recording uploader loop cancelled")

    async def process_pending_recordings(self) -> None:
        """Find rows without `storage_url` and retry the upload."""
        cutoff = datetime.utcnow() - timedelta(minutes=self.PENDING_GRACE_MINUTES)
        cutoff_iso = cutoff.isoformat()

        result = (
            SUPABASE_ADMIN.table("ambulance_session_recordings")
            .select(
                "id, session_id, camera_id, recording_path, session_start, session_end, "
                "status, storage_url, created_at"
            )
            .is_("storage_url", "null")
            .lt("created_at", cutoff_iso)
            .limit(self.MAX_BATCH)
            .execute()
        )

        pending = result.data or []
        if not pending:
            return

        logger.warning(
            "Found %d recording(s) stuck in pending upload – attempting recovery",
            len(pending),
        )

        for record in pending:
            try:
                uploaded = await self._attempt_upload(record)
                if uploaded:
                    logger.info(
                        "Recovered recording %s (session %s)",
                        record.get("id"),
                        (record.get("session_id") or "")[:8],
                    )
            except Exception as exc:
                # Keep loop going but note failure – we'll retry on next cycle
                logger.error(
                    "Failed to recover recording %s: %s", record.get("id"), exc
                )

    async def _attempt_upload(self, record: dict) -> bool:
        """Upload the local MP4 for a stale recording and update Supabase."""
        recording_path = record.get("recording_path")
        if not recording_path:
            logger.warning(
                "Recording %s has no recording_path, skipping", record.get("id")
            )
            return False

        mp4_path = self._resolve_mp4_path(str(recording_path))
        if not mp4_path.exists():
            logger.warning(
                "Recording %s missing MP4 at %s", record.get("id"), mp4_path
            )
            return False

        upload_path, temp_artifact = self._prepare_upload_file(mp4_path)
        file_size = upload_path.stat().st_size
        duration = self._estimate_duration(record, file_size)
        session_end = record.get("session_end") or datetime.utcnow().isoformat()

        storage_path = self._build_storage_path(record)
        try:
            public_url = await self._upload_file(upload_path, storage_path)
        finally:
            if temp_artifact and temp_artifact.exists():
                try:
                    temp_artifact.unlink()
                except OSError:
                    logger.warning(
                        "Unable to remove temporary upload file %s", temp_artifact
                    )

        if not public_url:
            return False

        self._update_recording_row(record, public_url, file_size, duration, session_end)
        return True

    def _resolve_mp4_path(self, raw_path: str) -> Path:
        """Return the most likely MP4 path given the stored recording_path string."""

        stored = Path(raw_path)
        candidates = []

        if stored.is_absolute():
            candidates.append(stored)
        else:
            candidates.append(self.RECORDINGS_DIR / stored)
            if stored.parts and stored.parts[0] == "recordings":
                relative_without_root = Path(*stored.parts[1:])
                candidates.append(self.RECORDINGS_DIR / relative_without_root)
                candidates.append(relative_without_root)
            else:
                candidates.append(Path(raw_path))

        for candidate in candidates:
            mp4_candidate = candidate
            if mp4_candidate.is_dir():
                mp4_candidate = mp4_candidate / "recording.mp4"
            elif mp4_candidate.suffix.lower() != ".mp4":
                mp4_candidate = mp4_candidate / "recording.mp4"

            if mp4_candidate.exists():
                return mp4_candidate

        # Fallback even if it doesn't exist yet
        fallback = self.RECORDINGS_DIR / stored
        if fallback.is_dir():
            return fallback / "recording.mp4"
        if fallback.suffix.lower() == ".mp4":
            return fallback
        return fallback / "recording.mp4"

    def _prepare_upload_file(self, mp4_path: Path) -> Tuple[Path, Optional[Path]]:
        """Ensure the upload respects Supabase's size limits by compressing if needed."""

        size = mp4_path.stat().st_size
        if size <= self.MAX_UPLOAD_BYTES:
            return mp4_path, None

        compressed = mp4_path.with_name(f"{mp4_path.stem}_upload.mp4")
        logger.warning(
            "Recording %s is %.2f MB (>%.2f MB limit); compressing before upload",
            mp4_path,
            size / (1024 * 1024),
            self.MAX_UPLOAD_BYTES / (1024 * 1024),
        )

        ffmpeg_cmd = [
            "ffmpeg",
            "-y",
            "-i",
            str(mp4_path),
            "-c:v",
            "libx264",
            "-preset",
            "veryfast",
            "-b:v",
            "850k",
            "-maxrate",
            "900k",
            "-bufsize",
            "1700k",
            "-movflags",
            "+faststart",
            "-an",
            str(compressed),
        ]

        try:
            subprocess.run(ffmpeg_cmd, check=True, capture_output=True)
        except FileNotFoundError:
            logger.error("FFmpeg not found while compressing %s", mp4_path)
            return mp4_path, None
        except subprocess.CalledProcessError as exc:
            stderr = exc.stderr.decode(errors="ignore") if exc.stderr else ""
            logger.error("FFmpeg failed to compress %s: %s", mp4_path, stderr)
            return mp4_path, None

        if not compressed.exists():
            logger.error("Compression output missing for %s", mp4_path)
            return mp4_path, None

        compressed_size = compressed.stat().st_size
        if compressed_size > self.MAX_UPLOAD_BYTES:
            logger.error(
                "Compressed file %s still above limit (%.2f MB)",
                compressed,
                compressed_size / (1024 * 1024),
            )
            return mp4_path, None

        return compressed, compressed

    @staticmethod
    def _estimate_duration(record: dict, file_size: int) -> int:
        """Estimate duration (seconds) using timestamps or file size."""
        start = PendingRecordingUploader._parse_datetime(record.get("session_start"))
        end = PendingRecordingUploader._parse_datetime(record.get("session_end"))
        if start and end and end > start:
            return max(int((end - start).total_seconds()), 1)

        # Fallback: derive from size (~3 MB per 10 seconds based on encoder settings)
        size_mb = file_size / (1024 * 1024)
        return max(int(size_mb / 0.3), 1)

    @staticmethod
    def _parse_datetime(value: Optional[str]) -> Optional[datetime]:
        if not value:
            return None
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None

    @staticmethod
    def _build_storage_path(record: dict) -> str:
        session_id = record.get("session_id") or "unknown-session"
        camera_id = record.get("camera_id") or record.get("id") or "unknown-room"
        return f"recordings/{session_id}/{camera_id}.mp4"

    async def _upload_file(self, mp4_path: Path, storage_path: str) -> Optional[str]:
        try:
            with open(mp4_path, "rb") as file_handle:
                SUPABASE_ADMIN.storage.from_("ambulance-recordings").upload(
                    storage_path,
                    file_handle,
                    file_options={
                        "content-type": "video/mp4",
                        "upsert": "true",
                    },
                )

            public_url = (
                SUPABASE_ADMIN.storage.from_("ambulance-recordings").get_public_url(
                    storage_path
                )
            )
            return public_url
        except Exception as exc:  # pragma: no cover - network call
            logger.error("Pending upload failed for %s: %s", mp4_path, exc)
            return None

    @staticmethod
    def _update_recording_row(
        record: dict,
        storage_url: str,
        file_size: int,
        duration: int,
        session_end: str,
    ) -> None:
        update_data = {
            "storage_url": storage_url,
            "file_size": file_size,
            "duration": duration,
            "session_end": session_end,
            "status": "completed",
            "updated_at": datetime.utcnow().isoformat(),
        }

        SUPABASE_ADMIN.table("ambulance_session_recordings").update(update_data).eq(
            "id", record.get("id")
        ).execute()

        logger.info(
            "Marked recording %s as completed (size %.2f MB)",
            record.get("id"),
            file_size / (1024 * 1024),
        )


pending_recording_uploader = PendingRecordingUploader()
