from common import logger, supabase
from fastapi import Depends, HTTPException, APIRouter
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date
from security.jwt_verify import current_user

router = APIRouter(dependencies=[Depends(current_user)])

class Patient(BaseModel):
    id: str
    first_name: str
    middle_name: Optional[str]
    last_name: str
    dob: date
    primary_phone: str
    address: str
    created_at: datetime
    updated_at: datetime

@router.get("/", response_model = list[Patient], summary = "Get all patients")
def getAllPatients():
    try: 
        result = (
            supabase
            .table("patients")
            .select("*")
            .execute()
        )

        return result.data
    except Exception as exc:
        logger.exception("Unhandled exception occurred: %s", exc)
        raise HTTPException(status_code=401, detail= exc)

@router.get("/{patient_id}", response_model = Patient, summary = "Get patient by id")
def getpatient(patient_id: str):
    try:
        result = (
            supabase
            .table("patients")
            .select("*")
            .eq("id", patient_id)
            .execute()
        )
        if not result:
            raise HTTPException(status_code=404, detail="Patient not found")
        
        return result.data[0]
    except Exception as exc:
        logger.exception("Unhandled exception occurred: %s", exc)
        raise HTTPException(status_code=500, detail=  exc)