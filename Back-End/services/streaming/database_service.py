"""
Database service for streaming operations.
"""

from typing import Optional, List, Dict, Any
from core.common import supabase, logger


class StreamingDatabaseService:
    """Service for handling all streaming-related database operations."""

    @staticmethod
    async def get_or_create_session(patient_id: str) -> Dict[str, Any]:
        """Get existing ACTIVE session for patient or create new one (1:1 relationship)."""
        try:
            # Check if an ACTIVE session already exists
            session_result = (
                supabase.table("streaming_sessions")
                .select("*")
                .eq("patient_id", patient_id)
                .eq("status", "active")
                .execute()
            )

            if session_result.data:
                logger.info("Using existing active session for patient %s", patient_id)
                return session_result.data[0]

            # Check if there are any non-ended sessions (should not create new ones)
            all_sessions_result = (
                supabase.table("streaming_sessions")
                .select("*")
                .eq("patient_id", patient_id)
                .neq("status", "ended")
                .execute()
            )

            if all_sessions_result.data:
                # There's a non-ended session, return the most recent one
                existing_session = all_sessions_result.data[0]
                logger.warning(
                    "Patient %s has non-ended session %s with status '%s'. Not creating new session.",
                    patient_id,
                    existing_session["id"],
                    existing_session["status"],
                )
                return existing_session

            # Create new session only if no active/non-ended sessions exist
            session_result = (
                supabase.table("streaming_sessions")
                .insert({"patient_id": patient_id, "status": "active"})
                .execute()
            )

            if not session_result.data:
                raise Exception("Failed to create streaming session")

            logger.info("Created new session for patient %s", patient_id)
            return session_result.data[0]

        except Exception as e:
            logger.error("Error managing session for patient %s: %s", patient_id, e)
            raise

    @staticmethod
    async def create_room(
        session_id: str, patient_id: str, room_id: str, device_name: str
    ) -> Dict[str, Any]:
        """Create a new room entry in the database."""
        try:
            room_result = (
                supabase.table("streaming_rooms")
                .insert(
                    {
                        "session_id": session_id,
                        "patient_id": patient_id,
                        "room_id": room_id,
                        "device_name": device_name,
                        "connected": True,
                    }
                )
                .execute()
            )

            if not room_result.data:
                raise Exception("Failed to create room entry")

            logger.info("Created room %s for session %s", room_id, session_id)
            return room_result.data[0]

        except Exception as e:
            logger.error("Error creating room %s: %s", room_id, e)
            raise

    @staticmethod
    async def get_room_by_id(room_id: str) -> Optional[Dict[str, Any]]:
        """Get existing room from database by room_id."""
        try:
            room_result = (
                supabase.table("streaming_rooms")
                .select("*")
                .eq("room_id", room_id)
                .execute()
            )

            if room_result.data:
                logger.info("Found existing room %s in database", room_id)
                return room_result.data[0]

            return None

        except Exception as e:
            logger.error("Error getting room %s: %s", room_id, e)
            raise

    @staticmethod
    async def update_room_status(
        room_db_id: str, connected: bool, ended_at: Optional[str] = None
    ) -> None:
        """Update room connection status in database."""
        try:
            update_data = {"connected": connected, "updated_at": "now()"}

            if ended_at:
                update_data["ended_at"] = ended_at
            elif not connected:
                update_data["ended_at"] = "now()"

            supabase.table("streaming_rooms").update(update_data).eq(
                "id", room_db_id
            ).execute()

            logger.info("Updated room %s status to connected=%s", room_db_id, connected)

        except Exception as e:
            logger.error("Error updating room %s status: %s", room_db_id, e)
            raise

    @staticmethod
    async def end_session(session_id: str) -> Dict[str, Any]:
        """Properly end a streaming session and all its rooms."""
        try:
            # First, disconnect all rooms in this session
            rooms_result = (
                supabase.table("streaming_rooms")
                .update(
                    {"connected": False, "ended_at": "now()", "updated_at": "now()"}
                )
                .eq("session_id", session_id)
                .eq("connected", True)
                .execute()
            )

            disconnected_rooms = len(rooms_result.data or [])

            # Then end the session
            session_result = (
                supabase.table("streaming_sessions")
                .update({"status": "ended", "ended_at": "now()", "updated_at": "now()"})
                .eq("id", session_id)
                .execute()
            )

            if not session_result.data:
                raise Exception(f"Session {session_id} not found")

            logger.info(
                "Ended session %s and disconnected %d rooms",
                session_id,
                disconnected_rooms,
            )
            return session_result.data[0]

        except Exception as e:
            logger.error("Error ending session %s: %s", session_id, e)
            raise

    @staticmethod
    async def update_session_status(session_id: str, status: str) -> Dict[str, Any]:
        """Update streaming session status."""
        try:
            update_data = {"status": status, "updated_at": "now()"}

            # Auto-set ended_at only if status is 'ended'
            if status == "ended":
                update_data["ended_at"] = "now()"

                # If ending session, also disconnect all its rooms
                supabase.table("streaming_rooms").update(
                    {"connected": False, "ended_at": "now()", "updated_at": "now()"}
                ).eq("session_id", session_id).eq("connected", True).execute()

            result = (
                supabase.table("streaming_sessions")
                .update(update_data)
                .eq("id", session_id)
                .execute()
            )

            if not result.data:
                raise Exception(f"Session {session_id} not found")

            logger.info("Updated session %s status to %s", session_id, status)
            return result.data[0]

        except Exception as e:
            logger.error("Error updating session %s: %s", session_id, e)
            raise

    @staticmethod
    async def get_all_sessions(
        patient_id: Optional[str] = None, status: Optional[str] = None, limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get streaming sessions with optional filters."""
        try:
            query = supabase.table("streaming_sessions").select("*, streaming_rooms(*)")

            if patient_id:
                query = query.eq("patient_id", patient_id)
            if status:
                query = query.eq("status", status)

            result = query.order("created_at", desc=True).limit(limit).execute()
            return result.data or []

        except Exception as e:
            logger.error("Error fetching sessions: %s", e)
            raise

    @staticmethod
    async def get_session_by_id(session_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific session with its rooms."""
        try:
            result = (
                supabase.table("streaming_sessions")
                .select("*, streaming_rooms(*)")
                .eq("id", session_id)
                .execute()
            )

            return result.data[0] if result.data else None

        except Exception as e:
            logger.error("Error fetching session %s: %s", session_id, e)
            raise

    @staticmethod
    async def get_patients_streaming_status() -> List[Dict[str, Any]]:
        """Get streaming status for all patients with live sessions."""
        try:
            # Get all patients with their streaming data
            result = (
                supabase.table("patients")
                .select(
                    """
                id, first_name, last_name,
                streaming_sessions!inner(
                    id, status, started_at,
                    streaming_rooms(*)
                )
                """
                )
                .execute()
            )

            patients_status = []
            for patient in result.data or []:
                session = patient.get("streaming_sessions", [])
                if session:
                    session = session[0]  # 1:1 relationship
                    rooms = session.get("streaming_rooms", [])

                    patients_status.append(
                        {
                            "patient_id": patient["id"],
                            "first_name": patient["first_name"],
                            "last_name": patient["last_name"],
                            "session_id": session["id"],
                            "session_status": session["status"],
                            "session_started": session["started_at"],
                            "total_rooms": len(rooms),
                            "connected_rooms": len(
                                [r for r in rooms if r["connected"]]
                            ),
                            "active_rooms": [
                                {
                                    "room_id": r["room_id"],
                                    "device_name": r["device_name"],
                                    "connected": r["connected"],
                                    "last_seen": r.get("last_seen"),
                                }
                                for r in rooms
                            ],
                        }
                    )

            return patients_status

        except Exception as e:
            logger.error("Error fetching patients streaming status: %s", e)
            raise

    @staticmethod
    async def cleanup_inactive_rooms(inactive_threshold_minutes: int = 30) -> int:
        """Clean up rooms that have been inactive for too long."""
        try:
            # Update rooms that haven't been seen recently
            result = (
                supabase.table("streaming_rooms")
                .update(
                    {"connected": False, "ended_at": "now()", "updated_at": "now()"}
                )
                .lt(
                    "last_seen",
                    f"now() - interval '{inactive_threshold_minutes} minutes'",
                )
                .eq("connected", True)
                .execute()
            )

            cleaned_count = len(result.data or [])

            if cleaned_count > 0:
                logger.info("Cleaned up %d inactive rooms", cleaned_count)

            return cleaned_count

        except Exception as e:
            logger.error("Error during room cleanup: %s", e)
            raise
