# STEMSight PIM Copilot Instructions

## Project Overview

STEMSight PIM is a medical AI system for detecting abnormal postures and involuntary movements in ambulance patients using computer vision. It consists of a **FastAPI backend** with ML detection models, a **Next.js frontend** for healthcare providers, and **Raspberry Pi 4 edge devices** for real-time patient monitoring.

### Hardware Integration

We use **Raspberry Pi 4 with camera integration** to live stream patients in real-time. The RPi 4 devices have their own on-board AI models to recognize postures and movements locally, then transmit detection data and video streams to the backend for storage and dashboard display.

### Dashboard Functionality

The frontend dashboard displays:

- **Live streaming patients**: Real-time video feeds from active RPi 4 devices
- **Recent patient data**: Historical movement/posture detection results
- **AI detection alerts**: Movement patterns detected by RPi 4 AI models

The frontend website is primarily used for **watching patient movement/posture** and **reading movement data detected from AI training models** that are sent from RPi 4 devices and stored in the backend.

## Architecture & Components

### Backend Structure (`/Back-End/`)

- **`main.py`**: FastAPI app with OAuth2 Bearer token auth and CORS for localhost/staging
- **`api_router/`**: Modular API endpoints organized by domain (auth, patients, doctors, medical_history, streaming, etc.)
- **`ai_models/`**: AI/ML processing and models (UNIK/, PostureMovementDetector.py, pose_model_capture.py, diagnosisReport.py, sendToChatbot.py)
- **`core/`**: Core backend utilities (common.py, env.py, timestamps.py, localization.py)
- **`supabase_settings/`**: Two Supabase clients - `SUPABASE_AUTH` (stateful sessions) and `SUPABASE` (stateless data operations)
- **`security/`**: Authentication and JWT verification
- **`Testing_files/broadcaster.py`**: WebRTC streaming utility for camera input simulation

### Raspberry Pi Structure (`/Raspberry-Pi/`)

- **Edge device deployment** with ARM64-optimized dependencies
- **`config_manager.py`**: Configuration management for camera and network settings
- **`setup.sh`**: Automated installation script for Raspberry Pi 4
- **Local AI models** for real-time posture/movement detection
- **Configuration files** for camera settings and network communication

### Frontend Structure (`/Front-End/src/`)

- **`app/`**: Next.js App Router with role-based dashboards (`/patient-dashboard`, `/dashboard`)
- **`components/`**: Reusable UI components with dedicated `layouts/` (DashboardLayout, AuthLayout)
- **`hooks/`**: React hooks including `useAuth` (context provider with token management)
- **`services/api.ts`**: Centralized API client with automatic Bearer token injection
- **`types/`**: TypeScript definitions organized by domain (auth, medical, api)

## Key Development Patterns

### Authentication Flow

```typescript
// Frontend: useAuth hook provides context-based auth state
const { user, login, logout } = useAuth();
// Backend: OAuth2PasswordBearer with JWT tokens
# Dependency injection in routers using security/jwt_verify.py
```

### API Communication

- Frontend uses `services/api.ts` with automatic token management
- Backend returns `ApiResponse<T>` format: `{ data: T | null, error: string | null, status?: number }`
- All endpoints follow RESTful patterns under `/api_router/` modules

### Real-time Streaming

- **Raspberry Pi 4 Integration**: Primary streaming source with camera modules for patient monitoring
- **Edge AI Processing**: RPi 4 devices run local AI models for real-time posture/movement detection
- **WebRTC implementation** via `aiortc` for live camera feeds from RPi 4 to dashboard
- **Data Pipeline**: RPi 4 → Backend API → Frontend Dashboard for live streaming and detection alerts
- Test streaming: `python ./Back-End/Testing_files/broadcaster.py --room {room_id} --video_device {device}`
- Platform-specific device detection (Windows: "Logitech BRIO", macOS: "0", RPi 4: Camera module)

### ML Model Integration

- **Edge AI on RPi 4**: Local pose detection and movement classification on Raspberry Pi devices
- **UNIK models** in PyTorch for pose classification (deployed on both backend and RPi 4)
- **MediaPipe integration** for real-time landmark detection on edge devices
- **Detection Pipeline**: RPi 4 AI → Data transmission → Backend storage → Frontend display
- Detection confidence thresholds configurable (default: 0.7)

## Development Workflow

### Local Development Commands

```bash
# Backend (Terminal 1)
cd PIM/Back-End
uvicorn main:app --reload
# API docs: http://localhost:3000/docs

# Frontend (Terminal 2)
cd PIM/Front-End
npm run dev
# App: http://localhost:8000
```

### Database & Auth

- Supabase PostgreSQL with row-level security
- Two client patterns: `SUPABASE_AUTH` for user sessions, `SUPABASE` for data queries
- Import from `core.common`: `supabase`, `supabase_auth`, `logger`

### Router Authentication Patterns

**Two types of routers based on authentication requirements:**

```python
# ✅ PROTECTED ROUTES - Require authentication token
from fastapi import APIRouter, Depends
from security.jwt_verify import current_user

# Router with authentication dependency - ALL endpoints require valid token
router = APIRouter(dependencies=[Depends(current_user)])

@router.get("/protected-endpoint")
async def protected_function():
    # User is automatically authenticated via router dependency
    return {"data": "Protected data"}

# ✅ PUBLIC ROUTES - No authentication required
from fastapi import APIRouter

# Router without dependencies - endpoints are public
router = APIRouter()

@router.post("/login")
async def public_login():
    # Public endpoint for login, registration, etc.
    return {"data": "Public access"}

# ✅ MIXED ROUTES - Some endpoints protected, some public
router = APIRouter()  # No router-level dependency

@router.post("/register")
async def public_register():
    # Public endpoint
    return {"data": "Registration"}

@router.get("/profile", dependencies=[Depends(current_user)])
async def protected_profile():
    # Individual endpoint requires authentication
    return {"data": "User profile"}
```

**When to use each pattern:**

- **Router-level auth** (`dependencies=[Depends(current_user)]`): When ALL endpoints need authentication (patient data, medical records)
- **No router auth** (`APIRouter()`): When endpoints are public (login, registration, health checks)
- **Endpoint-level auth**: When mixing public and protected endpoints in same router

### Component Conventions

- Use `"use client"` for interactive components
- Layouts: `DashboardLayout` for authenticated pages, `AuthLayout` for login/register
- UI components in `/components/ui/` (Button, Card, etc.)
- Icons: Heroicons React library

### TypeScript Patterns

- Centralized types in `/types/` with index.ts re-exports
- API responses typed as `ApiResponse<T>`
- Authentication: `User`, `LoginRequest`, `LoginResponse` interfaces

## Critical Integration Points

### Video Streaming Setup

1. Install FFMPEG for platform-specific camera access
2. Use `broadcaster.py` for testing with room IDs
3. WebRTC signaling through FastAPI streaming endpoints

### Pose Detection Pipeline

1. `PostureMovementDetector.py` processes live video frames
2. MediaPipe extracts pose landmarks with confidence scoring
3. UNIK models classify abnormal postures/movements
4. Results stored with timestamps for session review

### Role-Based Access

- Frontend routing: `/patient-dashboard` vs `/dashboard` by user role
- Backend: Router-level authentication dependencies
- Navigation context-aware in `DashboardLayout`

## Project-Specific Notes

- Port configuration: Backend on 8000, Frontend on 3000 (note reversed from typical)
- CORS origins include both localhost and AWS Amplify staging
- ML detection confidence tunable via `landmark_visibility_threshold`
- Error handling: Use project's `ApiResponse` pattern, not generic try/catch
- Camera device strings are platform-specific - see `broadcaster.py` defaults

## 🤖 AI Collaboration Guidelines

### For Teammates Using AI Tools (GitHub Copilot, ChatGPT, etc.)

#### 🏗️ Project Structure Rules

**ALWAYS follow the current folder structure:**

```
Back-End/
├── ai_models/          # AI/ML processing & models
├── core/              # Core utilities & configuration
├── api_router/        # API endpoints
├── security/          # Authentication
└── supabase_settings/ # Database configuration

Raspberry-Pi/          # Edge device deployment
Front-End/src/         # Next.js frontend
```

#### 📝 Import Statement Patterns

**Backend Python Imports:**

```python
# ✅ CORRECT - Use core.* for utilities
from core.common import supabase, supabase_auth, logger
from core.env import ENVIRONMENT
from core.timestamps import get_current_timestamp

# ❌ WRONG - Don't use old direct imports
from common import supabase  # OUTDATED
from env import ENVIRONMENT  # OUTDATED
```

**Frontend TypeScript Imports:**

```typescript
// ✅ CORRECT - Use centralized API service
import { api } from "@/services/api";
import { useAuth } from "@/hooks/useAuth";
import type { ApiResponse, User } from "@/types";

// ✅ CORRECT - Component patterns
import { DashboardLayout } from "@/components/layouts/DashboardLayout";
```

#### 🔧 Coding Conventions

**Backend FastAPI Router Patterns:**

```python
# ✅ CORRECT - Protected Router (requires authentication for ALL endpoints)
from fastapi import APIRouter, HTTPException, Depends
from core.common import supabase, logger
from security.jwt_verify import current_user

router = APIRouter(dependencies=[Depends(current_user)])

@router.get("/endpoint")
async def get_data():
    # User is automatically authenticated
    try:
        result = supabase.table('table').select('*').execute()
        return {"data": result.data, "error": None}
    except Exception as e:
        logger.error("Error description: %s", e)  # Use lazy formatting
        raise HTTPException(status_code=500, detail=str(e)) from e

# ✅ CORRECT - Public Router (no authentication required)
from fastapi import APIRouter, HTTPException
from core.common import supabase, logger

router = APIRouter()  # No dependencies - public access

@router.post("/login")
async def public_login():
    # Public endpoint for login, registration, etc.
    try:
        # Login logic here
        return {"data": "Login successful", "error": None}
    except Exception as e:
        logger.error("Login error: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e
```

**Frontend API Integration:**

```typescript
// ✅ CORRECT - Use centralized API service
import { api } from "@/services/api";

const fetchData = async () => {
  try {
    const response = await api.get<DataType>("/endpoint");
    if (response.error) {
      throw new Error(response.error);
    }
    return response.data;
  } catch (error) {
    console.error("Fetch error:", error);
    throw error;
  }
};
```

#### 🚨 Common AI Pitfalls to Avoid

1. **Don't suggest outdated imports**

   ```python
   # ❌ WRONG - AI might suggest old patterns
   from common import supabase
   from env import ENVIRONMENT

   # ✅ CORRECT - Always use core.*
   from core.common import supabase
   from core.env import ENVIRONMENT
   ```

2. **Don't mix old and new patterns**

   ```python
   # ❌ WRONG - Inconsistent import style
   from core.common import supabase
   from common import logger  # Outdated

   # ✅ CORRECT - Consistent imports
   from core.common import supabase, logger
   ```

3. **Don't ignore router authentication patterns**

   ```python
   # ❌ WRONG - Generic router without considering auth requirements
   router = APIRouter()

   # ✅ CORRECT - Choose based on endpoint requirements
   # For protected endpoints (patient data, medical records):
   router = APIRouter(dependencies=[Depends(current_user)])

   # For public endpoints (login, registration):
   router = APIRouter()  # No dependencies needed
   ```

4. **Don't ignore error handling patterns**

   ```python
   # ❌ WRONG - Generic error handling
   except Exception as e:
       print(f"Error: {e}")

   # ✅ CORRECT - Project-specific pattern
   except Exception as e:
       logger.error("Specific error description: %s", e)
       raise HTTPException(status_code=500, detail=str(e)) from e
   ```

#### 🎯 AI Tool Best Practices

**When asking AI for help:**

1. **Provide context about our structure:**

   ```
   "In our STEMSight project, we use:
   - FastAPI backend with core/ utilities
   - Next.js frontend with TypeScript
   - Supabase for database
   - Import from core.common, not common directly"
   ```

2. **Specify our patterns:**

   ```
   "Follow our ApiResponse<T> pattern: {data: T | null, error: string | null}"
   "Use our authentication: security/jwt_verify.py with Bearer tokens"
   "Frontend uses useAuth hook from hooks/useAuth"
   ```

3. **Reference our file structure:**
   ```
   "Place AI models in ai_models/ folder"
   "API routes go in api_router/"
   "Shared utilities in core/"
   ```

#### 🔍 Code Review Checklist for AI-Generated Code

**Before committing AI-suggested code, verify:**

- [ ] Uses correct import paths (`core.*` not direct imports)
- [ ] Follows our `ApiResponse<T>` format for backend responses
- [ ] Uses proper error handling with `logger.error` and lazy formatting
- [ ] Authentication uses `security/jwt_verify.py` dependencies
- [ ] Frontend components use `"use client"` when needed
- [ ] TypeScript types are imported from `/types/`
- [ ] Database operations use `supabase` from `core.common`
- [ ] AI models are placed in `ai_models/` directory
- [ ] Configuration uses `core.env.ENVIRONMENT`

#### 🚀 Development Commands for AI Context

**When AI suggests running commands, use these:**

```bash
# Backend development
cd Back-End && uvicorn main:app --reload

# Frontend development
cd Front-End && npm run dev

# Test imports (use this to verify AI suggestions)
cd Back-End && python -c "from core.common import supabase; print('✅ Import works')"

# Install dependencies
cd Back-End && pip install -r requirements.txt
cd Front-End && npm install
```

#### 🧠 Project Context for AI

**Key information to provide when using AI tools:**

- **Medical AI system** for posture/movement detection
- **Raspberry Pi 4 edge devices** with camera integration
- **Real-time streaming** with WebRTC (aiortc)
- **FastAPI + Next.js + Supabase** technology stack
- **PyTorch UNIK models** for pose classification
- **MediaPipe** for pose landmark detection
- **OAuth2 Bearer token** authentication
- **TypeScript** with strict type checking

This ensures AI tools understand our specific requirements and suggest appropriate solutions that fit our architecture and coding standards.
