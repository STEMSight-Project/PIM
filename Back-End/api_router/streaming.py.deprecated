"""
Standard Streaming API router - Simplified streaming endpoints for patient-based streaming.
Provides standard /streaming endpoints that integrate with the existing ambulance streaming infrastructure.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
from core.common import supabase, logger
from security.jwt_verify import current_user
from services.streaming.models import SDPBody
from services.streaming.database_service import StreamingDatabaseService
from services.streaming.webrtc_service import WebRTCService
from services.streaming.room_service import room_manager
import uuid

router = APIRouter()

# Initialize WebRTC service
webrtc_service = WebRTCService()


# ==============================================================================
# STANDARD STREAMING ENDPOINTS (Maps to ambulance streaming infrastructure)
# ==============================================================================


@router.post("/create_room/{room_id}")
async def create_streaming_room(room_id: str, device_name: Optional[str] = None):
    """
    Create a streaming room for a patient (maps to ambulance streaming infrastructure).
    This endpoint provides a standard interface for patient-based streaming.
    """
    try:
        # Generate a UUID for ambulance_id if room_id is not already a valid UUID
        try:
            # Try to parse as UUID to see if it's already valid
            uuid.UUID(room_id)
            ambulance_id = room_id
        except ValueError:
            # Not a valid UUID, generate one based on the room_id string
            # Use uuid5 to generate a consistent UUID from the room_id string
            ambulance_id = str(uuid.uuid5(uuid.NAMESPACE_DNS, room_id))
            logger.info("Generated UUID %s for room_id %s", ambulance_id, room_id)

        # Generate a unique camera_id if not provided
        camera_id = f"cam_{str(uuid.uuid4())[:8]}"

        # Check if there's already an active session for this ambulance/patient
        existing_sessions = await StreamingDatabaseService.get_ambulance_sessions(
            ambulance_id=ambulance_id, is_active=True
        )

        if existing_sessions:
            existing_session = existing_sessions[0]
            session_id = existing_session["id"]

            # Check if there are existing camera rooms for this session
            existing_rooms = await StreamingDatabaseService.get_camera_rooms_by_session(
                session_id
            )

            if existing_rooms:
                # Return existing room info
                existing_room = existing_rooms[0]
                actual_room_id = existing_room["room_id"]

                return {
                    "room_id": actual_room_id,
                    "session_id": session_id,
                    "reconnected": True,
                    "already_exists": True,
                    "message": "Connected to existing room",
                }
            else:
                # Create new camera room for existing session
                device_suffix = f"-{device_name}" if device_name else "-Standard"
                actual_room_id = f"{room_id}{device_suffix}"

                room = await StreamingDatabaseService.create_camera_room(
                    session_id,
                    camera_id,
                    actual_room_id,
                    device_name or "Standard Device",
                )

                return {
                    "room_id": actual_room_id,
                    "session_id": session_id,
                    "created": True,
                    "message": "Created new room for existing session",
                }
        else:
            # Create new session and room
            session = await StreamingDatabaseService.create_ambulance_session(
                ambulance_id=ambulance_id, session_type="standard_streaming"
            )
            session_id = session["id"]

            # Create camera room
            device_suffix = f"-{device_name}" if device_name else "-Standard"
            actual_room_id = f"{room_id}{device_suffix}"

            room = await StreamingDatabaseService.create_camera_room(
                session_id, camera_id, actual_room_id, device_name or "Standard Device"
            )

            logger.info("Created new streaming session and room: %s", actual_room_id)

            return {
                "room_id": actual_room_id,
                "session_id": session_id,
                "created": True,
                "message": "Created new session and room",
            }

    except Exception as e:
        logger.error("Error creating streaming room %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/streamer/{room_id}")
async def connect_streamer(room_id: str, body: SDPBody):
    """
    Connect a streamer to a room (maps to camera streamer endpoint).
    """
    try:
        # Find the camera room by room_id
        room = await StreamingDatabaseService.get_camera_room_by_id(room_id)

        if not room:
            logger.error(f"❌ Room not found in database: {room_id}")
            raise HTTPException(status_code=404, detail=f"Room {room_id} not found")

        camera_id = room["camera_id"]
        session_id_from_db = room["session_id"]

        # 🔥 DEBUG: Log room-to-session mapping
        logger.info(
            f"🔍 [STREAMER] room_id={room_id} → camera_room_id={room['id']} → session_id={session_id_from_db}"
        )

        # Update room status to connected
        await StreamingDatabaseService.update_camera_room_status(room["id"], True)

        # Create or get WebRTC room
        webrtc_room = room_manager.get_room(room_id)
        if not webrtc_room:
            webrtc_room = room_manager.create_room(
                room_id, session_id=room["session_id"]
            )

        # 🔥 FIX: Register camera room for monitoring (tracks session_id)
        webrtc_service.register_camera_room(
            room_id=room_id,
            camera_room_id=room["id"],  # Database ID
            session_id=room["session_id"],  # Link to session
        )
        logger.info(
            "Registered camera room %s for monitoring (session: %s)",
            room["id"],
            room["session_id"],
        )

        # Use WebRTC service to handle the connection
        answer = await webrtc_service.create_streamer_connection(room_id, body)

        logger.info("Streamer connected to room %s (camera %s)", room_id, camera_id)

        return answer

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error connecting streamer to room %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/viewer/{room_id}")
async def connect_viewer(room_id: str, body: SDPBody):
    """
    Connect a viewer to a room.
    """
    try:
        # Find the camera room by room_id
        room = await StreamingDatabaseService.get_camera_room_by_id(room_id)

        if not room:
            raise HTTPException(status_code=404, detail=f"Room {room_id} not found")

        if not room["connected"]:
            raise HTTPException(status_code=409, detail="No active streamer in room")

        camera_id = room["camera_id"]

        # Use WebRTC service to handle the viewer connection
        answer = await webrtc_service.create_viewer_connection(room_id, body)

        logger.info("Viewer connected to room %s (camera %s)", room_id, camera_id)

        return answer

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error connecting viewer to room %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/rooms/status")
async def get_rooms_status():
    """
    Get status of all streaming rooms.
    """
    try:
        # Get all active camera rooms
        all_rooms = await StreamingDatabaseService.get_all_camera_rooms()

        rooms_status = {}
        for room in all_rooms:
            room_id = room["room_id"]
            rooms_status[room_id] = {
                "is_active": room["connected"],
                "has_streamer": room["connected"],
                "viewer_count": 0,  # Could be tracked separately
                "reconnection_attempts": 0,
                "session_id": room["session_id"],
                "camera_id": room["camera_id"],
                "device_name": room["device_name"],
            }

        return {"rooms": rooms_status}

    except Exception as e:
        logger.error("Error getting rooms status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/sessions/{session_id}/end", dependencies=[Depends(current_user)])
async def end_streaming_session(session_id: str):
    """
    End a streaming session.
    """
    try:
        session = await StreamingDatabaseService.end_ambulance_session(session_id)
        logger.info("Ended streaming session %s", session_id)
        return session

    except Exception as e:
        logger.error("Error ending streaming session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# COMPATIBILITY ENDPOINTS (for existing code)
# ==============================================================================


@router.get("/sessions", dependencies=[Depends(current_user)])
async def get_streaming_sessions(
    patient_id: Optional[str] = None, is_live: Optional[bool] = None
):
    """
    Get streaming sessions (maps to ambulance sessions).
    """
    try:
        sessions = await StreamingDatabaseService.get_ambulance_sessions(
            ambulance_id=patient_id, is_active=is_live
        )

        return sessions

    except Exception as e:
        logger.error("Error getting streaming sessions: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/room/{room_id}/activity")
async def get_room_activity_status(room_id: str):
    """
    Get stream activity status for a room including timeout monitoring.
    """
    try:
        room = room_manager.get_room(room_id)
        if not room:
            raise HTTPException(status_code=404, detail=f"Room {room_id} not found")

        activity_info = room.get_connection_info()

        return {
            "room_id": room_id,
            "activity_status": activity_info,
            "message": f"Room has been active for {activity_info['seconds_since_data']} seconds. Timeout occurs at {activity_info['timeout_seconds']} seconds.",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error getting room activity status for %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/rooms/status")
async def get_all_rooms_status():
    """
    Get activity status for all active rooms.
    """
    try:
        all_rooms = room_manager.get_all_rooms()

        rooms_status = []
        for room_id, room in all_rooms.items():
            activity_info = room.get_connection_info()
            rooms_status.append(
                {
                    "room_id": room_id,
                    "activity_info": activity_info,
                    "status": "active" if activity_info["is_active"] else "inactive",
                }
            )

        return {"total_rooms": len(rooms_status), "rooms": rooms_status}

    except Exception as e:
        logger.error("Error getting all rooms status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
