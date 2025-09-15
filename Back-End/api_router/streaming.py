"""
Streaming API router - refactored to use service layer with dependency injection.
"""

from typing import Optional
from fastapi import APIRouter, HTTPException, Depends
from core.common import logger
from security.jwt_verify import current_user
from services.streaming import (
    SDPBody,
    StreamingSessionData,
    StreamingSessionStatusUpdate,
)
from services.streaming.dependencies import (
    get_database_service,
    get_room_manager,
    get_webrtc_service,
)

router = APIRouter()


@router.get("/rooms/status")
async def get_rooms_status(
    room_manager=Depends(get_room_manager), webrtc_service=Depends(get_webrtc_service)
):
    """Get status of all active rooms."""
    try:
        rooms = room_manager.get_all_rooms()
        rooms_status = []

        for room_id, room in rooms.items():
            stats = webrtc_service.get_connection_stats(room_id)
            rooms_status.append(
                {
                    "room_id": room_id,
                    "session_id": room.session_id,
                    "is_active": room.is_active,
                    "connection_count": len(room.pcs),
                    "stats": stats,
                }
            )

        return {"data": rooms_status, "error": None}

    except Exception as e:
        logger.error("Error getting rooms status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/create_room/{patient_id}")
async def create_room(
    patient_id: str,
    device_name: Optional[str] = None,
    db_service=Depends(get_database_service),
    room_manager=Depends(get_room_manager),
):
    """Create a room and automatically create/get streaming session."""
    try:
        room_id = f"{patient_id}-{device_name or 'default'}"

        # Check if room exists in memory (room manager)
        existing_room = room_manager.get_room(room_id)
        if existing_room:
            if not existing_room.is_active:
                # Reactivate existing room for reconnection
                await existing_room.reactivate()
                logger.info("Reactivated existing room %s for reconnection", room_id)
                return {
                    "room_id": room_id,
                    "session_id": existing_room.session_id,
                    "room_db_id": existing_room.room_db_id,
                    "reconnected": True,
                }
            else:
                # Room is still active, return existing info
                return {
                    "room_id": room_id,
                    "session_id": existing_room.session_id,
                    "room_db_id": existing_room.room_db_id,
                    "already_exists": True,
                }

        # Check if room exists in database (after server restart scenario)
        existing_room_data = await db_service.get_room_by_id(room_id)
        if existing_room_data:
            # Room exists in database but not in memory - recreate room manager entry
            session_id = existing_room_data["session_id"]
            room_db_id = existing_room_data["id"]

            # Recreate room object in manager
            room_manager.create_room(room_id, session_id, room_db_id)

            logger.info("Reconnected to existing room %s from database", room_id)
            return {
                "room_id": room_id,
                "session_id": session_id,
                "room_db_id": room_db_id,
                "reconnected": True,
            }

        # Get or create streaming session using database service
        session_data = await db_service.get_or_create_session(patient_id)
        session_id = session_data["id"]

        # Create room entry in database
        room_data = await db_service.create_room(
            session_id, patient_id, room_id, device_name or "Default Camera"
        )
        room_db_id = room_data["id"]

        # Create room object with service manager
        room_manager.create_room(room_id, session_id, room_db_id)

        # Start cleanup task if not already running
        await room_manager.start_cleanup_task()

        logger.info(
            "Created room %s with session %s and room DB ID %s",
            room_id,
            session_id,
            room_db_id,
        )

        return {
            "room_id": room_id,
            "session_id": session_id,
            "room_db_id": room_db_id,
            "created": True,
        }

    except Exception as e:
        logger.error("Error creating room and session: %s", e)
        raise HTTPException(
            status_code=500, detail=f"Failed to create room: {str(e)}"
        ) from e


@router.post("/streamer/{patient_id}")
async def publish_streamer(
    patient_id: str,
    body: SDPBody,
    webrtc_service=Depends(get_webrtc_service),
    room_manager=Depends(get_room_manager),
):
    """Establish WebRTC connection for streamer (publisher)."""
    try:
        # Find the actual room ID for this patient (may include device name)
        room_id = None
        all_rooms = room_manager.get_all_rooms()
        for rid, _ in all_rooms.items():
            if rid.startswith(patient_id):
                room_id = rid
                break

        if not room_id:
            raise ValueError(f"No active room found for patient {patient_id}")

        # Use WebRTC service to handle the connection
        response = await webrtc_service.create_streamer_connection(room_id, body)

        return response

    except ValueError as e:
        logger.error("Room not found for streamer %s: %s", patient_id, e)
        raise HTTPException(status_code=404, detail=str(e)) from e
    except Exception as e:
        logger.error("Error setting up streamer for %s: %s", patient_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/viewer/{patient_id}")
async def publish_viewer(
    patient_id: str,
    body: SDPBody,
    webrtc_service=Depends(get_webrtc_service),
    room_manager=Depends(get_room_manager),
):
    """Establish WebRTC connection for viewer (subscriber)."""
    try:
        # Find the actual room ID for this patient (may include device name)
        room_id = None
        all_rooms = room_manager.get_all_rooms()
        for rid, _ in all_rooms.items():
            if rid.startswith(patient_id):
                room_id = rid
                break

        if not room_id:
            raise ValueError(f"No active room found for patient {patient_id}")

        # Use WebRTC service to handle the connection
        response = await webrtc_service.create_viewer_connection(room_id, body)

        return response

    except ValueError as e:
        logger.error("Room not found for viewer %s: %s", patient_id, e)
        raise HTTPException(status_code=404, detail=str(e)) from e
    except Exception as e:
        logger.error("Error setting up viewer for %s: %s", patient_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/sessions", dependencies=[Depends(current_user)])
async def create_streaming_session(
    session_data: StreamingSessionData, db_service=Depends(get_database_service)
):
    """Create a new streaming session (1:1 with patient)."""
    try:
        # Use database service to create session
        session = await db_service.get_or_create_session(session_data.patient_id)

        # Check if this was an existing session
        existing = "existing" in session

        return {"data": session, "error": None, "existing": existing}

    except Exception as e:
        logger.error("Error creating streaming session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/sessions", dependencies=[Depends(current_user)])
async def get_streaming_sessions(
    patient_id: Optional[str] = None,
    status: Optional[str] = None,
    limit: int = 50,
    db_service=Depends(get_database_service),
):
    """Get streaming sessions with optional filters."""
    try:
        sessions = await db_service.get_all_sessions(patient_id, status, limit)
        return sessions

    except Exception as e:
        logger.error("Error fetching streaming sessions: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/sessions/{session_id}", dependencies=[Depends(current_user)])
async def get_streaming_session(
    session_id: str, db_service=Depends(get_database_service)
):
    """Get a specific streaming session."""
    try:
        session = await db_service.get_session_by_id(session_id)

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        return {"data": session, "error": None}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error fetching streaming session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/sessions/{session_id}", dependencies=[Depends(current_user)])
async def update_streaming_session(
    session_id: str,
    session_data: StreamingSessionStatusUpdate,
    db_service=Depends(get_database_service),
):
    """Update a streaming session status."""
    try:
        if not session_data.status:
            raise HTTPException(status_code=400, detail="Status is required")

        session = await db_service.update_session_status(
            session_id, session_data.status
        )
        return {"data": session, "error": None}

    except Exception as e:
        logger.error("Error updating streaming session: %s", e)
        if "not found" in str(e).lower():
            raise HTTPException(status_code=404, detail=str(e)) from e
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/sessions/{session_id}/end", dependencies=[Depends(current_user)])
async def end_streaming_session(
    session_id: str, db_service=Depends(get_database_service)
):
    """End a streaming session and all its rooms."""
    try:
        session = await db_service.end_session(session_id)
        return {"data": session, "error": None}

    except Exception as e:
        logger.error("Error ending streaming session %s: %s", session_id, e)
        if "not found" in str(e).lower():
            raise HTTPException(status_code=404, detail=str(e)) from e
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/patients/status", dependencies=[Depends(current_user)])
async def get_patients_streaming_status(db_service=Depends(get_database_service)):
    """Get streaming status for all patients."""
    try:
        patients_status = await db_service.get_patients_streaming_status()
        return {"data": patients_status, "error": None}

    except Exception as e:
        logger.error("Error fetching patients streaming status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get(
    "/sessions/patient/{patient_id}/active", dependencies=[Depends(current_user)]
)
async def get_active_sessions_for_patient(patient_id: str):
    """Get active streaming sessions for a specific patient"""
    try:
        result = (
            supabase.table("streaming_sessions")
            .select("*")
            .eq("patient_id", patient_id)
            .eq("is_live", True)
            .eq("status", "active")
            .execute()
        )

        return result.data
    except Exception as e:
        logger.error("Error fetching active sessions for patient: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
