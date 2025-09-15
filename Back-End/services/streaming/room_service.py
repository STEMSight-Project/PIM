"""
Room service for managing WebRTC rooms and connections.
"""

import asyncio
from typing import Set, Optional
from aiortc import RTCPeerConnection
from core.common import logger
from services.streaming.database_service import StreamingDatabaseService


class Room:
    """Manages a WebRTC room with peer connections and database sync."""

    def __init__(
        self,
        room_id: str,
        session_id: Optional[str] = None,
        room_db_id: Optional[str] = None,
    ):
        self.room_id = room_id
        self.session_id = session_id
        self.room_db_id = room_db_id
        self.pcs: Set[RTCPeerConnection] = set()
        self.is_active = True
        self.reconnect_timeout_task: Optional[asyncio.Task] = None
        self._db_service = StreamingDatabaseService()

    async def close(self):
        """Close all peer connections and clean up resources."""
        try:
            if self.is_active:
                # Update room status in database
                if self.room_db_id:
                    await self._db_service.update_room_status(
                        self.room_db_id, connected=False
                    )

                # Close all peer connections
                for pc in self.pcs:
                    await pc.close()
                self.pcs.clear()

                self.is_active = False
                logger.info("Room %s closed successfully", self.room_id)

        except Exception as e:
            logger.error("Error closing room %s: %s", self.room_id, e)
            raise

    async def handle_disconnection(self):
        """Handle room disconnection with potential for reconnection."""
        try:
            if not self.is_active:
                return

            # Update room status to disconnected (but keep session active)
            if self.room_db_id:
                await self._db_service.update_room_status(
                    self.room_db_id, connected=False
                )

            # Set up reconnection timeout (5 minutes)
            if self.reconnect_timeout_task:
                self.reconnect_timeout_task.cancel()

            self.reconnect_timeout_task = asyncio.create_task(
                self._handle_reconnection_timeout()
            )

            self.is_active = False
            logger.info(
                "Room %s disconnected, session remains active, waiting for reconnection",
                self.room_id,
            )

        except Exception as e:
            logger.error(
                "Error handling disconnection for room %s: %s", self.room_id, e
            )
            raise

    async def reactivate(self):
        """Reactivate room for reconnection."""
        try:
            if self.reconnect_timeout_task:
                self.reconnect_timeout_task.cancel()
                self.reconnect_timeout_task = None

            # Update room status in database
            if self.room_db_id:
                await self._db_service.update_room_status(
                    self.room_db_id, connected=True
                )

            self.is_active = True
            logger.info("Room %s reactivated successfully", self.room_id)

        except Exception as e:
            logger.error("Error reactivating room %s: %s", self.room_id, e)
            raise

    async def _handle_reconnection_timeout(self):
        """Handle reconnection timeout - permanently close room after waiting."""
        try:
            # Wait 5 minutes for reconnection
            await asyncio.sleep(300)

            if not self.is_active:  # Still inactive after timeout
                logger.info(
                    "Room %s timed out waiting for reconnection, closing permanently",
                    self.room_id,
                )
                await self.close()

        except asyncio.CancelledError:
            # Reconnection happened, timeout was cancelled
            logger.info("Reconnection timeout cancelled for room %s", self.room_id)
        except Exception as e:
            logger.error(
                "Error in reconnection timeout for room %s: %s", self.room_id, e
            )
            raise

    def add_peer_connection(self, pc: RTCPeerConnection):
        """Add a peer connection to this room."""
        self.pcs.add(pc)
        logger.info(
            "Added peer connection to room %s (total: %d)", self.room_id, len(self.pcs)
        )

    def remove_peer_connection(self, pc: RTCPeerConnection):
        """Remove a peer connection from this room."""
        if pc in self.pcs:
            self.pcs.remove(pc)
            logger.info(
                "Removed peer connection from room %s (remaining: %d)",
                self.room_id,
                len(self.pcs),
            )


class RoomManager:
    """Manages multiple rooms and their lifecycle."""

    def __init__(self):
        self.rooms: dict[str, Room] = {}
        self.cleanup_task: Optional[asyncio.Task] = None

    def get_room(self, room_id: str) -> Optional[Room]:
        """Get a room by ID."""
        return self.rooms.get(room_id)

    def create_room(
        self,
        room_id: str,
        session_id: Optional[str] = None,
        room_db_id: Optional[str] = None,
    ) -> Room:
        """Create a new room."""
        if room_id in self.rooms:
            logger.warning("Room %s already exists", room_id)
            return self.rooms[room_id]

        room = Room(room_id, session_id, room_db_id)
        self.rooms[room_id] = room
        logger.info("Created room %s", room_id)
        return room

    async def remove_room(self, room_id: str) -> bool:
        """Remove and close a room."""
        if room_id not in self.rooms:
            return False

        room = self.rooms[room_id]
        await room.close()
        del self.rooms[room_id]
        logger.info("Removed room %s", room_id)
        return True

    def get_all_rooms(self) -> dict[str, Room]:
        """Get all active rooms."""
        return self.rooms.copy()

    async def start_cleanup_task(self):
        """Start the periodic cleanup task."""
        if self.cleanup_task and not self.cleanup_task.done():
            return  # Already running

        self.cleanup_task = asyncio.create_task(self._periodic_cleanup())
        logger.info("Started room cleanup task")

    async def _periodic_cleanup(self):
        """Periodically clean up inactive rooms."""
        while True:
            try:
                await asyncio.sleep(300)  # Check every 5 minutes
                await self._cleanup_inactive_rooms()
            except asyncio.CancelledError:
                logger.info("Room cleanup task cancelled")
                break
            except Exception as e:
                logger.error("Error in periodic cleanup: %s", e)

    async def _cleanup_inactive_rooms(self):
        """Clean up rooms that are no longer active."""
        try:
            # Clean up database first
            db_service = StreamingDatabaseService()
            cleaned_count = await db_service.cleanup_inactive_rooms()

            # Clean up in-memory rooms that are inactive
            inactive_rooms = [
                room_id
                for room_id, room in self.rooms.items()
                if not room.is_active and len(room.pcs) == 0
            ]

            for room_id in inactive_rooms:
                await self.remove_room(room_id)

            if cleaned_count > 0 or inactive_rooms:
                logger.info(
                    "Cleanup completed: %d DB rooms, %d memory rooms",
                    cleaned_count,
                    len(inactive_rooms),
                )

        except Exception as e:
            logger.error("Error during room cleanup: %s", e)


# Global room manager instance
room_manager = RoomManager()
