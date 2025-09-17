"""
Streaming API router - refactored to use service layer with dependency injection.
"""

import asyncio
import json
from typing import Optional
from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.responses import StreamingResponse
from core.common import logger, supabase
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


# Supabase Real-time SSE Endpoints
@router.get("/realtime/sessions")
async def realtime_sessions(request: Request, patient_id: Optional[str] = None):
    """Stream real-time updates for streaming sessions using Supabase channels."""

    async def event_generator():
        # Create channel for streaming sessions
        channel_name = f"streaming_sessions_{patient_id or 'all'}"
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
            "table": "streaming_sessions",
        }

        # Add patient filter if specified
        if patient_id:
            subscription_config["filter"] = f"patient_id=eq.{patient_id}"

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
            logger.error("Error in sessions stream: %s", e)
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


@router.get("/realtime/rooms")
async def realtime_rooms(request: Request):
    """Stream real-time updates for streaming rooms using Supabase channels."""

    async def event_generator():
        # Create channel for streaming rooms
        channel_name = "streaming_rooms_all"
        channel = supabase.channel(channel_name)

        # Create async queue for events
        queue: asyncio.Queue[str] = asyncio.Queue()

        def handler(payload):
            """Handle Supabase real-time events."""
            try:
                msg = f"data: {json.dumps(payload)}\n\n"
                queue.put_nowait(msg)
            except Exception as e:
                logger.error("Error handling real-time room event: %s", e)

        # Subscribe to streaming_rooms table changes
        channel.on(
            "postgres_changes",
            {
                "event": "*",  # Listen to all events
                "schema": "public",
                "table": "streaming_rooms",
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
            logger.error("Error in rooms stream: %s", e)
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


@router.get(
    "/realtime/patient/{patient_id}/status", dependencies=[Depends(current_user)]
)
async def realtime_patient_status(request: Request, patient_id: str):
    """Stream real-time status updates for a specific patient."""

    async def event_generator():
        # Create channel for patient-specific updates
        channel_name = f"patient_status_{patient_id}"
        channel = supabase.channel(channel_name)

        # Create async queue for events
        queue: asyncio.Queue[str] = asyncio.Queue()

        def handler(payload):
            """Handle Supabase real-time events."""
            try:
                msg = f"data: {json.dumps(payload)}\n\n"
                queue.put_nowait(msg)
            except Exception as e:
                logger.error("Error handling patient status event: %s", e)

        # Subscribe to both streaming_sessions and streaming_rooms for this patient
        # Sessions subscription
        channel.on(
            "postgres_changes",
            {
                "event": "*",
                "schema": "public",
                "table": "streaming_sessions",
                "filter": f"patient_id=eq.{patient_id}",
            },
            handler,
        )

        # Subscribe to channel
        channel.subscribe()

        try:
            # Send initial heartbeat
            yield f"data: {json.dumps({'type': 'connected', 'channel': channel_name, 'patient_id': patient_id})}\n\n"

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
                    yield f"data: {json.dumps({'type': 'heartbeat', 'patient_id': patient_id, 'timestamp': asyncio.get_event_loop().time()})}\n\n"

        except Exception as e:
            logger.error("Error in patient status stream: %s", e)
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