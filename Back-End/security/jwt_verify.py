from fastapi import Request, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from typing import Annotated
from jwt import InvalidAudienceError, ExpiredSignatureError, InvalidTokenError
from core.common import supabase_auth, logger

# OAuth2 scheme for FastAPI docs integration
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)


def refresh_token(rf_token: str) -> dict:
    """Refresh an expired JWT token using the refresh token."""
    try:
        payload = supabase_auth.auth.refresh_session(rf_token)
        return payload.session
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error("Refresh token expired or invalid: %s", e)
        raise HTTPException(
            status_code=401, detail="Refresh token expired or invalid"
        ) from e
    except Exception as e:
        logger.error("Error refreshing token: %s", e)
        raise HTTPException(status_code=500, detail="Internal server error") from e


def _verify_token(access_token: str) -> dict:
    """Private function to verify token and return user data."""
    try:
        logger.info("Calling supabase_auth.auth.get_user with token...")
        user_response = supabase_auth.auth.get_user(access_token)

        logger.info("get_user response: %s", user_response)
        logger.info("user_response.user: %s", user_response.user)

        if user_response.user:
            logger.info("Token verification successful, returning user data")
            return user_response.user
        else:
            logger.error("User response is empty")
            raise HTTPException(
                status_code=401,
                detail="Invalid token - no user data",
                headers={"WWW-Authenticate": "Bearer"},
            )

    except InvalidAudienceError as e:
        logger.error("Invalid audience: %s", e)
        raise HTTPException(
            status_code=401,
            detail="Invalid audience",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e
    except (ExpiredSignatureError, InvalidTokenError) as e:
        logger.error("Token expired or invalid: %s", e)
        raise HTTPException(
            status_code=401,
            detail="Token expired or invalid",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Authentication error: %s", e)
        logger.exception("Full traceback:")
        raise HTTPException(
            status_code=401,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e


def current_user(
    request: Request,
    oauth2_token: Annotated[str, Depends(oauth2_scheme)] = None,
) -> dict:
    """
    Universal authentication that handles both OAuth2 and Authorization header tokens.

    This function provides compatibility for both FastAPI docs OAuth2 integration
    and direct API calls with Authorization headers.

    Args:
        oauth2_token: Optional OAuth2 token from FastAPI docs authentication
        request: FastAPI Request object to extract headers (injected via dependency)

    Returns:
        dict: User data from verified token

    Raises:
        HTTPException: 401 if no valid token found or authentication fails
    """
    logger.info(
        "Auth attempt - oauth2_token: %s, auth_header: %s",
        bool(oauth2_token),
        request.headers.get("authorization"),
    )
    access_token = None
    # Priority 1: OAuth2 token (from FastAPI docs Authorize button)
    if oauth2_token:
        access_token = oauth2_token
        logger.info("Using OAuth2 token")
    else:
        # Priority 2: Authorization header (from frontend/manual requests)
        authorization = request.headers.get("authorization")
        if authorization and authorization.startswith("Bearer "):
            access_token = authorization.replace("Bearer ", "", 1)
            logger.info("Using Authorization header token")
        else:
            logger.error(
                "No valid token found - oauth2: %s, auth_header: %s",
                oauth2_token,
                authorization,
            )
            raise HTTPException(
                status_code=401,
                detail="No valid token found. Provide token via OAuth2 or Authorization header.",
                headers={"WWW-Authenticate": "Bearer"},
            )

    logger.info("About to verify token...")
    return _verify_token(access_token)


def router_auth_dependency():
    """
    A dependency function specifically designed for router-level authentication.
    This works around FastAPI's limitation with Request injection in router dependencies.
    """

    def auth_checker(
        request: Request, oauth2_token: Annotated[str, Depends(oauth2_scheme)] = None
    ) -> dict:
        return current_user(request, oauth2_token)

    return auth_checker


# Type aliases for authentication
CurrentUser = Annotated[dict, Depends(current_user)]
