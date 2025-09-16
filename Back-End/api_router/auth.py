Antonio-Test-branch
from fastapi import APIRouter, HTTPException, Response, Request, BackgroundTasks
from pydantic import BaseModel, EmailStr, ValidationError
from common import admin_supabase, supabase
from env import ENVIRONMENT as ENV
from security.jwt_verify import setAccessToken, setRefreshToken
from email_service import (
    send_confirmation_email, 
    generate_confirmation_token, 
    store_confirmation_token,
    verify_confirmation_token,
    mark_email_confirmed
)
import asyncio
from common import supabase

from fastapi import APIRouter, HTTPException, Header, Depends, Request
from pydantic import BaseModel, EmailStr, ValidationError
from typing import Optional
from core.common import admin_supabase
from core.env import ENVIRONMENT as ENV
from security.jwt_verify import current_user

from core.common import supabase
 main

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
            
        # CHECK EMAIL CONFIRMATION - THIS IS THE NEW PART
        if not auth.user.email_confirmed_at:
            raise HTTPException(403, detail="Please confirm your email address before logging in.")
            
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


 Antonio-Test-branch



main
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
 Antonio-Test-branch
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str = None

class ConfirmEmailRequest(BaseModel):
    token: str

# Add these new endpoints to your existing auth router:

@router.post("/register")
async def register(body: RegisterRequest, background_tasks: BackgroundTasks):
    """Register a new user and send confirmation email"""
    try:
        # Create user in Supabase Auth (but don't confirm email yet)
        auth_response = supabase.auth.sign_up({
            "email": body.email,
            "password": body.password,
            "options": {
                "data": {
                    "full_name": body.full_name
                }
            }
        })
        
        if not auth_response.user:
            raise HTTPException(status_code=400, detail="Failed to create user")
        
        # Generate confirmation token
        confirmation_token = generate_confirmation_token()
        
        # Store confirmation token
        await store_confirmation_token(
            auth_response.user.id,
            body.email,
            confirmation_token
        )
        
        # Send confirmation email in background
        background_tasks.add_task(
            send_confirmation_email,
            body.email,
            confirmation_token,
            body.full_name or "User"
        )
        
        return {
            "message": "User registered successfully. Please check your email to confirm your account.",
            "user_id": auth_response.user.id
        }
        
    except Exception as e:
        logger.error(f"Registration failed: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Registration failed: {str(e)}")

@router.post("/confirm-email")
async def confirm_email(body: ConfirmEmailRequest):
    """Confirm user's email address"""
    try:
        # Verify the token
        confirmation = await verify_confirmation_token(body.token)
        
        if not confirmation:
            raise HTTPException(
                status_code=400, 
                detail="Invalid or expired confirmation token"
            )
        
        # Mark email as confirmed
        success = await mark_email_confirmed(body.token, confirmation['user_id'])
        
        if not success:
            raise HTTPException(
                status_code=500, 
                detail="Failed to confirm email"
            )
        
        return {
            "message": "Email confirmed successfully! You can now log in.",
            "confirmed": True
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Email confirmation failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Email confirmation failed")

@router.post("/resend-confirmation")
async def resend_confirmation(body: RegisterRequest, background_tasks: BackgroundTasks):
    """Resend confirmation email"""
    try:
        # Check if user exists and is not confirmed
        user = supabase.auth.get_user_by_email(body.email)
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # Generate new confirmation token
        confirmation_token = generate_confirmation_token()
        
        # Store new confirmation token
        await store_confirmation_token(
            user.id,
            body.email,
            confirmation_token
        )
        
        # Send confirmation email
        background_tasks.add_task(
            send_confirmation_email,
            body.email,
            confirmation_token,
            user.user_metadata.get('full_name', 'User')
        )
        
        return {"message": "Confirmation email sent"}
        
    except Exception as e:
        logger.error(f"Failed to resend confirmation: {str(e)}")
        raise HTTPException(status_code=400, detail="Failed to resend confirmation email")

 main
