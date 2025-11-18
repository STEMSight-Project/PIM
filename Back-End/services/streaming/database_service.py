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
        """
        Get existing ACTIVE session for ambulance or create new one.

        IMPORTANT: This method NEVER reactivates inactive sessions.
        When an ambulance reconnects after session timeout, a NEW session is created.
        This ensures clean session lifecycle and prevents data inconsistencies.

        Logic:
        1. Query for active session (is_active=True)
        2. If found: return existing active session
        3. If not found: create NEW session (inactive sessions are ignored)
        """
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
                    "Using existing active session %s for ambulance %s",
                    session_result.data[0]["id"],
                    ambulance_id,
                )
                return session_result.data[0]

            # No active session found - create NEW session
            # NOTE: Inactive sessions remain in database for historical records
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

            logger.info(
                "Created new session %s for ambulance %s (inactive sessions ignored)",
                session_result.data[0]["id"],
                ambulance_id,
            )
            return session_result.data[0]

        except Exception as e:
            logger.error("Error managing session for ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def create_camera_room(
        session_id: str,
        camera_id: str,
        room_name: str,
        device_name: str = "Camera Device",
    ) -> Dict[str, Any]:
        """
        Create a new camera room entry in the database.

        Args:
            session_id: UUID of the ambulance session
            camera_id: UUID of the camera
            room_name: Display name for the room (e.g., "AMB-001-ROOM-001")
            device_name: Name of the device

        Returns:
            Created room record with id (UUID), room_name, and other fields
        """
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
                        "room_name": room_name,
                        "device_name": device_name,
                        "connected": True,
                    }
                )
                .execute()
            )

            if not room_result.data:
                raise Exception("Failed to create camera room entry")

            logger.info("Created camera room %s for session %s", room_name, session_id)
            return room_result.data[0]

        except Exception as e:
            logger.error("Error creating camera room %s: %s", room_name, e)
            raise

    @staticmethod
    async def get_camera_room_by_id(room_name: str) -> Optional[Dict[str, Any]]:
        """
        Get existing camera room from database by room_name.
        Only returns rooms that belong to an ACTIVE session.

        Args:
            room_name: Display name of the room (e.g., "AMB-001-ROOM-001")

        Returns:
            Room record with id (UUID), room_name, and joined session/camera data
        """
        try:
            room_result = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*), ambulance_streaming_sessions!inner(is_active)")
                .eq("room_name", room_name)
                .eq("ambulance_streaming_sessions.is_active", True)
                .order("created_at", desc=True)
                .limit(1)
                .execute()
            )

            if room_result.data:
                logger.info(
                    "Found existing camera room %s in active session", room_name
                )
                return room_result.data[0]

            logger.info("No active camera room found for %s", room_name)
            return None

        except Exception as e:
            logger.error("Error getting camera room %s: %s", room_name, e)
            raise

    @staticmethod
    async def get_camera_room_by_room_id(room_name: str) -> Optional[Dict[str, Any]]:
        """
        Get existing camera room from database by room_name (alias for backward compatibility).

        Args:
            room_name: Display name of the room (e.g., "AMB-001-ROOM-001")

        Returns:
            Room record with id (UUID), room_name, and joined session/camera data
        """
        return await StreamingDatabaseService.get_camera_room_by_id(room_name)

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
    async def has_active_cameras(session_id: str) -> bool:
        """Check if a session has any active (connected) camera rooms."""
        try:
            result = (
                supabase.table("camera_streaming_rooms")
                .select("id")
                .eq("session_id", session_id)
                .eq("connected", True)
                .execute()
            )

            return len(result.data or []) > 0

        except Exception as e:
            logger.error(
                "Error checking active cameras for session %s: %s", session_id, e
            )
            raise

    @staticmethod
    async def get_all_camera_rooms(
        connected: Optional[bool] = None, limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get all camera streaming rooms with optional filters."""
        try:
            query = supabase.table("camera_streaming_rooms").select("*, cameras(*)")

            if connected is not None:
                query = query.eq("connected", connected)

            query = query.order("created_at", desc=True).limit(limit)
            result = query.execute()

            return result.data or []

        except Exception as e:
            logger.error("Error fetching all camera rooms: %s", e)
            raise

    @staticmethod
    async def get_camera_rooms_by_ambulance_id(
        ambulance_id: str, connected: Optional[bool] = None, limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get camera streaming rooms for a specific ambulance."""
        try:
            # First get active sessions for the ambulance
            sessions_result = (
                supabase.table("ambulance_streaming_sessions")
                .select("id")
                .eq("ambulance_id", ambulance_id)
                .eq("is_active", True)
                .execute()
            )

            if not sessions_result.data:
                return []

            session_ids = [session["id"] for session in sessions_result.data]

            # Get camera rooms for these sessions
            query = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .in_("session_id", session_ids)
            )

            if connected is not None:
                query = query.eq("connected", connected)

            query = query.order("created_at", desc=True).limit(limit)
            result = query.execute()

            return result.data or []

        except Exception as e:
            logger.error(
                "Error fetching camera rooms for ambulance %s: %s", ambulance_id, e
            )
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
    async def get_camera_rooms_by_session_id(
        session_id: str, connected: Optional[bool] = None, limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get all camera streaming rooms for a specific session."""
        try:
            query = (
                supabase.table("camera_streaming_rooms")
                .select("*, cameras(*)")
                .eq("session_id", session_id)
            )

            if connected is not None:
                query = query.eq("connected", connected)

            query = query.order("created_at", desc=True).limit(limit)
            result = query.execute()

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
    async def get_ambulance_sessions_paginated(
        ambulance_id: Optional[str] = None,
        is_active: Optional[bool] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> List[Dict[str, Any]]:
        """Get ambulance streaming sessions with pagination."""
        try:
            query = supabase.table("ambulance_streaming_sessions").select(
                "*, camera_streaming_rooms(*, cameras(*))"
            )

            if ambulance_id:
                query = query.eq("ambulance_id", ambulance_id)
            if is_active is not None:
                query = query.eq("is_active", is_active)

            result = (
                query.order("started_at", desc=True)
                .range(offset, offset + limit - 1)
                .execute()
            )
            return result.data or []

        except Exception as e:
            logger.error("Error fetching paginated ambulance sessions: %s", e)
            raise

    @staticmethod
    async def get_ambulance_sessions_count(
        ambulance_id: Optional[str] = None,
        is_active: Optional[bool] = None,
    ) -> int:
        """Get total count of ambulance sessions matching filters."""
        try:
            query = supabase.table("ambulance_streaming_sessions").select(
                "id", count="exact"
            )

            if ambulance_id:
                query = query.eq("ambulance_id", ambulance_id)
            if is_active is not None:
                query = query.eq("is_active", is_active)

            result = query.execute()
            return result.count or 0

        except Exception as e:
            logger.error("Error getting ambulance sessions count: %s", e)
            raise

    @staticmethod
    async def get_ambulances_streaming_status() -> List[Dict[str, Any]]:
        """Get streaming status for all ambulances (with or without active sessions)."""
        try:
            # Get ALL ambulances first
            ambulances_result = (
                supabase.table("ambulances")
                .select("id, ambulance_number, status")
                .execute()
            )

            ambulances_status = []

            for ambulance in ambulances_result.data or []:
                ambulance_id = ambulance["id"]

                # Get active sessions for this ambulance
                sessions_result = (
                    supabase.table("ambulance_streaming_sessions")
                    .select(
                        """
                        id, session_type, started_at, is_active,
                        camera_streaming_rooms(*, cameras(*))
                        """
                    )
                    .eq("ambulance_id", ambulance_id)
                    .eq("is_active", True)
                    .execute()
                )

                sessions = sessions_result.data or []

                if sessions:
                    # Ambulance has active sessions - add one entry per session
                    for session in sessions:
                        camera_rooms = session.get("camera_streaming_rooms", [])
                        ambulances_status.append(
                            {
                                "ambulance_id": ambulance_id,
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
                                        "id": r["id"],
                                        "room_name": r["room_name"],
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
                else:
                    # Ambulance has no active sessions - still add it with empty session data
                    ambulances_status.append(
                        {
                            "ambulance_id": ambulance_id,
                            "ambulance_number": ambulance.get(
                                "ambulance_number", "unknown"
                            ),
                            "status": ambulance.get("status", "unknown"),
                            "session_id": None,
                            "session_type": None,
                            "session_started": None,
                            "is_active": False,
                            "total_camera_rooms": 0,
                            "connected_camera_rooms": 0,
                            "camera_rooms": [],
                        }
                    )

            logger.info(
                "Fetched status for %d ambulances (%d total entries)",
                len(ambulances_result.data or []),
                len(ambulances_status),
            )
            return ambulances_status

        except Exception as e:
            logger.error("Error fetching ambulances streaming status: %s", e)
            raise

    @staticmethod
    async def cleanup_inactive_camera_rooms(
        inactive_threshold_minutes: int = 30,
    ) -> int:
        """Clean up camera rooms that have been DISCONNECTED for too long.

        NOTE: This only cleans up rooms that are already disconnected (connected=False)
        and have been disconnected for more than the threshold. It does NOT touch
        active streaming rooms.
        """
        try:
            # Calculate cutoff time (using Python datetime instead of SQL interval)
            from datetime import datetime, timedelta

            cutoff_time = datetime.now() - timedelta(minutes=inactive_threshold_minutes)
            cutoff_time_str = cutoff_time.isoformat()

            # Only update rooms that are ALREADY disconnected (connected=False)
            # and have been disconnected for more than threshold
            result = (
                supabase.table("camera_streaming_rooms")
                .update({"connection_ended_at": "now()"})
                .eq("connected", False)  # ONLY cleanup already disconnected rooms
                .is_("connection_ended_at", "null")  # And haven't been cleaned up yet
                .lt("connection_started_at", cutoff_time_str)
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
