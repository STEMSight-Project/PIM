from app.webrtc_streamer import MediaPipeStream
from fastapi import APIRouter

router = APIRouter()
stream = MediaPipeStream()


@router.post("/record/start")
async def start_record():
    stream.start_recording()
    return {"status": "recording started"}


@router.post("/record/stop")
async def stop_record():
    file_path = stream.stop_recording()
    return {"status": "recording stopped", "file": file_path}
