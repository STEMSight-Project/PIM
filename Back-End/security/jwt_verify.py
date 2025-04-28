from datetime import datetime
from fastapi import Request, HTTPException
import jwt
from jwt import InvalidAudienceError, ExpiredSignatureError, InvalidTokenError
from common import supabase, logger
from env import ENVIRONMENT as ENV

def current_user(request: Request):
    token = request.headers.get("Authorization")
    try:
        if token:
            token = token.split(" ")[1]  # Remove "Bearer" prefix
        else:
            token = None
        if not token:
            raise HTTPException(status_code=401, detail="Token not provided")
        jwt.decode(token, ENV.JWT_SECRET, algorithms=["HS256"], audience="authenticated")
        user = supabase.auth.get_user(token) # Check token
        return user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(status_code=401, detail="Token expired or invalid")
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(status_code=401, detail="Invalid audience")
