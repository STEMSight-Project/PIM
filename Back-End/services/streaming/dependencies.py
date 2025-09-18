"""
Dependency injection for streaming services.
"""

from functools import lru_cache
from services.streaming import (
    StreamingDatabaseService,
    RoomManager,
    WebRTCService,
    room_manager,
    webrtc_service,
)


@lru_cache()
def get_database_service() -> StreamingDatabaseService:
    """Get the streaming database service instance."""
    return StreamingDatabaseService()


@lru_cache()
def get_room_manager() -> RoomManager:
    """Get the room manager instance."""
    return room_manager


@lru_cache()
def get_webrtc_service() -> WebRTCService:
    """Get the WebRTC service instance."""
    return webrtc_service
