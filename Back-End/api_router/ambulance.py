"""
Ambulance Management API router.
Handles CRUD operations for ambulances and their cameras.
"""

from typing import Optional, Dict, Any
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from core.common import logger
from security.jwt_verify import current_user
from services.ambulance_service import AmbulanceService

router = APIRouter()


# Pydantic models
class AmbulanceCreate(BaseModel):
    vehicle_number: str
    station_id: str
    status: str = "available"
    current_location: Optional[str] = None


class AmbulanceUpdate(BaseModel):
    vehicle_number: Optional[str] = None
    station_id: Optional[str] = None
    status: Optional[str] = None
    current_location: Optional[str] = None


class CameraCreate(BaseModel):
    name: str
    camera_type: str
    location_in_ambulance: str
    static_id: str
    resolution: Optional[str] = "1920x1080"
    is_active: bool = True


class CameraUpdate(BaseModel):
    name: Optional[str] = None
    camera_type: Optional[str] = None
    location_in_ambulance: Optional[str] = None
    resolution: Optional[str] = None
    frame_rate: Optional[int] = None
    is_active: Optional[bool] = None


# ==============================================================================
# AMBULANCE CRUD ENDPOINTS
# ==============================================================================


@router.get("/")
async def get_all_ambulances():
    """Get all ambulances with camera counts."""
    try:
        ambulances = await AmbulanceService.get_all_ambulances()
        return {"data": ambulances, "error": None}
    except Exception as e:
        logger.error("Error fetching ambulances: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/{ambulance_id}")
async def get_ambulance(ambulance_id: str):
    """Get ambulance details by ID."""
    try:
        ambulance = await AmbulanceService.get_ambulance_by_id(ambulance_id)

        if not ambulance:
            raise HTTPException(status_code=404, detail="Ambulance not found")

        return {"data": ambulance, "error": None}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error fetching ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/")
async def create_ambulance(ambulance_data: AmbulanceCreate):
    """Create a new ambulance."""
    try:
        ambulance = await AmbulanceService.create_ambulance(ambulance_data.dict())
        return {"data": ambulance, "error": None}
    except Exception as e:
        logger.error("Error creating ambulance: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/{ambulance_id}")
async def update_ambulance(ambulance_id: str, update_data: AmbulanceUpdate):
    """Update ambulance information."""
    try:
        # Only include non-None fields
        update_dict = {k: v for k, v in update_data.dict().items() if v is not None}

        if not update_dict:
            raise HTTPException(status_code=400, detail="No update data provided")

        ambulance = await AmbulanceService.update_ambulance(ambulance_id, update_dict)
        return {"data": ambulance, "error": None}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error updating ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/{ambulance_id}")
async def delete_ambulance(ambulance_id: str):
    """Delete an ambulance."""
    try:
        success = await AmbulanceService.delete_ambulance(ambulance_id)

        if not success:
            raise HTTPException(status_code=404, detail="Ambulance not found")

        return {"data": {"deleted": True}, "error": None}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error deleting ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# CAMERA MANAGEMENT ENDPOINTS
# ==============================================================================


@router.get("/{ambulance_id}/cameras")
async def get_ambulance_cameras(ambulance_id: str):
    """Get all cameras for a specific ambulance."""
    try:
        cameras = await AmbulanceService.get_ambulance_cameras(ambulance_id)
        return {"data": cameras, "error": None}
    except Exception as e:
        logger.error("Error fetching cameras for ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/{ambulance_id}/cameras")
async def add_camera_to_ambulance(ambulance_id: str, camera_data: CameraCreate):
    """Add a camera to an ambulance."""
    try:
        camera = await AmbulanceService.add_camera_to_ambulance(
            ambulance_id, camera_data.dict()
        )
        return {"data": camera, "error": None}
    except Exception as e:
        logger.error("Error adding camera to ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/cameras/{camera_id}")
async def update_camera(camera_id: str, update_data: CameraUpdate):
    """Update camera information."""
    try:
        from services.streaming.database_service import StreamingDatabaseService

        # Get current camera
        camera = await StreamingDatabaseService.get_camera_by_id(camera_id)
        if not camera:
            raise HTTPException(status_code=404, detail="Camera not found")

        # Only include non-None fields
        update_dict = {k: v for k, v in update_data.dict().items() if v is not None}

        if not update_dict:
            raise HTTPException(status_code=400, detail="No update data provided")

        # Update camera (this would need to be implemented in the database service)
        # For now, return placeholder
        return {"data": {"updated": True, "camera_id": camera_id}, "error": None}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error updating camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/cameras/{camera_id}")
async def remove_camera(camera_id: str):
    """Remove a camera from an ambulance."""
    try:
        success = await AmbulanceService.remove_camera_from_ambulance(camera_id)

        if not success:
            raise HTTPException(status_code=404, detail="Camera not found")

        return {"data": {"deleted": True}, "error": None}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error removing camera %s: %s", camera_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ==============================================================================
# AMBULANCE STATUS AND SESSIONS
# ==============================================================================


@router.get("/{ambulance_id}/active-sessions")
async def get_ambulance_active_sessions(ambulance_id: str):
    """Get all active streaming sessions for an ambulance."""
    try:
        sessions = await AmbulanceService.get_ambulance_active_sessions(ambulance_id)
        return {"data": sessions, "error": None}
    except Exception as e:
        logger.error(
            "Error fetching active sessions for ambulance %s: %s", ambulance_id, e
        )
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/{ambulance_id}/status")
async def update_ambulance_status(
    ambulance_id: str, status: str, location: Optional[str] = None
):
    """Update ambulance status and location."""
    try:
        update_data = {"status": status}
        if location:
            update_data["current_location"] = location

        ambulance = await AmbulanceService.update_ambulance(ambulance_id, update_data)
        return {"data": ambulance, "error": None}
    except Exception as e:
        logger.error("Error updating ambulance status %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e
