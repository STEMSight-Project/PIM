# Posture & Involuntary Movement (PIM) Detection Module
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white) 
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) 
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) 
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi) 
![Next JS](https://img.shields.io/badge/Next-black?style=for-the-badge&logo=next.js&logoColor=white) 
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white) 
![Jira](https://img.shields.io/badge/jira-%230A0FFF.svg?style=for-the-badge&logo=jira&logoColor=white) 
![React](https://img.shields.io/badge/react-%2320232a.svg?style=for-the-badge&logo=react&logoColor=%2361DAFB) 
![OpenCV](https://img.shields.io/badge/opencv-%23white.svg?style=for-the-badge&logo=opencv&logoColor=white) 
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
- [Licenses](#licenses)

# Overview
Our team is developing a computer vision and machine learning system to detect abnormal postures and involuntary movements from live video aboard ambulances. Using a top- or side-mounted camera to collect live data, the system will be trained to recognize signs of neurological distress. This detection module will feed into NeuroSpring’s Virtual Neurologist detection tool, an autonomous diagnostic suite (under development).

# Screenshots

<insert_prototype_images>

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

2. Run
  ```bash
  
  ```

6. To simulate video streaming:
```bash
python ./Back-End/Testing_files/broadcaster.py --room {room_id}
```
Replace `{room_id}` with your desired room name or ID.

---

# Documentation

## Testing
## Deployment
## Developer Instructions

# Licenses

- google-ai-edge/mediapipe is licensed under the
Apache License 2.0
- supabase/supabase is licensed under the
Apache License 2.0
- opencv/opencv is licensed under the
Apache License 2.0

