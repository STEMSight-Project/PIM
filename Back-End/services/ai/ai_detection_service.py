"""
AI Detection Database Service
Handles database operations for AI movement detection results
"""

from typing import Dict, List, Optional
from datetime import datetime
import logging
from core.common import SUPABASE_ADMIN as supabase

logger = logging.getLogger(__name__)


class AIDetectionService:
    """Service for managing AI detection records in database"""

    TABLE_NAME = "ai_detections"

    @staticmethod
    async def create_detection(
        session_id: str,
        camera_id: str,
        video_id: int,
        patient_id: int,
        movement_type: str,
        movement_id: int,
        confidence_score: float,
        model_accuracy: float,
        tier: str,
        recommendation: str,
        all_probabilities: Dict,
        requires_review: bool,
        room_id: str = None,  # This is actually room_name (e.g., "AMB-001-ROOM-001")
        frame_timestamp: datetime = None,
        metadata: Dict = None,
    ) -> Dict:
        """
        Create a new AI detection record

        Args:
            session_id: Streaming session ID
            camera_id: Camera ID that captured the video
            video_id: ID of the video being analyzed
            patient_id: ID of the patient
            movement_type: Name of the detected movement (e.g., "tremor")
            movement_id: ID of the movement type (1-9)
            confidence_score: Model confidence (0-1)
            model_accuracy: Model's accuracy for this class (0-100)
            tier: Classification tier (excellent/good/needs_review)
            recommendation: Clinical recommendation text
            all_probabilities: Dictionary of all class probabilities
            requires_review: Whether manual review is needed
            room_id: Optional room name (e.g., "AMB-001-ROOM-001")
            frame_timestamp: Timestamp of the frame
            metadata: Additional metadata

        Returns:
            Created detection record
        """
        try:
            data = {
                # Existing columns
                "session_id": session_id,
                "camera_id": camera_id,
                "room_id": room_id,
                "detection_type": "movement_classification",
                "confidence_score": float(confidence_score),
                "detection_data": {
                    "movement_type": movement_type,
                    "movement_id": movement_id,
                    "tier": tier,
                    "recommendation": recommendation,
                    "all_probabilities": all_probabilities,
                    **(metadata or {}),
                },
                "frame_timestamp": frame_timestamp or datetime.now(),
                "model_used": "UNIK_v1.0",
                "processed_on": "cloud",
                # New movement classification columns
                "video_id": video_id,
                "patient_id": patient_id,
                "movement_type": movement_type,
                "movement_id": movement_id,
                "model_accuracy": float(model_accuracy),
                "tier": tier,
                "recommendation": recommendation,
                "all_probabilities": all_probabilities,
                "requires_review": requires_review,
                "detected_at": datetime.now(),
                "reviewed": False,
            }

            result = (
                supabase.table(AIDetectionService.TABLE_NAME).insert(data).execute()
            )

            if result.data:
                logger.info(
                    f"✅ Created AI detection: session={session_id}, video={video_id}, "
                    f"movement={movement_type}, confidence={confidence_score:.1%}"
                )
                return result.data[0]
            else:
                logger.error(f"Failed to create AI detection: {result}")
                return None

        except Exception as e:
            logger.error(f"Error creating AI detection: {str(e)}")
            raise

    @staticmethod
    async def get_detections_by_video(video_id: int) -> List[Dict]:
        """
        Get all AI detections for a specific video

        Args:
            video_id: ID of the video

        Returns:
            List of detection records
        """
        try:
            result = (
                supabase.table(AIDetectionService.TABLE_NAME)
                .select("*")
                .eq("video_id", video_id)
                .not_.is_("movement_type", "null")
                .order("detected_at", desc=True)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            logger.error(f"Error fetching detections for video {video_id}: {str(e)}")
            raise

    @staticmethod
    async def get_detections_by_patient(patient_id: int, limit: int = 50) -> List[Dict]:
        """
        Get AI detections for a specific patient

        Args:
            patient_id: ID of the patient
            limit: Maximum number of records to return

        Returns:
            List of detection records
        """
        try:
            result = (
                supabase.table(AIDetectionService.TABLE_NAME)
                .select("*")
                .eq("patient_id", patient_id)
                .not_.is_("movement_type", "null")
                .order("detected_at", desc=True)
                .limit(limit)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            logger.error(
                f"Error fetching detections for patient {patient_id}: {str(e)}"
            )
            raise

    @staticmethod
    async def get_detections_requiring_review(limit: int = 100) -> List[Dict]:
        """
        Get all detections that require manual review

        Args:
            limit: Maximum number of records to return

        Returns:
            List of detection records requiring review
        """
        try:
            result = (
                supabase.table(AIDetectionService.TABLE_NAME)
                .select("*")
                .eq("requires_review", True)
                .eq("reviewed", False)
                .order("detected_at", desc=True)
                .limit(limit)
                .execute()
            )

            return result.data if result.data else []

        except Exception as e:
            logger.error(f"Error fetching detections requiring review: {str(e)}")
            raise

    @staticmethod
    async def mark_as_reviewed(
        detection_id: int,
        reviewed_by: int,
        physician_diagnosis: Optional[str] = None,
        physician_notes: Optional[str] = None,
    ) -> Dict:
        """
        Mark a detection as reviewed by a physician

        Args:
            detection_id: ID of the detection record
            reviewed_by: ID of the physician who reviewed it
            physician_diagnosis: Final diagnosis from physician
            physician_notes: Additional notes from physician

        Returns:
            Updated detection record
        """
        try:
            data = {
                "reviewed": True,
                "reviewed_at": datetime.now().isoformat(),
                "reviewed_by": reviewed_by,
                "physician_diagnosis": physician_diagnosis,
                "physician_notes": physician_notes,
            }

            result = (
                supabase.table(AIDetectionService.TABLE_NAME)
                .update(data)
                .eq("id", detection_id)
                .execute()
            )

            if result.data:
                logger.info(f"✅ Marked detection {detection_id} as reviewed")
                return result.data[0]
            else:
                logger.error(f"Failed to mark detection as reviewed: {result}")
                return None

        except Exception as e:
            logger.error(f"Error marking detection as reviewed: {str(e)}")
            raise

    @staticmethod
    async def get_detection_statistics(patient_id: Optional[int] = None) -> Dict:
        """
        Get statistics about AI detections

        Args:
            patient_id: Optional patient ID to filter by

        Returns:
            Dictionary with statistics
        """
        try:
            query = supabase.table(AIDetectionService.TABLE_NAME).select("*")

            if patient_id:
                query = query.eq("patient_id", patient_id)

            result = query.execute()

            if not result.data:
                return {
                    "total_detections": 0,
                    "by_tier": {},
                    "by_movement": {},
                    "requiring_review": 0,
                    "reviewed": 0,
                    "avg_confidence": 0,
                }

            detections = result.data

            # Calculate statistics
            by_tier = {}
            by_movement = {}
            requiring_review = 0
            reviewed = 0
            total_confidence = 0

            for det in detections:
                # Tier stats
                tier = det.get("tier", "unknown")
                by_tier[tier] = by_tier.get(tier, 0) + 1

                # Movement stats
                movement = det.get("movement_type", "unknown")
                by_movement[movement] = by_movement.get(movement, 0) + 1

                # Review stats
                if det.get("requires_review"):
                    requiring_review += 1
                if det.get("reviewed"):
                    reviewed += 1

                # Confidence
                total_confidence += det.get("confidence_score", 0)

            return {
                "total_detections": len(detections),
                "by_tier": by_tier,
                "by_movement": by_movement,
                "requiring_review": requiring_review,
                "reviewed": reviewed,
                "avg_confidence": (
                    total_confidence / len(detections) if detections else 0
                ),
            }

        except Exception as e:
            logger.error(f"Error getting detection statistics: {str(e)}")
            raise

    @staticmethod
    async def delete_detection(detection_id: int) -> bool:
        """
        Delete an AI detection record

        Args:
            detection_id: ID of the detection to delete

        Returns:
            True if successful
        """
        try:
            result = (
                supabase.table(AIDetectionService.TABLE_NAME)
                .delete()
                .eq("id", detection_id)
                .execute()
            )

            logger.info(f"✅ Deleted detection {detection_id}")
            return True

        except Exception as e:
            logger.error(f"Error deleting detection {detection_id}: {str(e)}")
            raise
