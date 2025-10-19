from pathlib import Path

from fastapi import APIRouter
from fastapi.responses import FileResponse

router = APIRouter()


@router.get("/playback/{filename}")
async def playback_video(filename: str):
    file_path = Path(f"static/recordings/{filename}")
    if not file_path.exists():
        return {"error": "file not found"}
    return FileResponse(file_path)
