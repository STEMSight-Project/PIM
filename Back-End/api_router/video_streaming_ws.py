import asyncio
from fastapi import APIRouter, BackgroundTasks, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import StreamingResponse
from fastapi.websockets import WebSocketState
from supabase_settings.config import settings
import aiofiles
from datetime import datetime
from supabase_settings.supabase_client import get_supabase_client
from common import logger
import os

supabase = get_supabase_client()
router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
    
    def connect(self, ws: WebSocket):
        self.active_connections.append(ws)
    
    def disconnect(self, ws: WebSocket):
        self.active_connections.remove(ws)
    
    async def broadcast(self, data: bytes):
        if self.active_connections.count == 0:
            return
        for connection in self.active_connections:
            await connection.send_bytes(data)

class StreamingRoom:
    def __init__(self, patient_id: str, broadcasterWS: WebSocket):
        self.broadcasterWS = broadcasterWS
        self.patient_id = patient_id
        self.manager = ConnectionManager()
        time = datetime.now().strftime("%Y%m%d")
        self.temp_file_path = os.path.join(os.curdir, f"{patient_id}_{time}.mp4")
        self.broadcaster_connected = False

streaming_rooms: dict[str, StreamingRoom] = {}

async def upload_video_to_supabase(file_path: str):
    async with aiofiles.open(file_path) as file:
        data = await file.read()

    file_name = f"{file_path.split('/')[-1].split('.')[0]}"
    print("uploading...")
    await supabase.storage.from_(settings.SUPABASE_PATIENT_VIDEO_BUCKET).upload(file_name, data, {
        "x-upsert": True,
        "mime-type": "video/mp4"
    })
    

@router.websocket("/live/{patient_id}")
async def watch_video_stream(patient_id: str, ws: WebSocket, backgroundTasks: BackgroundTasks):
    # Ready for device connect into streaming room
    await ws.accept()
    streaming_rooms[patient_id] = StreamingRoom(patient_id, ws)
    room = streaming_rooms[patient_id]

    room.broadcaster_connected = True

    async with aiofiles.open(room.temp_file_path, "ab") as file:
        while True:
            chunk = await ws.receive_bytes()
            if not chunk:
                continue
            await room.manager.broadcast(chunk)
            await file.write(chunk)
            # backgroundTasks.add_task(upload_video_to_supabase, current.temp_file_path)
    streaming_rooms[patient_id].broadcaster_connected = False

@router.websocket("/watch/{patient_id}")
async def watch_video_stream(patient_id: str, ws: WebSocket):
    await ws.accept()
    room = streaming_rooms[patient_id]
    room.manager.connect(ws)
    while not ws.state == WebSocketState.DISCONNECTED:
        await asyncio.sleep(1)
    ws._raise_on_disconnect
    # streaming_rooms[patient_id].manager.disconnect(ws)
    logger.info("Client disconnected")