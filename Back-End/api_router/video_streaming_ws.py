import asyncio
from fastapi import APIRouter, BackgroundTasks, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import StreamingResponse
from supabase_settings.config import settings
import httpx
import aiofiles
from datetime import datetime
from supabase_settings.supabase_client import get_supabase_client
from common import logger

supabase = get_supabase_client()
router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []
    
    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active_connections.append(ws)
    
    def disconnect(self, ws: WebSocket):
        self.active_connections.remove(ws)
    
    async def broadcast(self, data: bytes):
        for connection in self.active_connections:
            await connection.send_bytes(data)

manager = ConnectionManager()

async def upload_video_to_supabase(file_path: str):
    async with aiofiles.open(file_path) as file:
        data = await file.read()

    file_name = f"{file_path.split('/')[-1].split('.')[0]}"

    await supabase.storage.from_(settings.SUPABASE_PATIENT_VIDEO_BUCKET).upload(file_name, data, {
        "x-upsert": True,
        "mime-type": "video/mp4"
    })
    

@router.websocket("/watch/live/{patient_id}")
async def watch_video_stream(patient_id: str, ws: WebSocket, backgroundTasks: BackgroundTasks):
    # Ready for device connect into streaming room
    await ws.accept()
    
    # Store video file into local storage as temporary file
    temp_file_path = f"/tmp/{patient_id}_{datetime.now()}.webm"

    async with aiofiles.open(temp_file_path, "wb") as file:
        try: 
            while True:
                chunk = await ws.receive_bytes()
                if not chunk:
                    continue
                await file.write(chunk)

                await manager.broadcast(chunk)
        except WebSocketDisconnect:
            logger.info(f"Live stream of {patient_id} had been ended")
            backgroundTasks.add_task(upload_video_to_supabase, temp_file_path)

@router.websocket("/watch/{patient_id}")
async def watch_video_stream(patient_id: str, ws: WebSocket):
    await ws.accept()
    manager.connect(ws)
    try:
        while True:
            await asyncio.sleep(1)
    except WebSocketDisconnect:
        manager.disconnect(ws)
        logger.info("Client disconnected")

