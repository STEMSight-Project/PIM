from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from api_router.router import api_router
from core.common import logger, supabase

app = FastAPI(
    title="STEMSight API",
    version="1.0.0",
    description="STEMSight API with Bearer Token Authentication",
    openapi_tags=[
        {"name": "Auth", "description": "Authentication endpoints"},
        {"name": "Patients", "description": "Patient management"},
        {"name": "Doctors", "description": "Doctor management"},
        {"name": "Videos", "description": "Video management"},
        {"name": "Medical History", "description": "Medical history management"},
        {"name": "Notes", "description": "Notes management"},
        {"name": "Patient Events", "description": "Patient events management"},
        {"name": "Streaming", "description": "Real-time streaming"},
    ],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

# CORS configuration
origins = [
    "http://127.0.0.1:8000",
    "http://127.0.0.1:3000",
    "http://localhost:3000",
    "https://localhost:3000",
    "https://main.d3nf33ntk31bcv.amplifyapp.com",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=False,  # Changed to False since we're using Bearer tokens, not cookies
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler((RequestValidationError))
async def validation_exception_handler(_, exc):
    return {"error": "Invalid request", "details": exc.errors()}


@app.post("/token", summary="OAuth2 Token Endpoint", tags=["Auth"])
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    OAuth2-compatible token endpoint for FastAPI docs authentication.

    This endpoint enables the "Authorize" button in FastAPI docs.
    Use your email as username and your password to get a Bearer token.
    """

    try:
        # Authenticate with Supabase using email (username) and password
        auth = supabase.auth.sign_in_with_password(
            {
                "email": form_data.username,  # FastAPI form uses 'username' field for email
                "password": form_data.password,
            }
        )
        if not auth.session or not auth.session.access_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Return OAuth2-compatible token response
        return {"access_token": auth.session.access_token, "token_type": "bearer"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Authentication error in /token endpoint: %s", e)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e


@app.get("/")
def read_root():
    """Redirect to API documentation"""
    return RedirectResponse(url="/docs")


app.include_router(api_router)
