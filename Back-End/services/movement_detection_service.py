"""
Movement Detection Service
Handles CRUD operations for movement_detections table with Supabase realtime support
"""

from typing import List, Optional, Dict, Any, AsyncIterator
from datetime import datetime
import logging
from uuid import UUID

from fastapi import Request

from core.common import SUPABASE_ADMIN as supabase
from models.movement_detection import (
    MovementDetectionCreate,
    MovementDetectionUpdate,
    MovementDetectionResponse,
)
from services.realtime.realtime_service import realtime_service

logger = logging.getLogger(__name__)


class MovementDetectionService:
    """Service for managing movement detection records"""

    TABLE_NAME = "movement_detections"

    @staticmethod
    async def create_detection(
        detection_data: MovementDetectionCreate,
    ) -> Optional[Dict[str, Any]]:
        """
        Create a new movement detection record

        Args:
            detection_data: Movement detection data to create

        Returns:
            Created detection record or None if failed

        Example:
            >>> data = MovementDetectionCreate(
            ...     timestamp=15.0,
            ...     name="tremor",
            ...     confidence=0.98,
            ...     validation_status="pending",
            ...     room_id="0f30f577-61a3-4a81-8c9f-64a952f718a1",
            ...     recording_id="1bce4928-82fe-4252-99ce-789e2783d1bc"
            ... )
            >>> result = await MovementDetectionService.create_detection(data)
        """
        try:
            data = {
                "timestamp": int(detection_data.timestamp),  # Ensure integer
                "name": detection_data.name,
                "confidence": detection_data.confidence,
                "validation_status": detection_data.validation_status,
                "room_id": str(detection_data.room_id),
                "recording_id": str(detection_data.recording_id),
                # Let Supabase handle created_at and updated_at with default values
            }

            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .insert(data)
                .execute()
            )

            if result.data:
                logger.info(
                    f"✅ Created movement detection: id={result.data[0].get('id')}, "
                    f"name={detection_data.name}, confidence={detection_data.confidence:.2%}, "
                    f"timestamp={detection_data.timestamp}s"
                )
                return result.data[0]
            else:
                logger.error(f"Failed to create movement detection: {result}")
                return None

        except Exception as e:
            logger.error(f"Error creating movement detection: {str(e)}", exc_info=True)
            raise

    @staticmethod
    async def get_detection_by_id(detection_id: int) -> Optional[Dict[str, Any]]:
        """
        Get a movement detection by ID

        Args:
            detection_id: ID of the detection record

        Returns:
            Detection record or None if not found
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .select("*")
                .eq("id", detection_id)
                .single()
                .execute()
            )

            return result.data if result.data else None

        except Exception as e:
            logger.error(
                f"Error fetching detection by id {detection_id}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def get_detections_by_recording(
        recording_id: str, limit: int = 100, offset: int = 0
    ) -> List[Dict[str, Any]]:
        """
        Get all movement detections for a specific recording

        Args:
            recording_id: UUID of the recording
            limit: Maximum number of records to return (default: 100)
            offset: Number of records to skip for pagination (default: 0)

        Returns:
            List of detection records ordered by timestamp
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .select("*")
                .eq("recording_id", recording_id)
                .order("timestamp", desc=False)  # Chronological order
                .range(offset, offset + limit - 1)
                .execute()
            )

            logger.info(
                f"📊 Fetched {len(result.data)} detections for recording {recording_id}"
            )
            return result.data if result.data else []

        except Exception as e:
            logger.error(
                f"Error fetching detections for recording {recording_id}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def get_detections_by_room(
        room_id: str,
        limit: int = 100,
        offset: int = 0,
        validation_status: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """
        Get all movement detections for a specific room

        Args:
            room_id: UUID of the room
            limit: Maximum number of records to return (default: 100)
            offset: Number of records to skip for pagination (default: 0)
            validation_status: Filter by validation status (pending/confirmed/rejected)

        Returns:
            List of detection records ordered by creation time (newest first)
        """
        try:
            query = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .select("*")
                .eq("room_id", room_id)
            )

            # Apply validation status filter if provided
            if validation_status:
                query = query.eq("validation_status", validation_status)

            result = (
                query.order("created_at", desc=True)
                .range(offset, offset + limit - 1)
                .execute()
            )

            logger.info(
                f"📊 Fetched {len(result.data)} detections for room {room_id} "
                f"(status={validation_status or 'all'})"
            )
            return result.data if result.data else []

        except Exception as e:
            logger.error(
                f"Error fetching detections for room {room_id}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def get_detections_by_movement_type(
        movement_name: str,
        limit: int = 100,
        offset: int = 0,
        min_confidence: float = 0.0,
    ) -> List[Dict[str, Any]]:
        """
        Get all detections for a specific movement type

        Args:
            movement_name: Name of the movement (e.g., 'tremor', 'dystonia')
            limit: Maximum number of records to return (default: 100)
            offset: Number of records to skip for pagination (default: 0)
            min_confidence: Minimum confidence threshold (0.0-1.0)

        Returns:
            List of detection records ordered by confidence (highest first)
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .select("*")
                .eq("name", movement_name)
                .gte("confidence", min_confidence)
                .order("confidence", desc=True)
                .range(offset, offset + limit - 1)
                .execute()
            )

            logger.info(
                f"📊 Fetched {len(result.data)} detections for movement '{movement_name}' "
                f"(confidence >= {min_confidence:.0%})"
            )
            return result.data if result.data else []

        except Exception as e:
            logger.error(
                f"Error fetching detections for movement {movement_name}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def get_pending_validations(
        limit: int = 50, offset: int = 0
    ) -> List[Dict[str, Any]]:
        """
        Get all movement detections pending validation

        Args:
            limit: Maximum number of records to return (default: 50)
            offset: Number of records to skip for pagination (default: 0)

        Returns:
            List of pending detection records ordered by creation time (oldest first)
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .select("*")
                .eq("validation_status", "pending")
                .order("created_at", desc=False)  # Oldest first for review queue
                .range(offset, offset + limit - 1)
                .execute()
            )

            logger.info(f"📋 Fetched {len(result.data)} pending validations")
            return result.data if result.data else []

        except Exception as e:
            logger.error(f"Error fetching pending validations: {str(e)}", exc_info=True)
            raise

    @staticmethod
    async def update_detection(
        detection_id: int, update_data: MovementDetectionUpdate
    ) -> Optional[Dict[str, Any]]:
        """
        Update a movement detection record

        Args:
            detection_id: ID of the detection to update
            update_data: Updated detection data (only provided fields will be updated)

        Returns:
            Updated detection record or None if not found
        """
        try:
            # Build update dict with only provided fields
            data = {}  # Let Supabase handle updated_at automatically

            if update_data.timestamp is not None:
                data["timestamp"] = int(update_data.timestamp)  # Ensure integer
            if update_data.name is not None:
                data["name"] = update_data.name
            if update_data.confidence is not None:
                data["confidence"] = update_data.confidence
            if update_data.validation_status is not None:
                data["validation_status"] = update_data.validation_status
            if update_data.room_id is not None:
                data["room_id"] = str(update_data.room_id)
            if update_data.recording_id is not None:
                data["recording_id"] = str(update_data.recording_id)

            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .update(data)
                .eq("id", detection_id)
                .execute()
            )

            if result.data:
                logger.info(f"✅ Updated movement detection: id={detection_id}")
                return result.data[0]
            else:
                logger.warning(f"Detection not found: id={detection_id}")
                return None

        except Exception as e:
            logger.error(
                f"Error updating detection {detection_id}: {str(e)}", exc_info=True
            )
            raise

    @staticmethod
    async def update_validation_status(
        detection_id: int, validation_status: str
    ) -> Optional[Dict[str, Any]]:
        """
        Update only the validation status of a detection

        Args:
            detection_id: ID of the detection to update
            validation_status: New validation status (pending/confirmed/rejected)

        Returns:
            Updated detection record or None if not found
        """
        try:
            if validation_status not in ["pending", "confirmed", "rejected"]:
                raise ValueError(
                    f"Invalid validation status: {validation_status}. "
                    "Must be 'pending', 'confirmed', or 'rejected'"
                )

            data = {
                "validation_status": validation_status,
                # Let Supabase handle updated_at automatically
            }

            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .update(data)
                .eq("id", detection_id)
                .execute()
            )

            if result.data:
                logger.info(
                    f"✅ Updated validation status: id={detection_id}, status={validation_status}"
                )
                return result.data[0]
            else:
                logger.warning(f"Detection not found: id={detection_id}")
                return None

        except Exception as e:
            logger.error(
                f"Error updating validation status for {detection_id}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def delete_detection(detection_id: int) -> bool:
        """
        Delete a movement detection record

        Args:
            detection_id: ID of the detection to delete

        Returns:
            True if deleted successfully, False otherwise
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .delete()
                .eq("id", detection_id)
                .execute()
            )

            if result.data:
                logger.info(f"🗑️ Deleted movement detection: id={detection_id}")
                return True
            else:
                logger.warning(f"Detection not found for deletion: id={detection_id}")
                return False

        except Exception as e:
            logger.error(
                f"Error deleting detection {detection_id}: {str(e)}", exc_info=True
            )
            raise

    @staticmethod
    async def get_detection_statistics(
        recording_id: Optional[str] = None, room_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get statistics about movement detections

        Args:
            recording_id: Optional UUID of specific recording
            room_id: Optional UUID of specific room

        Returns:
            Dictionary with detection statistics
        """
        try:
            query = supabase.table(MovementDetectionService.TABLE_NAME).select("*")

            if recording_id:
                query = query.eq("recording_id", recording_id)
            if room_id:
                query = query.eq("room_id", room_id)

            result = query.execute()
            detections = result.data if result.data else []

            # Calculate statistics
            total_count = len(detections)
            if total_count == 0:
                return {
                    "total_detections": 0,
                    "by_status": {"pending": 0, "confirmed": 0, "rejected": 0},
                    "by_movement": {},
                    "avg_confidence": 0.0,
                    "high_confidence_count": 0,
                }

            # Count by status
            by_status = {
                "pending": sum(
                    1 for d in detections if d["validation_status"] == "pending"
                ),
                "confirmed": sum(
                    1 for d in detections if d["validation_status"] == "confirmed"
                ),
                "rejected": sum(
                    1 for d in detections if d["validation_status"] == "rejected"
                ),
            }

            # Count by movement type
            by_movement = {}
            for detection in detections:
                name = detection["name"]
                by_movement[name] = by_movement.get(name, 0) + 1

            # Calculate average confidence
            avg_confidence = sum(d["confidence"] for d in detections) / total_count

            # Count high confidence (>= 0.8)
            high_confidence_count = sum(1 for d in detections if d["confidence"] >= 0.8)

            stats = {
                "total_detections": total_count,
                "by_status": by_status,
                "by_movement": by_movement,
                "avg_confidence": round(avg_confidence, 4),
                "high_confidence_count": high_confidence_count,
                "high_confidence_percentage": round(
                    (high_confidence_count / total_count) * 100, 2
                ),
            }

            logger.info(f"📈 Generated statistics: {stats}")
            return stats

        except Exception as e:
            logger.error(f"Error generating statistics: {str(e)}", exc_info=True)
            raise

    @staticmethod
    async def bulk_create_detections(
        detections: List[MovementDetectionCreate],
    ) -> List[Dict[str, Any]]:
        """
        Create multiple movement detections in bulk

        Args:
            detections: List of movement detection data to create

        Returns:
            List of created detection records

        Example:
            >>> detections = [
            ...     MovementDetectionCreate(timestamp=5.0, name="tremor", ...),
            ...     MovementDetectionCreate(timestamp=10.0, name="dystonia", ...),
            ... ]
            >>> results = await MovementDetectionService.bulk_create_detections(detections)
        """
        try:
            data_list = [
                {
                    "timestamp": int(d.timestamp),  # Ensure integer
                    "name": d.name,
                    "confidence": d.confidence,
                    "validation_status": d.validation_status,
                    "room_id": str(d.room_id),
                    "recording_id": str(d.recording_id),
                    # Let Supabase handle created_at and updated_at automatically
                }
                for d in detections
            ]

            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .insert(data_list)
                .execute()
            )

            if result.data:
                logger.info(f"✅ Bulk created {len(result.data)} movement detections")
                return result.data
            else:
                logger.error(f"Failed to bulk create detections: {result}")
                return []

        except Exception as e:
            logger.error(f"Error bulk creating detections: {str(e)}", exc_info=True)
            raise

    @staticmethod
    async def delete_detections_by_recording(recording_id: str) -> int:
        """
        Delete all movement detections for a specific recording

        Args:
            recording_id: UUID of the recording

        Returns:
            Number of detections deleted
        """
        try:
            result = (
                supabase.table(MovementDetectionService.TABLE_NAME)
                .delete()
                .eq("recording_id", recording_id)
                .execute()
            )

            count = len(result.data) if result.data else 0
            logger.info(f"🗑️ Deleted {count} detections for recording {recording_id}")
            return count

        except Exception as e:
            logger.error(
                f"Error deleting detections for recording {recording_id}: {str(e)}",
                exc_info=True,
            )
            raise

    @staticmethod
    async def stream_realtime_detections(
        request: Request,
        room_id: Optional[str] = None,
        recording_id: Optional[str] = None,
        validation_status: Optional[str] = None,
    ) -> AsyncIterator[str]:
        """
        Stream real-time updates for movement detections using SSE

        Uses the realtime_service helper to create an SSE stream that listens
        to postgres changes on the movement_detections table.

        Args:
            request: FastAPI Request object for disconnect detection
            room_id: Optional filter by room UUID
            recording_id: Optional filter by recording UUID
            validation_status: Optional filter by status (pending/confirmed/rejected)

        Yields:
            SSE formatted strings with detection events

        Example:
            >>> async for event in MovementDetectionService.stream_realtime_detections(
            ...     request, room_id="0f30f577-61a3-4a81-8c9f-64a952f718a1"
            ... ):
            ...     # Process SSE event
            ...     pass
        """
        # Build custom filter based on parameters
        filters = []
        if room_id:
            filters.append(f"room_id=eq.{room_id}")
        if recording_id:
            filters.append(f"recording_id=eq.{recording_id}")
        if validation_status:
            filters.append(f"validation_status=eq.{validation_status}")

        custom_filter = ",".join(filters) if filters else None

        logger.info(
            f"📡 Starting realtime stream for movement_detections "
            f"(room_id={room_id}, recording_id={recording_id}, "
            f"validation_status={validation_status})"
        )

        # Use realtime_service to create SSE stream
        async for event in realtime_service.create_sse_stream(
            request=request,
            table="movement_detections",
            patient_id=None,  # Not used for movement detections
            event_filter="*",  # Listen to all events (INSERT, UPDATE, DELETE)
            custom_filter=custom_filter,
        ):
            yield event
