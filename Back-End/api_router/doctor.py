from fastapi import APIRouter, Depends, HTTPException, Request, Response
from typing import Optional
from common import supabase
from pydantic import BaseModel, EmailStr, ValidationError
from enum import Enum
from common import logger
from security.jwt_verify import current_user

router = APIRouter(dependencies=[Depends(current_user)])

@router.get('/')
def get_doctors(request: Request, response: Response):
    try:
        response = supabase.table('doctors').select('*').execute()

        if not response.data:
            raise HTTPException(status_code=404, detail="No doctors found")
        return response.data
    except Exception as e:
        logger.exception("Unhandled exception occurred: %s", e)
        raise HTTPException(status_code=500, detail= e)

@router.get('/{doctor_id}')
def get_doctor(doctor_id: str):
    try:
        response = supabase.table('doctors').select('*').eq('id', doctor_id).execute()
        if not response.data:
            raise HTTPException(status_code=404, detail="Doctor not found")
        return response.data[0]
    except Exception as e:
        logger.exception("Unhandled exception occurred: %s", e)
        raise HTTPException(status_code=500, detail= e)

class Specialization(Enum):
    GENERAL_PRACTICE = "General Practice/Family Medicine"
    INTERNAL_MEDICINE = "Internal Medicine"
    CARDIOLOGY = "Cardiology"
    DERMATOLOGY = "Dermatology"
    ENDOCRINOLOGY = "Endocrinology"
    GASTROENTEROLOGY = "Gastroenterology"
    NEUROLOGY = "Neurology"
    OBSTETRICS_GYNECOLOGY = "Obstetrics & Gynecology"
    ONCOLOGY = "Oncology"
    ORTHOPEDICS = "Orthopedics"
    PEDIATRICS = "Pediatrics"
    PSYCHIATRY = "Psychiatry"
    RADIOLOGY = "Radiology"
    UROLOGY = "Urology"

class DoctorRequest(BaseModel):
    first_name: str
    middle_name: Optional[str]
    last_name: str
    specialization: Specialization
    email: EmailStr
    primary_phone: str
    
    class Config:
        from_attributes = True

@router.post('/')
def create_doctor(doctor: DoctorRequest):
    try:
        response = supabase.table('doctors').insert(doctor.model_dump_json()).execute()
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to create doctor")
        return response.data[0]
    except ValidationError as e:
        logger.error("Validation error occurred: %s", e.errors())
        raise HTTPException(status_code=422, detail=e.errors())
    except HTTPException as e:
        logger.error("HTTP error occurred: %s", e.detail)
        raise e
    except Exception as e:
        logger.exception("Unhandled exception occurred: %s", e)
        raise HTTPException(status_code=500, detail= e)

class DoctorUpdateRequest(BaseModel):
    first_name: Optional[str] = None
    middle_name: Optional[str] = None
    last_name: Optional[str] = None
    specialization: Optional[Specialization] = None
    primary_phone: Optional[str] = None

    class Config:
        use_enum_values = True

@router.patch('/')
def update_doctor(doctor_id: str, doctor: DoctorUpdateRequest):
    try:
        """This exclude_unset = True mean convert data to dict and exclude unset fields"""
        update_values = doctor.model_dump(exclude_unset=True)
        response = supabase.table('doctors').update(update_values).eq('id', doctor_id).execute()
        if not response.data:
            raise HTTPException(status_code=400, detail="Failed to update doctor")
        return response.data[0]
    except Exception as e:
        logger.exception("Unhandled exception occurred: %s", e)
        raise HTTPException(status_code=500, detail= e)