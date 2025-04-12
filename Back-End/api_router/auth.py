from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from supabase_settings.supabase_client import get_supabase_client

router = APIRouter()

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

supabase = get_supabase_client()

@router.get("/")
def read_root():
    return {"message": "Hello World"}

@router.post("/login")
def login(request: LoginRequest):
    try:

        response = supabase.auth.sign_in_with_password(
            {"email": request.email, "password": request.password}
        )
        # Some Supabase versions might raise an exception if login fails,
        # so it’s good practice to wrap this in try/except.

        if not response.session:
            # If session is None, the login was invalid.
            raise HTTPException(status_code=401, detail="Invalid credentials.")

        # If you got here, you have a valid session and user
        return {
            "access_token": response.session.access_token,
            "user": response.user
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")