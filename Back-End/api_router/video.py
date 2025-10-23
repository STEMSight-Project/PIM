from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel
from core.common import supabase, logger
from fastapi import APIRouter, Depends, HTTPException
from security.jwt_verify import current_user
from services.video_service import VideoService

router = APIRouter(dependencies=[Depends(current_user)])


class Video(BaseModel):
    id: str
    patient_id: str
    description: Optional[str]
    file_path: str
    public_video_url: str
    created_at: datetime


class VideoUpload(BaseModel):
    patient_id: str
    video_path: str
    description: str = None


# New models for ambulance recordings
class RecordingResponse(BaseModel):
    """Response model for ambulance session recordings"""

    id: str
    session_id: str
    session_name: Optional[str]
    ambulance_number: Optional[str]
    file_path: Optional[str]
    public_video_url: Optional[str]
    duration: Optional[int]  # Duration in seconds
    file_size: Optional[int]  # File size in bytes
    session_start: Optional[datetime]
    session_end: Optional[datetime]
    created_at: datetime
    is_archived: bool  # True if uploaded to Supabase Storage


# ============================================================================
# AMBULANCE RECORDINGS ENDPOINTS (New - from Supabase Storage)
# ============================================================================


@router.get("/recordings", response_model=List[RecordingResponse])
async def get_all_recordings():
    """
    Get all ambulance session recordings with public URLs from Supabase Storage.
    Returns both archived (uploaded to Supabase) and live (HLS) recordings.
    """
    try:
        recordings = await VideoService.get_all_recordings()
        return recordings
    except Exception as e:
        logger.error("Error getting all recordings: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/archived", response_model=List[RecordingResponse])
async def get_archived_recordings():
    """
    Get only archived recordings (uploaded to Supabase Storage).
    Excludes live/ongoing recordings.
    """
    try:
        recordings = await VideoService.get_archived_recordings()
        return recordings
    except Exception as e:
        logger.error("Error getting archived recordings: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/{recording_id}", response_model=RecordingResponse)
async def get_recording_by_id(recording_id: str):
    """
    Get a specific recording by ID with public URL from Supabase Storage.
    """
    try:
        recording = await VideoService.get_recording_by_id(recording_id)
        if not recording:
            raise HTTPException(status_code=404, detail="Recording not found")
        return recording
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error getting recording %s: %s", recording_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/session/{session_id}", response_model=List[RecordingResponse])
async def get_recordings_by_session(session_id: str):
    """
    Get all recordings for a specific ambulance session.
    """
    try:
        recordings = await VideoService.get_recordings_by_session(session_id)
        return recordings
    except Exception as e:
        logger.error("Error getting recordings for session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get(
    "/recordings/ambulance/{ambulance_id}", response_model=List[RecordingResponse]
)
async def get_recordings_by_ambulance(ambulance_id: str):
    """
    Get all recordings for a specific ambulance.
    """
    try:
        recordings = await VideoService.get_recordings_by_ambulance(ambulance_id)
        return recordings
    except Exception as e:
        logger.error("Error getting recordings for ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/recordings/{recording_id}")
async def delete_recording(recording_id: str):
    """
    Delete a recording from the database.
    Note: This does NOT delete the file from Supabase Storage.
    """
    try:
        await VideoService.delete_recording(recording_id)
        return {
            "data": {"message": "Recording deleted successfully"},
            "error": None,
        }
    except Exception as e:
        logger.error("Error deleting recording %s: %s", recording_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ============================================================================
# LEGACY PATIENT VIDEO ENDPOINTS (Old - keep for backward compatibility)
# ============================================================================


@router.get("/", response_model=list[Video])
def get_all_videos():
    try:
        response = supabase.table("video").select("*").execute()
        videos: list[Video] = []
        for obj in response.data:
            video_url = supabase.storage.from_("recorded.videos").get_public_url(
                obj["file_path"]
            )
            video = Video(
                id=obj["id"],
                patient_id=obj["patient_id"],
                description=obj["description"],
                file_path=obj["file_path"],
                public_video_url=video_url,
                created_at=obj["created_at"],
            )
            videos.append(video)
        return videos
    except Exception as e:
        logger.error("Error getting all videos: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/{patient_id}/videos", response_model=list[Video])
def get_videos_for_patient(patient_id: str):
    try:
        response_database = (
            supabase.table("video").select("*").eq("patient_id", patient_id).execute()
        )
        videos: list[Video] = []
        for obj in response_database.data:
            video_url = supabase.storage.from_("recorded.videos").get_public_url(
                obj["file_path"]
            )
            video = Video(
                id=obj["id"],
                patient_id=obj["patient_id"],
                description=obj["description"],
                file_path=obj["file_path"],
                public_video_url=video_url,
                created_at=obj["created_at"],
            )
            videos.append(video)

        return videos

    except Exception as e:
        logger.error("Error getting videos for patient %s: %s", patient_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/", response_model=Video)
async def create_video(video_upload: VideoUpload):
    try:
        # Save the video to the server
        file_content = video_upload.video.read()
    except Exception as e:
        logger.error("Error reading video file: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e

    try:
        response = await supabase.storage.from_("recorded.videos").upload(
            video_upload.video_path,
            file_content,
            {
                "upsert": True,
            },
        )
        if not response:
            raise HTTPException(status_code=500, detail="Error uploading video")
        videoURL = await supabase.storage.from_("recorded.videos").get_public_url(
            video_upload.video_path
        )
        if not videoURL:
            raise HTTPException(
                status_code=500, detail="Error getting public video URL"
            )
        video_response = (
            supabase.table("video")
            .upsert(
                {
                    "patient_id": video_upload.patient_id,
                    "file_path": video_upload.video_path,
                    "description": video_upload.description,
                    "public_video_url": videoURL,
                }
            )
            .execute()
        )
        return video_response.data[0]
    except Exception as e:
        logger.error("Error uploading video: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/{video_id}")
async def delete_video(video_id: str):
    try:
        video_response = (
            supabase.table("video").select("*").eq("id", video_id).execute()
        )

        await supabase.storage.from_("recorded.videos").remove(
            [video_response.data.file_path]
        )

        (supabase.table("video").delete().eq("id", video_id).execute())
        return {"message": "Video deleted successfully"}
    except Exception as e:
        logger.error("Error deleting video: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
