"""Lightweight FastAPI app for tests.

This module constructs a minimal FastAPI app that includes the project's
routers but avoids running lifespan/startup background tasks (FFmpeg,
room manager, pending uploaders, etc). Use this for pytest imports so tests
can import `app` without side effects.
"""
from fastapi import FastAPI
from pathlib import Path
from fastapi.staticfiles import StaticFiles

from api_router.router import api_router
from api_router.pim_classifier_api import router as pim_router
from api_router.ai_detections import router as ai_detections_router


def create_test_app() -> FastAPI:
    app = FastAPI(title="STEMSight API (test)")

    # Mount a recordings directory for HLS static serving used by tests
    RECORDINGS_PATH = Path("recordings")
    RECORDINGS_PATH.mkdir(parents=True, exist_ok=True)
    app.mount("/recordings", StaticFiles(directory=str(RECORDINGS_PATH)), name="recordings")

    # Include main routers (do NOT start background tasks)
    app.include_router(api_router)
    try:
        app.include_router(pim_router)
    except Exception:
        # Optional router - ignore if import fails in test env
        pass
    try:
        app.include_router(ai_detections_router)
    except Exception:
        pass

    return app


app = create_test_app()
