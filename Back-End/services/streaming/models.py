"""
Pydantic models for streaming service.
"""

from typing import Optional, List
from pydantic import BaseModel


class SDPBody(BaseModel):
    sdp: str
    type: str


class StreamingRoomCreate(BaseModel):
    patient_id: str
    room_id: str
    device_name: str


class StreamingRoomUpdate(BaseModel):
    connected: Optional[bool] = None
    device_name: Optional[str] = None


class StreamingRoomResponse(BaseModel):
    id: str
    session_id: str
    patient_id: str
    room_id: str
    device_name: str
    connected: bool
    started_at: str
    ended_at: Optional[str] = None
    last_seen: str
    created_at: str
    updated_at: str


class StreamingSessionResponse(BaseModel):
    id: str
    patient_id: str
    status: str
    started_at: str
    ended_at: Optional[str] = None
    created_at: str
    updated_at: str
    rooms: List[StreamingRoomResponse] = []


class PatientStreamingStatus(BaseModel):
    patient_id: str
    first_name: str
    last_name: str
    session_id: Optional[str] = None
    session_status: Optional[str] = None
    session_started: Optional[str] = None
    total_rooms: int = 0
    connected_rooms: int = 0
    active_rooms: List[dict] = []


class StreamingSessionData(BaseModel):
    patient_id: str


class StreamingSessionStatusUpdate(BaseModel):
    status: Optional[str] = None
