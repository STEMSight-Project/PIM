from fastapi import APIRouter, HTTPException, Response, Request  # Add Request here
from pydantic import BaseModel
from common import admin_supabase
from env import ENVIRONMENT as ENV
from security.jwt_verify import setAccessToken, setRefreshToken

from common import supabase

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(body: LoginRequest, response: Response) -> dict:
    supabase.auth._auto_refresh_token = True

    try:
        auth = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )   
    except Exception as e:
        raise HTTPException(401, "Bad credentials")
    access_token = auth.session.access_token
    refresh_token = auth.session.refresh_token
    setAccessToken(response, access_token)
    setRefreshToken(response, refresh_token)
    return {
        "access_token": auth.session.access_token,
        "refresh_token": auth.session.refresh_token,
        "user": auth.user
    }



@router.get("/me")
def me(request: Request):
    access_token = request.cookies.get("sb-access-token")
    try:
        user = supabase.auth.get_user(access_token)
        if not user:
            raise HTTPException(401, "Unauthorized")
    except Exception as e:
        raise HTTPException(401, "Unauthorized")
    return user

@router.post("/logout")
def logout(response: Response):
    response.delete_cookie("sb-access-token", path="/")
    response.delete_cookie("sb-refresh-token", path="/auth/refresh")
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
    email: str


@router.post("/request-password-reset")
async def request_password_reset(data: ResetRequest):
    try:
        supabase.auth.reset_password_email(
            data.email, {
                "redirect_to": "https://localhost:3000/password-reset",
            }
        )
        return {"message": "Password reset email sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
class ConfirmResetRequest(BaseModel):
    access_token: str
    new_password: str


@router.post("/confirm-password-reset")
def confirm_password_reset(data: ConfirmResetRequest):
    try:
        #Supabase will update user PW using the provided access token
        res = admin_supabase.auth.get_user(data.access_token)
        admin_supabase.auth.admin
        print(f"[BOGUS]: {res.user}")
        admin_supabase.auth.admin.update_user_by_id(
            res.user.id, {"password": data.new_password}
        )

        return {"message": "Password reset successfully"}
    except Exception as e:
        #Will return HTTP 500 error for any other encountered errors.
        print(f"[BOGUS]: {e.__dict__}")
        raise HTTPException(500, str(e))