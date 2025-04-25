import asyncio

from typing import Literal, Optional
from aiortc import RTCPeerConnection, RTCSessionDescription

from fastapi import APIRouter, HTTPException, Response

from common import logger
from pydantic import BaseModel

class Room:
    def __init__(self, room_id: str):
        self.room_id = room_id
        self.streamer: Optional[RTCPeerConnection] = None
        self.viewers: set[RTCPeerConnection] = set()

    async def close(self):
        coros = []
        if self.streamer:
            coros.append(self.streamer.close())
        for viewer in self.viewers:
            coros.append(viewer.close())
        await asyncio.gather(*coros)

class SDPBody(BaseModel):
    sdp: str
    type: Literal["offer", "answer"]

router = APIRouter()

rooms: dict[str, Room] = {}

@router.post("/create_room/{patient_id}")
async def create_room(patient_id: str):
    room_id = patient_id
    # if room_id in rooms:
    #     return HTTPException(402, "Room already exists")
    rooms[room_id] = Room(room_id)
    return {"room_id": room_id}

@router.post("/rooms/{patient_id}/streamer")
async def publish_streamer(patient_id: str, body: SDPBody):
    logger.info(rooms.values)
    if patient_id not in rooms:
        return HTTPException(404, "Room not found")
    room = rooms[patient_id]
    if room.streamer:
        return HTTPException(402, "Streamer already exists")

    pc = RTCPeerConnection()
    room.streamer = pc

    @pc.on("iceconnectionstatechange")
    async def on_state_change() -> None:
        logger.info("Publisher ICE state %s", pc.iceConnectionState)
        if pc.iceConnectionState in ("failed", "closed", "disconnected"):
            await pc.close()
            room.streamer = None

    @pc.on("icecandidate")
    async def on_icecandidate(candidate):
        if candidate:
            await pc.addIceCandidate(candidate)

    @pc.on("track")
    def on_track(track):
        logger.info(f"Track received: {track.kind}")

    await pc.setRemoteDescription(RTCSessionDescription(**body.model_dump()))
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)
    return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

@router.post("/rooms/{patient_id}/viewer")
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

    streamer = room.streamer
    @streamer.on("track")
    def on_track(track):
        logger.info(f"Track received: {track.kind}")
        if track.kind == "video":
            pc.addTrack(track)

    await pc.setRemoteDescription(RTCSessionDescription(**body.model_dump()))
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}
