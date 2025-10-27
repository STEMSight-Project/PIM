"""
WebRTC service for handling peer connections and media relay.
"""

import asyncio
from datetime import datetime, timedelta
from typing import Optional, Dict, Set, TYPE_CHECKING
from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.contrib.media import MediaRelay
from aiortc.mediastreams import MediaStreamError
from core.common import logger
from services.streaming.room_service import room_manager
from services.streaming.models import SDPBody
from services.streaming.database_service import StreamingDatabaseService

if TYPE_CHECKING:
    from services.streaming.room_service import Room


class ReconnectionManager:
    """Professional reconnection manager with 10-second timeout and force close."""

    RECONNECTION_TIMEOUT = 10  # seconds

    def __init__(self):
        self.reconnection_tasks: Dict[str, asyncio.Task] = {}
        self.reconnection_start_times: Dict[str, datetime] = {}

    async def start_reconnection(self, room_id: str, webrtc_service) -> None:
        """Start reconnection monitoring for a room."""
        if room_id in self.reconnection_tasks:
            logger.debug(f"[RECONNECT] Already monitoring room {room_id}")
            return

        logger.warning(
            f"⏱️ [RECONNECT] Starting 10-second reconnection window for room {room_id}"
        )

        start_time = datetime.utcnow()
        self.reconnection_start_times[room_id] = start_time

        task = asyncio.create_task(
            self._monitor_reconnection(room_id, start_time, webrtc_service)
        )
        self.reconnection_tasks[room_id] = task

    async def _monitor_reconnection(
        self, room_id: str, start_time: datetime, webrtc_service
    ) -> None:
        """Monitor for reconnection with timeout."""
        try:
            attempt = 0

            while True:
                attempt += 1
                elapsed = (datetime.utcnow() - start_time).total_seconds()

                # Check timeout
                if elapsed >= self.RECONNECTION_TIMEOUT:
                    logger.error(
                        f"❌ [RECONNECT] Room {room_id} failed to reconnect within "
                        f"{self.RECONNECTION_TIMEOUT}s after {attempt} attempts. Force closing stream."
                    )
                    await self._force_close_stream(room_id, webrtc_service)
                    break

                # Check if reconnected
                room = room_manager.get_room(room_id)
                if room and len(room.streamer_pcs) > 0:
                    for pc in room.streamer_pcs:
                        if pc.connectionState == "connected":
                            logger.info(
                                f"✅ [RECONNECT] Room {room_id} successfully reconnected after "
                                f"{elapsed:.1f}s ({attempt} attempts)"
                            )
                            await self.cancel_reconnection(room_id)
                            return

                # Log progress
                remaining = self.RECONNECTION_TIMEOUT - elapsed
                logger.debug(
                    f"[RECONNECT] Room {room_id}: {remaining:.1f}s remaining (attempt {attempt})"
                )

                await asyncio.sleep(1)

        except asyncio.CancelledError:
            logger.info(
                f"[RECONNECT] Monitoring cancelled for room {room_id} (reconnected successfully)"
            )
        except Exception as e:
            logger.error(f"[RECONNECT] Error monitoring room {room_id}: {e}")
            await self._force_close_stream(room_id, webrtc_service)

    async def cancel_reconnection(self, room_id: str) -> None:
        """Cancel reconnection monitoring for a room."""
        if room_id in self.reconnection_tasks:
            task = self.reconnection_tasks[room_id]

            if not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass

            del self.reconnection_tasks[room_id]
            del self.reconnection_start_times[room_id]

            logger.info(f"[RECONNECT] Cancelled monitoring for room {room_id}")

    async def _force_close_stream(self, room_id: str, webrtc_service) -> None:
        """Force close stream after failed reconnection."""
        try:
            logger.warning(f"🔒 [FORCE-CLOSE] Force closing stream for room {room_id}")

            room = room_manager.get_room(room_id)
            if room:
                # Close all peer connections
                for pc in list(room.pcs):
                    try:
                        pc.close()
                    except Exception as e:
                        logger.error(
                            f"[FORCE-CLOSE] Error closing peer connection: {e}"
                        )

                # Clear room state
                room.pcs.clear()
                room.streamer_pcs.clear()
                room.viewer_pcs.clear()
                room.relayed_track = None
                room.video_track = None

            # Update database via camera disconnection handler
            await webrtc_service._handle_camera_disconnection(room_id)

            # Clean up reconnection tracking
            self.reconnection_tasks.pop(room_id, None)
            self.reconnection_start_times.pop(room_id, None)

            logger.info(
                f"✅ [FORCE-CLOSE] Successfully force closed stream for room {room_id}"
            )

        except Exception as e:
            logger.error(f"[FORCE-CLOSE] Error closing room {room_id}: {e}")

    def get_status(self) -> dict:
        """Get reconnection status for all rooms."""
        current_time = datetime.utcnow()
        return {
            room_id: {
                "elapsed_seconds": (current_time - start_time).total_seconds(),
                "remaining_seconds": max(
                    0,
                    self.RECONNECTION_TIMEOUT
                    - (current_time - start_time).total_seconds(),
                ),
            }
            for room_id, start_time in self.reconnection_start_times.items()
        }

    async def cleanup(self) -> None:
        """Clean up all reconnection tasks."""
        for room_id in list(self.reconnection_tasks.keys()):
            await self.cancel_reconnection(room_id)


class WebRTCService:
    """Service for managing WebRTC peer connections and media streaming."""

    def __init__(self):
        self.relay = MediaRelay()

        # Reconnection manager
        self.reconnection_manager = ReconnectionManager()

        # Camera activity monitoring (DEPRECATED - now handled by room-based monitoring)
        # Keeping for backward compatibility but will be phased out
        self.camera_monitors: Dict[str, Dict] = {}  # room_id -> monitoring data
        self.inactive_timeout = (
            300  # Increased to 5 minutes to avoid conflict with room-based 30s timeout
        )

        # Background monitoring task
        self.monitoring_task = None
        self._start_monitoring()

    def _start_monitoring(self):
        """Start background monitoring task."""
        if self.monitoring_task is None or self.monitoring_task.done():
            self.monitoring_task = asyncio.create_task(self._monitor_cameras())
            logger.info("Started camera monitoring task")

    async def _monitor_cameras(self):
        """Background task to monitor camera activity and update database status."""
        while True:
            try:
                await asyncio.sleep(10)  # Check every 10 seconds
                current_time = datetime.utcnow()

                inactive_rooms = []
                sessions_to_check = set()

                for room_id, monitor_data in list(self.camera_monitors.items()):
                    last_activity = monitor_data.get("last_activity")
                    camera_room_id = monitor_data.get("camera_room_id")
                    session_id = monitor_data.get("session_id")

                    if last_activity and camera_room_id:
                        time_since_activity = (
                            current_time - last_activity
                        ).total_seconds()

                        if time_since_activity > self.inactive_timeout:
                            logger.warning(
                                "Camera in room %s inactive for %d seconds, marking as disconnected",
                                room_id,
                                int(time_since_activity),
                            )

                            # Update camera room status to disconnected
                            try:
                                await StreamingDatabaseService.update_camera_room_status(
                                    camera_room_id, connected=False
                                )
                                logger.info(
                                    "Updated camera room %s status to disconnected",
                                    camera_room_id,
                                )

                                if session_id:
                                    sessions_to_check.add(session_id)

                                inactive_rooms.append(room_id)

                            except Exception as e:
                                logger.error(
                                    "Failed to update camera room %s status: %s",
                                    camera_room_id,
                                    e,
                                )

                # Check sessions for deactivation
                for session_id in sessions_to_check:
                    try:
                        await self._check_and_deactivate_session(session_id)
                    except Exception as e:
                        logger.error("Failed to check session %s: %s", session_id, e)

                # Clean up inactive monitors
                for room_id in inactive_rooms:
                    self.camera_monitors.pop(room_id, None)

            except Exception as e:
                logger.error("Error in camera monitoring: %s", e)
                await asyncio.sleep(5)

    async def _check_and_deactivate_session(self, session_id: str):
        """Check if all cameras in session are disconnected and deactivate if so."""
        try:
            # Get all camera rooms for this session
            camera_rooms = (
                await StreamingDatabaseService.get_camera_rooms_by_session_id(
                    session_id
                )
            )

            if not camera_rooms:
                return

            # Check if any camera is still connected
            connected_rooms = [
                room for room in camera_rooms if room.get("connected", False)
            ]

            if not connected_rooms:
                logger.info(
                    "All %d cameras disconnected for session %s, deactivating session",
                    len(camera_rooms),
                    session_id,
                )

                await StreamingDatabaseService.end_ambulance_session(session_id)
                logger.info(
                    "Session %s deactivated due to all cameras being disconnected",
                    session_id,
                )

        except Exception as e:
            logger.error(
                "Error checking session %s for deactivation: %s", session_id, e
            )

    def register_camera_room(
        self, room_id: str, camera_room_id: str, session_id: Optional[str] = None
    ):
        """Register a camera room for activity monitoring."""
        self.camera_monitors[room_id] = {
            "camera_room_id": camera_room_id,
            "session_id": session_id,
            "last_activity": datetime.utcnow(),
            "registered_at": datetime.utcnow(),
        }

        logger.info(
            "Registered camera room %s (session: %s) for monitoring in room %s",
            camera_room_id,
            session_id,
            room_id,
        )

    def _update_activity(self, room_id: str):
        """Update last activity timestamp for a room."""
        if room_id in self.camera_monitors:
            self.camera_monitors[room_id]["last_activity"] = datetime.utcnow()

    async def _monitor_track_activity(
        self, track: MediaStreamTrack, room_id: str, room: "Room"
    ):
        """
        Monitor a track for activity even when there are no viewers.

        This is critical because MediaRelay.subscribe() only calls recv() when
        there are other peer connections to relay to. If there's only a streamer
        and no viewers, the ActivityTrackWrapper.recv() is never called.

        This task continuously receives frames from the original track to ensure
        activity monitoring works even without viewers.
        """
        try:
            logger.info("[TRACK-MONITOR] Started monitoring track for room %s", room_id)
            frame_count = 0

            while True:
                try:
                    # Receive frame from the track
                    await track.recv()
                    frame_count += 1

                    # Update activity in the room
                    if room:
                        room.update_stream_activity()

                    # Also update legacy monitoring
                    self._update_activity(room_id)

                    # Log every 30 frames (~1 second at 30fps)
                    if frame_count % 30 == 0:
                        logger.debug(
                            "[TRACK-MONITOR] Room %s: %d frames monitored",
                            room_id,
                            frame_count,
                        )

                except MediaStreamError:
                    # Track ended
                    logger.info(
                        "[TRACK-MONITOR] Track ended for room %s after %d frames",
                        room_id,
                        frame_count,
                    )
                    break
                except Exception as e:
                    logger.error(
                        "[TRACK-MONITOR] Error receiving frame in room %s: %s",
                        room_id,
                        e,
                    )
                    break

        except asyncio.CancelledError:
            logger.info("[TRACK-MONITOR] Monitoring cancelled for room %s", room_id)
        except Exception as e:
            logger.error(
                "[TRACK-MONITOR] Unexpected error monitoring track for room %s: %s",
                room_id,
                e,
            )

    async def create_streamer_connection(self, room_id: str, sdp_body: SDPBody) -> dict:
        """Create a WebRTC connection for a streamer (publisher)."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                raise ValueError(f"Room {room_id} not found")

            # Create peer connection
            pc = RTCPeerConnection()
            room.add_peer_connection(
                pc, is_streamer=True
            )  # Mark as streamer connection

            # Set up event handlers
            @pc.on("connectionstatechange")
            async def on_connectionstatechange():
                """Handle streamer connection state changes with 10-second reconnection."""
                state = pc.connectionState
                logger.info(f"🔌 Streamer connection state for room {room_id}: {state}")

                if state == "connected":
                    logger.info(
                        f"✅ Streamer connected successfully for room {room_id}"
                    )
                    # Cancel reconnection monitoring if active
                    await self.reconnection_manager.cancel_reconnection(room_id)

                elif state in ["disconnected", "failed"]:
                    logger.warning(f"⚠️ Streamer {state} for room {room_id}")
                    # Start 10-second reconnection window
                    await self.reconnection_manager.start_reconnection(room_id, self)

                elif state == "closed":
                    logger.info(f"🔒 Streamer connection closed for room {room_id}")
                    room.remove_peer_connection(pc)
                    await self._handle_camera_disconnection(room_id)

            @pc.on("track")
            def on_track(track: MediaStreamTrack):
                logger.info(
                    "[TRACK] Received %s track in room %s (kind: %s)",
                    track.kind,
                    room_id,
                    type(track).__name__,
                )

                # Update activity when track is received (legacy monitoring)
                self._update_activity(room_id)

                # Update stream activity in room for new 30-second timeout
                room.update_stream_activity()

                # Store video track in room for recording
                if track.kind == "video":
                    logger.info(f"[RECORDING] Storing video track for room {room_id}")
                    room.video_track = track

                # Create a custom track wrapper to monitor frame activity
                class ActivityTrackWrapper(MediaStreamTrack):
                    """Wrapper track that monitors frame activity for stream timeout."""

                    _frame_count = 0  # Class variable for counting frames

                    def __init__(self, track, room_id, room_ref, webrtc_service):
                        super().__init__()
                        self.kind = (
                            track.kind
                        )  # CRITICAL: Inherit kind from original track
                        self.track = track
                        self.room_id = room_id
                        self.room = room_ref
                        self.webrtc_service = webrtc_service
                        logger.info(
                            "[WRAPPER] Created ActivityTrackWrapper for room %s (kind: %s)",
                            room_id,
                            self.kind,
                        )

                    async def recv(self):
                        try:
                            frame = await self.track.recv()

                            # DEBUG: Log frame reception (every 30 frames = ~1 second at 30fps)
                            ActivityTrackWrapper._frame_count += 1
                            if ActivityTrackWrapper._frame_count % 30 == 0:
                                logger.debug(
                                    "[WRAPPER] Room %s received frame #%d",
                                    self.room_id,
                                    ActivityTrackWrapper._frame_count,
                                )

                            # Update activity on every frame received
                            if self.room:
                                self.room.update_stream_activity()
                            # Also update old monitoring system to keep them in sync
                            if self.webrtc_service:
                                self.webrtc_service._update_activity(self.room_id)
                            return frame
                        except Exception as e:
                            logger.debug(
                                "Frame recv error in room %s: %s", self.room_id, e
                            )
                            raise

                # Wrap the track to monitor frame activity
                activity_wrapped_track = ActivityTrackWrapper(
                    track, room_id, room, self
                )
                logger.info(
                    "[RELAY] Wrapping track for room %s with ActivityTrackWrapper",
                    room_id,
                )

                # Relay track to all other connections in the room
                relayed_track = self.relay.subscribe(activity_wrapped_track)
                logger.info(
                    "[RELAY] Subscribed wrapped track to relay for room %s",
                    room_id,
                )

                # CRITICAL FIX: Start a background task to monitor the ORIGINAL track
                # The relay only calls recv() when there are viewers, but we need to
                # monitor activity even when there are no viewers
                asyncio.create_task(self._monitor_track_activity(track, room_id, room))

                # Add track to all other peer connections in the room
                for other_pc in room.pcs:
                    if other_pc != pc:
                        other_pc.addTrack(relayed_track)
                        logger.debug(
                            "[RELAY] Added relayed track to peer connection in room %s",
                            room_id,
                        )

                @track.on("ended")
                async def on_ended():
                    logger.info("Track ended in room %s", room_id)
                    await self._handle_camera_disconnection(room_id)

            # Set remote description
            await pc.setRemoteDescription(
                RTCSessionDescription(sdp=sdp_body.sdp, type=sdp_body.type)
            )

            # Create answer
            answer = await pc.createAnswer()
            await pc.setLocalDescription(answer)

            return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

        except Exception as e:
            logger.error(
                "Error creating streamer connection for room %s: %s", room_id, e
            )
            raise

    async def create_viewer_connection(self, room_id: str, sdp_body: SDPBody) -> dict:
        """Create a WebRTC connection for a viewer (subscriber)."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                raise ValueError(f"Room {room_id} not found")

            # Create peer connection
            pc = RTCPeerConnection()
            room.add_peer_connection(pc, is_streamer=False)  # Mark as viewer connection

            # Set up event handlers
            @pc.on("connectionstatechange")
            async def on_connectionstatechange():
                logger.info(
                    "Viewer connection state for room %s: %s",
                    room_id,
                    pc.connectionState,
                )
                if pc.connectionState == "closed":
                    room.remove_peer_connection(pc)

            # Add existing tracks from other connections
            for other_pc in room.pcs:
                if other_pc != pc:
                    for transceiver in other_pc.getTransceivers():
                        if transceiver.receiver.track:
                            track = transceiver.receiver.track
                            relayed_track = self.relay.subscribe(track)
                            pc.addTrack(relayed_track)

            # Set remote description
            await pc.setRemoteDescription(
                RTCSessionDescription(sdp=sdp_body.sdp, type=sdp_body.type)
            )

            # Create answer
            answer = await pc.createAnswer()
            await pc.setLocalDescription(answer)

            return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

        except Exception as e:
            logger.error("Error creating viewer connection for room %s: %s", room_id, e)
            raise

    async def handle_ice_candidate(self, room_id: str, candidate_data: dict) -> bool:
        """Handle ICE candidate for a room."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                logger.warning("ICE candidate for non-existent room %s", room_id)
                return False

            # In a production environment, you would route this to the specific
            # peer connection that needs it. For now, we'll log it.
            logger.info(
                "Received ICE candidate for room %s: %s", room_id, candidate_data
            )
            return True

        except Exception as e:
            logger.error("Error handling ICE candidate for room %s: %s", room_id, e)
            return False

    def get_connection_stats(self, room_id: str) -> dict:
        """Get connection statistics for a room."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                return {"error": f"Room {room_id} not found"}

            stats = {
                "room_id": room_id,
                "active_connections": len(room.pcs),
                "room_active": room.is_active,
                "connections": [],
            }

            for i, pc in enumerate(room.pcs):
                stats["connections"].append(
                    {
                        "connection_id": i,
                        "state": pc.connectionState,
                        "ice_connection_state": pc.iceConnectionState,
                        "ice_gathering_state": pc.iceGatheringState,
                    }
                )

            return stats

        except Exception as e:
            logger.error("Error getting stats for room %s: %s", room_id, e)
            return {"error": str(e)}

    async def _handle_camera_disconnection(self, room_id: str):
        """Handle camera disconnection and update database."""
        if room_id in self.camera_monitors:
            monitor_data = self.camera_monitors[room_id]
            camera_room_id = monitor_data.get("camera_room_id")
            session_id = monitor_data.get("session_id")

            if camera_room_id:
                try:
                    # Update camera room status to disconnected
                    await StreamingDatabaseService.update_camera_room_status(
                        camera_room_id, connected=False
                    )

                    logger.info(
                        "Camera room %s disconnected and status updated", camera_room_id
                    )

                    # Check if session should be deactivated
                    if session_id:
                        await self._check_and_deactivate_session(session_id)

                except Exception as e:
                    logger.error(
                        "Failed to handle camera disconnection for room %s: %s",
                        room_id,
                        e,
                    )

            # Clean up monitoring data
            self.camera_monitors.pop(room_id, None)

    def get_monitoring_status(self) -> Dict:
        """Get current camera monitoring status."""
        current_time = datetime.utcnow()
        return {
            "monitoring_active": self.monitoring_task
            and not self.monitoring_task.done(),
            "monitored_rooms": len(self.camera_monitors),
            "inactive_timeout_seconds": self.inactive_timeout,
            "rooms": {
                room_id: {
                    "camera_room_id": data.get("camera_room_id"),
                    "session_id": data.get("session_id"),
                    "last_activity": (
                        data.get("last_activity").isoformat()
                        if data.get("last_activity")
                        else None
                    ),
                    "seconds_since_activity": (
                        (current_time - data.get("last_activity")).total_seconds()
                        if data.get("last_activity")
                        else None
                    ),
                    "is_active": (
                        (current_time - data.get("last_activity")).total_seconds()
                        <= self.inactive_timeout
                        if data.get("last_activity")
                        else False
                    ),
                }
                for room_id, data in self.camera_monitors.items()
            },
        }

    def get_reconnection_status(self) -> dict:
        """Get reconnection status for all rooms."""
        return self.reconnection_manager.get_status()

    async def cleanup(self):
        """Clean up monitoring resources."""
        # Clean up reconnection tasks
        await self.reconnection_manager.cleanup()

        if self.monitoring_task and not self.monitoring_task.done():
            self.monitoring_task.cancel()
            try:
                await self.monitoring_task
            except asyncio.CancelledError:
                pass

        self.camera_monitors.clear()
        logger.info("WebRTC service cleanup completed")


# Global WebRTC service instance
webrtc_service = WebRTCService()
