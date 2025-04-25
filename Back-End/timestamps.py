from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from supabase_client import supabase
import json
import os
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
from supabase_settings.supabase_client import get_supabase_client
from common import logger

app = FastAPI()
router = APIRouter()
supabase = get_supabase_client()

# Model to represent video data in the database
class Video(BaseModel):
    id: str
    patient_id: str
    description: Optional[str] = None
    file_path: str
    public_video_url: str
    created_at: datetime

# Model for video upload requests
class VideoUpload(BaseModel):
    patient_id: str
    video_path: str
    description: Optional[str] = None
    video: UploadFile

@app.post("/upload", response_model=Video)
async def upload_video(video_upload: VideoUpload):
    """Endpoint to upload a video along with its metadata."""
    # Ensure the uploaded file has a valid extension
    if not video_upload.video.filename.endswith(('.mp4', '.avi', '.mov')):
        raise HTTPException(status_code=400, detail="Invalid file type. Only video files are allowed.")

    # Read the video file content
    file_content = await video_upload.video.read()

    try:
        # Upload the video to Supabase storage
        response = await supabase.storage.from_('recorded.videos').upload(video_upload.video_path, file_content)

        if not response:
            raise HTTPException(status_code=500, detail="Error uploading video")

        # Get the public URL of the uploaded video
        video_url = supabase.storage.from_('recorded.videos').get_public_url(video_upload.video_path)

        if not video_url:
            raise HTTPException(status_code=500, detail="Error getting public video URL")

        # Insert video metadata into the database
        video_data = {
            'patient_id': video_upload.patient_id,
            'file_path': video_upload.video_path,
            'description': video_upload.description,
            'public_video_url': video_url
        }
        
        video_response = await supabase.table('video').upsert(video_data).execute()
        return video_response.data

    except Exception as e:
        logger.error(f"Error uploading video: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/videos/", response_model=List[Video])
async def get_all_videos():
    """Endpoint to retrieve all videos."""
    try:
        response = supabase.table('video').select('*').execute()
        return response.data
    except Exception as e:
        logger.error(f"Error getting all videos: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/videos/{patient_id}", response_model=List[Video])
async def get_videos_for_patient(patient_id: str):
    """Endpoint to retrieve all videos for a specific patient."""
    try:
        response = supabase.table('video').select('*').eq('patient_id', patient_id).execute()
        videos: List[Video] = []

        for obj in response.data:
            video_url = supabase.storage.from_('recorded.videos').get_public_url(obj.file_path)
            video = Video(
                id=obj.id,
                patient_id=obj.patient_id,
                description=obj.description,
                file_path=obj.file_path,
                public_video_url=video_url,
                created_at=obj.created_at
            )
            videos.append(video)

        return videos

    except Exception as e:
        logger.error(f"Error getting videos for patient {patient_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/videos/{video_id}")
async def delete_video(video_id: str):
    """Endpoint to delete a specific video."""
    try:
        video_response = supabase.table('video').select('*').eq('id', video_id).execute()

        if not video_response.data:
            raise HTTPException(status_code=404, detail="Video not found")

        # Remove the video from storage
        await supabase.storage.from_('recorded.videos').remove([video_response.data[0].file_path])
        
        # Delete the video metadata from the database
        response = supabase.table('video').delete().eq('id', video_id).execute()

        return {"message": "Video deleted successfully"}
    
    except Exception as e:
        logger.error(f"Error deleting video: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Include the router in the main application
app.include_router(router, prefix="/api/v1/videos")
