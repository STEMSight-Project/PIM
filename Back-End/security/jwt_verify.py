from fastapi import Request, HTTPException, Depends, Response
import jwt
from jwt import PyJWTError
from datetime import datetime, timezone
from common import supabase

SECRET_KEY = "WZFXAMweOYvERDZ6UviDeF7cia880Nee5euQVb7nKe79FuNC9Qeg7P7XnjPHQM9U2LrqVh4CGRsFa60iIB+0tQ=="
ALGORITHM = "HS256"

COOKIE_SETTINGS = dict(httponly=True, secure=True, samesite="None")

def current_user(request: Request, response: Response):
    token = request.cookies.get("sb-access-token")
    rf_token = request.cookies.get("sb-refresh-token")
    
    try:
        if not token and not rf_token:
            raise HTTPException(status_code=402, detail= "Unauthorize session")
        if not token:
            auth = refresh(rf_token, response)
            return auth.user
        user = supabase.auth.get_user(token) # Check token
        return user
    except PyJWTError:
        print(token)
        raise HTTPException(status_code=401, detail="Invalid token")
    except Exception:
        raise HTTPException(status_code=401, detail="Token verification failed")

def refresh(rf_token: str, response: Response) -> dict:
    try:
        auth = supabase.auth.refresh_session(rf_token)
        session = auth.session
        response.set_cookie(
            "sb-access-token", session.access_token,
            max_age=session.expires_in, **COOKIE_SETTINGS
        )
        response.set_cookie(
            "sb-refresh-token", session.refresh_token,
            max_age=60 * 60 * 24 * 30,  # 30 days
            path="/auth/refresh", **COOKIE_SETTINGS
        )
        return auth
    except Exception:
        raise HTTPException(status_code=401, detail="Unauthorized")