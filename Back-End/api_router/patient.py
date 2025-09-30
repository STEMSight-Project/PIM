from datetime import datetime, date
from typing import Optional, List
from fastapi import Depends, HTTPException, APIRouter, status
from pydantic import BaseModel, Field
from core.common import logger
from core.common import supabase
from security.jwt_verify import router_auth_dependency

# Use universal authentication for both OAuth2 docs AND frontend requests
router = APIRouter(dependencies=[Depends(router_auth_dependency())])


class PatientBase(BaseModel):
    first_name: str = Field(
        ..., min_length=1, max_length=50, description="Patient's first name"
    )
    middle_name: Optional[str] = Field(
        None, max_length=50, description="Patient's middle name"
    )
    last_name: str = Field(
        ..., min_length=1, max_length=50, description="Patient's last name"
    )
    dob: date = Field(..., description="Patient's date of birth")
    primary_phone: str = Field(
        ..., min_length=10, max_length=15, description="Patient's primary phone number"
    )
    address: str = Field(
        ..., min_length=5, max_length=255, description="Patient's address"
    )


class PatientCreate(PatientBase):
    pass


class PatientUpdate(BaseModel):
    first_name: Optional[str] = Field(None, min_length=1, max_length=50)
    middle_name: Optional[str] = Field(None, max_length=50)
    last_name: Optional[str] = Field(None, min_length=1, max_length=50)
    dob: Optional[date] = None
    primary_phone: Optional[str] = Field(None, min_length=10, max_length=15)
    address: Optional[str] = Field(None, min_length=5, max_length=255)


class Patient(PatientBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


@router.get("/", response_model=List[Patient], summary="Get all patients")
async def get_all_patients():
    try:
        result = (
            supabase.table("patients")
            .select("*")
            .order("created_at", desc=True)
            .execute()
        )

        if result.data is None:
            return []

        # Ensure dates/datetimes are JSON serializable
        def _serialize_row(r):
            for k, v in list(r.items()):
                if isinstance(v, (date, datetime)):
                    r[k] = v.isoformat()
            return r

        return [_serialize_row(r) for r in result.data]
    except Exception as exc:
        logger.exception("Failed to retrieve patients: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve patients",
        ) from exc


@router.get("/{patient_id}", response_model=Patient, summary="Get patient by id")
async def get_patient(patient_id: str):
    logger.info("get_patient called for patient_id: %s", patient_id)
    try:
        result = (
            supabase.table("patients")
            .select("*")
            .eq("id", patient_id)
            .single()
            .execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with id {patient_id} not found",
            )

        # Serialize date/datetime fields to ISO strings
        for k, v in list(result.data.items()):
            if isinstance(v, (date, datetime)):
                result.data[k] = v.isoformat()

        return result.data
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to retrieve patient %s: %s", patient_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve patient",
        ) from exc


@router.post(
    "/",
    response_model=Patient,
    summary="Create a new patient",
    status_code=status.HTTP_201_CREATED,
)
async def create_patient(patient: PatientCreate):
    try:
        # Convert patient data to dict for database insertion
        patient_data = patient.model_dump()

        # Ensure date fields are JSON serializable before sending to Supabase
        if isinstance(patient_data.get("dob"), (date, datetime)):
            patient_data["dob"] = patient_data["dob"].isoformat()

        result = supabase.table("patients").insert(patient_data).execute()

        if not result.data or len(result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create patient",
            )

        created = result.data[0]
        for k, v in list(created.items()):
            if isinstance(v, (date, datetime)):
                created[k] = v.isoformat()

        return created
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to create patient: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create patient",
        ) from exc


@router.patch("/{patient_id}", response_model=Patient, summary="Update patient by id")
async def update_patient(patient_id: str, patient: PatientUpdate):
    try:
        # Get only the fields that were actually provided
        updated_values = patient.model_dump(exclude_unset=True)

        if not updated_values:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No data provided for update",
            )

        # Convert date fields to serializable strings and add updated timestamp
        if isinstance(updated_values.get("dob"), (date, datetime)):
            updated_values["dob"] = updated_values["dob"].isoformat()

        # Add updated timestamp
        updated_values["updated_at"] = datetime.utcnow().isoformat()

        result = (
            supabase.table("patients")
            .update(updated_values)
            .eq("id", patient_id)
            .execute()
        )

        if not result.data or len(result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with id {patient_id} not found",
            )

        updated = result.data[0]
        for k, v in list(updated.items()):
            if isinstance(v, (date, datetime)):
                updated[k] = v.isoformat()

        return updated
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to update patient %s: %s", patient_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update patient",
        ) from exc


@router.delete(
    "/{patient_id}",
    summary="Delete patient by id",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_patient(patient_id: str):
    try:
        # First check if patient exists
        check_result = (
            supabase.table("patients").select("id").eq("id", patient_id).execute()
        )

        if not check_result.data or len(check_result.data) == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Patient with id {patient_id} not found",
            )

        # Delete the patient
        _ = supabase.table("patients").delete().eq("id", patient_id).execute()

        return {"message": "Patient deleted successfully"}
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to delete patient %s: %s", patient_id, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete patient",
        ) from exc
