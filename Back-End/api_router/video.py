from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from common import supabase
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from common import logger
from security.jwt_verify import current_user

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
    video: UploadFile

@router.get('/')
def get_all_videos():
    try:
        response = (
            supabase
            .table('video')
            .select('*')
            .execute()
        )
        return response.data
    except Exception as e:
        logger.error(f"Error getting all videos: {e}")
        raise HTTPException(status_code=500, detail= e)
    
@router.get('/{patient_id}/videos', response_model=list[Video])
def get_videos_for_patient(patient_id: str):
    try:
        response_database = (
            supabase
            .table('video')
            .select('*')
            .eq('patient_id', patient_id)
            .execute()
        )
        videos: list[Video] = []
        for obj in response_database.data:
            video_url = supabase.storage.from_('recorded.videos').get_public_url(obj['file_path'])
            video = Video(
                id= obj['id'], 
                patient_id= 
                obj['patient_id'], 
                description= obj['description'],
                file_path= obj['file_path'],
                public_video_url= video_url,
                created_at=obj['created_at'], 
            )
            videos.append(video)

        return videos 
        
    except Exception as e:
        logger.error(f"Error getting videos for patient {patient_id}: {e}")
        raise HTTPException(status_code=500, detail= e)

@router.post('/', response_model= Video)
async def create_video(video_upload: VideoUpload):
    try:
        # Save the video to the server
        file_content = video_upload.video.read()
    except Exception as e:
        logger.error(f"Error reading video file: {e}")
        raise HTTPException(status_code=500, detail= e)
    
    try:
        response = await (supabase
                .storage
                .from_('recorded.videos')
                .upload(video_upload.video_path, file_content, {
                    'upsert': True,
                }
            )
        )
        if not response:
            raise HTTPException(status_code=500, detail= "Error uploading video")
        videoURL = await supabase.storage.from_('recorded.videos').get_public_url(video_upload.video_path)
        if not videoURL:
            raise HTTPException(status_code=500, detail= "Error getting public video URL")
        video_response = (
            supabase
            .table('video')
            .upsert({
                'patient_id': video_upload.patient_id,
                'file_path': video_upload.video_path,
                'description': video_upload.description,
                'public_video_url': videoURL
            })
            .execute()
        )
        return 
    except Exception as e:
        logger.error(f"Error uploading video: {e}")
        raise HTTPException(status_code=500, detail= e)

@router.delete('/{video_id}')
async def delete_video(video_id: str):
    try:
        video_response = supabase.table('video').select('*').eq('id', video_id).execute()

        await supabase.storage.from_('recorded.videos').remove([video_response.data.file_path])

        response = (
            supabase
            .table('video')
            .delete()
            .eq('id', video_id)
            .execute()
        )
        return {"message": "Video deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting video: {e}")
        raise HTTPException(status_code=500, detail= e)
