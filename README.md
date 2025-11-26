# STEMSight PIM - Posture Intelligence Monitoring

![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
![OpenCV](https://img.shields.io/badge/opencv-%23white.svg?style=for-the-badge&logo=opencv&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=for-the-badge&logo=PyTorch&logoColor=white)

<div align="center">
  <img src="https://github.com/user-attachments/assets/f02eda1f-1769-4865-ad06-d2790e286197" width="350" height="350">
</div>

# Table of Contents

- [Overview](#overview)
- [Purpose](#purpose)
- [Screenshots](#screenshots)
- [System Architecture](#system-architecture)
- [Quick Start Guide](#quick-start-guide)
- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Data Flow Architecture](#data-flow-architecture)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Deployment](#deployment)
- [Documentation Links](#documentation-links)
- [Team Members](#team-members)
- [Contribution Guidelines](#contribution-guidelines)
- [System Requirements](#system-requirements)
- [Troubleshooting](#troubleshooting)
- [Performance Considerations](#performance-considerations)
- [Licenses](#licenses)

# Overview

STEMSight PIM is a **Camera AI Service** for detecting and tracking postures and movements using computer vision technology. The system combines real-time streaming from Raspberry Pi 4 devices with advanced machine learning models to provide AI-powered pose detection and movement analysis capabilities.

**STEMSight PIM** is a **real-time AI application** designed to detect and classify abnormal postures and involuntary movements from live video streams. Using camera modules on Raspberry Pi 4 edge devices, the system analyzes patient movement through MediaPipe pose estimation and custom PyTorch neural networks. Our team is developing a computer vision and machine learning system to detect abnormal postures and involuntary movements from live video aboard ambulances. Using a top- or side-mounted camera to collect live data, the system will be trained to recognize signs of neurological distress. This detection module will feed into NeuroSpring's Virtual Neurologist detection tool, an autonomous diagnostic suite (under development). The purpose of the project is to develop a database of video recordings demonstrating abnormal body postures ("postures") and involuntary movements ("movements") that represent neurological disease. Then train an artificial intelligence-based medical device to recognize these postures & movements based on the synthetic database. In production, the medical device then monitors patients as they are transported in ambulances for development of one of the postures or movements, triggering an alert to healthcare providers.

The application was developed to assist **healthcare providers and first responders** by automatically identifying potential neurological distress during **patient transport in ambulances**. It delivers instant visual feedback and alerts through a **Next.js dashboard**, allowing remote clinicians to monitor multiple live camera feeds securely and efficiently.

## 🎯 Purpose

This system was created to address a critical gap in emergency medicine: **early detection of neurological postures** during patient transport, where every second matters.  
By combining **edge computing**, **computer vision**, and **machine learning**, PIM aims to provide continuous, privacy-preserving monitoring without requiring manual supervision — reducing diagnostic delays and enabling faster intervention.

# Screenshots

| Feature | Preview |
| :--- | :--- |
| **Main Dashboard**<br>Central hub for system status and alerts. | ![Main Dashboard](https://github.com/user-attachments/assets/77e40c0a-d051-4c48-95ba-0617de66d790) |
| **Streaming Interface**<br>Live WebRTC video stream with low latency. | ![Streaming Dashboard](https://github.com/user-attachments/assets/14205763-a4fa-4da0-8c4f-c238371a118e) |
| **Playback & Review**<br>Replay recorded sessions with timeline controls. | ![Playback Page](https://github.com/user-attachments/assets/cfad5bf1-a721-40b5-930b-3903b2cf1ea5) |
| **Recent Sessions**<br>History of past monitoring activities. | ![Recent Sessions](https://github.com/user-attachments/assets/2af99f77-51ff-4940-b728-af7431655068) |
| **ERD**<br>Relationship diagram of supabase tables. | ![Edge Stream Simulation](https://github.com/user-attachments/assets/19edfff5-49a9-484f-8240-d7aaad03d763) |
| **Raspberry pi 4**<br>Edge device, meant to run ai inference and handle video recording in ambulances. | ![AI Output](https://github.com/user-attachments/assets/3cda8c3a-1f19-468b-acfb-10ee6441a871) |


# System Architecture

```
┌─────────────────┐    ┌──────────────────────┐    ┌──────────────────┐
│ Raspberry Pi 4  │    │ FastAPI Backend      │    │ Next.js Frontend │
│ • Camera module │───▶│ • REST/WebSocket API │───▶│ • AI Dashboard   │
│ • MediaPipe/AI  │    │ • ML inference       │    │ • Live streaming │
│ • WebRTC stream │    │ • DB (Supabase)      │    │ • Camera mgmt    │
└─────────────────┘    └──────────────────────┘    └──────────────────┘
```

## Core Components

| Component              | Technology                      | Purpose                                                    |
| ---------------------- | ------------------------------- | ---------------------------------------------------------- |
| **RPi 4 Edge Devices** | Python + MediaPipe + PyTorch    | Real-time movement detection with local AI processing      |
| **Backend API**        | FastAPI + Supabase + PostgreSQL | Central data processing, ML models, and API services       |
| **Frontend Dashboard** | Next.js 15 + React + TypeScript | AI monitoring interface for camera management and analysis |

# Quick Start Guide

## Prerequisites

- **Hardware**: Raspberry Pi 4 with camera module
- **Software**: Python 3.8+, Node.js 18+, PostgreSQL
- **Services**: Supabase account for database

## Download

1. Open the terminal and get into location which you're prefer to clone repository

2. Clone the repository
   ```bash
   git clone https://github.com/STEMSight-Project/PIM.git
   cd PIM
   ```

## 1. Backend Setup

```bash
# Navigate to backend
cd Back-End

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Supabase credentials

# Start backend server
uvicorn main:app --reload
# API available at: http://localhost:8000
```

## 2. Frontend Setup

```bash
# Navigate to frontend
cd Front-End

# Install dependencies
npm install

# Configure environment
echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:8000" > .env.local

# Start development server
npm run dev
# Frontend available at: http://localhost:3000
```

## 3. RPi 4 Edge Device Setup

```bash
# On Raspberry Pi 4
git clone <repository>
cd Raspberry-Pi

# Install RPi-specific dependencies
pip install -r requirements-rpi.txt

# Configure camera and start edge processing
python3 pose_model_capture.py --device camera_module --config config/

# For detailed setup instructions, see Raspberry-Pi/README.md
```


## 4. Camera Streaming Setup

1. Install FFMPEG at [FFMPEG](https://www.ffmpeg.org/download.html)

2. Find supported devices:

- For MacOS:
  ```bash
  ffmpeg -f avfoundation -list_devices true -i ""
  ```
- For Windows:
  ```bash
  ffmpeg -list_devices true -f dshow -i dummy
  ```
- Other devices:
  _*Coming later*_

3. To simulate video streaming:

```bash
python ./Back-End/Testing_files/broadcaster.py --room {room_id} --video_device {video_device} --audio_device {audio_device}
```

- Replace `{room_id}` with your desired room name or ID.
- Replace `{video_device}` for example:
  - Windows `LOGITECH Logi` for camera
  - MacOS `0` for Facetime HD Camera
- Replace `{audio_device}` for example:
  - Windows `Realtek Audio` for Realtek audio
  - MacOS `0` for Macbook microphone

# Key Features

## 🔴 **Live Patient Monitoring**

- Real-time video streaming from RPi 4 camera modules
- Edge AI processing for immediate pose detection
- Multi-patient dashboard with live status indicators
- Automatic alerts for abnormal movement patterns

## 🧠 **AI-Powered Detection**

- **UNIK Models**: Custom PyTorch models for pose classification
- **MediaPipe Integration**: Real-time landmark detection
- **Edge Computing**: Local processing on RPi 4 for low latency
- **Confidence Scoring**: Adjustable detection thresholds (default: 0.7)

## 📱 **Healthcare Provider Dashboard**

- **Recent Live Sessions**: Monitor and review all camera sessions from RPi 4 devices
- **Patient Management**: Comprehensive subject profiles with tabbed interface (Overview, Medical History, Detection History, Video Sessions)
- **Live Streaming View**: Real-time video feeds from multiple RPi 4 cameras simultaneously
- **Detection Analytics**: Review AI-detected movements and postures with confidence scores
- **Medical Records**: Comprehensive patient information and clinical history management
- **Session Insights**: Detailed analysis of detection events, alerts, and session statistics

## 🔒 **Security & Access Control**

- JWT-based authentication with role-based access
- Healthcare provider vs. patient dashboard views
- Secure API endpoints with OAuth2 Bearer tokens
- HIPAA-compliant data handling practices

# Project Structure

```
PIM/
├── 📚 README.md                    # This file - project overview
├──
├── 🔧 Back-End/                    # FastAPI backend application
│   ├── 📖 README.md               # Backend documentation
│   ├── main.py                    # FastAPI app entry point
│   ├── core/                      # Core utilities and configuration
│   ├── api_router/                # REST API endpoints
│   ├── ai_models/                 # AI/ML processing and models
│   ├── security/                  # Authentication & authorization
│   └── Testing_files/             # Development utilities
│
├── 🎨 Front-End/                   # Next.js frontend application
│   ├── 📖 README.md               # Frontend documentation
│   ├── src/app/                   # Next.js pages (App Router)
│   │   ├── dashboard/             # Main healthcare provider dashboard
│   │   ├── patients/              # Patient management
│   │   │   └── [slug]/            # Dynamic patient detail pages
│   │   ├── recent-live-session/   # RPi camera session monitoring
│   │   └── streamingDash/         # Live camera feeds
│   ├── src/components/            # Reusable UI components
│   ├── src/hooks/                 # Custom React hooks
│   ├── src/services/              # API service layer
│   └── src/types/                 # TypeScript definitions
│
├── 🤖 Raspberry-Pi/                # Edge device configuration
│   ├── 📖 README.md               # RPi setup and deployment guide
│   ├── pose_model_capture.py      # Main camera capture & AI processing
│   ├── PostureMovementDetector.py # MediaPipe pose detection engine
│   ├── UNIK/                      # AI models (edge deployment)
│   ├── config/                    # Device configuration files
│   └── requirements-rpi.txt       # RPi-specific dependencies
│
└── 📋 .github/                     # Project configuration
    └── instructions/               # Development guidelines
        └── copilot-instructions.md # Coding standards & patterns
```

# Data Flow Architecture

## Edge-to-Cloud Pipeline

```
1. **RPi 4 Auto-Initiation**: Camera modules automatically start monitoring sessions
   ↓
2. **Real-time Processing**: MediaPipe Pose Detection → Local AI Processing → Detection Results
   ↓
3. **Data Transmission**: Detection Results + Video Stream → FastAPI Backend → Database Storage
   ↓
4. **Dashboard Display**: WebRTC Streaming → Frontend Dashboard → Healthcare Provider Monitoring
```

**Note**: Sessions are automatically initiated by RPi 4 devices. Frontend provides monitoring and analysis, not manual session control.

## API Communication Pattern

```typescript
// All API responses follow consistent format
interface ApiResponse<T> {
  data: T | null;
  error: string | null;
  status?: number;
}

// Example: Frontend service layer
const response = await patientService.getById(patientId);
if (response.data) {
  // Handle successful response
} else {
  // Handle error case
}
```

# Development Workflow

## Local Development

```bash
# Terminal 1: Backend
cd Back-End
uvicorn main:app --reload

# Terminal 2: Frontend
cd Front-End
npm run dev

# Terminal 3: RPi 4 Simulation (optional)
cd Raspberry-Pi
python3 pose_model_capture.py --room test_room --device camera_module

# Or use backend testing utility
cd Back-End/Testing_files
python broadcaster.py --room test_room --video_device 0
```

## Code Organization

- **Backend**: Follow FastAPI router patterns with Pydantic models
- **Frontend**: Use service layer + custom hooks + TypeScript
- **Shared**: Consistent API response formats across all endpoints

## Testing Strategy

```bash
# Backend API testing
# Access Swagger UI: http://localhost:8000/docs

# Frontend linting
cd Front-End
npm run lint

# Streaming tests
cd Raspberry-Pi
python3 pose_model_capture.py --room test --device camera_module

# Or use backend testing utility
cd Back-End/Testing_files
python broadcaster.py --room test --device camera_module
```

# STEMSight PIM - Verified Test Command Reference

This appendix lists all test execution commands and environments drawn directly from the System Test Report for **Project PIM (iddCuties Team)**.

## 🧩 Test Environment Setup

### Front-End

```bash
cd Front-End
npm install        # Node/npm bundled with Next.js ^15.2.4
npm run test       # Runs full Jest suite
# or for targeted specs:
npm test -- <pattern>
```

### Back-End

```bash
cd Back-End
python -m venv .venv
.venv\Scripts\activate   # Windows PowerShell
pip install -r requirements.txt
pytest                   # Full suite
python -m pytest tests/<file>::<test>  # Targeted run
```

**System baseline:** Windows 11 + PowerShell 5.1 terminals.
**Python version:** 3.11

## 🧠 Backend Model & Integration Tests

| Test                            | Command                                                                                                                                                 | Notes                                                  |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| **Single View Model Loading**   | `cd Back-End/testing_files && python test_single_view.py`                                                                                               | Confirms single-view model loads and infers correctly  |
| **Multi View Model Test**       | `cd Back-End && python training_tests.py`                                                                                                               | Validates training logic for multi-view PoseTCN models |
| **Single View PoseTCN Test**    | `cd Back-End && python test_pose_tcn_single_view.py`                                                                                                    | Checks architecture and inference consistency          |
| **Model Discovery/Loading**     | `cd Back-End && python test_model.py`                                                                                                                   | Scans model directories for valid checkpoints          |
| **Broadcaster Unit Tests**      | `cd Back-End && pytest tests\test_broadcaster.py`                                                                                                       | Unit-level verification for broadcaster methods        |
| **Live Inference Test**         | `cd Back-End && python test_live.py --ckpt C:\runs\single_view_f1_bn_t240_gamma175_cm_tremor\best_single_view_f1_bn_t240_gamma175_cm_tremor.pt --T 240` | Validates end-to-end real-time inference               |
| **Broadcaster Functional Test** | `cd Back-End/Testing_files && python broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"`                                   | Simulates streaming + Supabase interaction             |

## 🎥 Annotated Video Generator Tests

### Multi-View

```bash
python annotated_video_generator.py \
  "$env:USERPROFILE\Desktop\2025-06-01 08-31-38.mkv" \
  --output "$env:USERPROFILE\Desktop\annotated_cnn_test.mp4" \
  --model "C:\runs\sv_t240_noMix_attn02_warp06_rebal\best_sv_t240_noMix_attn02_warp06_rebal.pt" \
  --skip-frames 1
```

### Single-View

```bash
python single_annotated.py \
  "$env:USERPROFILE\Desktop\2025-06-01 08-31-38.mkv" \
  --output "$env:USERPROFILE\Desktop\annotated_cnn_test1.mp4" \
  --model "runs\f1_plus\best_f1_plus.pt" \
  --skip-frames 1
```

**Expected result:** Annotated video with overlayed skeleton, live predictions, and confidence summary output.

## 💻 Front-End Test Suite

**Run all automated Jest tests:**

```bash
cd Front-End
npm run test
```

**Run a specific file:**

```bash
npm test -- src/__tests__/Dashboard.test.tsx
```

**Libraries & Versions:**

* jest 30.2.0
* jest-environment-jsdom 30.2.0
* ts-jest 29.4.4
* @testing-library/react 16.3.0
* @testing-library/jest-dom 6.8.0

## ⚙️ 3rd-Party Back-End Testing Libraries

* pytest ≥ 7.4.0
* pytest-asyncio ≥ 0.21.0
* pytest-cov ≥ 4.1.0
* pytest-mock ≥ 3.11.0

# 🚀 Deployment Appendix (Azure)

This app deploys **both** Frontend (Next.js) and Backend (FastAPI) to **Azure App Service** and uses **Supabase (PostgreSQL)** for data/storage. Raspberry Pi devices stream to the backend over WebRTC/REST.

## 🧩 Prerequisites

- Azure subscription + Azure CLI:
  
  ```bash
  az login
  az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
  ```

- **Backend**: Python 3.11, `uvicorn`, `requirements.txt`
- **Frontend**: Node 18+, `npm run build` succeeds locally
- **Supabase**: Project URL + keys (Anon and/or Service Role)

## ⚙️ Environment Variables

### Backend (FastAPI)

Set these as **App Settings** in Azure Web App → Configuration → Application settings:

| Variable            | Description                     |
| ------------------- | ------------------------------- |
| `SUPABASE_URL`      | Supabase project endpoint       |
| `SUPABASE_ANON_KEY` | Public API key                  |
| `JWT_SECRET`        | Token signing secret            |
| `CORS_ORIGINS`      | Comma-separated frontend URLs   |
| `MODEL_PATH`        | Optional: model checkpoint path |

### Frontend (Next.js)

| Variable                   | Example                                                                |
| -------------------------- | ---------------------------------------------------------------------- |
| `NEXT_PUBLIC_API_BASE_URL` | `https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net` |

## ☁️ Backend Deploy (FastAPI → Azure App Service)

### Option A — CLI Quick Create

```bash
az group create -n pim-rg -l westus3
az appservice plan create -g pim-rg -n pim-plan --sku B1 --is-linux
az webapp create -g pim-rg -p pim-plan -n fastapibackend-amfucydqayg9h8gb --runtime "PYTHON:3.11"

# App settings
az webapp config appsettings set -g pim-rg -n fastapibackend-amfucydqayg9h8gb --settings \
  SUPABASE_URL="https://XXXX.supabase.co" \
  SUPABASE_ANON_KEY="XXXX" \
  JWT_SECRET="change-me" \
  CORS_ORIGINS="https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net,http://localhost:3000"

# Deploy from local directory (OneDeploy)
az webapp deploy \
  --resource-group pim-rg \
  --name fastapibackend-amfucydqayg9h8gb \
  --src-path ./Back-End \
  --type zip
```

### Option B — GitHub Actions (OneDeploy)

Use the `azure/webapps-deploy@v3` GitHub Action to deploy the backend ZIP.
If you see **409 Conflict**, cancel concurrent runs or use **deployment slots**.

**Startup command:**

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --timeout-keep-alive 120
```

**Production URL:**
`https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs`

> 📝 **FFmpeg note:** Azure App Service doesn't include FFmpeg. You've disabled server-side recording. To enable it:
> 
> * Use a custom container with FFmpeg installed, or
> * Bundle a static binary in your app folder and add it to PATH.

## 🖥️ Frontend Deploy (Next.js → Azure App Service)

```bash
az webapp create -g pim-rg -p pim-plan -n nextjsfrontend-c0cydrgwa3ckdxgp --runtime "NODE:18LTS"

az webapp config appsettings set -g pim-rg -n nextjsfrontend-c0cydrgwa3ckdxgp --settings \
  NEXT_PUBLIC_API_BASE_URL="https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net"

az webapp deploy \
  --resource-group pim-rg \
  --name nextjsfrontend-c0cydrgwa3ckdxgp \
  --src-path ./Front-End \
  --type zip
```

**Build commands:**

```bash
npm install
npm run build
npm start   # or next start
```

**Production URL:**
`https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net`

## 🔐 CORS, WebSockets & HTTPS

* Add frontend origins to backend `CORS_ORIGINS`.
* Enable WebSockets: Azure Portal → App Settings → **Web sockets ON**.
* Always use HTTPS for camera/mic access.

## 🧪 Post-Deployment Checks

1. Verify backend health at `/docs` endpoint.
2. Check that frontend `NEXT_PUBLIC_API_BASE_URL` points to production backend.
3. Confirm WebRTC streams connect and predictions appear.
4. Optionally simulate an ambulance camera stream:

   ```bash
   cd Back-End/Testing_files
   python broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
   ```

## 🧱 Optional: Deployment Slots

Create a staging slot:

```bash
az webapp deployment slot create -g pim-rg -n fastapibackend-amfucydqayg9h8gb --slot staging
```

Swap after validation:

```bash
az webapp deployment slot swap -g pim-rg -n fastapibackend-amfucydqayg9h8gb --slot staging
```

## 🧩 Common Issues

| Issue                        | Fix                                    |
| ---------------------------- | -------------------------------------- |
| **409 Conflict**             | Cancel concurrent deploys or use slots |
| **WebRTC not connecting**    | Enable WebSockets, check CORS & HTTPS  |
| **FFmpeg missing**           | Custom container or static binary      |
| **Environment vars ignored** | Restart the Web App                    |

# Documentation Links

- **[Backend Documentation](./Back-End/README.md)** - FastAPI setup, API endpoints, AI models
- **[Frontend Documentation](./Front-End/README.md)** - Next.js setup, components, service layer
- **[Raspberry Pi Documentation](./Raspberry-Pi/README.md)** - Edge device setup, camera configuration, AI deployment
- **[Development Guidelines](./.github/instructions/copilot-instructions.md)** - Coding standards and patterns

## Local Development URLs

- **Backend (Local):** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Frontend (Local):** [http://localhost:3000](http://localhost:3000)

## Production URLs

- **Backend (Production):** [https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs](https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs)
- **Frontend (Production):** [https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net](https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net)

> Production links may be offline if not currently deployed.

# Team Members

## 👥 Contributors

| Name | Contact |
|------|---------|
| Mike Feschenko | [mikefeschenko@csus.edu](mailto:mikefeschenko@csus.edu) |
| Ian Anderson | [ima34@csus.edu](mailto:ima34@csus.edu) |
| Nguyen Phuc Tran | [nguyenphuctran@csus.edu](mailto:nguyenphuctran@csus.edu) |
| Xeng Feng | [xiangfeng@csus.edu](mailto:xiangfeng@csus.edu) |
| Faith Montemayor | [faithmontemayor@csus.edu](mailto:faithmontemayor@csus.edu) |
| Antonio Graci | [agraci@csus.edu](mailto:agraci@csus.edu) |
| Corbin West | [corbinwest@csus.edu](mailto:corbinwest@csus.edu) |
| Pablo Hernandez | [phernandez4@csus.edu](mailto:phernandez4@csus.edu) |

# Contribution Guidelines

## Getting Started

1. **Read the documentation** for your component (Backend/Frontend)
2. **Follow the established patterns** outlined in the README files
3. **Use the service layer** for API communication in frontend
4. **Implement proper error handling** with consistent response formats
5. **Test with real RPi 4 devices** when possible

## Code Standards

- **Backend**: FastAPI + Pydantic models + JWT authentication
- **Frontend**: Next.js 15 + TypeScript + Tailwind CSS + Custom hooks
- **Shared**: Consistent `ApiResponse<T>` format for all endpoints

## Pull Request Process

1. Create feature branch from `main`
2. Follow existing code patterns and documentation
3. Test locally with both backend and frontend running
4. Update relevant README.md files for new features
5. Submit PR with clear description of changes

# System Requirements

## Development Environment

- **OS**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB available space
- **Network**: Stable internet for database connection

## Production Environment

- **RPi 4**: 4GB RAM model with camera module
- **Backend**: 2+ CPU cores, 4GB RAM, Docker support
- **Frontend**: Static hosting (Vercel, Netlify, AWS S3)
- **Database**: PostgreSQL 12+ (Supabase recommended)

# Troubleshooting

## Common Issues

1. **CORS Errors**: Ensure backend includes frontend URL in CORS_ORIGINS
2. **Streaming Issues**: Check camera permissions and WebRTC browser support
3. **Build Errors**: Clear `.next` cache and restart development servers
4. **Database Connection**: Verify Supabase credentials in environment files
5. **Port mix-ups**: Backend runs on `8000`, Frontend on `3000`

## Support Resources

- **API Documentation**: http://localhost:8000/docs (when backend running)
- **Frontend Logs**: Browser developer console
- **Backend Logs**: Terminal running uvicorn server
- **System Status**: Check individual component README files

## Additional Troubleshooting

* **CORS errors:** Add your frontend origin to backend CORS settings.
* **WebRTC not connecting:** Check camera permissions and HTTPS on prod.
* **DB issues:** Verify Supabase keys/URL in `.env`.

# Performance Considerations

- **Edge Processing**: RPi 4 handles real-time AI to reduce latency
- **WebRTC Streaming**: Direct peer-to-peer connections for video
- **Database Optimization**: Indexed queries and connection pooling
- **Frontend Caching**: Service worker and static asset optimization

# Licenses

- google-ai-edge/mediapipe is licensed under the Apache License 2.0
- supabase/supabase is licensed under the Apache License 2.0
- opencv/opencv is licensed under the Apache License 2.0

---

**For detailed setup instructions, see the README files in each component directory.**
