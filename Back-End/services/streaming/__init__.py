"""
Ambulance-based streaming services package.
Updated to use ambulance_streaming_sessions and camera_streaming_rooms schema.
"""

from .database_service import StreamingDatabaseService
from .room_service import Room, RoomManager, room_manager
from .webrtc_service import WebRTCService, webrtc_service
from .models import (
    SDPBody,
    AmbulanceSessionCreate,
    AmbulanceSessionUpdate,
    AmbulanceSessionResponse,
    CameraRoomCreate,
    CameraRoomUpdate,
    CameraRoomResponse,
    AmbulanceStreamingStatus,
)

__all__ = [
    "StreamingDatabaseService",
    "Room",
    "RoomManager",
    "room_manager",
    "WebRTCService",
    "webrtc_service",
    "SDPBody",
    "AmbulanceSessionCreate",
    "AmbulanceSessionUpdate",
    "AmbulanceSessionResponse",
    "CameraRoomCreate",
    "CameraRoomUpdate",
    "CameraRoomResponse",
    "AmbulanceStreamingStatus",
]
