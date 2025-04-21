from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from common import supabase, logger

router = APIRouter()

class NoteBase(BaseModel):
    content: str
    patient_id: str
    video_id: Optional[str] = None
    author: str
    timestamp_seconds: Optional[float] = None

class Note(NoteBase):
    id: str
    created_at: datetime
    updated_at: Optional[datetime] = None

@router.get('/patient/{patient_id}')
def get_notes_for_patient(patient_id: str):
    try:
        response = (
            supabase
            .table('note')
            .select('*')
            .eq('patient_id', patient_id)
            .order('created_at', desc=True)
            .execute()
        )
        return response.data
    except Exception as e:
        logger.error(f"Error getting notes for patient: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/video/{video_id}')
def get_notes_for_video(video_id: str):
    try:
        response = (
            supabase
            .table('note')
            .select('*')
            .eq('video_id', video_id)
            .order('created_at', desc=True)
            .execute()
        )
        return response.data
    except Exception as e:
        logger.error(f"Error getting notes for video: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post('/')
def create_note(note: NoteBase):
    try:
        response = (
            supabase
            .table('note')
            .insert(note.model_dump())
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to create note")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error creating note: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put('/{note_id}')
def update_note(note_id: str, note_update: NoteBase):
    try:
        response = (
            supabase
            .table('note')
            .update(note_update.model_dump())
            .eq('id', note_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=404, detail="Note not found")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error updating note: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete('/{note_id}')
def delete_note(note_id: str):
    try:
        response = (
            supabase
            .table('note')
            .delete()
            .eq('id', note_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=404, detail="Note not found")
        return {"message": "Note deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting note: {e}")
        raise HTTPException(status_code=500, detail=str(e))