from fastapi import Request, HTTPException
from typing import Optional
from jwt import InvalidAudienceError, ExpiredSignatureError, InvalidTokenError
from common import supabase_auth, admin_supabase, logger
from env import ENVIRONMENT as ENV

def refresh_token(rf_token: str) -> dict:
    try:
        # Use the auth client for token operations
        payload = supabase_auth.auth.refresh_session(rf_token)
        return payload.session
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Refresh token expired or invalid: {e}")
        raise HTTPException(status_code=401, detail="Refresh token expired or invalid")
    except Exception as e:
        logger.error(f"Error refreshing token: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

def current_user(request: Request) -> dict:
    # Extract authorization header from request
    print(request.headers)
    authorization = request.headers.get("Authorization")
    
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header missing")
    
    # Extract Bearer token
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization header format")
    
    access_token = authorization.replace("Bearer ", "", 1)
    
    try:
        # Verify the token and get user
        user_response = supabase_auth.auth.get_user(access_token)
        return user_response.user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(status_code=401, detail="Token expired or invalid")
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(status_code=401, detail="Invalid audience")
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(status_code=401, detail="Authentication failed")

