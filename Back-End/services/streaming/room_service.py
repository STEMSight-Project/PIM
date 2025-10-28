"""
Room service for managing WebRTC rooms and connections.
"""

import asyncio
import time
from typing import Set, Optional
from aiortc import RTCPeerConnection
from core.common import logger
from services.streaming.database_service import StreamingDatabaseService
from services.streaming.recording_service import recording_manager


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
        self.streamer_pcs: Set[RTCPeerConnection] = (
            set()
        )  # Track streamer connections separately
        self.viewer_pcs: Set[RTCPeerConnection] = (
            set()
        )  # Track viewer connections separately
        self.is_active = True
        self.reconnect_timeout_task: Optional[asyncio.Task] = None
        self._db_service = StreamingDatabaseService()

        # Stream activity monitoring
        self.last_data_timestamp = time.time()  # Track last data activity
        self.activity_monitor_task: Optional[asyncio.Task] = None
        self.STREAM_TIMEOUT_SECONDS = 30  # End stream if no data for 30 seconds

        # Video track for recording
        self.video_track = None

    async def close(self):
        """Close all peer connections and clean up resources."""
        try:
            if self.is_active:
                # Cancel activity monitoring task
                if self.activity_monitor_task:
                    self.activity_monitor_task.cancel()
                    self.activity_monitor_task = None

                # Update room status in database
                if self.room_db_id:
                    await self._db_service.update_camera_room_status(
                        self.room_db_id, connected=False
                    )

                # Close all peer connections
                for pc in self.pcs:
                    await pc.close()
                self.pcs.clear()
                self.streamer_pcs.clear()
                self.viewer_pcs.clear()

                self.is_active = False

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error("Error closing room %s: %s", self.room_id, str(e))
            raise
        except Exception as e:
            logger.error("Unexpected error closing room %s: %s", self.room_id, str(e))
            raise

    async def handle_disconnection(self):
        """Handle room disconnection with potential for reconnection."""
        try:
            if not self.is_active:
                return

            # Cancel activity monitoring task
            if self.activity_monitor_task:
                self.activity_monitor_task.cancel()
                self.activity_monitor_task = None

            # Update room status to disconnected (but keep session active)
            if self.room_db_id:
                await self._db_service.update_camera_room_status(
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

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Error handling disconnection for room %s: %s", self.room_id, str(e)
            )
            raise
        except Exception as e:
            logger.error(
                "Unexpected error handling disconnection for room %s: %s",
                self.room_id,
                str(e),
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
                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=True
                )

            # Reset activity timestamp and restart monitoring
            self.last_data_timestamp = time.time()
            if len(self.streamer_pcs) > 0:
                self._start_activity_monitoring()

            self.is_active = True
            logger.info("Room %s reactivated successfully", self.room_id)

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error("Error reactivating room %s: %s", self.room_id, str(e))
            raise
        except Exception as e:
            logger.error(
                "Unexpected error reactivating room %s: %s", self.room_id, str(e)
            )
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
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Error in reconnection timeout for room %s: %s", self.room_id, str(e)
            )
            raise
        except Exception as e:
            logger.error(
                "Unexpected error in reconnection timeout for room %s: %s",
                self.room_id,
                str(e),
            )
            raise

    def update_stream_activity(self):
        """Update the last data timestamp when stream data is received."""
        old_timestamp = self.last_data_timestamp
        self.last_data_timestamp = time.time()

        # DEBUG: Log EVERY update to verify this is being called on every frame
        # This should fire ~30 times per second if working correctly
        logger.debug(
            "[FRAME] Room %s activity updated (delta: %.4fs)",
            self.room_id,
            self.last_data_timestamp - old_timestamp if old_timestamp else 0,
        )

    def _start_activity_monitoring(self):
        """Start monitoring stream activity for timeout."""
        if self.activity_monitor_task and not self.activity_monitor_task.done():
            return  # Already monitoring

        self.activity_monitor_task = asyncio.create_task(
            self._monitor_stream_activity()
        )
        logger.info("Started stream activity monitoring for room %s", self.room_id)

    def _stop_activity_monitoring(self):
        """Stop monitoring stream activity."""
        if self.activity_monitor_task:
            self.activity_monitor_task.cancel()
            self.activity_monitor_task = None
            logger.info("Stopped stream activity monitoring for room %s", self.room_id)

    async def _monitor_stream_activity(self):
        """Monitor stream activity and end room if no data for specified timeout."""
        try:
            logger.info(
                "[MONITOR] Started activity monitoring for room %s (timeout: %ds)",
                self.room_id,
                self.STREAM_TIMEOUT_SECONDS,
            )

            while self.is_active and len(self.streamer_pcs) > 0:
                await asyncio.sleep(5)  # Check every 5 seconds

                # Calculate time since last data
                time_since_data = time.time() - self.last_data_timestamp

                # DEBUG: Log monitoring check
                logger.debug(
                    "[MONITOR] Room %s check: active=%s, streamers=%d, last_data=%.2fs ago",
                    self.room_id,
                    self.is_active,
                    len(self.streamer_pcs),
                    time_since_data,
                )

                if time_since_data >= self.STREAM_TIMEOUT_SECONDS:
                    logger.warning(
                        "Room %s has been inactive for %d seconds (timeout: %d), ending stream",
                        self.room_id,
                        int(time_since_data),
                        self.STREAM_TIMEOUT_SECONDS,
                    )

                    # End the stream session due to inactivity
                    await self._end_session_due_to_inactivity()
                    break

                # Log periodic status for monitoring
                if int(time_since_data) % 15 == 0 and time_since_data >= 15:
                    logger.info(
                        "Room %s: %d seconds since last data (will timeout at %d)",
                        self.room_id,
                        int(time_since_data),
                        self.STREAM_TIMEOUT_SECONDS,
                    )

            # Loop exited - log why
            logger.info(
                "[MONITOR] Monitoring loop exited for room %s: active=%s, streamers=%d",
                self.room_id,
                self.is_active,
                len(self.streamer_pcs),
            )

        except asyncio.CancelledError:
            logger.info(
                "[MONITOR] Stream activity monitoring cancelled for room %s",
                self.room_id,
            )
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Database error in activity monitoring for room %s: %s",
                self.room_id,
                str(e),
            )
        except Exception as e:
            logger.error(
                "Unexpected error in activity monitoring for room %s: %s",
                self.room_id,
                str(e),
            )

    async def _end_session_due_to_inactivity(self):
        """End the streaming session due to inactivity."""
        try:
            # End the ambulance session (which also disconnects all camera rooms)
            if self.session_id:
                await self._db_service.end_ambulance_session(self.session_id)
                logger.info(
                    "Ended session %s for room %s due to stream inactivity (no data for %d seconds)",
                    self.session_id,
                    self.room_id,
                    self.STREAM_TIMEOUT_SECONDS,
                )

            # Close the room
            await self.close()

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Database error ending session for room %s: %s", self.room_id, str(e)
            )
            raise
        except Exception as e:
            logger.error(
                "Unexpected error ending session for room %s: %s", self.room_id, str(e)
            )
            raise

    def add_peer_connection(self, pc: RTCPeerConnection, is_streamer: bool = False):
        """Add a peer connection to this room.

        Args:
            pc: The peer connection to add
            is_streamer: True if this is a streamer (RPi) connection, False for viewer
        """
        # Ensure the connection isn't already tracked
        if pc in self.pcs:
            logger.warning(
                "Peer connection already exists in room %s, ignoring duplicate add",
                self.room_id,
            )
            return

        was_streamer_empty = len(self.streamer_pcs) == 0
        self.pcs.add(pc)

        if is_streamer:
            self.streamer_pcs.add(pc)
            logger.info(
                "Added STREAMER connection to room %s (streamers: %d, viewers: %d)",
                self.room_id,
                len(self.streamer_pcs),
                len(self.viewer_pcs),
            )
            self.log_connection_state()

            # Only update room status to connected when STREAMER joins
            if was_streamer_empty:
                logger.info(
                    "Room %s now has streamer connection, updating status to connected",
                    self.room_id,
                )
                asyncio.create_task(self._update_room_connected())

                # Schedule recording to start after video track is received
                if self.session_id:
                    asyncio.create_task(self._start_recording_when_track_ready())

                # Start activity monitoring when first streamer connects
                self.last_data_timestamp = time.time()
                self._start_activity_monitoring()
        else:
            self.viewer_pcs.add(pc)
            logger.info(
                "Added VIEWER connection to room %s (streamers: %d, viewers: %d)",
                self.room_id,
                len(self.streamer_pcs),
                len(self.viewer_pcs),
            )
            self.log_connection_state()

    def remove_peer_connection(self, pc: RTCPeerConnection):
        """Remove a peer connection from this room."""
        if pc in self.pcs:
            self.pcs.remove(pc)

            # Check if this was a streamer connection
            if pc in self.streamer_pcs:
                self.streamer_pcs.remove(pc)
                logger.info(
                    "Removed STREAMER connection from room %s (streamers: %d, viewers: %d)",
                    self.room_id,
                    len(self.streamer_pcs),
                    len(self.viewer_pcs),
                )
                self.log_connection_state()

                # Only update room status to disconnected when NO STREAMERS remain
                if len(self.streamer_pcs) == 0:
                    logger.info(
                        "Room %s has no streamer connections, updating status to disconnected",
                        self.room_id,
                    )
                    # Stop activity monitoring when no streamers remain
                    self._stop_activity_monitoring()
                    asyncio.create_task(self._update_room_disconnected())

                    # Stop HLS recording when last streamer disconnects
                    if self.session_id:
                        try:
                            logger.info(
                                f"Stopping HLS recording for session {self.session_id}"
                            )
                            asyncio.create_task(
                                recording_manager.stop_session_recording(
                                    self.session_id
                                )
                            )
                        except Exception as e:
                            logger.error(
                                f"Failed to stop recording for session {self.session_id}: {e}"
                            )

            # Check if this was a viewer connection
            elif pc in self.viewer_pcs:
                self.viewer_pcs.remove(pc)
                logger.info(
                    "Removed VIEWER connection from room %s (streamers: %d, viewers: %d)",
                    self.room_id,
                    len(self.streamer_pcs),
                    len(self.viewer_pcs),
                )
                self.log_connection_state()
                # Viewers disconnecting does NOT affect room connection status

            else:
                # Connection not found in either set - this shouldn't happen but log it
                logger.warning(
                    "Removed UNKNOWN connection from room %s (not in streamer or viewer sets) - (streamers: %d, viewers: %d)",
                    self.room_id,
                    len(self.streamer_pcs),
                    len(self.viewer_pcs),
                )
                # Assume it's a viewer and don't affect room status

    async def _update_room_disconnected(self):
        """Update room status to disconnected when no STREAMER connections remain."""
        try:
            if self.room_db_id:
                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=False
                )
                logger.info(
                    "Updated room %s status to disconnected in database (no streamers remaining)",
                    self.room_id,
                )
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Database error updating room %s status to disconnected: %s",
                self.room_id,
                str(e),
            )
        except Exception as e:
            logger.error(
                "Unexpected error updating room %s status to disconnected: %s",
                self.room_id,
                str(e),
            )

    async def _update_room_connected(self):
        """Update room status to connected when first STREAMER connection is added."""
        try:
            if self.room_db_id:
                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=True
                )
                logger.info(
                    "Updated room %s status to connected in database (streamer connected)",
                    self.room_id,
                )
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Database error updating room %s status to connected: %s",
                self.room_id,
                str(e),
            )
        except Exception as e:
            logger.error(
                "Unexpected error updating room %s status to connected: %s",
                self.room_id,
                str(e),
            )

    def get_connection_info(self) -> dict:
        """Get detailed connection information for monitoring."""
        time_since_data = (
            time.time() - self.last_data_timestamp if self.last_data_timestamp else 0
        )
        return {
            "room_id": self.room_id,
            "total_connections": len(self.pcs),
            "streamer_connections": len(self.streamer_pcs),
            "viewer_connections": len(self.viewer_pcs),
            "is_active": self.is_active,
            "has_streamers": len(self.streamer_pcs) > 0,
            "last_data_timestamp": self.last_data_timestamp,
            "seconds_since_data": int(time_since_data),
            "timeout_seconds": self.STREAM_TIMEOUT_SECONDS,
            "is_monitoring_activity": self.activity_monitor_task is not None
            and not self.activity_monitor_task.done(),
        }

    def log_connection_state(self):
        """Log current connection state for debugging."""
        time_since_data = (
            time.time() - self.last_data_timestamp if self.last_data_timestamp else 0
        )
        monitoring_status = (
            "monitoring"
            if (self.activity_monitor_task and not self.activity_monitor_task.done())
            else "not monitoring"
        )

        logger.info(
            "Room %s connection state: total=%d, streamers=%d, viewers=%d, active=%s, data_age=%ds, activity=%s",
            self.room_id,
            len(self.pcs),
            len(self.streamer_pcs),
            len(self.viewer_pcs),
            self.is_active,
            int(time_since_data),
            monitoring_status,
        )

    async def _start_recording_when_track_ready(self):
        """Wait for video track to be available, then start recording"""
        try:
            # Wait up to 10 seconds for video track
            for _ in range(20):  # 20 * 0.5 = 10 seconds
                if self.video_track:
                    # Video track is available, start recording
                    ambulance_number = (
                        self.room_id.split("-")[1] if "-" in self.room_id else "unknown"
                    )
                    logger.info(
                        f"Video track ready, starting HLS recording for session {self.session_id}"
                    )

                    await recording_manager.start_session_recording(
                        self.session_id, ambulance_number, self.video_track
                    )
                    return

                await asyncio.sleep(0.5)

            # Timeout - video track never received
            logger.error(
                f"Timeout waiting for video track for session {self.session_id}"
            )

        except Exception as e:
            logger.error(
                f"Failed to start recording for session {self.session_id}: {e}"
            )


class RoomManager:
    """Manages multiple rooms and their lifecycle."""

    def __init__(self):
        self.rooms: dict[str, Room] = {}
        self.cleanup_task: Optional[asyncio.Task] = None
        self.session_monitor_task: Optional[asyncio.Task] = None
        self.session_inactivity_timers: dict[str, asyncio.Task] = (
            {}
        )  # session_id -> timeout task
        self.SESSION_TIMEOUT_MINUTES = (
            20  # End session if no active cameras for 20 minutes
        )

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
            except (OSError, ConnectionError, RuntimeError) as e:
                logger.error("Database error in periodic cleanup: %s", str(e))
            except Exception as e:
                logger.error("Unexpected error in periodic cleanup: %s", str(e))

    async def _cleanup_inactive_rooms(self):
        """Clean up rooms that are no longer active."""
        try:
            # Clean up database first
            db_service = StreamingDatabaseService()
            cleaned_count = await db_service.cleanup_inactive_camera_rooms()

            # Clean up in-memory rooms that are inactive and have no streamer connections
            inactive_rooms = [
                room_id
                for room_id, room in self.rooms.items()
                if not room.is_active and len(room.streamer_pcs) == 0
            ]

            for room_id in inactive_rooms:
                await self.remove_room(room_id)

            if cleaned_count > 0 or inactive_rooms:
                logger.info(
                    "Cleanup completed: %d DB rooms, %d memory rooms",
                    cleaned_count,
                    len(inactive_rooms),
                )

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error("Database error during room cleanup: %s", str(e))
        except Exception as e:
            logger.error("Unexpected error during room cleanup: %s", str(e))

    async def start_session_monitoring(self):
        """Start the periodic session monitoring task."""
        if self.session_monitor_task and not self.session_monitor_task.done():
            return  # Already running

        self.session_monitor_task = asyncio.create_task(self._monitor_sessions())
        logger.info("Started session monitoring task")

    async def _monitor_sessions(self):
        """Periodically monitor sessions for inactivity and end them after timeout."""
        while True:
            try:
                await asyncio.sleep(60)  # Check every 1 minute
                await self._check_session_inactivity()
            except asyncio.CancelledError:
                logger.info("Session monitoring task cancelled")
                break
            except (OSError, ConnectionError, RuntimeError) as e:
                logger.error("Database error in session monitoring: %s", str(e))
            except Exception as e:
                logger.error("Unexpected error in session monitoring: %s", str(e))

    async def _check_session_inactivity(self):
        """Check all active sessions and start/cancel timeout timers."""
        try:
            db_service = StreamingDatabaseService()

            # Get all active sessions
            active_sessions = await db_service.get_all_ambulance_sessions(
                is_active=True, limit=100
            )

            for session in active_sessions:
                session_id = session["id"]

                # Check if session has any active cameras
                has_active = await db_service.has_active_cameras(session_id)

                if has_active:
                    # Session has active cameras - cancel any existing timeout timer
                    if session_id in self.session_inactivity_timers:
                        self.session_inactivity_timers[session_id].cancel()
                        del self.session_inactivity_timers[session_id]
                        logger.info(
                            "Session %s has active cameras - timeout timer cancelled",
                            session_id,
                        )
                else:
                    # Session has NO active cameras
                    if session_id not in self.session_inactivity_timers:
                        # Start new timeout timer
                        timeout_task = asyncio.create_task(
                            self._handle_session_timeout(session_id)
                        )
                        self.session_inactivity_timers[session_id] = timeout_task
                        logger.warning(
                            "Session %s has no active cameras - started %d minute timeout timer",
                            session_id,
                            self.SESSION_TIMEOUT_MINUTES,
                        )

        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error("Database error checking session inactivity: %s", str(e))
        except Exception as e:
            logger.error("Unexpected error checking session inactivity: %s", str(e))

    async def _handle_session_timeout(self, session_id: str):
        """Handle session timeout after no active cameras for configured duration."""
        try:
            # Wait for configured timeout (20 minutes)
            await asyncio.sleep(self.SESSION_TIMEOUT_MINUTES * 60)

            # Verify session still has no active cameras
            db_service = StreamingDatabaseService()
            has_active = await db_service.has_active_cameras(session_id)

            if not has_active:
                logger.warning(
                    "Session %s has had no active cameras for %d minutes - ending session",
                    session_id,
                    self.SESSION_TIMEOUT_MINUTES,
                )

                # End the session
                await db_service.end_ambulance_session(session_id)

                # Remove from tracking
                if session_id in self.session_inactivity_timers:
                    del self.session_inactivity_timers[session_id]

                logger.info("Session %s ended due to inactivity", session_id)
            else:
                # Camera reconnected during timeout period
                logger.info(
                    "Session %s timeout cancelled - camera reconnected", session_id
                )
                if session_id in self.session_inactivity_timers:
                    del self.session_inactivity_timers[session_id]

        except asyncio.CancelledError:
            # Timeout was cancelled (camera reconnected)
            logger.info(
                "Timeout cancelled for session %s - camera reconnected", session_id
            )
            if session_id in self.session_inactivity_timers:
                del self.session_inactivity_timers[session_id]
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "Database error in session timeout for %s: %s", session_id, str(e)
            )
        except Exception as e:
            logger.error(
                "Unexpected error in session timeout for %s: %s", session_id, str(e)
            )


# Global room manager instance
room_manager = RoomManager()
