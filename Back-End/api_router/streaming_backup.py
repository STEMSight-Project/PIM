import asyncio
from typing import Optional, List
import time

from aiortc import RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaRelay
from fastapi import APIRouter, HTTPException, Depends
from core.common import logger, supabase
from pydantic import BaseModel
from security.jwt_verify import current_user


class Room:
    def __init__(self, room_id: str, session_id: Optional[str] = None, room_db_id: Optional[str] = None):
        self.room_id = room_id
        self.session_id = session_id  # Link to streaming session
        self.room_db_id = room_db_id  # Link to streaming_rooms table
        self.streamer: Optional[RTCPeerConnection] = None
        self.viewers: set[RTCPeerConnection] = set()
        self.is_active = True
        self.reconnection_attempts = 0
        self.max_reconnection_attempts = 5
        self.disconnection_time: Optional[float] = None
        self.max_disconnection_time = 15.0
        self.reconnection_timeout_task: Optional[asyncio.Task] = None

    async def close(self):
        """Close all connections and mark room as inactive"""
        # Cancel any pending timeout task
        if self.reconnection_timeout_task and not self.reconnection_timeout_task.done():
            self.reconnection_timeout_task.cancel()

        coros = []
        if self.streamer:
            coros.append(self.streamer.close())
        for viewer in self.viewers:
            coros.append(viewer.close())
        await asyncio.gather(*coros, return_exceptions=True)
        self.is_active = False

        # Update room status in database
        if self.room_db_id:
            try:
                await self._update_room_status(False)
            except Exception as e:
                logger.error("Failed to update room status on close: %s", e)

    async def handle_disconnection(self):
        """Handle room disconnection with potential for reconnection"""
        self.is_active = False
        self.reconnection_attempts += 1

        # Record disconnection time if this is the first disconnection
        if self.disconnection_time is None:
            self.disconnection_time = time.time()
            # Start timeout task for automatic cancellation
            self.reconnection_timeout_task = asyncio.create_task(
                self._handle_reconnection_timeout()
            )

        logger.info(
            "Room %s disconnected. Attempt %d/%d (disconnected for %.1fs)",
            self.room_id,
            self.reconnection_attempts,
            self.max_reconnection_attempts,
            time.time() - self.disconnection_time,
        )

        # Update session status
        if self.session_id:
            try:
                # Update room status instead of session status
                await self._update_room_status(False)  # Set room as disconnected
            except Exception as e:
                logger.error("Failed to update room status on disconnection: %s", e)

        # If max attempts reached, close permanently
        if self.reconnection_attempts >= self.max_reconnection_attempts:
            logger.warning(
                "Room %s reached max reconnection attempts (%d). Closing permanently.",
                self.room_id,
                self.max_reconnection_attempts,
            )
            await self.close()
            return False

        return True  # Can attempt reconnection

    async def reactivate(self):
        """Reactivate room for reconnection"""
        self.is_active = True
        # Reset disconnection tracking since we're back online
        self.disconnection_time = None
        self.reconnection_attempts = 0

        # Cancel timeout task since we're reconnected
        if self.reconnection_timeout_task and not self.reconnection_timeout_task.done():
            self.reconnection_timeout_task.cancel()

        logger.info("Room %s reactivated for reconnection", self.room_id)

        # Update room status back to connected
        if self.room_db_id:
            try:
                await self._update_room_status(True)
            except Exception as e:
                logger.error("Failed to update room status on reactivation: %s", e)

    async def _handle_reconnection_timeout(self):
        """Background task to handle reconnection timeout"""
        try:
            await asyncio.sleep(self.max_disconnection_time)

            # Check if we're still disconnected after timeout
            if not self.is_active and self.disconnection_time is not None:
                elapsed = time.time() - self.disconnection_time
                logger.warning(
                    "Room %s timed out after %.1fs of disconnection. Closing room.",
                    self.room_id,
                    elapsed,
                )
                await self.close()

                # Remove from rooms dict
                if self.room_id in rooms:
                    rooms.pop(self.room_id, None)

        except asyncio.CancelledError:
            # Task was cancelled, which is fine (means reconnection happened)
            logger.debug(
                "Reconnection timeout task cancelled for room %s", self.room_id
            )
        except Exception as e:
            logger.error(
                "Error in reconnection timeout handler for room %s: %s", self.room_id, e
            )

    async def _update_room_status(self, connected: bool):
        """Update the room connection status in database"""
        try:
            update_data = {
                "connected": connected,
                "last_seen": "now()"
            }
            if not connected:
                update_data["ended_at"] = "now()"
            
            result = supabase.table("streaming_rooms").update(update_data).eq(
                "id", self.room_db_id
            ).execute()
            
            logger.debug("Updated room %s status to connected=%s", self.room_id, connected)
            
        except Exception as e:
            logger.error("Failed to update room status: %s", e)
            raise


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


router = APIRouter()

rooms: dict[str, Room] = {}
relay = MediaRelay()

# Background task for cleanup
cleanup_task: Optional[asyncio.Task] = None


async def start_cleanup_task():
    """Start the background cleanup task"""
    global cleanup_task
    if cleanup_task is None or cleanup_task.done():
        cleanup_task = asyncio.create_task(periodic_cleanup())
        logger.info("Started room cleanup background task")


async def periodic_cleanup():
    """Periodically clean up inactive rooms"""
    while True:
        try:
            await asyncio.sleep(5)  # Run cleanup every 5 seconds
            await cleanup_inactive_rooms()
        except asyncio.CancelledError:
            logger.info("Cleanup task cancelled")
            break
        except Exception as e:
            logger.error("Error in periodic cleanup: %s", e)


async def cleanup_inactive_rooms():
    """Clean up rooms that have been inactive for too long"""
    current_time = time.time()
    inactive_rooms = []

    for room_id, room in rooms.items():
        should_cleanup = False

        # Check if room reached max reconnection attempts
        if (
            not room.is_active
            and room.reconnection_attempts >= room.max_reconnection_attempts
        ):
            should_cleanup = True
            logger.info(
                "Room %s marked for cleanup: max reconnection attempts reached", room_id
            )

        # Check if room has been disconnected for too long (15 seconds)
        elif (
            not room.is_active
            and room.disconnection_time is not None
            and (current_time - room.disconnection_time) >= room.max_disconnection_time
        ):
            should_cleanup = True
            elapsed = current_time - room.disconnection_time
            logger.info(
                "Room %s marked for cleanup: disconnected for %.1fs (limit: %.1fs)",
                room_id,
                elapsed,
                room.max_disconnection_time,
            )

        if should_cleanup:
            inactive_rooms.append(room_id)

    for room_id in inactive_rooms:
        room = rooms.pop(room_id, None)
        if room:
            await room.close()
            logger.info("Cleaned up inactive room %s", room_id)


@router.get("/rooms/status")
async def get_rooms_status():
    """Get status of all rooms for debugging"""
    room_status = {}
    for room_id, room in rooms.items():
        room_status[room_id] = {
            "is_active": room.is_active,
            "has_streamer": room.streamer is not None,
            "viewer_count": len(room.viewers),
            "reconnection_attempts": room.reconnection_attempts,
            "session_id": room.session_id,
        }
    return {"rooms": room_status}


@router.post("/create_room/{patient_id}")
async def create_room(patient_id: str, device_name: Optional[str] = None):
    """Create a room and automatically create/get streaming session"""
    room_id = f"{patient_id}-{device_name or 'default'}"

    # Check if room exists and handle reconnection
    if room_id in rooms:
        existing_room = rooms[room_id]
        if not existing_room.is_active:
            # Reactivate existing room for reconnection
            await existing_room.reactivate()
            logger.info("Reactivated existing room %s for reconnection", room_id)
            return {
                "room_id": room_id,
                "session_id": existing_room.session_id,
                "room_db_id": existing_room.room_db_id,
                "reconnected": True,
            }
        else:
            # Room is still active, return existing info
            return {
                "room_id": room_id,
                "session_id": existing_room.session_id,
                "room_db_id": existing_room.room_db_id,
                "already_exists": True,
            }

    try:
        # Get or create streaming session (1:1 with patient)
        session_result = supabase.table("streaming_sessions").select("*").eq(
            "patient_id", patient_id
        ).execute()

        if session_result.data:
            # Session exists, use it
            session_id = session_result.data[0]["id"]
            logger.info("Using existing session %s for patient %s", session_id, patient_id)
        else:
            # Create new session
            session_result = supabase.table("streaming_sessions").insert({
                "patient_id": patient_id,
                "status": "active"
            }).execute()

            if not session_result.data:
                raise HTTPException(
                    status_code=500, detail="Failed to create streaming session"
                )

            session_id = session_result.data[0]["id"]
            logger.info("Created new session %s for patient %s", session_id, patient_id)

        # Create room entry in database
        room_result = supabase.table("streaming_rooms").insert({
            "session_id": session_id,
            "patient_id": patient_id,
            "room_id": room_id,
            "device_name": device_name or "Default Camera",
            "connected": True
        }).execute()

        if not room_result.data:
            raise HTTPException(
                status_code=500, detail="Failed to create room entry"
            )

        room_db_id = room_result.data[0]["id"]

        # Create room object with both session and room DB IDs
        rooms[room_id] = Room(room_id, session_id, room_db_id)

        # Start cleanup task if not already running
        await start_cleanup_task()

        logger.info("Created room %s with session %s and room DB ID %s", 
                   room_id, session_id, room_db_id)

        return {
            "room_id": room_id, 
            "session_id": session_id, 
            "room_db_id": room_db_id,
            "created": True
        }

    except Exception as e:
        logger.error("Error creating room and session: %s", e)
        raise HTTPException(
            status_code=500, detail=f"Failed to create room: {str(e)}"
        ) from e


@router.post("/rooms/{patient_id}/streamer")
async def publish_streamer(patient_id: str, body: SDPBody):
    logger.info("Streamer connection request for room %s", patient_id)

    if patient_id not in rooms:
        raise HTTPException(
            status_code=404, detail="Room not found. Create room first."
        )

    room = rooms[patient_id]

    # If room exists but is inactive, try to reactivate it
    if not room.is_active:
        await room.reactivate()

    # If there's already a streamer and it's still connected, reject
    if room.streamer and room.streamer.connectionState not in [
        "closed",
        "failed",
        "disconnected",
    ]:
        raise HTTPException(
            status_code=409, detail="Streamer already exists and is active"
        )

    # Clean up old streamer if exists
    if room.streamer:
        await room.streamer.close()
        room.streamer = None

    pc = RTCPeerConnection()
    room.streamer = pc

    @pc.on("iceconnectionstatechange")
    async def on_state_change() -> None:
        logger.info("Publisher ICE state %s", pc.iceConnectionState)
        if pc.iceConnectionState in ("failed", "closed", "disconnected"):
            # Handle disconnection with potential for reconnection
            can_reconnect = await room.handle_disconnection()

            await pc.close()
            room.streamer = None

            if not can_reconnect:
                # Remove room from active rooms if max attempts reached
                if room.room_id in rooms:
                    del rooms[room.room_id]
                logger.info("Removed room %s from active rooms", room.room_id)
        elif pc.iceConnectionState == "connected":
            # Reset reconnection attempts on successful connection
            room.reconnection_attempts = 0
            logger.info("Publisher successfully connected, reset reconnection attempts")

    @pc.on("icecandidate")
    async def on_icecandidate(candidate):
        if candidate:
            await pc.addIceCandidate(candidate)

    @pc.on("track")
    def on_track(track):
        logger.info("Track received: %s", track.kind)

    await pc.setRemoteDescription(RTCSessionDescription(**body.model_dump()))
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    logger.info("Streamer successfully connected to room %s", patient_id)
    return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}


@router.post("/rooms/{patient_id}/viewer", dependencies=[Depends(current_user)])
async def publish_viewer(patient_id: str, body: SDPBody):
    if patient_id not in rooms:
        return HTTPException(404, "Room not found")
    room = rooms[patient_id]
    if not room.streamer:
        return HTTPException(402, "Streamer not found")

    pc = RTCPeerConnection()
    room.viewers.add(pc)

    @pc.on("iceconnectionstatechange")
    async def on_state_change() -> None:
        logger.info("Viewer ICE state %s", pc.iceConnectionState)
        if pc.iceConnectionState in ("failed", "closed", "disconnected"):
            await pc.close()
            room.viewers.discard(pc)
            logger.info("Viewer disconnected from room %s", room.room_id)
        elif pc.iceConnectionState == "connected":
            logger.info("Viewer successfully connected to room %s", room.room_id)

    streamer = room.streamer

    for receiver in streamer.getReceivers():
        if receiver.track.kind == "video" or receiver.track.kind == "audio":
            pc.addTrack(relay.subscribe(receiver.track))

    await pc.setRemoteDescription(RTCSessionDescription(**body.model_dump()))
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}


# Streaming Sessions CRUD Operations


@router.post("/sessions", dependencies=[Depends(current_user)])
async def create_streaming_session(session_data: StreamingSessionData):
    """Create a new streaming session (1:1 with patient)"""
    try:
        # Check if session already exists for this patient
        existing_result = (
            supabase.table("streaming_sessions")
            .select("*")
            .eq("patient_id", session_data.patient_id)
            .execute()
        )

        if existing_result.data:
            return {"data": existing_result.data[0], "error": None, "existing": True}

        # Create new session
        result = (
            supabase.table("streaming_sessions")
            .insert(
                {
                    "patient_id": session_data.patient_id,
                    "status": "active",
                }
            )
            .execute()
        )

        if result.data:
            return {"data": result.data[0], "error": None}
        else:
            raise HTTPException(
                status_code=400, detail="Failed to create streaming session"
            )
    except Exception as e:
        logger.error("Error creating streaming session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/sessions", dependencies=[Depends(current_user)])
async def get_streaming_sessions(
    patient_id: Optional[str] = None, is_live: Optional[bool] = None
):
    """Get streaming sessions with optional filters"""
    try:
        query = supabase.table("streaming_sessions").select("*")

        if patient_id:
            query = query.eq("patient_id", patient_id)
        if is_live is not None:
            query = query.eq("is_live", is_live)

        result = query.order("started_at", desc=True).execute()

        return result.data
    except Exception as e:
        logger.error("Error fetching streaming sessions: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/sessions/{session_id}", dependencies=[Depends(current_user)])
async def get_streaming_session(session_id: str):
    """Get a specific streaming session by ID"""
    try:
        result = (
            supabase.table("streaming_sessions")
            .select("*")
            .eq("id", session_id)
            .execute()
        )

        if result.data:
            return {"data": result.data[0], "error": None}
        else:
            raise HTTPException(status_code=404, detail="Streaming session not found")
    except Exception as e:
        logger.error("Error fetching streaming session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.put("/sessions/{session_id}", dependencies=[Depends(current_user)])
async def update_streaming_session(
    session_id: str, session_data: StreamingSessionStatusUpdate
):
    """Update a streaming session status"""
    try:
        update_data = {}
        if session_data.status is not None:
            update_data["status"] = session_data.status

        # Auto-set ended_at if session is ending
        if session_data.status in ["ended", "error", "disconnected"]:
            update_data["ended_at"] = "now()"

        update_data["updated_at"] = "now()"

        result = (
            supabase.table("streaming_sessions")
            .update(update_data)
            .eq("id", session_id)
            .execute()
        )

        if result.data:
            return {"data": result.data[0], "error": None}
        else:
            raise HTTPException(
                status_code=404, detail="Streaming session not found"
            )
    except Exception as e:
        logger.error("Error updating streaming session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/sessions/{session_id}/end", dependencies=[Depends(current_user)])
async def end_streaming_session(session_id: str):
    """End a streaming session"""
    try:
        result = (
            supabase.table("streaming_sessions")
            .update({"is_live": False, "status": "ended", "ended_at": "now()"})
            .eq("id", session_id)
            .execute()
        )

        if result.data:
            return {"data": result.data[0], "error": None}
        else:
            raise HTTPException(status_code=404, detail="Streaming session not found")
    except Exception as e:
        logger.error("Error ending streaming session: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get(
    "/sessions/patient/{patient_id}/active", dependencies=[Depends(current_user)]
)
async def get_active_sessions_for_patient(patient_id: str):
    """Get active streaming sessions for a specific patient"""
    try:
        result = (
            supabase.table("streaming_sessions")
            .select("*")
            .eq("patient_id", patient_id)
            .eq("is_live", True)
            .eq("status", "active")
            .execute()
        )

        return result.data
    except Exception as e:
        logger.error("Error fetching active sessions for patient: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
