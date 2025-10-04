"""
Database service for ambulance streaming operations.
Updated to work with ambulance-based schema: ambulances, cameras, ambulance_streaming_sessions, camera_streaming_rooms.
"""

from typing import Optional, List, Dict, Any
from core.common import supabase, logger
from core.timestamps import get_current_timestamp


class StreamingDatabaseService:
    """Service for handling all ambulance streaming-related database operations."""

    @staticmethod
    async def get_or_create_ambulance_session(
        ambulance_id: str, session_type: str = "emergency"
    ) -> Dict[str, Any]:
        """Get existing ACTIVE session for ambulance or create new one."""
        try:
            # Check if an ACTIVE session already exists for this ambulance
            session_result = (
                supabase.table("ambulance_streaming_sessions")
                .select("*")
                .eq("ambulance_id", ambulance_id)
                .eq("is_active", True)
                .execute()
            )

            if session_result.data:
                logger.info(
                    "Using existing active session for ambulance %s", ambulance_id
                )
                return session_result.data[0]

            # Check if there are any non-ended sessions (should not create new ones)
            all_sessions_result = (
                supabase.table("ambulance_streaming_sessions")
                .select("*")
                .eq("ambulance_id", ambulance_id)
                .eq("is_active", True)
                .execute()
            )

            if all_sessions_result.data:
                # There's a non-ended session, return the most recent one
                existing_session = all_sessions_result.data[0]
                logger.warning(
                    "Ambulance %s has active session %s. Not creating new session.",
                    ambulance_id,
                    existing_session["id"],
                )
                return existing_session

            # Create new session only if no active sessions exist
            session_result = (
                supabase.table("ambulance_streaming_sessions")
                .insert(
                    {
                        "ambulance_id": ambulance_id,
                        "session_type": session_type,
                        "is_active": True,
                    }
                )
                .execute()
            )

            if not session_result.data:
                raise Exception("Failed to create ambulance streaming session")

            logger.info("Created new session for ambulance %s", ambulance_id)
            return session_result.data[0]

        except Exception as e:
            logger.error("Error managing session for ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def create_camera_room(
        session_id: str,
        camera_id: str,
        room_id: str,
        device_name: str = "Camera Device",
    ) -> Dict[str, Any]:
        """Create a new camera room entry in the database."""
        try:
            # Verify camera exists
            camera_result = (
                supabase.table("cameras").select("id").eq("id", camera_id).execute()
            )
            if not camera_result.data:
                raise Exception(f"Camera {camera_id} not found")

            room_result = (
                supabase.table("camera_streaming_rooms")
                .insert(
                    {
                        "session_id": session_id,
                        "camera_id": camera_id,
                        "room_id": room_id,
                        "device_name": device_name,
                        "connected": True,
                    }
                )
                .execute()
            )

            if not room_result.data:
                raise Exception("Failed to create camera room entry")

            logger.info("Created camera room %s for session %s", room_id, session_id)
            return room_result.data[0]

        except Exception as e:
            logger.error("Error creating camera room %s: %s", room_id, e)
            raise

    @staticmethod
    async def get_camera_room_by_id(room_id: str) -> Optional[Dict[str, Any]]:
        """Get existing camera room from database by room_id."""
        try:
            room_result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .eq("room_id", room_id)
                .execute()
            )

            if room_result.data:
                logger.info("Found existing camera room %s in database", room_id)
                return room_result.data[0]

            return None

        except Exception as e:
            logger.error("Error getting camera room %s: %s", room_id, e)
            raise

    @staticmethod
    async def update_camera_room_status(
        room_db_id: str, connected: bool, ended_at: Optional[str] = None
    ) -> None:
        """Update camera room connection status in database."""
        try:
            update_data = {"connected": connected}

            if ended_at:
                update_data["connection_ended_at"] = ended_at
            elif not connected:
                update_data["connection_ended_at"] = "now()"

            supabase.table("camera_streaming_rooms").update(update_data).eq(
                "id", room_db_id
            ).execute()

            logger.info(
                "Updated camera room %s status to connected=%s", room_db_id, connected
            )

        except Exception as e:
            logger.error("Error updating camera room %s status: %s", room_db_id, e)
            raise

    @staticmethod
    async def end_ambulance_session(session_id: str) -> Dict[str, Any]:
        """Properly end an ambulance streaming session and all its camera rooms."""
        try:
            # First, disconnect all camera rooms in this session
            rooms_result = (
                supabase.table("camera_streaming_rooms")
                .update({"connected": False, "connection_ended_at": "now()"})
                .eq("session_id", session_id)
                .eq("connected", True)
                .execute()
            )

            disconnected_rooms = len(rooms_result.data or [])

            # Then end the session
            session_result = (
                supabase.table("ambulance_streaming_sessions")
                .update({"is_active": False, "ended_at": "now()"})
                .eq("id", session_id)
                .execute()
            )

            if not session_result.data:
                raise Exception(f"Ambulance session {session_id} not found")

            logger.info(
                "Ended ambulance session %s and disconnected %d camera rooms",
                session_id,
                disconnected_rooms,
            )
            return session_result.data[0]

        except Exception as e:
            logger.error("Error ending ambulance session %s: %s", session_id, e)
            raise

    @staticmethod
    async def update_ambulance_session_status(
        session_id: str, is_active: bool
    ) -> Dict[str, Any]:
        """Update ambulance streaming session status."""
        try:
            update_data = {"is_active": is_active}

            # Auto-set ended_at only if status is inactive
            if not is_active:
                update_data["ended_at"] = "now()"

                # If ending session, also disconnect all its camera rooms
                supabase.table("camera_streaming_rooms").update(
                    {"connected": False, "connection_ended_at": "now()"}
                ).eq("session_id", session_id).eq("connected", True).execute()

            result = (
                supabase.table("ambulance_streaming_sessions")
                .update(update_data)
                .eq("id", session_id)
                .execute()
            )

            if not result.data:
                raise Exception(f"Ambulance session {session_id} not found")

            logger.info(
                "Updated ambulance session %s active status to %s",
                session_id,
                is_active,
            )
            return result.data[0]

        except Exception as e:
            logger.error("Error updating ambulance session %s: %s", session_id, e)
            raise

    @staticmethod
    async def get_ambulance_sessions(
        ambulance_id: Optional[str] = None,
        is_active: Optional[bool] = None,
        limit: int = 50,
    ) -> List[Dict[str, Any]]:
        """Get ambulance streaming sessions with optional filters (alias for compatibility)."""
        return await StreamingDatabaseService.get_all_ambulance_sessions(
            ambulance_id, is_active, limit
        )

    @staticmethod
    async def create_ambulance_session(
        ambulance_id: str, session_type: str = "standard_streaming"
    ) -> Dict[str, Any]:
        """Create a new ambulance streaming session."""
        try:
            session_result = (
                supabase.table("ambulance_streaming_sessions")
                .insert(
                    {
                        "ambulance_id": ambulance_id,
                        "session_type": session_type,
                        "is_active": True,
                    }
                )
                .execute()
            )

            if not session_result.data:
                raise Exception("Failed to create ambulance streaming session")

            logger.info("Created new session for ambulance %s", ambulance_id)
            return session_result.data[0]

        except Exception as e:
            logger.error("Error creating session for ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def get_camera_rooms_by_session(session_id: str) -> List[Dict[str, Any]]:
        """Get all camera rooms for a specific session."""
        try:
            result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .eq("session_id", session_id)
                .execute()
            )

            return result.data or []

        except Exception as e:
            logger.error(
                "Error fetching camera rooms for session %s: %s", session_id, e
            )
            raise

    @staticmethod
    async def get_all_camera_rooms() -> List[Dict[str, Any]]:
        """Get all camera streaming rooms."""
        try:
            result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .execute()
            )

            return result.data or []

        except Exception as e:
            logger.error("Error fetching all camera rooms: %s", e)
            raise

    @staticmethod
    async def get_camera_rooms_by_camera_id(camera_id: str) -> List[Dict[str, Any]]:
        """Get all camera streaming rooms for a specific camera (including disconnected ones for reconnection)."""
        try:
            result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .eq("camera_id", camera_id)
                # Remove connected=True filter to allow reconnection to existing rooms
                .order(
                    "connected", desc=True
                )  # Connected rooms first, then disconnected
                .order("created_at", desc=True)  # Most recent first within each group
                .execute()
            )

            return result.data or []

        except Exception as e:
            logger.error("Error fetching camera rooms for camera %s: %s", camera_id, e)
            raise

    @staticmethod
    async def get_camera_rooms_by_session_id(session_id: str) -> List[Dict[str, Any]]:
        """Get all camera streaming rooms for a specific session."""
        try:
            result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .eq("session_id", session_id)
                .order("created_at", desc=True)
                .execute()
            )

            return result.data or []

        except Exception as e:
            logger.error(
                "Error fetching camera rooms for session %s: %s", session_id, e
            )
            raise

    @staticmethod
    async def get_all_ambulance_sessions(
        ambulance_id: Optional[str] = None,
        is_active: Optional[bool] = None,
        limit: int = 50,
    ) -> List[Dict[str, Any]]:
        """Get ambulance streaming sessions with optional filters."""
        try:
            query = supabase.table("ambulance_streaming_sessions").select(
                "*, camera_streaming_rooms(*, cameras(*))"
            )

            if ambulance_id:
                query = query.eq("ambulance_id", ambulance_id)
            if is_active is not None:
                query = query.eq("is_active", is_active)

            result = query.order("started_at", desc=True).limit(limit).execute()
            return result.data or []

        except Exception as e:
            logger.error("Error fetching ambulance sessions: %s", e)
            raise

    @staticmethod
    async def get_ambulance_session_by_id(session_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific ambulance session with its camera rooms."""
        try:
            result = (
                supabase.table("ambulance_streaming_sessions")
                .select("*, camera_streaming_rooms(*, cameras(*))")
                .eq("id", session_id)
                .execute()
            )

            return result.data[0] if result.data else None

        except Exception as e:
            logger.error("Error fetching ambulance session %s: %s", session_id, e)
            raise

    @staticmethod
    async def get_ambulances_streaming_status() -> List[Dict[str, Any]]:
        """Get streaming status for all ambulances with active sessions."""
        try:
            # Get all ambulances with their active streaming sessions
            result = (
                supabase.table("ambulances")
                .select(
                    """
                id, ambulance_number, status,
                ambulance_streaming_sessions!inner(
                    id, session_type, started_at, is_active,
                    camera_streaming_rooms(*, cameras(*))
                )
                """
                )
                .eq("ambulance_streaming_sessions.is_active", True)
                .execute()
            )

            ambulances_status = []
            for ambulance in result.data or []:
                sessions = ambulance.get("ambulance_streaming_sessions", [])
                print(ambulance)
                for session in sessions:
                    camera_rooms = session.get("camera_streaming_rooms", [])
                    print(camera_rooms)
                    ambulances_status.append(
                        {
                            "ambulance_id": ambulance["id"],
                            "ambulance_number": ambulance.get(
                                "ambulance_number", "unknown"
                            ),
                            "status": ambulance.get("status", "unknown"),
                            "session_id": session["id"],
                            "session_type": session["session_type"],
                            "session_started": session["started_at"],
                            "is_active": session["is_active"],
                            "total_camera_rooms": len(camera_rooms),
                            "connected_camera_rooms": len(
                                [r for r in camera_rooms if r["connected"]]
                            ),
                            "camera_rooms": [
                                {
                                    "room_id": r["room_id"],
                                    "camera_id": r["camera_id"],
                                    "camera_name": (
                                        r["cameras"]["camera_name"]
                                        if r["cameras"]
                                        else "Unknown"
                                    ),
                                    "connected": r["connected"],
                                    "connection_started_at": r.get(
                                        "connection_started_at"
                                    ),
                                }
                                for r in camera_rooms
                            ],
                        }
                    )
            print(ambulances_status)
            return ambulances_status

        except Exception as e:
            logger.error("Error fetching ambulances streaming status: %s", e)
            raise

    @staticmethod
    async def cleanup_inactive_camera_rooms(
        inactive_threshold_minutes: int = 30,
    ) -> int:
        """Clean up camera rooms that have been inactive for too long."""
        try:
            # Calculate cutoff time (using Python datetime instead of SQL interval)
            from datetime import datetime, timedelta

            cutoff_time = datetime.now() - timedelta(minutes=inactive_threshold_minutes)
            cutoff_time_str = cutoff_time.isoformat()

            # Update camera rooms that haven't had activity recently
            result = (
                supabase.table("camera_streaming_rooms")
                .update({"connected": False, "connection_ended_at": "now()"})
                .lt("connection_started_at", cutoff_time_str)
                .eq("connected", True)
                .execute()
            )

            cleaned_count = len(result.data or [])

            if cleaned_count > 0:
                logger.info("Cleaned up %d inactive camera rooms", cleaned_count)

            return cleaned_count

        except Exception as e:
            logger.error("Error during camera room cleanup: %s", e)
            raise

    @staticmethod
    async def get_ambulance_cameras(ambulance_id: str) -> List[Dict[str, Any]]:
        """Get all cameras for a specific ambulance."""
        try:
            result = (
                supabase.table("cameras")
                .select("*")
                .eq("ambulance_id", ambulance_id)
                .execute()
            )
            return result.data or []
        except Exception as e:
            logger.error("Error fetching cameras for ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def get_camera_by_id(camera_id: str) -> Optional[Dict[str, Any]]:
        """Get camera details by ID."""
        try:
            result = (
                supabase.table("cameras")
                .select("*, ambulances(*)")
                .eq("id", camera_id)
                .execute()
            )
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error("Error fetching camera %s: %s", camera_id, e)
            raise
