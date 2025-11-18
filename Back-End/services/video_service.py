"""
Video service for managing ambulance session recordings from Supabase Storage.
Handles retrieval of recorded videos for playback in the frontend.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from core.common import supabase, logger


class VideoService:
    """Service for handling video recording operations."""

    @staticmethod
    async def get_all_recordings() -> List[Dict[str, Any]]:
        """
        Get all ambulance session recordings with public URLs.
        Returns videos from Supabase Storage.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .select(
                    """
                    *,
                    ambulance_streaming_sessions!inner(
                        session_name,
                        ambulance_id,
                        ambulances(ambulance_number, license_plate)
                    )
                """
                )
                .order("created_at", desc=True)
                .execute()
            )

            recordings = []
            for record in result.data or []:
                # Get public URL from Supabase Storage if available
                public_url = None
                if record.get("storage_url"):
                    public_url = record["storage_url"]
                elif record.get("hls_playlist_url"):
                    # Fallback to HLS URL for live sessions
                    public_url = record["hls_playlist_url"]

                recordings.append(
                    {
                        "id": record["id"],
                        "session_id": record["session_id"],
                        "session_name": record.get(
                            "ambulance_streaming_sessions", {}
                        ).get("session_name"),
                        "ambulance_number": record.get(
                            "ambulance_streaming_sessions", {}
                        )
                        .get("ambulances", {})
                        .get("ambulance_number"),
                        "file_path": record.get("storage_url")
                        or record.get("hls_playlist_url"),
                        "public_video_url": public_url,
                        "duration": record.get("duration"),
                        "file_size": record.get("file_size"),
                        "session_start": record.get("session_start"),
                        "session_end": record.get("session_end"),
                        "created_at": record["created_at"],
                        "is_archived": record.get("storage_url")
                        is not None,  # True if uploaded to Supabase
                    }
                )

            return recordings

        except Exception as e:
            logger.error("Error fetching all recordings: %s", e)
            raise

    @staticmethod
    async def get_recording_by_id(recording_id: str) -> Optional[Dict[str, Any]]:
        """
        Get a specific recording by ID with public URL.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .select(
                    """
                    *,
                    ambulance_streaming_sessions!inner(
                        session_name,
                        ambulance_id,
                        ambulances(ambulance_number, license_plate)
                    )
                """
                )
                .eq("id", recording_id)
                .single()
                .execute()
            )

            if not result.data:
                return None

            record = result.data

            # Get public URL from Supabase Storage if available
            public_url = None
            if record.get("storage_url"):
                public_url = record["storage_url"]
            elif record.get("hls_playlist_url"):
                # Fallback to HLS URL for live sessions
                public_url = record["hls_playlist_url"]

            return {
                "id": record["id"],
                "session_id": record["session_id"],
                "session_name": record.get("ambulance_streaming_sessions", {}).get(
                    "session_name"
                ),
                "ambulance_number": record.get("ambulance_streaming_sessions", {})
                .get("ambulances", {})
                .get("ambulance_number"),
                "file_path": record.get("storage_url")
                or record.get("hls_playlist_url"),
                "public_video_url": public_url,
                "duration": record.get("duration"),
                "file_size": record.get("file_size"),
                "session_start": record.get("session_start"),
                "session_end": record.get("session_end"),
                "created_at": record["created_at"],
                "is_archived": record.get("storage_url")
                is not None,  # True if uploaded to Supabase
            }

        except Exception as e:
            logger.error("Error fetching recording %s: %s", recording_id, e)
            raise

    @staticmethod
    async def get_recordings_by_session(session_id: str) -> List[Dict[str, Any]]:
        """
        Get all recordings for a specific ambulance session.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .select("*")
                .eq("session_id", session_id)
                .order("created_at", desc=True)
                .execute()
            )

            recordings = []
            for record in result.data or []:
                recordings.append(
                    {
                        "id": record["id"],
                        "session_id": record["session_id"],
                        "session_name": None,
                        "ambulance_number": None,
                        "camera_id": record.get("camera_id"),
                        "recording_path": record.get("recording_path"),
                        "file_path": record.get("storage_url"),
                        "public_video_url": record.get("storage_url"),
                        "duration": record.get("duration"),
                        "file_size": record.get("file_size"),
                        "session_start": record.get("session_start"),
                        "session_end": record.get("session_end"),
                        "created_at": record["created_at"],
                        "is_archived": record.get("storage_url") is not None,
                    }
                )

            return recordings

        except Exception as e:
            logger.error("Error fetching recordings for session %s: %s", session_id, e)
            raise

    @staticmethod
    async def get_recordings_by_ambulance(ambulance_id: str) -> List[Dict[str, Any]]:
        """
        Get all recordings for a specific ambulance.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .select(
                    """
                    *,
                    ambulance_streaming_sessions!inner(
                        session_name,
                        ambulance_id,
                        ambulances(ambulance_number, license_plate)
                    )
                """
                )
                .eq("ambulance_streaming_sessions.ambulance_id", ambulance_id)
                .order("created_at", desc=True)
                .execute()
            )

            recordings = []
            for record in result.data or []:
                # Get public URL from Supabase Storage if available
                public_url = None
                if record.get("storage_url"):
                    public_url = record["storage_url"]
                elif record.get("hls_playlist_url"):
                    # Fallback to HLS URL for live sessions
                    public_url = record["hls_playlist_url"]

                recordings.append(
                    {
                        "id": record["id"],
                        "session_id": record["session_id"],
                        "session_name": record.get(
                            "ambulance_streaming_sessions", {}
                        ).get("session_name"),
                        "ambulance_number": record.get(
                            "ambulance_streaming_sessions", {}
                        )
                        .get("ambulances", {})
                        .get("ambulance_number"),
                        "file_path": record.get("storage_url")
                        or record.get("hls_playlist_url"),
                        "public_video_url": public_url,
                        "duration": record.get("duration"),
                        "file_size": record.get("file_size"),
                        "session_start": record.get("session_start"),
                        "session_end": record.get("session_end"),
                        "created_at": record["created_at"],
                        "is_archived": record.get("storage_url")
                        is not None,  # True if uploaded to Supabase
                    }
                )

            return recordings

        except Exception as e:
            logger.error(
                "Error fetching recordings for ambulance %s: %s", ambulance_id, e
            )
            raise

    @staticmethod
    async def get_archived_recordings() -> List[Dict[str, Any]]:
        """
        Get only archived recordings (uploaded to Supabase Storage).
        Excludes live/ongoing recordings that only have HLS URLs.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .select(
                    """
                    *,
                    ambulance_streaming_sessions!inner(
                        session_name,
                        ambulance_id,
                        ambulances(ambulance_number, license_plate)
                    )
                """
                )
                .not_.is_("storage_url", "null")  # Only records with storage_url
                .order("created_at", desc=True)
                .execute()
            )

            recordings = []
            for record in result.data or []:
                recordings.append(
                    {
                        "id": record["id"],
                        "session_id": record["session_id"],
                        "session_name": record.get(
                            "ambulance_streaming_sessions", {}
                        ).get("session_name"),
                        "ambulance_number": record.get(
                            "ambulance_streaming_sessions", {}
                        )
                        .get("ambulances", {})
                        .get("ambulance_number"),
                        "file_path": record.get("storage_url"),
                        "public_video_url": record.get("storage_url"),
                        "duration": record.get("duration"),
                        "file_size": record.get("file_size"),
                        "session_start": record.get("session_start"),
                        "session_end": record.get("session_end"),
                        "created_at": record["created_at"],
                        "is_archived": True,
                    }
                )

            return recordings

        except Exception as e:
            logger.error("Error fetching archived recordings: %s", e)
            raise

    @staticmethod
    async def delete_recording(recording_id: str) -> bool:
        """
        Delete a recording from the database.
        Note: This does NOT delete the file from Supabase Storage.
        For storage deletion, use Supabase Storage admin operations.
        """
        try:
            result = (
                supabase.table("ambulance_session_recordings")
                .delete()
                .eq("id", recording_id)
                .execute()
            )

            return True

        except Exception as e:
            logger.error("Error deleting recording %s: %s", recording_id, e)
            raise
