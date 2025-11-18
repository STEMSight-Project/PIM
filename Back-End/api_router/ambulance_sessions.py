# Back-End/api_router/ambulance_sessions.py

from fastapi import APIRouter, HTTPException, Depends, status
from typing import List, Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime
from core.common import logger, supabase
from security.jwt_verify import router_auth_dependency

# Use the same auth pattern as your other routes
router = APIRouter(
    prefix="/ambulance_sessions",
    tags=["ambulance_sessions"],
    dependencies=[Depends(router_auth_dependency())],
)


# Response models
class AmbulanceSession(BaseModel):
    id: str
    session_id: str
    hls_playlist_url: Optional[str] = None
    recording_path: Optional[str] = None
    session_start: str
    session_end: Optional[str] = None
    duration: Optional[int] = None
    file_size: Optional[int] = None
    status: str
    created_at: str
    updated_at: Optional[str] = None
    storage_url: Optional[str] = None

    class Config:
        from_attributes = True


@router.get("/", response_model=List[AmbulanceSession])
async def get_all_sessions():
    """
    Get all ambulance session recordings
    """
    try:
        result = (
            supabase.table("ambulance_session_recordings")
            .select("*")
            .order("session_start", desc=True)
            .execute()
        )

        if result.data is None:
            return []

        return result.data
    except Exception as exc:
        logger.exception("Failed to retrieve sessions: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch sessions",
        ) from exc


@router.get("/{session_id}")
async def get_session_by_id(session_id: str) -> Dict[str, Any]:
    """
    Get a specific ambulance session by ID
    Checks both ambulance_streaming_sessions (new) and ambulance_session_recordings (legacy)
    Returns raw data without validation to support both table schemas
    """
    try:
        # First try the new streaming sessions table
        result = (
            supabase.table("ambulance_streaming_sessions")
            .select("*")
            .eq("id", session_id)
            .execute()
        )

        if result.data and len(result.data) > 0:
            return result.data[0]

        # Fall back to old recordings table for backward compatibility
        result = (
            supabase.table("ambulance_session_recordings")
            .select("*")
            .eq("id", session_id)
            .execute()
        )

        if result.data and len(result.data) > 0:
            return result.data[0]

        # Not found in either table
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Session with id {session_id} not found",
        )

    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to retrieve session %s: %s", session_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch session",
        ) from exc


@router.get("/active/list", response_model=List[AmbulanceSession])
async def get_active_sessions():
    """
    Get all active ambulance sessions (sessions without end time)
    """
    try:
        result = (
            supabase.table("ambulance_session_recordings")
            .select("*")
            .is_("session_end", "null")
            .order("session_start", desc=True)
            .execute()
        )

        if result.data is None:
            return []

        return result.data
    except Exception as exc:
        logger.exception("Failed to retrieve active sessions: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch active sessions",
        ) from exc


@router.get("/by-session-id/{session_id}", response_model=List[AmbulanceSession])
async def get_sessions_by_session_id(session_id: str):
    """
    Get all ambulance session records for a specific session_id
    (There can be multiple records for the same session_id)
    """
    try:
        result = (
            supabase.table("ambulance_session_recordings")
            .select("*")
            .eq("session_id", session_id)
            .execute()
        )

        if result.data is None:
            return []

        return result.data
    except Exception as exc:
        logger.exception(
            "Failed to retrieve sessions for session_id %s: %s", session_id, exc
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch sessions",
        ) from exc


@router.get("/status/{status_filter}", response_model=List[AmbulanceSession])
async def get_sessions_by_status(status_filter: str):
    """
    Get ambulance sessions by status (e.g., 'completed', 'active', 'recording')
    """
    try:
        result = (
            supabase.table("ambulance_session_recordings")
            .select("*")
            .eq("status", status_filter)
            .order("session_start", desc=True)
            .execute()
        )

        if result.data is None:
            return []

        return result.data
    except Exception as exc:
        logger.exception(
            "Failed to retrieve sessions by status %s: %s", status_filter, exc
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch sessions",
        ) from exc
