"""
Realtime API router for Server-Sent Events (SSE) endpoints with Supabase integration
Updated for ambulance-based streaming with ambulance_streaming_sessions and camera_streaming_rooms
"""

import asyncio
import json
from typing import AsyncIterator, Optional, Dict, Any
from fastapi import APIRouter, Request, Depends
from fastapi.responses import StreamingResponse
from security.jwt_verify import current_user
from core.common import logger, supabase_async
from services.realtime.realtime_service import realtime_service
from core.env import ENVIRONMENT

# Initialize router
router = APIRouter()


@router.get("/ambulance-sessions")
async def realtime_ambulance_sessions(
    request: Request, ambulance_id: Optional[str] = None
):
    """Stream real-time updates for ambulance streaming sessions using SSE"""
    logger.info(
        "Starting real-time ambulance sessions stream for ambulance_id: %s",
        ambulance_id or "all",
    )

    # Set custom filter for ambulance_id if provided
    custom_filter = f"ambulance_id=eq.{ambulance_id}" if ambulance_id else None

    stream = realtime_service.create_sse_stream(
        request=request,
        table="ambulance_streaming_sessions",
        patient_id=None,  # Not used for ambulance sessions
        event_filter="*",
        custom_filter=custom_filter,
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


# Keep legacy endpoint for backward compatibility
@router.get("/sessions")
async def realtime_sessions(request: Request, patient_id: Optional[str] = None):
    """Legacy endpoint - redirects to ambulance sessions (deprecated)"""
    logger.warning(
        "Legacy /sessions endpoint used - consider migrating to /ambulance-sessions"
    )

    # For backward compatibility, treat patient_id as ambulance_id
    return await realtime_ambulance_sessions(request, patient_id)


@router.get("/camera-rooms")
async def realtime_camera_rooms(
    request: Request, camera_id: Optional[str] = None, session_id: Optional[str] = None
):
    """Stream real-time updates for camera streaming rooms using SSE"""
    logger.info(
        "Starting real-time camera rooms stream for camera_id: %s, session_id: %s",
        camera_id or "all",
        session_id or "all",
    )

    # Build custom filter based on provided parameters
    filters = []
    if camera_id:
        filters.append(f"camera_id=eq.{camera_id}")
    if session_id:
        filters.append(f"session_id=eq.{session_id}")

    custom_filter = ",".join(filters) if filters else None

    stream = realtime_service.create_sse_stream(
        request=request,
        table="camera_streaming_rooms",
        event_filter="*",
        custom_filter=custom_filter,
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


# Keep legacy endpoint for backward compatibility
@router.get("/rooms")
async def realtime_rooms(request: Request):
    """Legacy endpoint - redirects to camera rooms (deprecated)"""
    logger.warning("Legacy /rooms endpoint used - consider migrating to /camera-rooms")

    return await realtime_camera_rooms(request)


@router.get("/ambulance/{ambulance_id}/status", dependencies=[Depends(current_user)])
async def realtime_ambulance_status(request: Request, ambulance_id: str):
    """Stream real-time ambulance status updates using SSE"""
    logger.info(
        "Starting real-time ambulance status stream for ambulance: %s", ambulance_id
    )

    stream = realtime_service.create_sse_stream(
        request=request,
        table="ambulances",
        patient_id=None,
        event_filter="UPDATE",
        custom_filter=f"id=eq.{ambulance_id}",
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get(
    "/ambulance/{ambulance_id}/session-status", dependencies=[Depends(current_user)]
)
async def realtime_ambulance_session_status(request: Request, ambulance_id: str):
    """Stream real-time updates for all sessions and camera rooms of a specific ambulance"""
    logger.info(
        "Starting real-time ambulance session status stream for ambulance: %s",
        ambulance_id,
    )

    # Stream updates for ambulance sessions filtered by ambulance_id
    stream = realtime_service.create_sse_stream(
        request=request,
        table="ambulance_streaming_sessions",
        patient_id=None,
        event_filter="*",
        custom_filter=f"ambulance_id=eq.{ambulance_id}",
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/camera/{camera_id}/status", dependencies=[Depends(current_user)])
async def realtime_camera_status(request: Request, camera_id: str):
    """Stream real-time updates for camera streaming rooms of a specific camera"""
    logger.info("Starting real-time camera status stream for camera: %s", camera_id)

    stream = realtime_service.create_sse_stream(
        request=request,
        table="camera_streaming_rooms",
        patient_id=None,
        event_filter="*",
        custom_filter=f"camera_id=eq.{camera_id}",
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/ai-detections", dependencies=[Depends(current_user)])
async def realtime_ai_detections(
    request: Request,
    ambulance_id: Optional[str] = None,
    patient_id: Optional[str] = None,
):
    """Stream real-time AI detection updates"""
    logger.info(
        "Starting real-time AI detections stream for ambulance: %s, patient: %s",
        ambulance_id or "all",
        patient_id or "all",
    )

    # Build custom filter based on provided parameters
    filters = []
    if ambulance_id:
        filters.append(f"ambulance_id=eq.{ambulance_id}")
    if patient_id:
        filters.append(f"detected_patient_id=eq.{patient_id}")

    custom_filter = ",".join(filters) if filters else None

    stream = realtime_service.create_sse_stream(
        request=request,
        table="ai_detections",
        patient_id=None,
        event_filter="INSERT",  # Mainly interested in new detections
        custom_filter=custom_filter,
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


# Keep legacy endpoint for backward compatibility
@router.get("/patient/{patient_id}/status", dependencies=[Depends(current_user)])
async def realtime_patient_status(request: Request, patient_id: str):
    """Legacy endpoint - now streams AI detections for patient (deprecated)"""
    logger.warning(
        "Legacy /patient/{patient_id}/status endpoint used - consider migrating to /ai-detections"
    )

    return await realtime_ai_detections(request, patient_id=patient_id)
