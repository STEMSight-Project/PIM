from fastapi import APIRouter, HTTPException, Response, Request  # Add Request here
from pydantic import BaseModel

from common import supabase

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

COOKIE_SETTINGS = dict(httponly=True, secure=True, samesite="None")

@router.post("/login")
def login(body: LoginRequest, request: Request, response: Response):
    try:
        auth = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )   
    except Exception as e:
        raise HTTPException(401, "Bad credentials")

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



@router.get("/me")
def me(request: Request, response: Response):
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