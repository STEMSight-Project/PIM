"""
Ambulance Streaming API router - Updated for ambulance-based camera streaming.
Uses ambulance_streaming_sessions and camera_streaming_rooms tables.
"""

import asyncio
import json
from typing import Optional, Dict, Any
from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.responses import StreamingResponse
from core.common import logger, supabase
from security.jwt_verify import current_user
from services.streaming.database_service import StreamingDatabaseService
from services.streaming.webrtc_service import webrtc_service
from services.streaming.room_service import room_manager

router = APIRouter()

# Pydantic models for request/response
from pydantic import BaseModel


class AmbulanceSessionCreate(BaseModel):
    ambulance_id: str
    session_name: Optional[str] = None
    session_type: str = "emergency"
    incident_id: Optional[str] = None
    priority_level: int = 3


class CameraRoomCreate(BaseModel):
    camera_id: str
    room_id: Optional[str] = None
    device_name: Optional[str] = "Camera Device"


class SDPBody(BaseModel):
    sdp: str
    type: str


# ==============================================================================
# AMBULANCE STREAMING SESSIONS ENDPOINTS
# ==============================================================================


@router.post("/ambulance-sessions")
async def create_ambulance_session(session_data: AmbulanceSessionCreate):
    """Create a new ambulance streaming session."""
    try:
        # Check if ambulance exists
        ambulance_result = (
            supabase.table("ambulances")
            .select("id")
            .eq("id", session_data.ambulance_id)
            .execute()
        )
        if not ambulance_result.data:
            raise HTTPException(status_code=404, detail="Ambulance not found")

        # Create new streaming session using the service
        session = await StreamingDatabaseService.get_or_create_ambulance_session(
            session_data.ambulance_id, session_data.session_type
        )

        logger.info(
            "Created ambulance session %s for ambulance %s",
            session["id"],
            session_data.ambulance_id,
        )
        return session

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error creating ambulance session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/ambulance-sessions", dependencies=[Depends(current_user)])
async def get_ambulance_sessions(
    ambulance_id: Optional[str] = None,
    is_active: Optional[bool] = None,
    limit: int = 50,
):
    """Get ambulance streaming sessions with optional filters."""
    try:
        sessions = await StreamingDatabaseService.get_all_ambulance_sessions(
            ambulance_id, is_active, limit
        )
        return sessions

    except Exception as e:
        logger.error("Error fetching ambulance sessions: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/ambulance-sessions/{session_id}", dependencies=[Depends(current_user)])
async def get_ambulance_session(session_id: str):
    """Get a specific ambulance streaming session."""
    try:
        session = await StreamingDatabaseService.get_ambulance_session_by_id(session_id)

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        return session

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error fetching session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put(
    "/ambulance-sessions/{session_id}/end", dependencies=[Depends(current_user)]
)
async def end_ambulance_session(session_id: str):
    """End an ambulance streaming session."""
    try:
        session = await StreamingDatabaseService.end_ambulance_session(session_id)

        logger.info("Ended ambulance session %s", session_id)
        return session

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error ending session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# CAMERA STREAMING ROOMS ENDPOINTS
# ==============================================================================


@router.post("/camera-rooms")
async def create_camera_room(room_data: CameraRoomCreate, session_id: str):
    """Create a new camera streaming room."""
    try:
        # Generate room_id if not provided
        room_id = room_data.room_id or f"{room_data.camera_id}_{session_id}"

        # Create camera room using the service
        room = await StreamingDatabaseService.create_camera_room(
            session_id, room_data.camera_id, room_id, room_data.device_name
        )

        logger.info(
            "Created camera room %s for camera %s", room_id, room_data.camera_id
        )
        return room

    except Exception as e:
        logger.error("Error creating camera room: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/camera-rooms", dependencies=[Depends(current_user)])
async def get_camera_rooms(
    session_id: Optional[str] = None,
    ambulance_id: Optional[str] = None,
    connected: Optional[bool] = None,
    limit: int = 50,
):
    """Get camera rooms with optional filters."""
    try:
        if ambulance_id:
            # Get camera rooms by ambulance ID
            rooms = await StreamingDatabaseService.get_camera_rooms_by_ambulance_id(
                ambulance_id, connected, limit
            )
        elif session_id:
            # Get camera rooms by session ID
            rooms = await StreamingDatabaseService.get_camera_rooms_by_session_id(
                session_id, connected, limit
            )
        else:
            # Get all camera rooms with optional connected filter
            rooms = await StreamingDatabaseService.get_all_camera_rooms(
                connected, limit
            )

        return rooms

    except Exception as e:
        logger.error("Error fetching camera rooms: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/camera-rooms/{room_id}", dependencies=[Depends(current_user)])
async def get_camera_room(room_id: str):
    """Get camera room details."""
    try:
        room = await StreamingDatabaseService.get_camera_room_by_id(room_id)

        if not room:
            raise HTTPException(status_code=404, detail="Camera room not found")

        return room

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error fetching camera room %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/camera-rooms/{room_id}/disconnect", dependencies=[Depends(current_user)])
async def disconnect_camera_room(room_id: str):
    """Disconnect a camera room."""
    try:
        # Get room first to get the DB ID
        room = await StreamingDatabaseService.get_camera_room_by_id(room_id)
        if not room:
            raise HTTPException(status_code=404, detail="Camera room not found")

        await StreamingDatabaseService.update_camera_room_status(room["id"], False)

        logger.info("Disconnected camera room %s", room_id)
        return {"disconnected": True}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error disconnecting camera room %s: %s", room_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# AMBULANCE STATUS ENDPOINTS
# ==============================================================================


@router.get("/ambulances/status", dependencies=[Depends(current_user)])
async def get_ambulances_streaming_status():
    """Get streaming status for all ambulances."""
    try:
        ambulances_status = (
            await StreamingDatabaseService.get_ambulances_streaming_status()
        )
        print(ambulances_status)
        return ambulances_status

    except Exception as e:
        logger.error("Error fetching ambulances streaming status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/ambulances/{ambulance_id}/cameras", dependencies=[Depends(current_user)])
async def get_ambulance_cameras(ambulance_id: str):
    """Get all cameras for a specific ambulance."""
    try:
        cameras = await StreamingDatabaseService.get_ambulance_cameras(ambulance_id)
        return cameras

    except Exception as e:
        logger.error("Error fetching cameras for ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/cameras/{camera_id}", dependencies=[Depends(current_user)])
async def get_camera_details(camera_id: str):
    """Get camera details."""
    try:
        camera = await StreamingDatabaseService.get_camera_by_id(camera_id)

        if not camera:
            raise HTTPException(status_code=404, detail="Camera not found")

        return camera

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error fetching camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# WEBRTC STREAMING ENDPOINTS (Simplified for ambulance/camera model)
# ==============================================================================


@router.post("/camera/{camera_id}/streamer")
async def camera_streamer(camera_id: str, body: SDPBody):
    """Establish WebRTC connection for camera streamer (publisher)."""
    try:
        # Find active camera room for this camera
        camera_rooms = await StreamingDatabaseService.get_camera_rooms_by_camera_id(
            camera_id
        )

        if not camera_rooms:
            raise HTTPException(
                status_code=404, detail="No active camera room found for this camera"
            )

        # Use the first active room
        camera_room = camera_rooms[0]
        room_id = camera_room.get("room_id")

        if not room_id:
            raise HTTPException(status_code=400, detail="Camera room has no room_id")

        logger.info("Setting up streamer for camera %s in room %s", camera_id, room_id)

        # Create or get WebRTC room
        room = room_manager.get_room(room_id)
        if not room:
            room = room_manager.create_room(
                room_id=room_id,
                session_id=camera_room.get("session_id"),
                room_db_id=camera_room.get("id"),
            )

        # Register camera room for monitoring
        webrtc_service.register_camera_room(
            room_id, camera_room["id"], camera_room.get("session_id")
        )

        # Create WebRTC connection for streamer
        sdp_response = await webrtc_service.create_streamer_connection(room_id, body)

        # Update camera room status to connected
        await StreamingDatabaseService.update_camera_room_status(
            camera_room["id"], connected=True
        )

        # Return only SDP fields (no camera_id to avoid WebRTC errors)
        return {"sdp": sdp_response["sdp"], "type": sdp_response["type"]}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error setting up camera streamer for %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/camera/{camera_id}/viewer")
async def camera_viewer(camera_id: str, body: SDPBody):
    """Establish WebRTC connection for camera viewer (subscriber)."""
    try:
        # Find active camera room for this camera
        camera_rooms = await StreamingDatabaseService.get_camera_rooms_by_camera_id(
            camera_id
        )

        if not camera_rooms:
            raise HTTPException(
                status_code=404, detail="No active camera room found for this camera"
            )

        # Use the first active room
        camera_room = camera_rooms[0]
        room_id = camera_room.get("room_id")

        if not room_id:
            raise HTTPException(status_code=400, detail="Camera room has no room_id")

        logger.info("Setting up viewer for camera %s in room %s", camera_id, room_id)

        # Get existing WebRTC room (should exist from streamer)
        room = room_manager.get_room(room_id)
        if not room:
            raise HTTPException(
                status_code=404,
                detail=f"No active streaming session found for camera {camera_id}",
            )

        # Create WebRTC connection for viewer
        sdp_response = await webrtc_service.create_viewer_connection(room_id, body)

        # Return only SDP fields (no camera_id to avoid WebRTC errors)
        return {"sdp": sdp_response["sdp"], "type": sdp_response["type"]}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error setting up camera viewer for %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# WEBRTC ADDITIONAL ENDPOINTS
# ==============================================================================


@router.post("/camera/{camera_id}/ice-candidate")
async def handle_ice_candidate(camera_id: str, candidate_data: dict):
    """Handle ICE candidate for camera streaming."""
    try:
        # Find active camera room for this camera
        camera_rooms = await StreamingDatabaseService.get_camera_rooms_by_camera_id(
            camera_id
        )

        if not camera_rooms:
            raise HTTPException(status_code=404, detail="No active camera room found")

        room_id = camera_rooms[0].get("room_id")

        if not room_id:
            raise HTTPException(status_code=400, detail="Camera room has no room_id")

        # Handle ICE candidate
        success = await webrtc_service.handle_ice_candidate(room_id, candidate_data)

        if not success:
            raise HTTPException(
                status_code=500, detail="Failed to handle ICE candidate"
            )

        return {"success": True}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error handling ICE candidate for camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/camera/{camera_id}/stats")
async def get_camera_connection_stats(camera_id: str):
    """Get WebRTC connection statistics for a camera."""
    try:
        # Find active camera room for this camera
        camera_rooms = await StreamingDatabaseService.get_camera_rooms_by_camera_id(
            camera_id
        )

        if not camera_rooms:
            raise HTTPException(status_code=404, detail="No active camera room found")

        room_id = camera_rooms[0].get("room_id")

        if not room_id:
            raise HTTPException(status_code=400, detail="Camera room has no room_id")

        # Get connection statistics
        stats = webrtc_service.get_connection_stats(room_id)

        return {"camera_id": camera_id, "room_id": room_id, **stats}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error getting stats for camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/camera/{camera_id}/disconnect")
async def disconnect_camera_stream(camera_id: str):
    """Disconnect camera streaming and close WebRTC connections."""
    try:
        # Find active camera room for this camera
        camera_rooms = await StreamingDatabaseService.get_camera_rooms_by_camera_id(
            camera_id
        )

        if not camera_rooms:
            raise HTTPException(status_code=404, detail="No active camera room found")

        camera_room = camera_rooms[0]
        room_id = camera_room.get("room_id")

        if room_id:
            # Close WebRTC room
            room = room_manager.get_room(room_id)
            if room:
                await room.close()
                room_manager.remove_room(room_id)

        # Update database status
        await StreamingDatabaseService.update_camera_room_status(
            camera_room["id"], connected=False
        )

        logger.info("Disconnected camera %s from room %s", camera_id, room_id)

        return {"camera_id": camera_id, "room_id": room_id, "disconnected": True}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error disconnecting camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# REAL-TIME SSE ENDPOINTS (Updated for ambulance schema)
# ==============================================================================


@router.get("/realtime/ambulance-sessions")
async def realtime_ambulance_sessions(
    request: Request, ambulance_id: Optional[str] = None
):
    """Stream real-time updates for ambulance sessions using Supabase channels."""

    async def event_generator():
        # Create channel for ambulance streaming sessions
        channel_name = f"ambulance_sessions_{ambulance_id or 'all'}"
        channel = supabase.channel(channel_name)

        # Create async queue for events
        queue: asyncio.Queue[str] = asyncio.Queue()

        def handler(payload):
            """Handle Supabase real-time events."""
            try:
                msg = f"data: {json.dumps(payload)}\n\n"
                queue.put_nowait(msg)
            except Exception as e:
                logger.error("Error handling real-time event: %s", e)

        # Configure table subscription
        subscription_config = {
            "event": "*",  # Listen to all events (INSERT, UPDATE, DELETE)
            "schema": "public",
            "table": "ambulance_streaming_sessions",
        }

        # Add ambulance filter if specified
        if ambulance_id:
            subscription_config["filter"] = f"ambulance_id=eq.{ambulance_id}"

        # Subscribe to postgres changes
        channel.on("postgres_changes", subscription_config, handler).subscribe()

        try:
            # Send initial heartbeat
            yield f"data: {json.dumps({'type': 'connected', 'channel': channel_name})}\n\n"

            while True:
                # Check if client disconnected
                if await request.is_disconnected():
                    break

                try:
                    # Wait for event with timeout for heartbeat
                    msg = await asyncio.wait_for(queue.get(), timeout=30.0)
                    yield msg
                except asyncio.TimeoutError:
                    # Send heartbeat
                    yield f"data: {json.dumps({'type': 'heartbeat', 'timestamp': asyncio.get_event_loop().time()})}\n\n"

        except Exception as e:
            logger.error("Error in ambulance sessions stream: %s", e)
            yield f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"
        finally:
            # Clean up channel
            try:
                supabase.remove_channel(channel)
                logger.info("Removed Supabase channel: %s", channel_name)
            except Exception as cleanup_error:
                logger.error("Error removing channel: %s", cleanup_error)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/realtime/camera-rooms")
async def realtime_camera_rooms(request: Request):
    """Stream real-time updates for camera streaming rooms using Supabase channels."""

    async def event_generator():
        # Create channel for camera streaming rooms
        channel_name = "camera_rooms_all"
        channel = supabase.channel(channel_name)

        # Create async queue for events
        queue: asyncio.Queue[str] = asyncio.Queue()

        def handler(payload):
            """Handle Supabase real-time events."""
            try:
                msg = f"data: {json.dumps(payload)}\n\n"
                queue.put_nowait(msg)
            except Exception as e:
                logger.error("Error handling real-time camera room event: %s", e)

        # Subscribe to camera_streaming_rooms table changes
        channel.on(
            "postgres_changes",
            {
                "event": "*",  # Listen to all events
                "schema": "public",
                "table": "camera_streaming_rooms",
            },
            handler,
        ).subscribe()

        try:
            # Send initial heartbeat
            yield f"data: {json.dumps({'type': 'connected', 'channel': channel_name})}\n\n"

            while True:
                # Check if client disconnected
                if await request.is_disconnected():
                    break

                try:
                    # Wait for event with timeout for heartbeat
                    msg = await asyncio.wait_for(queue.get(), timeout=30.0)
                    yield msg
                except asyncio.TimeoutError:
                    # Send heartbeat
                    yield f"data: {json.dumps({'type': 'heartbeat', 'timestamp': asyncio.get_event_loop().time()})}\n\n"

        except Exception as e:
            logger.error("Error in camera rooms stream: %s", e)
            yield f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"
        finally:
            # Clean up channel
            try:
                supabase.remove_channel(channel)
                logger.info("Removed Supabase channel: %s", channel_name)
            except Exception as cleanup_error:
                logger.error("Error removing channel: %s", cleanup_error)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


# ==============================================================================
# MAINTENANCE ENDPOINTS
# ==============================================================================


@router.post(
    "/maintenance/cleanup-inactive-rooms", dependencies=[Depends(current_user)]
)
async def cleanup_inactive_camera_rooms(threshold_minutes: int = 30):
    """Clean up camera rooms that have been inactive."""
    try:
        cleaned_count = await StreamingDatabaseService.cleanup_inactive_camera_rooms(
            threshold_minutes
        )
        return {"cleaned_rooms": cleaned_count}

    except Exception as e:
        logger.error("Error cleaning up inactive camera rooms: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/maintenance/monitoring-status", dependencies=[Depends(current_user)])
async def get_camera_monitoring_status():
    """Get real-time camera monitoring and data transfer status."""
    try:
        status = webrtc_service.get_monitoring_status()
        return status

    except Exception as e:
        logger.error("Error getting monitoring status: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
