# STEMSight PIM Backend

## 

The STEMSight PIM backend is a **FastAPI-based** Camera AI Service designed to detect and track postures and movements using computer vision technology. It provides REST APIs for camera management, real-time streaming, AI-
## 

````
Back-End/
├── main.py                     # FastAPI application entry point
├── requirements.txt            # Python dependencies
├──
├── core/                       # Core backend utilities
│   ├── common.py              # Shared utilities (Supabase, logger)
│   ├── env.py                 # Environment configuration
│   ├── localization.py        # Internationalization
│   └── timestamps.py          # Timestamp utilities
│
├── api_router/                 # API endpoint modules
│   ├── __init__.py
│   ├── router.py              # Main router configuration
│   ├── auth.py                # Authentication endpoints
│   ├── patient.py             # Subject management (camera targets)
│   ├── doctor.py              # User management
│   ├── medical_history.py     # Detection history and records
│   ├── note.py                # Notes and annotations
│   ├── patient_event.py       # Detection events tracking
│   ├── streaming.py           # WebRTC streaming
│   └── video.py               # Video management
│
├── ai_models/                  # AI/ML Processing
│   ├── diagnosisReport.py     # Medical diagnosis generation
│   ├── pose_model_capture.py  # Pose model capture utility
│   ├── PostureMovementDetector.py # MediaPipe pose detection
│   ├── sendToChatbot.py       # AI chatbot integration
│   └── UNIK/                  # AI/ML models
│       ├── run_unik.py        # Main UNIK model runner
│       ├── ensemble.py        # Model ensemble logic
│       ├── evaluation-cs.py   # Cross-section evaluation
│       ├── evaluation-cv.py   # Cross-validation evaluation
│       ├── unik_executable.py # Standalone executable
│       ├── model/             # PyTorch model definitions
│       ├── feeders/           # Data feeding utilities
│       └── data_gen/          # Data generation tools
│
├── security/                   # Authentication & authorization
│   └── jwt_verify.py          # JWT token verification
│
├── supabase_settings/          # Database configuration
│   ├── create_client.py       # Supabase client setup
│   └── create_admin.py        # Admin user creation
│
├── Testing_files/              # Development & testing tools
│   ├── broadcaster.py         # WebRTC streaming test utility
│   └── save_stream.py         # Stream recording utility
│
├── templates/                  # Template files
└── build/                     # Build artifacts
```## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- PostgreSQL (via Supabase)
- FFMPEG (for video processing)

### Installation

1. **Clone and navigate to backend:**

   ```bash
   cd PIM/Back-End
````

2. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment:**

   ```bash
   # Copy environment template
   cp .env.example .env

   # Edit .env with your Supabase credentials
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   JWT_SECRET=your_jwt_secret
   ```

4. **Start development server:**

   ```bash
   uvicorn main:app --reload
   ```

5. **Access API documentation:**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## 📡 API Architecture

### Authentication System

```python
# JWT-based authentication with OAuth2 Bearer tokens
from security.jwt_verify import current_user
from fastapi import Depends

@router.get("/protected-endpoint")
def protected_route(user: dict = Depends(current_user)):
    return {"user_id": user["id"]}
```

### Database Integration

```python
# Import shared Supabase clients
from core.common import supabase, supabase_auth, logger

# Use supabase for data operations
response = supabase.table("patients").select("*").execute()

# Use supabase_auth for authentication
auth_response = supabase_auth.auth.sign_in_with_password({
    "email": email,
    "password": password
})
```

### API Response Pattern

All endpoints return a consistent response format:

```python
from pydantic import BaseModel
from typing import Optional, Any

class ApiResponse(BaseModel):
    data: Optional[Any] = None
    error: Optional[str] = None
    status: Optional[int] = None

# Example usage
@router.get("/patients/{patient_id}")
def get_patient(patient_id: str):
    try:
        result = supabase.table("patients").select("*").eq("id", patient_id).execute()
        return {"data": result.data[0], "error": None}
    except Exception as e:
        logger.error(f"Error getting patient: {e}")
        return {"data": None, "error": str(e)}
```

## 🤖 AI/ML Integration

### UNIK Models

The UNIK system provides pose classification using PyTorch:

```python
# Running UNIK pose detection
from ai_models.UNIK.run_unik import detect_pose

# Process video frame
detection_result = detect_pose(frame_data, confidence_threshold=0.7)
```

### MediaPipe Integration

```python
# Real-time pose detection
from ai_models.PostureMovementDetector import PostureMovementDetector

detector = PostureMovementDetector()
landmarks = detector.process_frame(video_frame)
```

### AI Model Organization

The `ai_models/` directory contains all AI-related functionality:

- **UNIK/**: Custom PyTorch models for pose classification
- **PostureMovementDetector.py**: MediaPipe pose detection engine
- **pose_model_capture.py**: Camera capture with AI processing
- **diagnosisReport.py**: Automated medical report generation
- **sendToChatbot.py**: AI chatbot integration for medical insights

## 🎥 Streaming & RPi 4 Integration

### WebRTC Streaming

```python
# Streaming endpoints in api_router/streaming.py
@router.post("/streaming/rooms")
def create_room(room_data: RoomCreate):
    """Create WebRTC room for RPi 4 streaming"""

@router.post("/streaming/publish/viewer")
def publish_viewer(viewer_data: ViewerPublish):
    """Handle viewer connection from dashboard"""
```

### Testing Streaming

```bash
# Test with broadcaster utility
python Testing_files/broadcaster.py --room test_room --video_device 0

# Platform-specific devices:
# Windows: "Logitech BRIO"
# macOS: "0"
# RPi 4: Camera module
```

## 📊 Database Schema

### Core Tables

- **`users`**: Authentication and user management
- **`patients`**: Patient information and demographics
- **`doctors`**: Healthcare provider data
- **`medical_history`**: Patient medical records
- **`videos`**: Uploaded video files and metadata
- **`notes`**: Annotations and observations
- **`patient_events`**: Timestamped patient events

### Supabase Configuration

Two client patterns are used:

```python
# Stateful authentication operations
supabase_auth = create_client(url, key)

# Stateless data operations
supabase = create_client(url, service_key)
```

## 🔧 Development Guidelines

### Adding New Endpoints

1. **Create router module:**

   ```python
   # api_router/new_feature.py
   from fastapi import APIRouter, Depends
   from security.jwt_verify import current_user

   router = APIRouter(dependencies=[Depends(current_user)])

   @router.get("/")
   def get_items():
       return {"items": []}
   ```

2. **Register in main router:**

   ```python
   # api_router/router.py
   from .new_feature import router as new_feature_router

   api_router.include_router(
       new_feature_router,
       prefix="/new-feature",
       tags=["New Feature"]
   )
   ```

### Error Handling

```python
# Standard error handling pattern
try:
    response = supabase.table("table").operation().execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Resource not found")
    return response.data
except Exception as e:
    logger.error(f"Operation failed: {e}")
    raise HTTPException(status_code=500, detail=str(e)) from e
```

### Pydantic Models

```python
# Input/Output models
class PatientBase(BaseModel):
    name: str
    age: int
    gender: str

class PatientCreate(PatientBase):
    pass

class Patient(PatientBase):
    id: str
    created_at: datetime
```

## 🧪 Testing

### Manual API Testing

Use the interactive Swagger UI at `/docs` for testing endpoints.

### Streaming Tests

```bash
# Test WebRTC streaming
python Testing_files/broadcaster.py --room test --video_device 0

# Save stream for analysis
python Testing_files/save_stream.py --input stream_url --output recording.mp4
```

## 📋 Environment Variables

Required environment variables:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key

# JWT Configuration
JWT_SECRET=your-secret-key
JWT_ALGORITHM=HS256

# CORS Configuration
CORS_ORIGINS=http://localhost:3000,https://your-frontend.com
```

## 🚨 Common Issues

### CORS Problems

- Ensure frontend URL is in `CORS_ORIGINS`
- Check that backend runs on port 8000

### Database Connection

- Verify Supabase credentials in `.env`
- Check Row Level Security policies

### Video Streaming

- Install FFMPEG for video processing
- Ensure camera permissions on development machine

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Supabase Python Client](https://supabase.com/docs/reference/python/)
- [PyTorch Documentation](https://pytorch.org/docs/)
- [MediaPipe Pose](https://google.github.io/mediapipe/solutions/pose.html)

## 🤝 Contributing

1. Follow the existing API response patterns
2. Add authentication dependencies to protected routes
3. Use consistent error handling with logging
4. Update this README when adding new features
5. Test streaming functionality with `broadcaster.py`
