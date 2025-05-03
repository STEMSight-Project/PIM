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
- Replease `{video_device}` for example:
  - Windows `LOGITECH Logi` for camera
  - MacOS `0` for Facetime HD Camera
- Replease `{audio_device}` for example:
  - Windows `Realtek Audio` for Realtek audio
  - MacOS `0` for Macbook microphone

---

# Documentation

## Testing
## Deployment
## Developer Instructions
# Timeline
![Image](https://github.com/user-attachments/assets/a323d74b-f31b-4633-8b33-18589715bfa0)
![Image](https://github.com/user-attachments/assets/7ae066f5-d493-44a3-881e-2479fff4fa89)
# 🗓️ Timeline

## Phase 2: Feature Expansion (Late August – October 2025)

### 🔹 Milestone 4: Enhanced Detection System *(Est. Start: Week of 8/25)*
- Implement all target posture detection algorithms  
- Develop movement detection algorithms  
- Integrate detection confidence scoring  
**✅ Deliverable:** Comprehensive detection system for all target conditions

---

### 🔹 Milestone 5: Advanced UI Features *(Est. Start: Week of 8/25)*
- Implement session review interface  
- Develop comprehensive reporting system  
- Create remote monitoring capabilities  
**✅ Deliverable:** Complete user interface with all planned screens

---

### 🔹 Milestone 6: System Integration *(Est. Start: Mid–Late September)*
- Integrate with docking station hardware  
- Implement HoloLens (headset) activation trigger  
- Develop offline operation mode  
**✅ Deliverable:** Fully integrated system with hardware components

---

### 🔹 Milestone 7A: Begin Testing & Refinement *(Est. Start: Early–Mid October)*
- Refine detection algorithms based on test results  
- Conduct API integration & UI interaction testing  
- Perform unit tests  
**✅ Deliverable:** Testing report and optimized system

---

## Phase 3: Optimization & Finalization (November – December 2025)

### 🔹 Milestone 7B: Continue Testing & Refinement *(Est. Start: November)*
- Conduct comprehensive system testing  
- Further refine detection algorithms  
**✅ Deliverable:** Continued testing report and optimized system

---

### 🔹 Milestone 8: Final Delivery *(Est. Delivery: Mid December)*
- Complete system documentation  
- Perform final validation testing  
**🎯 Deliverable:** Final system delivery with full documentation

![image](https://github.com/user-attachments/assets/967dde73-34a1-4288-a7fc-3b0568330afc)
![image](https://github.com/user-attachments/assets/601f45cd-edb7-454c-aa34-d988cd4293be)


# Licenses

- google-ai-edge/mediapipe is licensed under the
Apache License 2.0
- supabase/supabase is licensed under the
Apache License 2.0
- opencv/opencv is licensed under the
Apache License 2.0

