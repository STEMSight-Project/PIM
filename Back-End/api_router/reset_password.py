from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from supabase import create_client
from env import ENVIRONMENT as ENV
from common import supabase, logger

#Initialize FastAPI instance
router = APIRouter()

class ResetRequest(BaseModel):
    email: str


@router.post("/request-password-reset")
async def request_password_reset(data: ResetRequest):
    try:
        supabase.auth.reset_password_email(
            data.email,
            {
                "redirect_to": ENV.REDIRECT_PASSWORD_URL,
            }
        )
        return {"message": "Password reset email sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
class ConfirmResetRequest(BaseModel):
    access_token: str
    new_password: str


@router.post("/confirm-password-reset")
async def confirm_password_reset(data: ConfirmResetRequest):
    try:
        #Supabase will update user PW using the provided access token
        user = supabase.auth.update_user(
            access_token=data.access_token,
            attributes={"password": data.new_password}
        )

        return {"message": "Password reset successfully"}
    except Exception as e:
        #Will return HTTP 500 error for any other encountered errors.
        raise HTTPException(500, str(e))
