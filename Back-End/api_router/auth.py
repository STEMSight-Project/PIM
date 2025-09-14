from fastapi import APIRouter, HTTPException, Header, Depends, Request
from pydantic import BaseModel, EmailStr, ValidationError
from typing import Optional
from core.common import admin_supabase
from core.env import ENVIRONMENT as ENV
from security.jwt_verify import current_user

from core.common import supabase

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
    supabase.auth._auto_refresh_token = True

    try:
        # Pydantic will raise ValidationError if email is not valid
        auth = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )
        if not auth.session:
            raise HTTPException(401, detail="Invalid email or password.")
    except ValidationError as ve:
        raise HTTPException(422, detail="Invalid email format.")
    except HTTPException as he:
        # Already handled above
        raise he
    except Exception as e:
        # Any other error (e.g., network, supabase error)
        raise HTTPException(401, detail="Invalid email or password.")

    access_token = auth.session.access_token
    refresh_token = auth.session.refresh_token

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": auth.user,
    }


@router.get("/me")
def me(request: Request):
    user = current_user(request)  # Extract user from auth
    return user


@router.post("/logout")
def logout():
    # With Bearer token authentication, logout is handled client-side
    # by removing tokens from localStorage
    return {"logged_out": True}


class TokenRefreshRequest(BaseModel):
    refresh_token: str


@router.post("/refresh")
def refresh(body: TokenRefreshRequest) -> dict:
    try:
        auth = supabase.auth.refresh_session(body.refresh_token)
        session = auth.session
        access_token = session.access_token
        refresh_token = session.refresh_token
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
        }
    except Exception:
        raise HTTPException(status_code=401, detail="Session expired")


class ResetRequest(BaseModel):
    email: EmailStr


@router.post("/request-password-reset")
async def request_password_reset(data: ResetRequest):
    try:
        supabase.auth.reset_password_email(
            data.email,
            {
                "redirect_to": "https://main.d3nf33ntk31bcv.amplifyapp.com/password-reset",
            },
        )
        return {"message": "Password reset email sent"}
    except ValidationError as ve:
        raise HTTPException(status_code=422, detail="Invalid email format.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class ConfirmResetRequest(BaseModel):
    access_token: str
    new_password: str


@router.post("/confirm-password-reset")
def confirm_password_reset(data: ConfirmResetRequest):
    try:
        # Supabase will update user PW using the provided access token
        res = admin_supabase.auth.get_user(data.access_token)
        admin_supabase.auth.admin
        print(f"[BOGUS]: {res.user}")
        admin_supabase.auth.admin.update_user_by_id(
            res.user.id, {"password": data.new_password}
        )

        return {"message": "Password reset successfully"}
    except Exception as e:
        # Will return HTTP 500 error for any other encountered errors.
        print(f"[BOGUS]: {e.__dict__}")
        raise HTTPException(500, str(e))
