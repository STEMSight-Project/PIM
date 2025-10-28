import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import playback_routes, record_routes, stream_routes

# Define where videos are stored
VIDEOS_DIR = os.path.join(os.path.dirname(__file__), "videos")

# Ensure the videos directory exists
os.makedirs(VIDEOS_DIR, exist_ok=True)

# Initialize FastAPI app
app = FastAPI(
    title="MediaPipe Video Streamer",
    description="Stream, record, and play back video with MediaPipe + WebRTC",
    version="1.0.0",
)

# Allow CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # for dev; tighten later in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(stream_routes.router, prefix="/stream", tags=["Stream"])
app.include_router(record_routes.router, prefix="/record", tags=["Record"])
app.include_router(playback_routes.router,
                   prefix="/playback", tags=["Playback"])


@app.get("/")
async def root():
    """Root endpoint to check that API is running."""
    return {"message": "MediaPipe Handler backend is running!"}
