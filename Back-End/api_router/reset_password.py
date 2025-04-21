from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env

#Initialize FastAPI instance
router = APIRouter()

# Supabase setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
REDIRECT_PASSWORD_URL = os.getenv("REDIRECT_PASSWORD_URL")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

class ResetRequest(BaseModel):
    email: str


@router.post("/request-password-reset")
async def request_password_reset(data: ResetRequest):
    try:
        #Will request Supabase for password reset, and prompt redirection to reset PW page
        response = supabase.auth.api.reset_password_for_email(
            data.email,
            redirect_to=REDIRECT_PASSWORD_URL
        )
         #if Supabase return error, raise HTTP 400
        if response.get("error"):
            raise HTTPException(status_code=400, detail=response["error"]["message"])
        #return success message back
        return {"message": "Password reset email sent"}
        #Any other error will return error 500
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
class ConfirmResetRequest(BaseModel):
    access_token: str
    new_password: str


@router.post("/confirm-password-reset")
async def confirm_password_reset(data: ConfirmResetRequest):
    try:
        #Supabase will update user PW using the provided access token
        result = supabase.auth.api.update_user(
            access_token=data.access_token,
            attributes={"password": data.new_password}
        )
        #IF supabase has error, raise HTTP 400
        if result.get("error"):
            raise HTTPException(400, result["error"]["message"])
        #will return success message
        return {"message": "Password has been reset successfully"}
    except Exception as e:
        #Will return HTTP 500 error for any other encountered errors.
        raise HTTPException(500, str(e))
