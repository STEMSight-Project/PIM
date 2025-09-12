from fastapi import Request, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import Optional, Annotated
from jwt import InvalidAudienceError, ExpiredSignatureError, InvalidTokenError
from common import supabase_auth, admin_supabase, logger
from env import ENVIRONMENT as ENV

# OAuth2 scheme for FastAPI docs integration
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

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

def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]) -> dict:
    """
    OAuth2PasswordBearer authentication for FastAPI docs integration.
    This function enables the 'Authorize' button in FastAPI docs.
    """
    print("Token received in get_current_user:", token)
    try:
        # Verify the token and get user
        user_response = supabase_auth.auth.get_user(token)
        return user_response.user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Token expired or invalid",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Invalid audience",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"}
        )

def universal_auth(
    request: Request,
    oauth2_token: Annotated[str, Depends(oauth2_scheme)] = None
) -> dict:
    """
    Universal authentication that handles ALL scenarios:
    1. OAuth2 token from FastAPI docs (oauth2_token parameter)
    2. Direct Authorization headers from frontend (request.headers)
    
    Checks which source has the token and uses it.
    """
    print("=== Universal Auth Debug ===")
    print("OAuth2 token:", oauth2_token[:50] + "..." if oauth2_token and len(oauth2_token) > 50 else oauth2_token)
    print("Request headers:", dict(request.headers))
    
    access_token = None
    token_source = None
    
    # Priority 1: Check OAuth2 token (from FastAPI docs Authorize button)
    if oauth2_token:
        access_token = oauth2_token
        token_source = "OAuth2PasswordBearer"
    else:
        # Priority 2: Check Authorization header (from frontend/manual requests)
        authorization = request.headers.get("authorization")
        if authorization and authorization.startswith("Bearer "):
            access_token = authorization.replace("Bearer ", "", 1)
            token_source = "Authorization header"
        else:
            raise HTTPException(
                status_code=401,
                detail="No valid token found. Provide token via OAuth2 or Authorization header.",
                headers={"WWW-Authenticate": "Bearer"}
            )
    
    print(f"Using token from: {token_source}")
    print("Token:", access_token[:50] + "..." if len(access_token) > 50 else access_token)
    
    try:
        # Verify the token and get user
        user_response = supabase_auth.auth.get_user(access_token)
        print("Authentication successful for user:", user_response.user.email if hasattr(user_response.user, 'email') else 'unknown')
        return user_response.user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(
            status_code=401,
            detail="Token expired or invalid",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(
            status_code=401,
            detail="Invalid audience",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(
            status_code=401,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"}
        )

def unified_auth(request: Request) -> dict:
    """
    Unified authentication that handles both:
    1. OAuth2 tokens from FastAPI docs (via Authorization header)
    2. Direct Authorization headers from frontend
    
    This provides the best of both worlds - OAuth2 docs integration + Request flexibility
    """
    print("Request headers:", dict(request.headers))
    
    # Extract authorization header from request
    authorization = request.headers.get("authorization")
    if not authorization:
        raise HTTPException(
            status_code=401, 
            detail="Authorization header missing",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # Extract Bearer token
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401, 
            detail="Invalid authorization header format. Expected 'Bearer <token>'",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    access_token = authorization.replace("Bearer ", "", 1)
    print("Extracted token:", access_token[:50] + "..." if len(access_token) > 50 else access_token)
    
    try:
        # Verify the token and get user
        user_response = supabase_auth.auth.get_user(access_token)
        print("Authentication successful for user:", user_response.user.email if hasattr(user_response.user, 'email') else 'unknown')
        return user_response.user
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error(f"Token expired or invalid: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Token expired or invalid",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except InvalidAudienceError as e:
        logger.error(f"Invalid audience: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Invalid audience",
            headers={"WWW-Authenticate": "Bearer"}
        )
    except Exception as e:
        logger.error(f"Authentication error: {e}")
        raise HTTPException(
            status_code=401, 
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"}
        )

def current_user(
    request: Request,
    oauth2_token: Annotated[str, Depends(oauth2_scheme)] = None
) -> dict:
    # Legacy function - now uses unified_auth
    return universal_auth(request, oauth2_token)

# Type aliases for authentication
CurrentUser = Annotated[dict, Depends(universal_auth)]    # Universal (handles both OAuth2 + Request)

