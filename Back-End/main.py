from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.responses import RedirectResponse, JSONResponse, HTMLResponse
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from api_router.router import api_router
from api_router.pim_classifier_api import router as pim_router
from api_router.ai_detections import router as ai_detections_router
from core.common import logger, supabase
import os
import sys
import asyncio
from pathlib import Path

# ✅ FIX: Windows asyncio subprocess support
# Windows ProactorEventLoop doesn't support subprocesses
# Use SelectorEventLoop instead for FFmpeg recording
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    logger.info("🪟 Windows: Using SelectorEventLoop for subprocess support")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events - startup and shutdown."""
    # Startup
    logger.info("Starting up STEMSight backend...")

    # Start room manager background tasks
    from services.streaming.room_service import room_manager

    await room_manager.start_cleanup_task()
    await room_manager.start_session_monitoring()
    logger.info("Room manager background tasks started")

    yield

    # Shutdown
    logger.info("Shutting down STEMSight backend...")


app = FastAPI(
    title="STEMSight API",
    version="1.0.0",
    description="STEMSight API with Bearer Token Authentication",
    lifespan=lifespan,
    openapi_tags=[
        {"name": "Auth", "description": "Authentication endpoints"},
        {"name": "Patients", "description": "Patient management"},
        {"name": "Doctors", "description": "Doctor management"},
        {"name": "Videos", "description": "Video management"},
        {"name": "Medical History", "description": "Medical history management"},
        {"name": "Notes", "description": "Notes management"},
        {"name": "Patient Events", "description": "Patient events management"},
        {"name": "Streaming", "description": "Real-time streaming"},
        {
            "name": "PIM Classification",
            "description": "AI-powered movement classification",
        },
        {
            "name": "Movement Detections",
            "description": "Movement detection records with realtime support",
        },
    ],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)

# CORS configuration
origins = [
    "http://127.0.0.1:8000",
    "http://127.0.0.1:3000",
    "http://localhost:3000",
    "http://localhost:8000",
    "https://localhost:3000",
    "https://main.d3nf33ntk31bcv.amplifyapp.com",
    "*",  # Allow all origins (for local HTML file testing)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,  # Enable credentials for Bearer token auth
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=422, content={"error": "Invalid request", "details": exc.errors()}
    )


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


@app.get("/test-realtime", response_class=HTMLResponse)
async def serve_realtime_test():
    """Serve the realtime test HTML page"""
    html_path = Path(__file__).parent / "test_movement_realtime.html"
    if html_path.exists():
        return HTMLResponse(content=html_path.read_text(), status_code=200)
    return HTMLResponse(content="<h1>Test file not found</h1>", status_code=404)


# Mount static files for HLS recordings
RECORDINGS_PATH = Path("recordings")
RECORDINGS_PATH.mkdir(parents=True, exist_ok=True)
app.mount("/recordings", StaticFiles(directory=str(RECORDINGS_PATH)), name="recordings")

# Include routers
app.include_router(api_router)
app.include_router(pim_router)
app.include_router(ai_detections_router)
