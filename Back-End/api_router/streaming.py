import asyncio
from typing import Optional

from aiortc import RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaRelay
from fastapi import APIRouter, HTTPException, Depends
from core.common import logger, supabase
from pydantic import BaseModel
from security.jwt_verify import current_user


class Room:
    def __init__(self, room_id: str, session_id: Optional[str] = None):
        self.room_id = room_id
        self.session_id = session_id  # Link to database session
        self.streamer: Optional[RTCPeerConnection] = None
        self.viewers: set[RTCPeerConnection] = set()
        self.is_active = True
        self.reconnection_attempts = 0
        self.max_reconnection_attempts = 3

    async def close(self):
        """Close all connections and mark room as inactive"""
        coros = []
        if self.streamer:
            coros.append(self.streamer.close())
        for viewer in self.viewers:
            coros.append(viewer.close())
        await asyncio.gather(*coros)
        self.is_active = False

        # Update session status in database
        if self.session_id:
            try:
                await self._update_session_status("disconnected")
            except Exception as e:
                logger.error("Failed to update session status on room close: %s", e)

    async def handle_disconnection(self):
        """Handle room disconnection with potential for reconnection"""
        self.is_active = False
        self.reconnection_attempts += 1

        logger.info(
            "Room %s disconnected. Attempt %d/%d",
            self.room_id,
            self.reconnection_attempts,
            self.max_reconnection_attempts,
        )

        # Update session status
        if self.session_id:
            try:
                status = (
                    "error"
                    if self.reconnection_attempts >= self.max_reconnection_attempts
                    else "disconnected"
                )
                await self._update_session_status(status)
            except Exception as e:
                logger.error("Failed to update session status on disconnection: %s", e)

        # If max attempts reached, close permanently
        if self.reconnection_attempts >= self.max_reconnection_attempts:
            logger.warning(
                "Room %s reached max reconnection attempts. Closing permanently.",
                self.room_id,
            )
            await self.close()
            return False

        return True  # Can attempt reconnection

    async def reactivate(self):
        """Reactivate room for reconnection"""
        self.is_active = True
        logger.info("Room %s reactivated for reconnection", self.room_id)

        # Update session status back to active
        if self.session_id:
            try:
                await self._update_session_status("active")
            except Exception as e:
                logger.error("Failed to update session status on reactivation: %s", e)

    async def _update_session_status(self, status: str):
        """Update the session status in database"""
        update_data = {"status": status}
        if status in ["ended", "error"]:
            update_data["is_live"] = False
            update_data["ended_at"] = "now()"

        supabase.table("streaming_sessions").update(update_data).eq(
            "id", self.session_id
        ).execute()


class SDPBody(BaseModel):
    sdp: str
    type: str


class StreamingSessionCreate(BaseModel):
    patient_id: str
    room_id: str
    device_name: Optional[str] = None


class StreamingSessionUpdate(BaseModel):
    is_live: Optional[bool] = None
    status: Optional[str] = None
    device_name: Optional[str] = None


class StreamingSessionResponse(BaseModel):
    id: str
    patient_id: str
    room_id: str
    is_live: bool
    status: str
    started_at: str
    ended_at: Optional[str] = None
    device_name: Optional[str] = None
    created_at: str
    updated_at: str


router = APIRouter()

rooms: dict[str, Room] = {}
relay = MediaRelay()


async def cleanup_inactive_rooms():
    """Clean up rooms that have been inactive for too long"""
    inactive_rooms = []
    for room_id, room in rooms.items():
        if (
            not room.is_active
            and room.reconnection_attempts >= room.max_reconnection_attempts
        ):
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
    """Create a room and automatically create a streaming session"""
    room_id = patient_id

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
                "reconnected": True,
            }
        else:
            # Room is still active, return existing info
            return {
                "room_id": room_id,
                "session_id": existing_room.session_id,
                "already_exists": True,
            }

    try:
        # Create streaming session in database
        session_result = (
            supabase.table("streaming_sessions")
            .insert(
                {
                    "patient_id": patient_id,
                    "room_id": room_id,
                    "device_name": device_name,
                    "is_live": True,
                    "status": "active",
                }
            )
            .execute()
        )

        if not session_result.data:
            raise HTTPException(
                status_code=500, detail="Failed to create streaming session"
            )

        session_id = session_result.data[0]["id"]

        # Create room with session link
        rooms[room_id] = Room(room_id, session_id)

        logger.info("Created room %s with session %s", room_id, session_id)

        return {"room_id": room_id, "session_id": session_id, "created": True}

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
async def create_streaming_session(session_data: StreamingSessionCreate):
    """Create a new streaming session"""
    try:
        result = (
            supabase.table("streaming_sessions")
            .insert(
                {
                    "patient_id": session_data.patient_id,
                    "room_id": session_data.room_id,
                    "device_name": session_data.device_name,
                    "is_live": True,
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

        return {"data": result.data, "error": None}
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
    session_id: str, session_data: StreamingSessionUpdate
):
    """Update a streaming session"""
    try:
        update_data = {}
        if session_data.is_live is not None:
            update_data["is_live"] = session_data.is_live
        if session_data.status is not None:
            update_data["status"] = session_data.status
        if session_data.device_name is not None:
            update_data["device_name"] = session_data.device_name

        # Auto-set ended_at if session is ending
        if session_data.is_live is False or session_data.status in [
            "ended",
            "error",
            "disconnected",
        ]:
            update_data["ended_at"] = "now()"

        result = (
            supabase.table("streaming_sessions")
            .update(update_data)
            .eq("id", session_id)
            .execute()
        )

        if result.data:
            return {"data": result.data[0], "error": None}
        else:
            raise HTTPException(status_code=404, detail="Streaming session not found")
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

        return {"data": result.data, "error": None}
    except Exception as e:
        logger.error("Error fetching active sessions for patient: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
