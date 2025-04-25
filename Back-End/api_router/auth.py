from fastapi import APIRouter, HTTPException, Response, Request  # Add Request here
from pydantic import BaseModel, EmailStr

from common import supabase

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

COOKIE_SETTINGS = dict(httponly=True, secure=True, samesite="lax")

@router.post("/login")
def login(body: LoginRequest, response: Response):
    try:
        auth = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )   
    except Exception as e:
        raise HTTPException(401, "Bad credentials")

    print(auth.session)
    session = auth.session
    response.set_cookie(
        "sb-access-token", session.access_token,
        max_age=session.expires_in, **COOKIE_SETTINGS
    )
    response.set_cookie(
        "sb-refresh-token", session.refresh_token,
        max_age=60*60*24*30,  # 30 days
        path="/auth/refresh", **COOKIE_SETTINGS
    )
    return {
        "access_token": auth.session.access_token,
        "user": auth.user
    }

def check_auth(request: Request, response: Response) -> bool:
    access_token = request.cookies.get("sb-access-token")
    if not access_token:
        raise HTTPException(401, "Unauthorized")
    try:
        user = supabase.auth.get_user(access_token)
        if not user:
            refresh(request, response)
    except Exception as e:
        raise HTTPException(401, "Unauthorized")
    return True

def refresh(request: Request, response: Response):
    rt = request.cookies.get("sb-refresh-token")
    if not rt:
        raise HTTPException(401)
    try:
        new = supabase.auth.refresh_session(rt)
        session = new.session
        response.set_cookie(
            "sb-access-token", session.access_token,
            max_age=session.expires_in, **COOKIE_SETTINGS
        )
        response.set_cookie(
            "sb-refresh-token", session.refresh_token,
            max_age=60*60*24*30, # 1 month for refresh token
            path="/auth/refresh", **COOKIE_SETTINGS
        )
    except Exception as e:
        raise HTTPException(401, "Unauthorized")

@router.post("/logout")
def logout(response: Response):
    response.delete_cookie("sb-access-token", path="/")
    response.delete_cookie("sb-refresh-token", path="/auth/refresh")
    return {"logged_out": True}