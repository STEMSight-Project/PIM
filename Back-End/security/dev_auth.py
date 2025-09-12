"""
Development authentication bypass
Use this for testing when auth is not needed
"""
from fastapi import Request, Response
from common import logger

def dev_user(request: Request, response: Response = None) -> dict:
    """Development user - bypasses authentication"""
    logger.info("Using development authentication bypass")
    return {
        "id": "dev-user-123",
        "email": "dev@stemsight.com", 
        "role": "admin",
        "aud": "authenticated",
        "exp": 9999999999  # Far future expiry
    }

def optional_auth(request: Request, response: Response = None):
    """Try auth first, fallback to dev user"""
    try:
        from security.jwt_verify import current_user
        return current_user(request, response)
    except Exception as e:
        logger.warning(f"Auth failed, using dev user: {e}")
        return dev_user(request, response)