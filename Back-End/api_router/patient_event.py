from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum
from common import supabase, logger

router = APIRouter()

class ValidationStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    DISMISSED = "dismissed"

class PatientEventBase(BaseModel):
    type: str
    patient_id: str
    video_id: str
    timestamp: float
    confidence: Optional[int] = None
    validation_status: ValidationStatus = ValidationStatus.PENDING

class PatientEvent(PatientEventBase):
    id: str
    created_at: datetime

class StatusUpdate(BaseModel):
    validation_status: ValidationStatus

@router.get('/patient/{patient_id}')
def get_events_for_patient(patient_id: str):
    try:
        response = (
            supabase
            .table('patient_event')
            .select('*')
            .eq('patient_id', patient_id)
            .order('timestamp')
            .execute()
        )
        return response.data
    except Exception as e:
        logger.error(f"Error getting events for patient: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/video/{video_id}')
def get_events_for_video(video_id: str):
    try:
        response = (
            supabase
            .table('patient_event')
            .select('*')
            .eq('video_id', video_id)
            .order('timestamp')
            .execute()
        )
        return response.data
    except Exception as e:
        logger.error(f"Error getting events for video: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post('/')
def create_event(event: PatientEventBase):
    try:
        response = (
            supabase
            .table('patient_event')
            .insert(event.model_dump())
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to create event")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error creating event: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.patch('/{event_id}/status')
def update_event_status(event_id: str, status_update: StatusUpdate):
    try:
        response = (
            supabase
            .table('patient_event')
            .update({"validation_status": status_update.validation_status})
            .eq('id', event_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=404, detail="Event not found")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error updating event status: {e}")
        raise HTTPException(status_code=500, detail=str(e))