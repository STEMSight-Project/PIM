"""
Pydantic models for ambulance-based streaming service.
Updated to use ambulance_streaming_sessions and camera_streaming_rooms schema.
"""

from typing import Optional, List
from pydantic import BaseModel


class SDPBody(BaseModel):
    sdp: str
    type: str


class AmbulanceSessionCreate(BaseModel):
    ambulance_id: str
    session_name: Optional[str] = None
    session_type: str = "emergency"
    incident_id: Optional[str] = None
    priority_level: int = 3


class AmbulanceSessionUpdate(BaseModel):
    session_name: Optional[str] = None
    session_type: Optional[str] = None
    incident_id: Optional[str] = None
    priority_level: Optional[int] = None
    is_active: Optional[bool] = None


class CameraRoomCreate(BaseModel):
    camera_id: str
    room_id: Optional[str] = None
    device_name: Optional[str] = "Camera Device"


class CameraRoomUpdate(BaseModel):
    connected: Optional[bool] = None
    ended_at: Optional[str] = None


class CameraRoomResponse(BaseModel):
    id: str
    session_id: str
    camera_id: str
    room_id: str
    connected: bool
    connection_started_at: str
    connection_ended_at: Optional[str] = None
    created_at: str
    updated_at: str


class AmbulanceSessionResponse(BaseModel):
    id: str
    ambulance_id: str
    session_type: str
    incident_id: Optional[str] = None
    priority_level: int
    is_active: bool
    started_at: str
    ended_at: Optional[str] = None
    created_at: str
    updated_at: str
    camera_rooms: List[CameraRoomResponse] = []


class AmbulanceStreamingStatus(BaseModel):
    ambulance_id: str
    vehicle_number: str
    station_id: str
    status: str
    session_id: Optional[str] = None
    session_type: Optional[str] = None
    session_started: Optional[str] = None
    total_cameras: int = 0
    connected_cameras: int = 0
    active_camera_rooms: List[dict] = []
