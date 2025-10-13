from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional
from core.common import supabase, supabase_auth, logger
from core.env import ENVIRONMENT as ENV
from api_router.doctor import Specialization

router = APIRouter()


class RegisterDoctorRequest(BaseModel):
    first_name: str
    last_name: str
    specialization: Specialization
    email: EmailStr
    password: str
    primary_phone: str


class RegisterDoctorResponse(BaseModel):
    user_id: str
    doctor_id: Optional[str]
    message: str


@router.post("/register-doctor", response_model=RegisterDoctorResponse, summary="Register a new doctor account (public)")
async def register_doctor(body: RegisterDoctorRequest):
    """
    Public endpoint to create a new doctor account with Supabase Auth and a matching doctor profile row.

    Flow:
    Will create a Supabase Auth user and will trigger an email being sent to the address provided.
    Will insert doctor profile from the given data row into `doctor` table in Supabase database.
    """
    try:
        # Sign up the user via Supabase Auth (client-style). This will
        # trigger a confirmation email automatically.
        email_redirect = None
        try:
            base_url = getattr(ENV, "NEXT_PUBLIC_API_URL", None)
            if base_url:
                email_redirect = base_url  # You can configure a specific callback route if desired
        except Exception:
            email_redirect = None

        signup_payload = {"email": body.email, "password": body.password}
        if email_redirect:
            signup_payload = {
                **signup_payload,
                "options": {"email_redirect_to": email_redirect,
                             "data": {"first_name": body.first_name, "last_name": body.last_name, "role": "doctor"}},
            }

        auth_res = supabase_auth.auth.sign_up(signup_payload)
        user = getattr(auth_res, "user", None)
        if not user:
            raise HTTPException(status_code=400, detail="Failed to sign up user")

        user_id = user.id

        # Will insert the doctor information
        doctor_payload = {
            "first_name": body.first_name.strip(),
            "last_name": body.last_name.strip(),
            "specialization": body.specialization.value if isinstance(body.specialization, Specialization) else body.specialization,
            "email": body.email.strip(),
            "primary_phone": body.primary_phone,
            
        }

        db_res = (
            supabase
            .table("doctor")
            .insert(doctor_payload)
            .execute()
        )

        doctor_id = None
        if db_res.data and len(db_res.data) > 0:
            doctor_id = db_res.data[0].get("id")

        return RegisterDoctorResponse(
            user_id=user_id,
            doctor_id=doctor_id,
            message="Registration successful. Please check your email for a verification link to activate your account.",
        )

    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("Failed to register doctor: %s", exc)
        raise HTTPException(status_code=500, detail="Failed to register doctor")
