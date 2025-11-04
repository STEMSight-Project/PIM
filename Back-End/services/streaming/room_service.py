"""
Room service for managing WebRTC rooms and connections.
"""

import asyncio
import time
from typing import Set, Optional
from datetime import datetime
from aiortc import RTCPeerConnection
from core.common import logger
from services.streaming.database_service import StreamingDatabaseService
from services.streaming.recording_service import recording_manager


class StreamActivityMonitor:
    """
    Professional monitor for stream activity with automatic timeout handling.

    Note: room_id parameter stores the room_name (display name like "AMB-001-ROOM-001").
    """

    TIMEOUT_SECONDS = 120  # Increased to 120 seconds (2 minutes) for stability
    CHECK_INTERVAL = 10  # Check every 10 seconds (reduced overhead)

    def __init__(self, room_id: str, session_id: Optional[str] = None):
        self.room_id = room_id  # This is actually room_name (e.g., "AMB-001-ROOM-001")
        self.session_id = session_id
        self.last_data_timestamp = time.time()
        self.monitor_task: Optional[asyncio.Task] = None
        self._db_service = StreamingDatabaseService()
        self.is_monitoring = False
        self._has_received_frames = False  # Track if any frames received

    def update_activity(self):
        """Update the last data timestamp when stream data is received."""
        old_timestamp = self.last_data_timestamp
        self.last_data_timestamp = time.time()
        self._has_received_frames = True

        # Log frame activity for debugging (reduced frequency to avoid spam)
        if (
            not hasattr(self, "_last_log_time")
            or (self.last_data_timestamp - self._last_log_time) > 10
        ):
            logger.debug(
                "[FRAME] Room %s activity updated (delta: %.4fs)",
                self.room_id,
                self.last_data_timestamp - old_timestamp if old_timestamp else 0,
            )
            self._last_log_time = self.last_data_timestamp

    def start_monitoring(self, streamer_count: int):
        """Start monitoring stream activity."""
        if self.monitor_task and not self.monitor_task.done():
            logger.debug(f"[MONITOR] Already monitoring room {self.room_id}")
            return

        self.is_monitoring = True
        self.last_data_timestamp = time.time()
        self.monitor_task = asyncio.create_task(self._monitor_loop(streamer_count))
        logger.info(
            f"✅ [MONITOR] Started activity monitoring for room {self.room_id} "
            f"(timeout: {self.TIMEOUT_SECONDS}s)"
        )

    def stop_monitoring(self):
        """Stop monitoring stream activity."""
        if self.monitor_task and not self.monitor_task.done():
            self.is_monitoring = False
            self.monitor_task.cancel()
            self.monitor_task = None
            logger.info(
                f"🛑 [MONITOR] Stopped activity monitoring for room {self.room_id}"
            )

    async def _monitor_loop(self, initial_streamer_count: int):
        """Monitor stream activity and end room if no data for timeout period."""
        try:
            logger.info(
                f"[MONITOR] Monitoring loop started for room {self.room_id} "
                f"({initial_streamer_count} streamers)"
            )

            while self.is_monitoring:
                await asyncio.sleep(self.CHECK_INTERVAL)

                # Calculate time since last data
                time_since_data = time.time() - self.last_data_timestamp

                # Only log if significant time has passed or approaching timeout
                if time_since_data >= 10:
                    logger.info(
                        f"[MONITOR] Room {self.room_id} check: last_data={time_since_data:.2f}s ago "
                        f"(has_received_frames={self._has_received_frames})"
                    )
                else:
                    logger.debug(
                        f"[MONITOR] Room {self.room_id} check: last_data={time_since_data:.2f}s ago"
                    )

                # Check timeout - only if frames were previously received
                if time_since_data >= self.TIMEOUT_SECONDS:
                    # Only timeout if we've actually received frames before
                    # This prevents timeout on initial connection
                    if self._has_received_frames:
                        logger.error(
                            f"❌ [MONITOR] Room {self.room_id} TIMEOUT after {int(time_since_data)}s "
                            f"(timeout: {self.TIMEOUT_SECONDS}s, had frames but stopped)"
                        )
                        # Stop monitoring first to prevent re-entry
                        self.is_monitoring = False
                        await self._end_session_due_to_inactivity()
                        break
                    else:
                        # Still waiting for first frame - reset timer
                        logger.warning(
                            f"⏳ [MONITOR] Room {self.room_id} waiting for first frame "
                            f"({int(time_since_data)}s elapsed)"
                        )
                        self.last_data_timestamp = (
                            time.time()
                        )  # Reset to give more time

                # Log periodic status
                if int(time_since_data) >= 15 and int(time_since_data) % 15 == 0:
                    remaining = self.TIMEOUT_SECONDS - int(time_since_data)
                    logger.info(
                        f"[MONITOR] Room {self.room_id}: {int(time_since_data)}s since last data "
                        f"({remaining}s until timeout)"
                    )

        except asyncio.CancelledError:
            logger.info(f"[MONITOR] Monitoring cancelled for room {self.room_id}")
        except Exception as e:
            logger.error(
                f"[MONITOR] Error in monitoring loop for room {self.room_id}: {e}"
            )
        finally:
            # Ensure monitoring is marked as stopped
            self.is_monitoring = False
            logger.info(f"[MONITOR] Monitoring loop exited for room {self.room_id}")

    async def _end_session_due_to_inactivity(self):
        """End the streaming session due to inactivity."""
        try:
            if self.session_id:
                await self._db_service.end_ambulance_session(self.session_id)
                logger.info(
                    f"✅ [MONITOR] Ended session {self.session_id} for room {self.room_id} "
                    f"due to stream inactivity (no data for {self.TIMEOUT_SECONDS}s)"
                )
        except Exception as e:
            logger.error(f"[MONITOR] Error ending session for room {self.room_id}: {e}")

    def get_status(self) -> dict:
        """Get current monitoring status."""
        time_since_data = time.time() - self.last_data_timestamp
        return {
            "is_monitoring": self.is_monitoring,
            "last_activity_seconds_ago": time_since_data,
            "timeout_seconds": self.TIMEOUT_SECONDS,
            "will_timeout_in_seconds": max(0, self.TIMEOUT_SECONDS - time_since_data),
        }


class ReconnectionHandler:
    """
    Professional handler for room reconnection with 5-minute grace period.

    Note: room_id parameter stores the room_name (display name like "AMB-001-ROOM-001").
    room_db_id stores the UUID from the database.
    """

    RECONNECTION_TIMEOUT = 300  # 5 minutes

    def __init__(self, room_id: str, room_db_id: Optional[str] = None):
        self.room_id = room_id  # This is actually room_name (e.g., "AMB-001-ROOM-001")
        self.room_db_id = room_db_id  # This is the UUID from database
        self.timeout_task: Optional[asyncio.Task] = None
        self.reconnection_start_time: Optional[datetime] = None
        self._db_service = StreamingDatabaseService()

    async def start_reconnection_window(self):
        """Start the 5-minute reconnection window."""
        if self.timeout_task and not self.timeout_task.done():
            logger.debug(
                f"[RECONNECT] Already waiting for reconnection on room {self.room_id}"
            )
            return

        self.reconnection_start_time = datetime.utcnow()
        self.timeout_task = asyncio.create_task(self._handle_timeout())

        # Update room status to disconnected
        if self.room_db_id:
            await self._db_service.update_camera_room_status(
                self.room_db_id, connected=False
            )

        logger.warning(
            f"⏱️ [RECONNECT] Started 5-minute reconnection window for room {self.room_id}"
        )

    async def cancel_reconnection(self):
        """Cancel reconnection timeout (successful reconnection)."""
        if self.timeout_task and not self.timeout_task.done():
            self.timeout_task.cancel()
            try:
                await self.timeout_task
            except asyncio.CancelledError:
                pass

            self.timeout_task = None
            self.reconnection_start_time = None

            # Update room status to connected
            if self.room_db_id:
                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=True
                )

            elapsed = (
                datetime.utcnow() - (self.reconnection_start_time or datetime.utcnow())
            ).total_seconds()
            logger.info(
                f"✅ [RECONNECT] Room {self.room_id} reconnected successfully after {elapsed:.1f}s"
            )

    async def _handle_timeout(self):
        """Handle reconnection timeout - permanently close after 5 minutes."""
        try:
            logger.info(
                f"[RECONNECT] Room {self.room_id}: Waiting up to {self.RECONNECTION_TIMEOUT}s for reconnection"
            )

            await asyncio.sleep(self.RECONNECTION_TIMEOUT)

            # Timeout reached
            logger.error(
                f"❌ [RECONNECT] Room {self.room_id} timed out after {self.RECONNECTION_TIMEOUT}s, "
                "closing permanently"
            )
            # The close will be handled by the room itself

        except asyncio.CancelledError:
            logger.info(
                f"[RECONNECT] Timeout cancelled for room {self.room_id} (reconnected)"
            )

    def get_status(self) -> dict:
        """Get reconnection status."""
        if not self.reconnection_start_time:
            return {"is_waiting": False}

        elapsed = (datetime.utcnow() - self.reconnection_start_time).total_seconds()
        remaining = max(0, self.RECONNECTION_TIMEOUT - elapsed)

        return {
            "is_waiting": True,
            "elapsed_seconds": elapsed,
            "remaining_seconds": remaining,
            "timeout_seconds": self.RECONNECTION_TIMEOUT,
        }


class Room:
    """
    Manages a WebRTC room with peer connections and database sync.

    Note: room_id parameter stores the room_name (display name like "AMB-001-ROOM-001").
    room_db_id stores the UUID from the database.
    """

    def __init__(
        self,
        room_id: str,
        session_id: Optional[str] = None,
        room_db_id: Optional[str] = None,
    ):
        self.room_id = room_id  # room_name for display (e.g., "AMB-001-ROOM-001")
        self.session_id = session_id
        self.room_db_id = room_db_id  # UUID from database (used for recording folders)
        self.pcs: Set[RTCPeerConnection] = set()
        self.streamer_pcs: Set[RTCPeerConnection] = set()
        self.viewer_pcs: Set[RTCPeerConnection] = set()
        self.is_active = True
        self._db_service = StreamingDatabaseService()

        # Professional handlers (NEW!)
        self.activity_monitor = StreamActivityMonitor(room_id, session_id)
        self.reconnection_handler = ReconnectionHandler(room_id, room_db_id)

        # DEPRECATED: Old monitoring attributes (keeping for backward compatibility)
        self.reconnect_timeout_task: Optional[asyncio.Task] = None
        self.last_data_timestamp = time.time()
        self.activity_monitor_task: Optional[asyncio.Task] = None
        self.STREAM_TIMEOUT_SECONDS = 30

        # Video track for recording AND for new viewer connections
        self.video_track = None
        self.relayed_track = None  # Store relayed track for new viewers

        # ✅ NEW: Track if we've received actual video data before marking as connected
        self._first_frame_received = False
        self._waiting_for_first_frame = False

    async def close(self):
        """Close all peer connections and clean up resources."""
        try:
            if self.is_active:
                # Stop professional handlers
                self.activity_monitor.stop_monitoring()

                # Cancel reconnection if active
                if self.reconnection_handler.timeout_task:
                    self.reconnection_handler.timeout_task.cancel()

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
                logger.info(f"✅ [CLOSE] Room {self.room_id} closed successfully")

        except Exception as e:
            logger.error(f"[CLOSE] Error closing room {self.room_id}: {e}")
            raise

    async def handle_disconnection(self):
        """Handle room disconnection with potential for reconnection."""
        try:
            if not self.is_active:
                return

            # Stop activity monitoring
            self.activity_monitor.stop_monitoring()

            # Start 5-minute reconnection window
            await self.reconnection_handler.start_reconnection_window()

            self.is_active = False
            logger.warning(
                f"⚠️ [DISCONNECT] Room {self.room_id} disconnected, waiting for reconnection"
            )

        except Exception as e:
            logger.error(
                f"[DISCONNECT] Error handling disconnection for room {self.room_id}: {e}"
            )
            raise

    async def reactivate(self):
        """Reactivate room for reconnection."""
        try:
            # Cancel reconnection timeout
            await self.reconnection_handler.cancel_reconnection()

            # Restart activity monitoring
            if len(self.streamer_pcs) > 0:
                self.activity_monitor.start_monitoring(len(self.streamer_pcs))

            self.is_active = True
            logger.info(f"✅ [REACTIVATE] Room {self.room_id} reactivated successfully")

        except Exception as e:
            logger.error(f"[REACTIVATE] Error reactivating room {self.room_id}: {e}")
            raise

    def update_stream_activity(self):
        """Update the last data timestamp when stream data is received."""
        # Use professional activity monitor
        self.activity_monitor.update_activity()

        # Update legacy attribute for backward compatibility
        self.last_data_timestamp = time.time()

        # ✅ NEW: Mark that first frame has been received and update room status
        if not self._first_frame_received:
            self._first_frame_received = True
            logger.info(
                f"🎬 [FIRST FRAME] Room {self.room_id} received first video frame, updating status to connected"
            )
            # Update room status to connected NOW that we have actual data
            asyncio.create_task(self._update_room_connected_on_first_frame())

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

            # ✅ IMPROVED: Only start waiting for first frame when STREAMER joins
            # Database update to connected will happen when first frame arrives
            # BUT: If we've already received first frame (reconnection), don't wait again
            if was_streamer_empty:
                if not self._first_frame_received:
                    logger.info(
                        f"⏳ [WAITING] Room {self.room_id} has streamer connection, waiting for first video frame before marking as connected"
                    )
                    self._waiting_for_first_frame = True
                else:
                    # Reconnection case - we already received frames before
                    logger.info(
                        f"✅ [RECONNECTION] Room {self.room_id} streamer reconnected (first frame was already received, marking as connected immediately)"
                    )
                    # Update database immediately for reconnections
                    asyncio.create_task(self._update_room_connected())

                # Schedule recording to start after video track is received
                if self.session_id:
                    print(
                        f"\n🔥🔥🔥 CREATING RECORDING TASK FOR SESSION {self.session_id} 🔥🔥🔥\n"
                    )
                    logger.info(
                        f"🔥 [RECORDING] Creating recording task for session {self.session_id}"
                    )
                    asyncio.create_task(self._start_recording_when_track_ready())

                # Start professional activity monitoring when first streamer connects
                self.activity_monitor.start_monitoring(len(self.streamer_pcs))
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
                    logger.warning(
                        f"⚠️ Room {self.room_id} has no streamer connections, updating status to disconnected"
                    )
                    # Stop professional activity monitoring when no streamers remain
                    self.activity_monitor.stop_monitoring()
                    asyncio.create_task(self._update_room_disconnected())

                    # Stop HLS recording when last streamer disconnects
                    if self.session_id:
                        try:
                            logger.info(
                                f"Stopping HLS recording for room {self.room_id} (session {self.session_id})"
                            )
                            asyncio.create_task(
                                recording_manager.stop_session_recording(self.room_db_id)  # Use UUID
                            )
                        except Exception as e:
                            logger.error(
                                f"Failed to stop recording for room {self.room_id} (session {self.session_id}): {e}"
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
                logger.info(
                    "[DB UPDATE] Starting update for room %s (db_id: %s) to connected=True",
                    self.room_id,
                    self.room_db_id,
                )

                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=True
                )

                logger.info(
                    "✅ [DB UPDATE] Successfully updated room %s status to connected in database",
                    self.room_id,
                )
            else:
                logger.warning(
                    "[DB UPDATE] Room %s has no room_db_id, cannot update database",
                    self.room_id,
                )
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "[DB UPDATE] Database error updating room %s status to connected: %s",
                self.room_id,
                str(e),
            )
        except Exception as e:
            logger.error(
                "[DB UPDATE] Unexpected error updating room %s status to connected: %s",
                self.room_id,
                str(e),
            )

    async def _update_room_connected_on_first_frame(self):
        """Update room status to connected when first video frame is received.

        This is called from update_stream_activity() when the first frame arrives,
        ensuring the camera is actually working before marking as connected.
        """
        try:
            if self.room_db_id:
                logger.info(
                    "✅ [FIRST FRAME DB] Updating room %s (db_id: %s) to connected=True after receiving video data",
                    self.room_id,
                    self.room_db_id,
                )

                await self._db_service.update_camera_room_status(
                    self.room_db_id, connected=True
                )

                logger.info(
                    "✅ [FIRST FRAME DB] Successfully updated room %s status to connected in database (verified working camera)",
                    self.room_id,
                )

                # Reset waiting flag
                self._waiting_for_first_frame = False
            else:
                logger.warning(
                    "[FIRST FRAME DB] Room %s has no room_db_id, cannot update database",
                    self.room_id,
                )
        except (OSError, ConnectionError, RuntimeError) as e:
            logger.error(
                "[FIRST FRAME DB] Database error updating room %s status to connected: %s",
                self.room_id,
                str(e),
            )
        except Exception as e:
            logger.error(
                "[FIRST FRAME DB] Unexpected error updating room %s status to connected: %s",
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
            "first_frame_received": self._first_frame_received,
            "waiting_for_first_frame": self._waiting_for_first_frame,
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

        frame_status = "✅ received" if self._first_frame_received else "⏳ waiting"
        if self._waiting_for_first_frame:
            frame_status = "⏳ waiting (streamer connected)"

        logger.info(
            "Room %s connection state: total=%d, streamers=%d, viewers=%d, active=%s, first_frame=%s, data_age=%ds, activity=%s",
            self.room_id,
            len(self.pcs),
            len(self.streamer_pcs),
            len(self.viewer_pcs),
            self.is_active,
            frame_status,
            int(time_since_data),
            monitoring_status,
        )

    async def _start_recording_when_track_ready(self):
        """Wait for video track to be available, then start recording"""
        print(
            f"\n🔥🔥🔥 _START_RECORDING_WHEN_TRACK_READY CALLED FOR ROOM {self.room_id} 🔥🔥🔥\n"
        )
        try:
            logger.info(f"[RECORDING] Waiting for video track for room {self.room_id}")
            # Wait up to 10 seconds for video track
            for i in range(20):  # 20 * 0.5 = 10 seconds
                logger.debug(
                    f"[RECORDING] Check #{i+1}/20 - video_track is {'AVAILABLE' if self.video_track else 'None'}"
                )
                if self.video_track:
                    # Video track is available, start recording
                    ambulance_number = (
                        self.room_id.split("-")[1] if "-" in self.room_id else "unknown"
                    )
                    logger.info(
                        f"✅ [RECORDING] Video track ready, starting HLS recording for room {self.room_id} (session {self.session_id})"
                    )

                    # Use room_db_id (UUID) for recording folder identification
                    await recording_manager.start_session_recording(
                        self.session_id,
                        self.room_db_id,  # Pass UUID instead of room_name
                        ambulance_number,
                        self.video_track,
                    )
                    logger.info(
                        f"✅ [RECORDING] start_session_recording() completed for room {self.room_id} (UUID: {self.room_db_id})"
                    )
                    return

                await asyncio.sleep(0.5)

            # Timeout - video track never received
            logger.error(
                f"❌ [RECORDING] Timeout waiting for video track for room {self.room_id} (session {self.session_id}) - video_track is still None!"
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

            logger.debug(
                "[SESSION MONITOR] Checking %d active session(s) for camera activity",
                len(active_sessions),
            )

            for session in active_sessions:
                session_id = session["id"]
                ambulance_id = session.get("ambulance_id", "unknown")

                # Check if session has any active cameras
                has_active = await db_service.has_active_cameras(session_id)

                if has_active:
                    # Session has active cameras - cancel any existing timeout timer
                    if session_id in self.session_inactivity_timers:
                        self.session_inactivity_timers[session_id].cancel()
                        del self.session_inactivity_timers[session_id]
                        logger.info(
                            "Session %s (AMB %s) has active cameras - timeout timer cancelled",
                            session_id[:8],
                            ambulance_id,
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
                            "Session %s (AMB %s) has no active cameras - started %d minute timeout timer",
                            session_id[:8],
                            ambulance_id,
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
