# STEMSight PIM - Posture Intelligence Monitoring

![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB)
![OpenCV](https://img.shields.io/badge/opencv-%23white.svg?style=for-the-badge&logo=opencv&logoColor=white)

## � Project Overview

STEMSight PIM is a **Camera AI Service** for detecting and tracking postures and movements using computer vision technology. The system combines real-time streaming from Raspberry Pi 4 devices with advanced machine learning models to provide AI-powered pose detection and movement analysis capabilities.

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Raspberry     │    │   FastAPI       │    │   Next.js       │
│   Pi 4 Devices  │───▶│   Backend       │───▶│   Frontend      │
│                 │    │                 │    │                 │
│ • Camera Module │    │ • REST APIs     │    │ • AI Dashboard  │
│ • Edge AI       │    │ • ML Models     │    │ • Live Streaming│
│ • Live Stream   │    │ • WebRTC        │    │ • Camera Mgmt   │
│ • Pose Detection│    │ • Database      │    │ • Video Analysis│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🎯 Core Components

| Component              | Technology                      | Purpose                                                    |
| ---------------------- | ------------------------------- | ---------------------------------------------------------- |
| **RPi 4 Edge Devices** | Python + MediaPipe + PyTorch    | Real-time movement detection with local AI processing      |
| **Backend API**        | FastAPI + Supabase + PostgreSQL | Central data processing, ML models, and API services       |
| **Frontend Dashboard** | Next.js 15 + React + TypeScript | AI monitoring interface for camera management and analysis |

## 🚀 Quick Start Guide

### Prerequisites

- **Hardware**: Raspberry Pi 4 with camera module
- **Software**: Python 3.8+, Node.js 18+, PostgreSQL
- **Services**: Supabase account for database

### 1. Backend Setup

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

### 2. Frontend Setup

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

### 3. RPi 4 Edge Device Setup

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

## 📊 Key Features

### 🔴 **Live Patient Monitoring**

- Real-time video streaming from RPi 4 camera modules
- Edge AI processing for immediate pose detection
- Multi-patient dashboard with live status indicators
- Automatic alerts for abnormal movement patterns

### 🧠 **AI-Powered Detection**

- **UNIK Models**: Custom PyTorch models for pose classification
- **MediaPipe Integration**: Real-time landmark detection
- **Edge Computing**: Local processing on RPi 4 for low latency
- **Confidence Scoring**: Adjustable detection thresholds (default: 0.7)

### 📱 **Healthcare Provider Dashboard**

- **Recent Live Sessions**: Monitor and review all camera sessions from RPi 4 devices
- **Patient Management**: Comprehensive subject profiles with tabbed interface (Overview, Medical History, Detection History, Video Sessions)
- **Live Streaming View**: Real-time video feeds from multiple RPi 4 cameras simultaneously
- **Detection Analytics**: Review AI-detected movements and postures with confidence scores
- **Medical Records**: Comprehensive patient information and clinical history management
- **Session Insights**: Detailed analysis of detection events, alerts, and session statistics

### 🔒 **Security & Access Control**

- JWT-based authentication with role-based access
- Healthcare provider vs. patient dashboard views
- Secure API endpoints with OAuth2 Bearer tokens
- HIPAA-compliant data handling practices

## 📁 Project Structure

````
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
```## 🔄 Data Flow Architecture

### Edge-to-Cloud Pipeline

````

1. **RPi 4 Auto-Initiation**: Camera modules automatically start monitoring sessions
   ↓
2. **Real-time Processing**: MediaPipe Pose Detection → Local AI Processing → Detection Results
   ↓
3. **Data Transmission**: Detection Results + Video Stream → FastAPI Backend → Database Storage
   ↓
4. **Dashboard Display**: WebRTC Streaming → Frontend Dashboard → Healthcare Provider Monitoring

**Note**: Sessions are automatically initiated by RPi 4 devices. Frontend provides monitoring and analysis, not manual session control.

````

### API Communication Pattern

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
````

## 🛠️ Development Workflow

### Local Development

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

### Code Organization

- **Backend**: Follow FastAPI router patterns with Pydantic models
- **Frontend**: Use service layer + custom hooks + TypeScript
- **Shared**: Consistent API response formats across all endpoints

### Testing Strategy

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

## 🌐 Deployment Architecture

### Production Environment

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Edge Devices  │    │   Cloud Backend │    │   Web Frontend  │
│                 │    │                 │    │                 │
│ Multiple RPi 4  │───▶│ AWS/GCP/Azure   │───▶│ Vercel/Netlify  │
│ Hospital Units  │    │ Docker + K8s    │    │ CDN Deployment  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌─────────────────┐
                       │   Database      │
                       │ Supabase/       │
                       │ PostgreSQL      │
                       └─────────────────┘
```


---

### ✅ **Updated “Documentation Links” Section**


## 📚 Documentation Links

- **Backend API (Production):** [https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs](https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs)
- **Frontend (Production):** [https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net](https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net)
- **Backend (Local):** http://localhost:8000/docs
- **Frontend (Local):** http://localhost:3000
- **[Backend Documentation](./Back-End/README.md)** — FastAPI setup, API endpoints, AI models  
- **[Frontend Documentation](./Front-End/README.md)** — Next.js setup, components, service layer  
- **[Raspberry Pi Documentation](./Raspberry-Pi/README.md)** — Edge device setup, camera configuration, AI deployment  
- **[Development Guidelines](./.github/instructions/copilot-instructions.md)** — Coding standards and patterns  

Backend (FastAPI) tests – Back-End

Activate the repo’s virtualenv (Activate.ps1 on PowerShell) and install deps from requirements.txt if you haven’t yet.
From Back-End, run the full suite with:
cd C:\Users\Mike\PIM Detector\PIM\Back-End
pytest
or, for verbose output / specific files, python -m pytest -v tests/services/test_room_service.py.
These tests rely on the project fixtures under tests (see pytest.ini), so don’t move or rename them. Environment variables (Supabase keys, etc.) must match .env for anything hitting external services.
Frontend (Next.js) tests – Front-End

Ensure Node 18+; install deps via npm install inside Front-End.
Run the Vitest suite (configured via vitest.config.ts) with:
cd C:\Users\Mike\PIM Detector\PIM\Front-End
npm test
You can add -- run filename.test.tsx to target individual specs. Tests live under src/__tests__/ or beside components and use React Testing Library.
Manual streaming / broadcaster checks

For end-to-end validation of WebRTC + detection, the repo ships broadcaster.py. With the backend running (uvicorn main:app --reload from Back-End), you can simulate an ambulance camera:
cd C:\Users\Mike\PIM Detector\PIM\Back-End
python Testing_files\broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO" (or whichever video device is active/in use)
This exercises pose detection, Supabase storage writes, and the pending-recording recovery loop. Watch backend logs for INFO:publisher lines (live run complete) or PendingRecordingUploader warnings (stuck upload recovery).
Raspberry Pi edge tests (optional but recommended)

Under Raspberry-Pi, use python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device /dev/video0 on the Pi to verify real hardware streaming.
test_broadcaster.ps1 provides a Windows pre-flight check for FFmpeg, virtualenv, and backend availability before running broadcaster tests.
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


### Getting Started

1. **Read the documentation** for your component (Backend/Frontend)
2. **Follow the established patterns** outlined in the README files
3. **Use the service layer** for API communication in frontend
4. **Implement proper error handling** with consistent response formats
5. **Test with real RPi 4 devices** when possible

### Code Standards

- **Backend**: FastAPI + Pydantic models + JWT authentication
- **Frontend**: Next.js 15 + TypeScript + Tailwind CSS + Custom hooks
- **Shared**: Consistent `ApiResponse<T>` format for all endpoints

### Pull Request Process

1. Create feature branch from `main`
2. Follow existing code patterns and documentation
3. Test locally with both backend and frontend running
4. Update relevant README.md files for new features
5. Submit PR with clear description of changes

## 📋 System Requirements

### Development Environment

- **OS**: Windows 10+, macOS 10.15+, Ubuntu 18.04+
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB available space
- **Network**: Stable internet for database connection

### Production Environment

- **RPi 4**: 4GB RAM model with camera module
- **Backend**: 2+ CPU cores, 4GB RAM, Docker support
- **Frontend**: Static hosting (Vercel, Netlify, AWS S3)
- **Database**: PostgreSQL 12+ (Supabase recommended)

## 🚨 Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure backend includes frontend URL in CORS_ORIGINS
2. **Streaming Issues**: Check camera permissions and WebRTC browser support
3. **Build Errors**: Clear `.next` cache and restart development servers
4. **Database Connection**: Verify Supabase credentials in environment files

### Support Resources

- **API Documentation**: http://localhost:8000/docs (when backend running)
- **Frontend Logs**: Browser developer console
- **Backend Logs**: Terminal running uvicorn server
- **System Status**: Check individual component README files

## 📈 Performance Considerations

- **Edge Processing**: RPi 4 handles real-time AI to reduce latency
- **WebRTC Streaming**: Direct peer-to-peer connections for video
- **Database Optimization**: Indexed queries and connection pooling
- **Frontend Caching**: Service worker and static asset optimization

## 🔮 Future Roadmap

- [ ] Mobile app for healthcare providers
- [ ] Advanced ML models for specific medical conditions
- [ ] Integration with hospital management systems
- [ ] Real-time analytics and reporting dashboard
- [ ] Multi-language support for international deployment

---

**For detailed setup instructions, see the README files in each component directory.**
![PyTorch](https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=for-the-badge&logo=PyTorch&logoColor=white)

<div align="center">
  <img src="https://github.com/user-attachments/assets/f02eda1f-1769-4865-ad06-d2790e286197" width="350" height="350">
</div>

# Table of Contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Download](#download)
- [Build and Install](#installation)
- [Documentation](#documentation)
- [Timeline](#timeline)
- [Licenses](#licenses)

# Overview

Our team is developing a computer vision and machine learning system to detect abnormal postures and involuntary movements from live video aboard ambulances. Using a top- or side-mounted camera to collect live data, the system will be trained to recognize signs of neurological distress. This detection module will feed into NeuroSpring’s Virtual Neurologist detection tool, an autonomous diagnostic suite (under development). The purpose of the project is to develop a database of video recordings demonstrating abnormal body postures (“postures”) and involuntary movements (“movements”) that represent neurological disease. Then train an artificial intelligence-based medical device to recognize these postures & movements based on the synthetic database. In production, the medical device then monitors patients as they are transported in ambulances for development of one of the postures or movements, triggering an alert to healthcare providers.

# Screenshots

![Image](https://github.com/user-attachments/assets/e4975e16-84d4-41da-bfce-4849d732eb41)
![Image](https://github.com/user-attachments/assets/43201b92-210f-4900-939d-03bf0cce1743)
![Image](https://github.com/user-attachments/assets/1226fefd-6a3a-4371-8f7d-307c578d7746)
![Image](https://github.com/user-attachments/assets/76ff5830-a69b-439e-a7cb-7c2a36e87457)
![Image](https://github.com/user-attachments/assets/3cda8c3a-1f19-468b-acfb-10ee6441a871)

# Download

1. Open the terminal and get into location which you're prefer to clone repository

2. Clone the repository
   ```bash
   git clone https://github.com/STEMSight-Project/PIM.git
   ```

---

# Build and Install

This repository contains both **Back-End** and **Front-End** components.

### Back-End Setup

1. Open a terminal window and navigate to the back-end directory:
   ```bash
   cd PIM/Back-End
   ```
2. Start the local server for testing:
   ```bash
   uvicorn main:app --reload
   ```
3. After starting, access the API documentation at:
   [http://localhost:3000/docs](http://localhost:3000/docs)

### Front-End Setup

1. Open a second terminal window without closing the back-end server.
2. Navigate to the front-end directory:
   ```bash
   cd PIM/Front-End
   ```
3. Build the project to check for errors:
   ```bash
   npm run build
   ```
4. Start the development server:
   ```bash
   npm run dev
   ```
5. The front-end will be available at:
   [http://localhost:8000](http://localhost:8000)

### Camera Streaming Setup

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

---


# Licenses

- google-ai-edge/mediapipe is licensed under the
  Apache License 2.0
- supabase/supabase is licensed under the
  Apache License 2.0
- opencv/opencv is licensed under the
  Apache License 2.0
