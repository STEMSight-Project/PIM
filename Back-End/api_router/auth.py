from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel, EmailStr, ValidationError
from typing import Optional
from core.common import admin_supabase, supabase
from core.env import ENVIRONMENT as ENV
from security.jwt_verify import current_user

router = APIRouter()

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

@router.post(
    "/login",
    summary="Login to get access token",
    description="Use this endpoint to get your Bearer token for API authentication",
)
def login(body: LoginRequest) -> dict:
    """Authenticate user and return tokens. Requires email confirmation."""
    supabase.auth._auto_refresh_token = True
    try:
        auth = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )
        if not auth.session:
            raise HTTPException(401, detail="Invalid email or password.")
        # Require email confirmation
        if not auth.user.email_confirmed_at:
            raise HTTPException(403, detail="Please confirm your email address before logging in.")
    except ValidationError:
        raise HTTPException(422, detail="Invalid email format.")
    except HTTPException as he:
        raise he
    except Exception:
        raise HTTPException(401, detail="Invalid email or password.")
    return {
        "access_token": auth.session.access_token,
        "refresh_token": auth.session.refresh_token,
        "user": auth.user,
    }

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None

@router.post("/register", summary="Register a new user (Supabase handles confirmation email)")
def register(body: RegisterRequest):
    """Register a new user. Supabase will send a confirmation email automatically."""
    try:
        result = admin_supabase.auth.sign_up({
            "email": body.email,
            "password": body.password,
            "data": {"full_name": body.full_name or ""}
        })
        user = result.user
        if not user:
            raise HTTPException(400, detail="Failed to create user.")
        return {"message": "User created. Please check your email to confirm your account."}
    except Exception as e:
        raise HTTPException(500, detail=f"Registration failed: {str(e)}")

@router.get("/me")
def me(request: Request):
    """Get current authenticated user info."""
    user = current_user(request)
    return user

@router.post("/logout")
def logout():
    """Logout endpoint (client should remove tokens)."""
    return {"logged_out": True}

class TokenRefreshRequest(BaseModel):
    refresh_token: str

@router.post("/refresh")
def refresh(body: TokenRefreshRequest) -> dict:
    """Refresh access and refresh tokens."""
    try:
        auth = supabase.auth.refresh_session(body.refresh_token)
        session = auth.session
        return {
            "access_token": session.access_token,
            "refresh_token": session.refresh_token,
        }
    except Exception:
        raise HTTPException(status_code=401, detail="Session expired")

class ResetRequest(BaseModel):
    email: EmailStr

@router.post("/request-password-reset")
async def request_password_reset(data: ResetRequest):
    """Request a password reset email (Supabase handles email)."""
    try:
        supabase.auth.reset_password_email(
            data.email,
            {"redirect_to": "https://main.d3nf33ntk31bcv.amplifyapp.com/password-reset"},
        )
        return {"message": "Password reset email sent"}
    except ValidationError:
        raise HTTPException(status_code=422, detail="Invalid email format.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class ConfirmResetRequest(BaseModel):
    access_token: str
    new_password: str

@router.post("/confirm-password-reset")
def confirm_password_reset(data: ConfirmResetRequest):
    """Confirm password reset using access token and new password."""
    try:
        res = admin_supabase.auth.get_user(data.access_token)
        admin_supabase.auth.admin.update_user_by_id(
            res.user.id, {"password": data.new_password}
        )
        return {"message": "Password reset successfully"}
    except Exception as e:
        raise HTTPException(500, str(e))
