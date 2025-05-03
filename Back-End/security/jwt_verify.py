from fastapi import Request, HTTPException, Response
from jwt import InvalidAudienceError, ExpiredSignatureError, InvalidTokenError
from common import supabase, logger
from env import ENVIRONMENT as ENV

def refresh_token(rf_token: str) -> dict:
    try:
        # Decode the refresh token to get the user ID
        payload = supabase.auth.refresh_session(rf_token)
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Refresh token expired or invalid: {e}")
        raise HTTPException(status_code=401, detail="Refresh token expired or invalid")
    except Exception as e:
        logger.error(f"Error refreshing token: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    return payload

def current_user(request: Request, response: Response) -> dict:
    # token = request.headers.get("Authorization")
    access_token = request.cookies.get("sb-access-token")
    rf_token = request.cookies.get("sb-refresh-token")
    try:
        # if token:
        #     token = token.split(" ")[1]  # Remove "Bearer" prefix
        # else:
        #     token = None
        if not access_token:
            if not refresh_token:
                raise HTTPException(status_code=401, detail="No token provided")
            data = refresh_token(rf_token)
            print(data)
            access_token = data.access_token
            rf_token = data.refesh_token

        setAccessToken(response, access_token)
        setRefreshToken(response, rf_token)

        user = supabase.auth.get_user(access_token) # Check token
        return user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(status_code=401, detail="Token expired or invalid")
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(status_code=401, detail="Invalid audience")

def setAccessToken(response: Response, access_token: str) -> None:
    response.set_cookie(
        "sb-access-token",
        access_token,
        max_age=60 * 50,  # 50 minutes
        expires=60 * 60,  # 1 hour
        httponly=True,
        secure=True,
        samesite="none",
        path="/",
    )

def setRefreshToken(response: Response, refresh_token: str) -> None:
    response.set_cookie(
        "sb-refresh-token",
        refresh_token,
        max_age=60 * 60 * 24 * 30 ,  # 30 days
        expires=60 * 60 * 24 * 30,  # 30 days
        httponly=True,
        secure=True,
        samesite="none",
        path="/auth/refresh",
    )