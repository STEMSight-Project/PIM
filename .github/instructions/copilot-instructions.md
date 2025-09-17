# STEMSight PIM Copilot Instructions

## Project Overview

STEMSight PIM is a **Camera AI Service** for detecting and tracking postures and movements using computer vision technology. It consists of a **FastAPI backend** with ML detection models, a **Next.js frontend** for AI monitoring and management, and **Raspberry Pi 4 edge devices** with cameras for real-time pose detection and movement analysis.

### Hardware Integration

We use **Raspberry Pi 4 with camera integration** to capture and analyze movement in real-time. The RPi 4 devices have their own on-board AI models to recognize postures and movements locally, then transmit detection data and video streams to the backend for storage and dashboard display.

### Dashboard Functionality

The frontend dashboard displays:

- **Live camera feeds**: Real-time video streams from active RPi 4 devices
- **AI detection results**: Movement patterns and pose classifications detected by RPi 4 AI models
- **Performance metrics**: Model accuracy, confidence scores, and processing statistics

The frontend website is primarily used for **monitoring camera AI performance** and **analyzing movement detection data** that are processed by RPi 4 AI models and stored in the backend.

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

- **`app/`**: Next.js App Router with role-based dashboards and updated navigation structure
  - **`/dashboard`**: Main healthcare provider dashboard
  - **`/patients/[slug]`**: Dynamic patient detail pages with tabbed interface (Overview, Medical History, Detection History, Video Sessions)
  - **`/recent-live-session`**: Centralized RPi camera session monitoring and analytics
  - **`/streamingDash`**: Live camera streaming dashboard
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

- **Raspberry Pi 4 Integration**: Primary streaming source with camera modules for movement monitoring
- **Edge AI Processing**: RPi 4 devices run local AI models for real-time posture/movement detection
- **WebRTC implementation** via `aiortc` for live camera feeds from RPi 4 to dashboard
- **Data Pipeline**: RPi 4 → Backend API → Frontend Dashboard for live streaming and detection analytics
- **Session Management**: RPi 4 devices automatically initiate sessions - frontend provides monitoring only (no manual start controls)
- **Recent Live Session Dashboard**: Centralized view at `/recent-live-session` for all camera session analytics
- Test streaming: `python ./Back-End/Testing_files/broadcaster.py --room {room_id} --video_device {device}`
- Platform-specific device detection (Windows: "Logitech BRIO", macOS: "0", RPi 4: Camera module)

### ML Model Integration

- **Edge AI on RPi 4**: Local pose detection and movement classification on Raspberry Pi devices
- **UNIK models** in PyTorch for pose classification (deployed on both backend and RPi 4)
- **MediaPipe integration** for real-time landmark detection on edge devices
- **Detection Pipeline**: RPi 4 AI → Data transmission → Backend storage → Frontend display
- Detection confidence thresholds configurable (default: 0.7)

### UNIK Deployment Strategy

**Hybrid Architecture - UNIK exists in both locations with different purposes:**

#### **Raspberry Pi (Edge) - PRIMARY**

- **Location**: `Raspberry-Pi/UNIK/`
- **Purpose**: Real-time pose classification for immediate alerts
- **Model**: Lightweight UNIK variant optimized for ARM64 architecture
- **Processing**: Live camera feed analysis with low latency
- **Output**: Basic classifications + confidence scores
- **Benefits**: Low latency, reduced bandwidth, better privacy compliance

#### **Backend (Server) - SECONDARY/SUPPORT**

- **Location**: `Back-End/ai_models/UNIK/`
- **Purpose**: Detailed analysis and batch processing
- **Model**: Full UNIK model with complete feature set
- **Processing**: Historical data analysis, comprehensive medical reports
- **Output**: Detailed medical analysis and diagnosis generation
- **Benefits**: Full model capabilities, complex analysis, training updates

#### **Workflow Pattern**

1. **RPi UNIK**: Real-time detection → Basic alerts → Flag abnormal events
2. **Data transmission**: Send flagged events and metadata to backend
3. **Backend UNIK**: Detailed analysis → Comprehensive medical reports
4. **Dashboard**: Display both real-time alerts and detailed analysis results

**When developing:**

- Use RPi UNIK for real-time features and edge processing
- Use Backend UNIK for detailed analysis, reports, and batch operations
- Avoid duplicating heavy processing - leverage the hybrid architecture

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

### Frontend Data Flow Architecture

**CRITICAL: Follow this clean data flow pattern for all frontend development:**

```
Service Layer → Hooks Layer → UI/Page Components
```

#### ✅ CORRECT Data Flow Pattern

```typescript
// 1. SERVICE LAYER - Pure data fetching (services/api.ts)
export const streamingService = {
  async getSessions(filters?: any): Promise<ApiResponse<StreamingSession[]>> {
    return api.get("/streaming/sessions", { params: filters });
  },

  async getRooms(): Promise<ApiResponse<StreamingRoom[]>> {
    return api.get("/streaming/rooms");
  },
};

// 2. HOOKS LAYER - State management and business logic (hooks/)
export const useStreamingData = () => {
  const [sessions, setSessions] = useState<StreamingSession[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchSessions = useCallback(async () => {
    setLoading(true);
    try {
      const response = await streamingService.getSessions();
      if (response.error) throw new Error(response.error);
      setSessions(response.data || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  return { sessions, loading, error, fetchSessions };
};

// 3. UI/PAGE COMPONENTS - Pure presentation logic
export default function StreamingPage() {
  const { sessions, loading, error, fetchSessions } = useStreamingData();

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      {sessions.map((session) => (
        <SessionCard key={session.id} session={session} />
      ))}
    </div>
  );
}
```

#### ❌ AVOID These Anti-Patterns

```typescript
// ❌ DON'T: Direct API calls in components
export default function BadComponent() {
  const [data, setData] = useState([]);

  useEffect(() => {
    // Never do direct API calls in components
    fetch("/api/sessions")
      .then((res) => res.json())
      .then(setData);
  }, []);
}

// ❌ DON'T: Business logic in components
export default function BadComponent() {
  const { sessions } = useStreamingData();

  // Never put business logic in render
  const processedSessions = sessions.map((session) => ({
    ...session,
    // Complex business logic here - belongs in hooks!
    computedStatus: session.status === "active" ? "live" : "offline",
  }));
}

// ❌ DON'T: State management in components
export default function BadComponent() {
  // Don't manage complex state directly in components
  const [sessions, setSessions] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(false);
  // ... lots of useState calls
}
```

#### Key Principles

1. **Services**: Pure functions for API communication, no state management
2. **Hooks**: Encapsulate state management, business logic, and side effects
3. **Components**: Pure presentation, minimal logic, consume hook data
4. **Separation**: Never mix data fetching with rendering logic
5. **Reusability**: Hooks can be shared across multiple components
6. **Testing**: Each layer can be tested independently

#### Real-World Example Structure

```
services/
├── api.ts                 # Core API client
├── streamingService.ts    # Streaming-specific API calls
├── patientService.ts      # Patient-specific API calls
└── authService.ts         # Authentication API calls

hooks/
├── useAuth.ts            # Authentication state management
├── useStreamingData.ts   # Streaming data management
├── usePatients.ts        # Patient data management
└── useRealtimeData.ts    # Generic real-time data hook

components/
├── pages/
│   └── StreamingPage.tsx # Page component using hooks
├── ui/
│   └── SessionCard.tsx   # Pure UI component
└── layouts/
    └── DashboardLayout.tsx # Layout component
```

### Frontend Routing Patterns

#### Updated Navigation Structure

```typescript
// DashboardLayout.tsx navigation
const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: HomeIcon },
  { name: "Subjects", href: "/patients", icon: UserGroupIcon },
  {
    name: "Recent Live Session",
    href: "/recent-live-session",
    icon: DocumentTextIcon,
  },
  { name: "Live Cameras", href: "/streamingDash", icon: VideoCameraIcon },
];
```

#### Dynamic Patient Routes

```
/patients/[slug]                # RESTful patient detail page
├── Overview Tab                # Personal info + monitoring statistics
├── Medical History Tab         # Clinical records and notes
├── Detection History Tab       # AI-detected movements/postures from RPi sessions
└── Video Sessions Tab          # Recorded camera feeds and playback
```

**Key Patterns:**

- **Dynamic routes**: Use `[slug]` for patient IDs (e.g., `/patients/123`)
- **Tabbed interfaces**: Single page with tab navigation for related content
- **No manual session controls**: RPi devices automatically initiate sessions
- **Centralized session monitoring**: `/recent-live-session` page for all camera analytics

#### Session Management Philosophy

- **RPi-Initiated**: Camera sessions start automatically from Raspberry Pi devices
- **Frontend Monitoring**: Dashboard displays and analyzes existing sessions
- **No Start Buttons**: Remove manual session start controls (handled by edge devices)
- **Analytics Focus**: Frontend emphasizes monitoring, analysis, and reporting

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
   "Use RPi UNIK for real-time processing, Backend UNIK for detailed analysis"
   ```

4. **Specify UNIK deployment context:**
   ```
   "We use hybrid UNIK deployment:
   - Raspberry-Pi/UNIK/ for real-time edge processing
   - Back-End/ai_models/UNIK/ for detailed analysis and reports
   - Don't duplicate heavy processing between edge and cloud"
   ```

#### 🔍 Code Review Checklist for AI-Generated Code

**Before committing AI-suggested code, verify:**

- [ ] Uses correct import paths (`core.*` not direct imports)
- [ ] Follows our `ApiResponse<T>` format for backend responses
- [ ] Uses proper error handling with `logger.error` and lazy formatting
- [ ] Authentication uses `security/jwt_verify.py` dependencies
- [ ] UNIK usage follows hybrid deployment strategy (edge vs backend)
- [ ] AI models are placed in correct location (`ai_models/` vs `Raspberry-Pi/`)
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

- **Camera AI system** for posture/movement detection and tracking
- **Raspberry Pi 4 edge devices** with camera integration
- **Real-time streaming** with WebRTC (aiortc)
- **FastAPI + Next.js + Supabase** technology stack
- **PyTorch UNIK models** for pose classification
- **Hybrid UNIK deployment**: Edge processing on RPi + detailed analysis on backend
- **MediaPipe** for pose landmark detection
- **OAuth2 Bearer token** authentication
- **TypeScript** with strict type checking

This ensures AI tools understand our specific requirements and suggest appropriate solutions that fit our architecture and coding standards.

## 🎥 Updated Streaming Architecture (September 2025)

### Frontend Streaming Model: Viewer-Only

**CRITICAL: The frontend website is for WATCHING streams, NOT creating them.**

#### ✅ Correct Streaming Approach

```typescript
// Frontend useStreaming hook - WATCHING existing sessions
const findActiveSession = async (patientId: string) => {
  // Look for existing sessions started by RPi devices
  const sessionsResponse = await streamingService.getSessions({
    patient_id: patientId,
    is_live: true, // Only get active sessions
  });

  if (sessionsResponse.data && sessionsResponse.data.length > 0) {
    return sessionsResponse.data[0]; // Found existing session
  }

  return null; // No active session - RPi hasn't started streaming
};

// Frontend displays: "Start Watching" not "Start Stream"
<Button onClick={startWatching}>Start Watching</Button>;
```

#### ❌ Avoid These Anti-Patterns

```typescript
// ❌ WRONG - Don't create sessions from frontend
const createSession = await streamingService.createSession(sessionData);

// ❌ WRONG - Don't use "Start Stream" terminology
<Button>Start Stream</Button>

// ❌ WRONG - Don't end sessions when viewer disconnects
stopStreaming() => {
  updateSessionStatus(currentSession.id, "ended", false); // Don't do this
}
```

### Backend Room Management

#### Room Connection Status Tracking

```python
# services/streaming/room_service.py - Auto-update room status
class Room:
    def add_peer_connection(self, pc: RTCPeerConnection):
        was_empty = len(self.pcs) == 0
        self.pcs.add(pc)

        # If first connection, mark room as connected
        if was_empty:
            asyncio.create_task(self._update_room_connected())

    def remove_peer_connection(self, pc: RTCPeerConnection):
        self.pcs.remove(pc)

        # If no more connections, mark room as disconnected
        if len(self.pcs) == 0:
            asyncio.create_task(self._update_room_disconnected())
```

#### Fixed Frontend Service Methods

```typescript
// services/streamingService.ts - Use existing backend endpoints
async getActiveSessionsForPatient(patientId: string) {
  // Use existing getSessions endpoint with filters
  return this.getSessions({
    patient_id: patientId,
    is_live: true
  });
  // NOTE: Don't use /streaming/sessions/patient/{id}/active - doesn't exist
}

// Helper method for checking active sessions
async hasActiveSession(patientId: string): Promise<boolean> {
  const response = await this.getSessions({
    patient_id: patientId,
    is_live: true
  });
  return response.data ? response.data.length > 0 : false;
}
```

### Streaming Workflow Patterns

#### 1. **RPi Device Workflow** (Session Creator)

```
1. RPi boots up with camera → Connects to backend
2. Creates streaming session → Starts WebRTC room
3. Streams video continuously → Updates session status
4. On disconnect → Session ends automatically (1-minute timeout)
```

#### 2. **Frontend Workflow** (Session Viewer)

```
1. User clicks "Start Watching" → Look for active sessions
2. If session found → Connect as WebRTC viewer
3. If no session → Show "No camera currently streaming"
4. User disconnects → Only affects viewer, session continues
```

#### 3. **Backend Room Lifecycle**

```
Room Creation (RPi) → connected=true in DB
├── Add viewer connections → Keep connected=true
├── Remove viewer connections → Still connected=true (RPi active)
└── RPi disconnects → connected=false → 1-min timeout → End session
```

### Key Development Rules

#### ✅ DO

- **Frontend**: Use "Start Watching" / "Stop Watching" terminology
- **Frontend**: Only connect to existing sessions, never create them
- **Backend**: Auto-update room `connected` status based on peer connections
- **Sessions**: Let RPi devices manage session lifecycle (create/end)
- **Error messages**: "No camera currently streaming" when no active sessions
- **API calls**: Use `getSessions()` with filters instead of non-existent endpoints

#### ❌ DON'T

- **Frontend**: Create or end sessions from the website
- **Frontend**: Use "Stream" terminology - use "Watch" instead
- **Backend**: End sessions when viewers disconnect (only when RPi disconnects)
- **API**: Create endpoints like `/sessions/patient/{id}/active` - use existing filtered endpoints
- **Room status**: Leave rooms as `connected=true` when no peer connections remain

### Updated Component Patterns

```typescript
// Streaming dashboard page - Viewer pattern
const StreamingPage = () => {
  const { startStreaming, stopStreaming, error } = useStreaming();

  const handleStartWatching = () => {
    startStreaming(patientId); // This finds existing session and connects as viewer
  };

  const handleStopWatching = () => {
    stopStreaming(); // This disconnects viewer only
  };

  if (error?.includes("No active camera session")) {
    return (
      <div>
        <p>No camera is currently streaming.</p>
        <p>Please ensure the camera device is connected and active.</p>
      </div>
    );
  }

  return (
    <div>
      <video ref={videoRef} autoPlay />
      <Button onClick={handleStartWatching}>Start Watching</Button>
      <Button onClick={handleStopWatching}>Stop Watching</Button>
    </div>
  );
};
```

### Session Timeout Behavior

- **Room Inactivity**: If no peer connections for 1 minute → Room marked as `connected=false`
- **Session Management**: Sessions are ended by RPi devices or timeout, not by frontend viewers
- **Auto-cleanup**: Backend automatically cleans up disconnected rooms and ended sessions
- **Graceful Recovery**: Viewers can reconnect to existing sessions without affecting session state

This streaming architecture ensures clear separation between edge devices (session creators) and frontend (session viewers), preventing conflicts and ensuring proper resource management.
