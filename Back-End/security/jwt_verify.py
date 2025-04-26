from fastapi import Request, HTTPException, Depends, Response
import jwt
from jwt import PyJWTError
from datetime import datetime, timezone
from common import supabase

SECRET_KEY = "your-supabase-jwt-secret"
ALGORITHM = "HS256"

COOKIE_SETTINGS = dict(httponly=True, secure=True, samesite="None")

def verify_jwt(request: Request):
    token = request.cookies.get("sb-access-token")
    if not token:
        raise HTTPException(status_code=401, detail="Missing access token")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        if payload.get("exp") and datetime.fromtimestamp(payload["exp"], timezone.utc) < datetime.now(timezone.utc):
            raise HTTPException(status_code=401, detail="Token expired")
        print(payload)
        return payload
    except PyJWTError:
        print(token)
        raise HTTPException(status_code=401, detail="Invalid token")
    except Exception:
        raise HTTPException(status_code=401, detail="Token verification failed")

def refresh(request: Request, response: Response) -> dict:
    if request.cookies.get("sb-access-token"):
        return {
            "access_token": request.cookies.get("sb-access-token"),
            "user": supabase.auth.get_user(request.cookies.get("sb-access-token"))
        }

    rt = request.cookies.get("sb-refresh-token")
    if not rt:
        raise HTTPException(status_code=401, detail="Missing refresh token")

    try:
        new = supabase.auth.refresh_session(rt)
        session = new.session
        response.set_cookie(
            "sb-access-token", session.access_token,
            max_age=session.expires_in, **COOKIE_SETTINGS
        )
        response.set_cookie(
            "sb-refresh-token", session.refresh_token,
            max_age=60 * 60 * 24 * 30,  # 30 days
            path="/auth/refresh", **COOKIE_SETTINGS
        )
        return {
            "access_token": session.access_token,
            "user": new.user
        }
    except Exception:
        raise HTTPException(status_code=401, detail="Unauthorized")
