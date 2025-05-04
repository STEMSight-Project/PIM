from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from datetime import datetime
from common import logger, supabase
from security.jwt_verify import current_user

router = APIRouter(dependencies=[Depends(current_user)])

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

class MedicalHistoryOut(BaseModel):
    id: str
    patient_id: str
    doctor_id: str
    diagnosis: str
    note: Optional[str]
    created_at: str
    updated_at: str

@router.get("/", response_model=List[MedicalHistory])
def get_all_medical_history():
    try:
        response = supabase.table("medical_history").select("*").execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="No medical history found")
        return response.data
    except Exception as e:
        logger.error(f"Error getting medical history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{medical_history_id}", response_model=MedicalHistoryOut)
def get_medical_history_by_id(medical_history_id: str):
    try:
        response = (
            supabase.table("medical_history")
            .select("*")
            .eq("id", medical_history_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=404, detail="Medical history not found")
        return response.data[0]
    except Exception as e:
        logger.error(f"Error getting medical history by id: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=MedicalHistoryOut)
def create_medical_history(payload: MedicalHistoryCreate):
    try:
        resp = supabase.table("medical_history").insert(payload.dict()).execute()
        if not resp.data:
            raise HTTPException(status_code=400, detail="Insert failed")
        # refetch full record
        new_id = resp.data[0]["id"]
        full = supabase.table("medical_history").select("*").eq("id", new_id).execute()
        return full.data[0]
    except Exception as e:
        logger.error(f"Error creating medical history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{medical_history_id}", response_model=MedicalHistory)
def update_medical_history(medical_history_id: str, req: MedicalHistoryBase):
    try:
        response = (
            supabase.table("medical_history")
            .update(req.dict())
            .eq("id", medical_history_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to update medical history")
        # refetch to get the updated record
        full = supabase.table("medical_history").select("*").eq("id", medical_history_id).execute()
        return full.data[0]
    except Exception as e:
        logger.error(f"Error updating medical history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{medical_history_id}")
def delete_medical_history(medical_history_id: str):
    try:
        response = (
            supabase.table("medical_history")
            .delete()
            .eq("id", medical_history_id)
            .execute()
        )
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to delete medical history")
        return {"message": "Deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting medical history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

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