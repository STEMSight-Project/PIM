"""
Ambulance service for managing ambulance entities and operations.
"""

from typing import Optional, List, Dict, Any
from core.common import supabase, logger


class AmbulanceService:
    """Service for handling ambulance-related operations."""

    @staticmethod
    async def get_all_ambulances() -> List[Dict[str, Any]]:
        """Get all ambulances with their camera counts."""
        try:
            result = (
                supabase.table("ambulances").select("*, cameras!left(count)").execute()
            )
            return result.data or []
        except Exception as e:
            logger.error("Error fetching ambulances: %s", e)
            raise

    @staticmethod
    async def get_ambulance_by_id(ambulance_id: str) -> Optional[Dict[str, Any]]:
        """Get ambulance details by ID."""
        try:
            result = (
                supabase.table("ambulances")
                .select("*, cameras(*)")
                .eq("id", ambulance_id)
                .execute()
            )
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error("Error fetching ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def create_ambulance(ambulance_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new ambulance."""
        try:
            result = supabase.table("ambulances").insert(ambulance_data).execute()

            if not result.data:
                raise Exception("Failed to create ambulance")

            logger.info("Created ambulance %s", result.data[0]["id"])
            return result.data[0]
        except Exception as e:
            logger.error("Error creating ambulance: %s", e)
            raise

    @staticmethod
    async def update_ambulance(
        ambulance_id: str, update_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Update ambulance information."""
        try:
            result = (
                supabase.table("ambulances")
                .update(update_data)
                .eq("id", ambulance_id)
                .execute()
            )

            if not result.data:
                raise Exception(f"Ambulance {ambulance_id} not found")

            logger.info("Updated ambulance %s", ambulance_id)
            return result.data[0]
        except Exception as e:
            logger.error("Error updating ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def delete_ambulance(ambulance_id: str) -> bool:
        """Delete an ambulance."""
        try:
            # Check if ambulance has active sessions
            active_sessions = (
                supabase.table("ambulance_streaming_sessions")
                .select("id")
                .eq("ambulance_id", ambulance_id)
                .eq("is_active", True)
                .execute()
            )

            if active_sessions.data:
                raise Exception(
                    "Cannot delete ambulance with active streaming sessions"
                )

            result = (
                supabase.table("ambulances").delete().eq("id", ambulance_id).execute()
            )

            logger.info("Deleted ambulance %s", ambulance_id)
            return len(result.data) > 0
        except Exception as e:
            logger.error("Error deleting ambulance %s: %s", ambulance_id, e)
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
    async def add_camera_to_ambulance(
        ambulance_id: str, camera_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Add a camera to an ambulance."""
        try:
            # Verify ambulance exists
            ambulance = await AmbulanceService.get_ambulance_by_id(ambulance_id)
            if not ambulance:
                raise Exception(f"Ambulance {ambulance_id} not found")

            # Add ambulance_id to camera data
            camera_data["ambulance_id"] = ambulance_id

            result = supabase.table("cameras").insert(camera_data).execute()

            if not result.data:
                raise Exception("Failed to create camera")

            logger.info(
                "Added camera %s to ambulance %s", result.data[0]["id"], ambulance_id
            )
            return result.data[0]
        except Exception as e:
            logger.error("Error adding camera to ambulance %s: %s", ambulance_id, e)
            raise

    @staticmethod
    async def remove_camera_from_ambulance(camera_id: str) -> bool:
        """Remove a camera from an ambulance."""
        try:
            # Check if camera has active streaming rooms
            active_rooms = (
                supabase.table("camera_streaming_rooms")
                .select("id")
                .eq("camera_id", camera_id)
                .eq("connected", True)
                .execute()
            )

            if active_rooms.data:
                raise Exception("Cannot remove camera with active streaming rooms")

            result = supabase.table("cameras").delete().eq("id", camera_id).execute()

            logger.info("Removed camera %s", camera_id)
            return len(result.data) > 0
        except Exception as e:
            logger.error("Error removing camera %s: %s", camera_id, e)
            raise

    @staticmethod
    async def get_ambulance_active_sessions(ambulance_id: str) -> List[Dict[str, Any]]:
        """Get all active streaming sessions for an ambulance."""
        try:
            result = (
                supabase.table("ambulance_streaming_sessions")
                .select("*, camera_streaming_rooms(*, cameras(*))")
                .eq("ambulance_id", ambulance_id)
                .eq("is_active", True)
                .execute()
            )
            return result.data or []
        except Exception as e:
            logger.error(
                "Error fetching active sessions for ambulance %s: %s", ambulance_id, e
            )
            raise
