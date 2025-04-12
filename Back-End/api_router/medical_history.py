from typing import Optional
from supabase_settings.supabase_client import get_supabase_client
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from common import logger

supabase = get_supabase_client()

router = APIRouter()

class MedicalHistoryBase(BaseModel):
    patient_id: str
    doctor_id: str
    diagnosis: str
    note: Optional[str] = None

class MedicalHistory(MedicalHistoryBase):
    id: str
    created_at: datetime
    updated_at: datetime

class MedicalHistoryCreate(MedicalHistoryBase):
    class Config:
        orm_mode = True

@router.get('/', response_model= list[MedicalHistory])
def get_all_medical_history():
    try:
        response = (
            supabase
            .table('medical_history')
            .select('*')
            .execute()
        )
        if (not response):
            raise HTTPException(status_code=404, detail="No medical history found")
        return response.data
    except Exception as e:
        logger.error(f"Error getting medical history: {e}")
        raise HTTPException(status_code=500, detail= e)

@router.get('/{medical_history_id}', response_model= MedicalHistory)
def get_medical_history_by_id(medical_history_id: str):
    try:
        response = (
            supabase
            .table('medical_history')
            .select('*')
            .eq('id', medical_history_id)
            .execute()
        )
        if (not response):
            raise HTTPException(status_code=404, detail="Medical history not found")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error getting medical history by id: {e}")
        raise HTTPException(status_code=500, detail= e)

@router.post('/')
def create_medical_history(req : MedicalHistoryCreate):
    try:
        response = (
            supabase
            .table('medical_history')
            .insert(req.model_dump_json())
            .execute()
        )
        if not response:
            raise HTTPException(status_code=400, detail="Failed to create medical history")
        return response.data
    except Exception as e:
        logger.error(f"Error creating medical history: {e}")
        raise HTTPException(status_code=500, detail= e)
    
@router.put('/{medical_history_id}', response_model= MedicalHistory)
def update_medical_history(medical_history_id: str, req : MedicalHistoryBase):
    try:
        response = (
            supabase
            .table('medical_history')
            .update(req)
            .eq('id', medical_history_id)
            .execute()
        )
        if not response:
            raise HTTPException(status_code=400, detail="Failed to update medical history")
        return response.data
    except Exception as e:
        logger.error(f"Error updating medical history: {e}")
        raise HTTPException(status_code=500, detail= e)
    
@router.delete('/{medical_history_id}')
def delete_medical_history(medical_history_id: str):
    try:
        response = (
            supabase
            .table('medical_history')
            .delete()
            .eq('id', id)
            .execute()
        )
        if not response:
            raise HTTPException(status_code=400, detail="Failed to delete medical history")
        
    except Exception as e:
        logger.error(f"Error deleting medical history: {e}")
        raise HTTPException(status_code=500, detail= e)
    
@router.patch('/update_note/{medical_history_id}')
def update_note(medical_history_id: str, note: str):
    try:
        response = (
            supabase
            .table('medical_history')
            .update({'note': note})
            .eq('id', medical_history_id)
            .execute()
        )
        if not response:
            raise HTTPException(status_code=400, detail="Failed to update note")
        return response.data
    except Exception as e:
        logger.error(f"Error updating note: {e}")
        raise HTTPException(status_code=500, detail= e)
