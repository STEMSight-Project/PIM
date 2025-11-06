"""
Movement Detection API Routes
RESTful API endpoints for movement_detections CRUD operations
"""

from fastapi import APIRouter, HTTPException, Query, Path, status, Request
from fastapi.responses import StreamingResponse
from typing import Optional, List
import logging

from models.movement_detection import (
    MovementDetectionCreate,
    MovementDetectionUpdate,
    MovementDetectionResponse,
    ValidationStatusUpdate,
)
from services.movement_detection_service import MovementDetectionService
from core.common import supabase, logger

router = APIRouter(
    prefix="/api/movement-detections",
    tags=["Movement Detections"],
    responses={404: {"description": "Not found"}},
)


@router.post(
    "",
    response_model=MovementDetectionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create movement detection",
    description="Create a new movement detection record for a recording",
)
async def create_detection(detection_data: MovementDetectionCreate):
    """
    Create a new movement detection record.

    **Request Body Example:**
    ```json
    {
        "timestamp": 15.0,
        "name": "tremor",
        "confidence": 0.98,
        "validation_status": "pending",
        "room_id": "0f30f577-61a3-4a81-8c9f-64a952f718a1",
        "recording_id": "1bce4928-82fe-4252-99ce-789e2783d1bc"
    }
    ```

    **Returns:** Created movement detection record with ID and timestamps
    """
    try:
        result = await MovementDetectionService.create_detection(detection_data)
        if not result:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create movement detection",
            )
        return result
    except Exception as e:
        logger.error(f"Error in create_detection endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.post(
    "/bulk",
    response_model=List[MovementDetectionResponse],
    status_code=status.HTTP_201_CREATED,
    summary="Bulk create movement detections",
    description="Create multiple movement detections in a single request",
)
async def bulk_create_detections(detections: List[MovementDetectionCreate]):
    """
    Create multiple movement detections at once.

    **Use case:** Import multiple detections from a processed video file.

    **Request Body Example:**
    ```json
    [
        {
            "timestamp": 5.0,
            "name": "tremor",
            "confidence": 0.95,
            "validation_status": "pending",
            "room_id": "0f30f577-61a3-4a81-8c9f-64a952f718a1",
            "recording_id": "1bce4928-82fe-4252-99ce-789e2783d1bc"
        },
        {
            "timestamp": 10.5,
            "name": "dystonia",
            "confidence": 0.87,
            "validation_status": "pending",
            "room_id": "0f30f577-61a3-4a81-8c9f-64a952f718a1",
            "recording_id": "1bce4928-82fe-4252-99ce-789e2783d1bc"
        }
    ]
    ```

    **Returns:** List of created detection records
    """
    try:
        if not detections:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Detection list cannot be empty",
            )

        results = await MovementDetectionService.bulk_create_detections(detections)
        return results
    except Exception as e:
        logger.error(f"Error in bulk_create_detections endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/realtime",
    summary="Real-time movement detections stream",
    description="Stream real-time updates for movement detections using Server-Sent Events (SSE)",
)
async def realtime_movement_detections(
    request: Request,
    room_id: Optional[str] = Query(None, description="Filter by room ID"),
    recording_id: Optional[str] = Query(None, description="Filter by recording ID"),
    validation_status: Optional[str] = Query(
        None, description="Filter by validation status (pending, confirmed, dismissed)"
    ),
):
    """
    Stream real-time updates for movement detections.

    **Protocol:** Server-Sent Events (SSE)

    **Query Parameters:**
    - **room_id**: Filter detections for a specific room
    - **recording_id**: Filter detections for a specific recording
    - **validation_status**: Filter by status (pending, confirmed, dismissed)

    **Event Types:**
    - `INSERT`: New detection created
    - `UPDATE`: Detection updated (e.g., validation status changed)
    - `DELETE`: Detection deleted
    - `heartbeat`: Keep-alive signal every 30 seconds

    **Usage Example (JavaScript):**
    ```javascript
    const eventSource = new EventSource(
        '/api/movement-detections/realtime?room_id=0f30f577-61a3-4a81-8c9f-64a952f718a1'
    );

    eventSource.onmessage = (event) => {
        const data = JSON.parse(event.data);
        if (data.type === 'INSERT') {
            console.log('New detection:', data.record);
        } else if (data.type === 'UPDATE') {
            console.log('Updated detection:', data.record);
        }
    };
    ```

    **Returns:** Server-Sent Events stream
    """
    logger.info(
        "Starting real-time movement detections stream - room_id: %s, recording_id: %s, status: %s",
        room_id or "all",
        recording_id or "all",
        validation_status or "all",
    )

    # Delegate to service layer for realtime streaming
    return StreamingResponse(
        MovementDetectionService.stream_realtime_detections(
            request=request,
            room_id=room_id,
            recording_id=recording_id,
            validation_status=validation_status,
        ),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get(
    "/{detection_id}",
    response_model=MovementDetectionResponse,
    summary="Get movement detection by ID",
    description="Retrieve a specific movement detection record by its ID",
)
async def get_detection(
    detection_id: int = Path(..., description="ID of the detection record", gt=0)
):
    """
    Get a movement detection by ID.

    **Path Parameters:**
    - **detection_id**: Integer ID of the detection (must be > 0)

    **Returns:** Movement detection record

    **Example:** `GET /api/movement-detections/1`
    """
    try:
        result = await MovementDetectionService.get_detection_by_id(detection_id)
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Movement detection with ID {detection_id} not found",
            )
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in get_detection endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/recording/{recording_id}",
    response_model=List[MovementDetectionResponse],
    summary="Get detections by recording",
    description="Get all movement detections for a specific recording (chronological order)",
)
async def get_detections_by_recording(
    recording_id: str = Path(..., description="UUID of the recording"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip (pagination)"),
):
    """
    Get all movement detections for a specific recording.

    **Path Parameters:**
    - **recording_id**: UUID of the recording

    **Query Parameters:**
    - **limit**: Maximum number of results (1-1000, default: 100)
    - **offset**: Skip N results for pagination (default: 0)

    **Returns:** List of detections ordered by timestamp (earliest first)

    **Example:** `GET /api/movement-detections/recording/1bce4928-82fe-4252-99ce-789e2783d1bc?limit=50&offset=0`
    """
    try:
        results = await MovementDetectionService.get_detections_by_recording(
            recording_id, limit, offset
        )
        return results
    except Exception as e:
        logger.error(f"Error in get_detections_by_recording endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/room/{room_id}",
    response_model=List[MovementDetectionResponse],
    summary="Get detections by room",
    description="Get all movement detections for a specific room with optional status filter",
)
async def get_detections_by_room(
    room_id: str = Path(..., description="UUID of the room"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip (pagination)"),
    validation_status: Optional[str] = Query(
        None,
        regex="^(pending|confirmed|rejected)$",
        description="Filter by validation status",
    ),
):
    """
    Get all movement detections for a specific room.

    **Path Parameters:**
    - **room_id**: UUID of the room

    **Query Parameters:**
    - **limit**: Maximum number of results (1-1000, default: 100)
    - **offset**: Skip N results for pagination (default: 0)
    - **validation_status**: Filter by status (pending/confirmed/rejected)

    **Returns:** List of detections ordered by creation time (newest first)

    **Examples:**
    - All detections: `GET /api/movement-detections/room/0f30f577-61a3-4a81-8c9f-64a952f718a1`
    - Pending only: `GET /api/movement-detections/room/0f30f577-61a3-4a81-8c9f-64a952f718a1?validation_status=pending`
    """
    try:
        results = await MovementDetectionService.get_detections_by_room(
            room_id, limit, offset, validation_status
        )
        return results
    except Exception as e:
        logger.error(f"Error in get_detections_by_room endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/movement/{movement_name}",
    response_model=List[MovementDetectionResponse],
    summary="Get detections by movement type",
    description="Get all detections for a specific movement type with confidence filter",
)
async def get_detections_by_movement_type(
    movement_name: str = Path(
        ...,
        description="Movement type name (e.g., 'tremor', 'dystonia')",
        regex="^[a-z_]+$",
    ),
    limit: int = Query(100, ge=1, le=1000, description="Maximum results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip (pagination)"),
    min_confidence: float = Query(
        0.0, ge=0.0, le=1.0, description="Minimum confidence threshold (0.0-1.0)"
    ),
):
    """
    Get all detections for a specific movement type.

    **Path Parameters:**
    - **movement_name**: Movement type name (lowercase with underscores)

    **Query Parameters:**
    - **limit**: Maximum number of results (1-1000, default: 100)
    - **offset**: Skip N results for pagination (default: 0)
    - **min_confidence**: Minimum confidence (0.0-1.0, default: 0.0)

    **Returns:** List of detections ordered by confidence (highest first)

    **Examples:**
    - All tremors: `GET /api/movement-detections/movement/tremor`
    - High confidence only: `GET /api/movement-detections/movement/tremor?min_confidence=0.8`
    """
    try:
        results = await MovementDetectionService.get_detections_by_movement_type(
            movement_name, limit, offset, min_confidence
        )
        return results
    except Exception as e:
        logger.error(f"Error in get_detections_by_movement_type endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/pending/validations",
    response_model=List[MovementDetectionResponse],
    summary="Get pending validations",
    description="Get all movement detections that require validation (review queue)",
)
async def get_pending_validations(
    limit: int = Query(50, ge=1, le=500, description="Maximum results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip (pagination)"),
):
    """
    Get all movement detections pending validation.

    **Use case:** Review queue for medical staff to validate AI detections.

    **Query Parameters:**
    - **limit**: Maximum number of results (1-500, default: 50)
    - **offset**: Skip N results for pagination (default: 0)

    **Returns:** List of pending detections ordered by creation time (oldest first)

    **Example:** `GET /api/movement-detections/pending/validations?limit=20`
    """
    try:
        results = await MovementDetectionService.get_pending_validations(limit, offset)
        return results
    except Exception as e:
        logger.error(f"Error in get_pending_validations endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.get(
    "/statistics/summary",
    summary="Get detection statistics",
    description="Get summary statistics about movement detections",
)
async def get_detection_statistics(
    recording_id: Optional[str] = Query(
        None, description="Filter by recording UUID (optional)"
    ),
    room_id: Optional[str] = Query(None, description="Filter by room UUID (optional)"),
):
    """
    Get statistics about movement detections.

    **Query Parameters:**
    - **recording_id**: Filter stats for specific recording (optional)
    - **room_id**: Filter stats for specific room (optional)

    **Returns:** Statistics including:
    - Total detection count
    - Count by validation status (pending/confirmed/rejected)
    - Count by movement type
    - Average confidence score
    - High confidence count (>= 0.8)

    **Examples:**
    - All stats: `GET /api/movement-detections/statistics/summary`
    - Recording stats: `GET /api/movement-detections/statistics/summary?recording_id=1bce4928-82fe-4252-99ce-789e2783d1bc`
    """
    try:
        stats = await MovementDetectionService.get_detection_statistics(
            recording_id, room_id
        )
        return stats
    except Exception as e:
        logger.error(f"Error in get_detection_statistics endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.patch(
    "/{detection_id}",
    response_model=MovementDetectionResponse,
    summary="Update movement detection",
    description="Update a movement detection record (partial update)",
)
async def update_detection(
    detection_id: int = Path(..., description="ID of the detection record", gt=0),
    update_data: MovementDetectionUpdate = ...,
):
    """
    Update a movement detection record (partial update).

    **Path Parameters:**
    - **detection_id**: Integer ID of the detection (must be > 0)

    **Request Body Example (update any fields):**
    ```json
    {
        "confidence": 0.95,
        "validation_status": "confirmed"
    }
    ```

    **Returns:** Updated detection record

    **Example:** `PATCH /api/movement-detections/1`
    """
    try:
        result = await MovementDetectionService.update_detection(
            detection_id, update_data
        )
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Movement detection with ID {detection_id} not found",
            )
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in update_detection endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.patch(
    "/{detection_id}/validation",
    response_model=MovementDetectionResponse,
    summary="Update validation status",
    description="Update only the validation status of a detection (quick validation)",
)
async def update_validation_status(
    detection_id: int = Path(..., description="ID of the detection record", gt=0),
    status_update: ValidationStatusUpdate = ...,
):
    """
    Update only the validation status of a detection.

    **Use case:** Quick validation by medical staff without changing other fields.

    **Path Parameters:**
    - **detection_id**: Integer ID of the detection (must be > 0)

    **Request Body Example:**
    ```json
    {
        "validation_status": "confirmed"
    }
    ```

    **Allowed values:** "pending", "confirmed", "rejected"

    **Returns:** Updated detection record

    **Example:** `PATCH /api/movement-detections/1/validation`
    """
    try:
        result = await MovementDetectionService.update_validation_status(
            detection_id, status_update.validation_status
        )
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Movement detection with ID {detection_id} not found",
            )
        return result
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in update_validation_status endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.delete(
    "/{detection_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete movement detection",
    description="Delete a specific movement detection record",
)
async def delete_detection(
    detection_id: int = Path(..., description="ID of the detection record", gt=0)
):
    """
    Delete a movement detection record.

    **Path Parameters:**
    - **detection_id**: Integer ID of the detection (must be > 0)

    **Returns:** 204 No Content on success

    **Example:** `DELETE /api/movement-detections/1`
    """
    try:
        success = await MovementDetectionService.delete_detection(detection_id)
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Movement detection with ID {detection_id} not found",
            )
        return None
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in delete_detection endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )


@router.delete(
    "/recording/{recording_id}/all",
    summary="Delete all detections for recording",
    description="Delete all movement detections for a specific recording",
)
async def delete_detections_by_recording(
    recording_id: str = Path(..., description="UUID of the recording")
):
    """
    Delete all movement detections for a specific recording.

    **Use case:** Cleanup when a recording is deleted or needs reprocessing.

    **Path Parameters:**
    - **recording_id**: UUID of the recording

    **Returns:** Number of detections deleted

    **Example:** `DELETE /api/movement-detections/recording/1bce4928-82fe-4252-99ce-789e2783d1bc/all`
    """
    try:
        count = await MovementDetectionService.delete_detections_by_recording(
            recording_id
        )
        return {"deleted_count": count, "recording_id": recording_id}
    except Exception as e:
        logger.error(f"Error in delete_detections_by_recording endpoint: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(e)}",
        )
