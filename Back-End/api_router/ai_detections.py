"""
AI Detections API Router
Handles CRUD operations for ai_detections table (live streaming detections)
"""

from fastapi import APIRouter, HTTPException, Query
from core.common import supabase, logger
from typing import Optional, List
from pydantic import BaseModel

router = APIRouter()


class AIDetectionResponse(BaseModel):
    """AI Detection model matching ai_detections table schema"""

    id: str
    session_id: str
    camera_id: str
    recording_id: Optional[str] = None
    room_id: Optional[str] = None
    detection_type: str
    confidence_score: Optional[float] = None
    detection_data: dict
    frame_timestamp: str
    sequence_number: Optional[int] = None
    model_used: Optional[str] = None
    processing_time_ms: Optional[int] = None
    processed_on: Optional[str] = "edge"
    created_at: str


@router.get("/ai-detections", response_model=List[AIDetectionResponse])
async def get_ai_detections(
    room_id: Optional[str] = Query(None, description="Filter by room ID"),
    session_id: Optional[str] = Query(None, description="Filter by session ID"),
    camera_id: Optional[str] = Query(None, description="Filter by camera ID"),
    recording_id: Optional[str] = Query(
        None, description="Filter by recording ID (ambulance recording UUID)"
    ),
    limit: int = Query(50, ge=1, le=500, description="Maximum number of results"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
):
    """
    Fetch AI detections from ai_detections table

    Query Parameters:
    - room_id: Filter by room ID (e.g., "AMB-001-ROOM-001")
    - session_id: Filter by session UUID
    - camera_id: Filter by camera UUID
    - recording_id: Filter by recording UUID
    - recording_id: Filter by recording UUID
    - limit: Max results (1-500, default 50)
    - offset: Pagination offset (default 0)

    Returns:
    - List of AI detections ordered by created_at descending
    """
    try:
        logger.info(
            "Fetching AI detections - room_id=%s, session_id=%s, camera_id=%s,"
            " recording_id=%s, limit=%s, offset=%s",
            room_id,
            session_id,
            camera_id,
            recording_id,
            limit,
            offset,
        )

        # Build query
        query = supabase.table("ai_detections").select("*")

        # Apply filters
        if room_id:
            query = query.eq("room_id", room_id)
        if session_id:
            query = query.eq("session_id", session_id)
        if camera_id:
            query = query.eq("camera_id", camera_id)
        if recording_id:
            query = query.eq("recording_id", recording_id)

        # Order and pagination
        query = query.order("created_at", desc=True).range(offset, offset + limit - 1)

        # Execute query
        response = query.execute()

        if response.data is None:
            logger.warning("AI detections query returned None")
            return []

        logger.info(f"✅ Fetched {len(response.data)} AI detections")
        return response.data

    except Exception as e:
        logger.error(f"❌ Failed to fetch AI detections: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to fetch AI detections: {str(e)}"
        ) from e


@router.get("/ai-detections/stats")
async def get_ai_detection_stats(
    room_id: Optional[str] = Query(None, description="Filter by room ID"),
    session_id: Optional[str] = Query(None, description="Filter by session ID"),
):
    """
    Get statistics for AI detections

    Returns aggregated stats:
    - total_detections: Total count
    - by_detection_type: Count per detection type
    - average_confidence: Average confidence score
    - recent_detections: Count in last 5 minutes
    """
    try:
        logger.info(
            f"Fetching AI detection stats - room_id={room_id}, session_id={session_id}"
        )

        # Build query
        query = supabase.table("ai_detections").select("*")

        if room_id:
            query = query.eq("room_id", room_id)
        if session_id:
            query = query.eq("session_id", session_id)

        response = query.execute()

        if not response.data:
            return {
                "total_detections": 0,
                "by_detection_type": {},
                "average_confidence": 0.0,
                "recent_detections": 0,
            }

        detections = response.data
        total = len(detections)

        # Calculate stats
        by_type = {}
        total_confidence = 0.0

        for detection in detections:
            det_type = detection.get("detection_type", "unknown")
            by_type[det_type] = by_type.get(det_type, 0) + 1
            total_confidence += detection.get("confidence_score", 0.0)

        # Count recent detections (last 5 minutes)
        from datetime import datetime, timedelta

        five_min_ago = datetime.utcnow() - timedelta(minutes=5)
        recent_count = sum(
            1
            for d in detections
            if datetime.fromisoformat(
                d.get("created_at", "1970-01-01").replace("Z", "+00:00")
            )
            > five_min_ago
        )

        stats = {
            "total_detections": total,
            "by_detection_type": by_type,
            "average_confidence": total_confidence / total if total > 0 else 0.0,
            "recent_detections": recent_count,
        }

        logger.info(f"✅ AI detection stats: {stats}")
        return stats

    except Exception as e:
        logger.error(f"❌ Failed to fetch AI detection stats: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to fetch stats: {str(e)}"
        ) from e


@router.delete("/ai-detections/{detection_id}")
async def delete_ai_detection(detection_id: str):
    """
    Delete a specific AI detection by ID

    Path Parameters:
    - detection_id: UUID of the detection to delete

    Returns:
    - Success message
    """
    try:
        logger.info(f"Deleting AI detection: {detection_id}")

        response = (
            supabase.table("ai_detections").delete().eq("id", detection_id).execute()
        )

        if not response.data:
            raise HTTPException(status_code=404, detail="Detection not found")

        logger.info(f"✅ Deleted AI detection: {detection_id}")
        return {"message": "Detection deleted successfully", "id": detection_id}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Failed to delete AI detection: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to delete detection: {str(e)}"
        ) from e
