"""
Realtime API router for Server-Sent Events (SSE) endpoints with Supabase integration
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


@router.get("/sessions")
async def realtime_sessions(request: Request, patient_id: Optional[str] = None):
    """Stream real-time updates for streaming sessions using SSE"""
    logger.info(
        "Starting real-time sessions stream for patient_id: %s", patient_id or "all"
    )

    stream = realtime_service.create_sse_stream(
        request=request,
        table="streaming_sessions",
        patient_id=patient_id,
        event_filter="*",
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


@router.get("/rooms")
async def realtime_rooms(request: Request):
    """Stream real-time updates for streaming rooms using SSE"""
    logger.info("Starting real-time rooms stream")

    stream = realtime_service.create_sse_stream(
        request=request, table="streaming_rooms", event_filter="*"
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


@router.get("/patient/{patient_id}/status", dependencies=[Depends(current_user)])
async def realtime_patient_status(request: Request, patient_id: str):
    """Stream real-time patient status updates using SSE"""
    logger.info("Starting real-time patient status stream for patient: %s", patient_id)

    stream = realtime_service.create_sse_stream(
        request=request,
        table="patients",
        patient_id=patient_id,
        event_filter="UPDATE",
        custom_filter=f"id=eq.{patient_id}",
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
