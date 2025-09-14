from fastapi import APIRouter, Depends, HTTPException, status
from typing import Optional, List
from core.common import supabase, logger
from pydantic import BaseModel, EmailStr, ValidationError
from enum import Enum
from datetime import datetime
from security.jwt_verify import current_user

router = APIRouter(dependencies=[Depends(current_user)])

class Specialization(str, Enum):
    GENERAL_PRACTICE = "General Practice/Family Medicine"
    INTERNAL_MEDICINE = "Internal Medicine"
    CARDIOLOGY = "Cardiology"
    DERMATOLOGY = "Dermatology"
    ENDOCRINOLOGY = "Endocrinology"
    GASTROENTEROLOGY = "Gastroenterology"
    NEUROLOGY = "Neurology"
    NEUROSURGERY = "neurosurgeon"
    OBSTETRICS_GYNECOLOGY = "Obstetrics & Gynecology"
    ONCOLOGY = "Oncology"
    ORTHOPEDICS = "Orthopedics"
    PEDIATRICS = "Pediatrics"
    PSYCHIATRY = "Psychiatry"
    RADIOLOGY = "Radiology"
    UROLOGY = "Urology"

class DoctorBase(BaseModel):
    first_name: str
    middle_name: Optional[str] = None
    last_name: str
    specialization: Specialization
    email: EmailStr
    primary_phone: str

class DoctorCreate(DoctorBase):
    pass

class DoctorUpdate(BaseModel):
    first_name: Optional[str] = None
    middle_name: Optional[str] = None
    last_name: Optional[str] = None
    specialization: Optional[Specialization] = None
    email: Optional[EmailStr] = None
    primary_phone: Optional[str] = None

class Doctor(DoctorBase):
    id: str
    created_at: datetime
    updated_at: datetime

@router.get("/", response_model=List[Doctor], summary="Get all doctors")
async def get_all_doctors():
    try:
        result = (
            supabase
            .table("doctor")
            .select("*")
            .order("created_at", desc=True)
            .execute()
        )

        if result.data is None:
            return []
        
        return result.data
    except Exception as exc:
        logger.exception("Failed to retrieve doctors: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve doctors"
        )

@router.get("/{doctor_id}", response_model=Doctor, summary="Get doctor by ID")
async def get_doctor(doctor_id: str):
    """Retrieve a specific doctor by their ID"""
    try:
        result = (
            supabase
            .table("doctor")
            .select("*")
            .eq("id", doctor_id)
            .single()
            .execute()
        )
        
        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Doctor with id {doctor_id} not found"
            )
        
        return result.data
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to retrieve doctor %s: %s", doctor_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve doctor"
        )

@router.post("/", response_model=Doctor, summary="Create a new doctor", status_code=status.HTTP_201_CREATED)
async def create_doctor(doctor: DoctorCreate):
    """Create a new doctor record"""
    try:
        # Convert doctor data to dict for database insertion
        doctor_data = doctor.model_dump()
        
        result = (
            supabase
            .table("doctor")
            .insert(doctor_data)
            .execute()
        )
        
        if not result.data or len(result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create doctor"
            )
        
        return result.data[0]
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to create doctor: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create doctor"
        )

@router.patch("/{doctor_id}", response_model=Doctor, summary="Update doctor by ID")
async def update_doctor(doctor_id: str, doctor: DoctorUpdate):
    """Update an existing doctor record"""
    try:
        # Get only the fields that were actually provided
        update_values = doctor.model_dump(exclude_unset=True)
        
        if not update_values:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No data provided for update"
            )
        
        # Add updated timestamp
        update_values["updated_at"] = datetime.utcnow().isoformat()
        
        result = (
            supabase
            .table("doctor")
            .update(update_values)
            .eq("id", doctor_id)
            .execute()
        )
        
        if not result.data or len(result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Doctor with id {doctor_id} not found"
            )
        
        return result.data[0]
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to update doctor %s: %s", doctor_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update doctor"
        )

@router.delete("/{doctor_id}", summary="Delete doctor by ID", status_code=status.HTTP_204_NO_CONTENT)
async def delete_doctor(doctor_id: str):
    """Delete a doctor record"""
    try:
        # First check if doctor exists
        check_result = (
            supabase
            .table("doctor")
            .select("id")
            .eq("id", doctor_id)
            .execute()
        )
        
        if not check_result.data or len(check_result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Doctor with id {doctor_id} not found"
            )
        
        # Delete the doctor
        result = (
            supabase
            .table("doctor")
            .delete()
            .eq("id", doctor_id)
            .execute()
        )
        
        return {"message": "Doctor deleted successfully"}
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to delete doctor %s: %s", doctor_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete doctor"
        )
