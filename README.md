# STEMSight PIM — Posture Intelligence Monitoring  

![Project Logo](https://github.com/user-attachments/assets/f02eda1f-1769-4865-ad06-d2790e286197)

---

## 🧠 Project Description  

**STEMSight PIM** (Posture Intelligence Monitoring) is a **real-time AI application** designed to detect and classify abnormal postures and involuntary movements from live video streams. Using camera modules on Raspberry Pi 4 edge devices, the system analyzes patient movement through MediaPipe pose estimation and custom PyTorch neural networks.  

The application was developed to assist **healthcare providers and first responders** by automatically identifying potential neurological distress during **patient transport in ambulances**. It delivers instant visual feedback and alerts through a **Next.js dashboard**, allowing remote clinicians to monitor multiple live camera feeds securely and efficiently.  

---

## 🎯 Purpose  

This system was created to address a critical gap in emergency medicine: **early detection of neurological postures** during patient transport, where every second matters.  
By combining **edge computing**, **computer vision**, and **machine learning**, PIM aims to provide continuous, privacy-preserving monitoring without requiring manual supervision — reducing diagnostic delays and enabling faster intervention.

---

## 📸 Screenshots  

| Description | Screenshot |
|-------------|-------------|
| **Dashboard Overview** – Displays live streaming sessions from multiple Raspberry Pi cameras. | ![Dashboard Screenshot](https://github.com/user-attachments/assets/e4975e16-84d4-41da-bfce-4849d732eb41) |
| **Detection Panel** – AI-powered posture/movement classification with confidence scoring. | ![Detection Panel](https://github.com/user-attachments/assets/43201b92-210f-4900-939d-03bf0cce1743) |
| **Patient Profiles** – View detection history, session stats, and medical data. | ![Patient Profiles](https://github.com/user-attachments/assets/1226fefd-6a3a-4371-8f7d-307c578d7746) |
| **Edge Stream Simulation** – Backend test running with WebRTC video input. | ![Edge Stream](https://github.com/user-attachments/assets/76ff5830-a69b-439e-a7cb-7c2a36e87457) |
| **AI Model Inference Output** – Example classification of posture sequence. | ![AI Output](https://github.com/user-attachments/assets/3cda8c3a-1f19-468b-acfb-10ee6441a871) |

---

## 👥 Team Members  

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

---

## 🧪 Testing  

### Automated Testing  

**Backend (FastAPI):**  

```bash
cd Back-End
pytest
```

**Frontend (Next.js):**

```bash
cd Front-End
npm test
```

### Manual Streaming Tests

Use `broadcaster.py` to simulate live camera feeds:

```bash
cd Back-End/Testing_files
python broadcaster.py --room test_room --video_device "Logitech BRIO"
```

For real Raspberry Pi devices:

```bash
cd Raspberry-Pi
python3 pose_model_capture.py --device camera_module
```

These tests verify **pose detection**, **Supabase data writes**, and **streaming stability**.

---

## ⚙️ Download, Setup & Run

1. **Clone the repository**

   ```bash
   git clone https://github.com/STEMSight-Project/PIM.git
   cd PIM
   ```

2. **Backend Setup**

   ```bash
   cd Back-End
   pip install -r requirements.txt
   cp .env.example .env   # update Supabase credentials
   uvicorn main:app --reload
   # http://localhost:8000/docs
   ```

3. **Frontend Setup**

   ```bash
   cd Front-End
   npm install
   npm run dev
   # http://localhost:3000
   ```

4. **Raspberry Pi Setup**

   ```bash
   cd Raspberry-Pi
   pip install -r requirements-rpi.txt
   python3 pose_model_capture.py --device camera_module
   ```

5. **Optional Cloud Deploy**

   * Backend: Deploy FastAPI on **Azure** or **AWS Lambda + API Gateway**
   * Frontend: Deploy on **Vercel/Netlify**
   * Database: Supabase or hosted PostgreSQL

---

## 🏗️ System Architecture

```
┌─────────────────┐    ┌──────────────────────┐    ┌──────────────────┐
│ Raspberry Pi 4  │    │ FastAPI Backend      │    │ Next.js Frontend │
│ • Camera module │───▶│ • REST/WebSocket API │───▶│ • AI Dashboard   │
│ • MediaPipe/AI  │    │ • ML inference       │    │ • Live streaming │
│ • WebRTC stream │    │ • DB (Supabase)      │    │ • Camera mgmt    │
└─────────────────┘    └──────────────────────┘    └──────────────────┘
```

### Core Components

| Component              | Technology                    | Purpose                                          |
| ---------------------- | ----------------------------- | ------------------------------------------------ |
| **RPi 4 Edge**         | Python, MediaPipe, PyTorch    | Local pose detection & streaming                 |
| **Backend API**        | FastAPI, Supabase/PostgreSQL  | Device/session APIs, inference services, storage |
| **Frontend Dashboard** | Next.js 15, React, TypeScript | Multi-camera live monitoring & analytics         |

---

## 🔄 Data Flow

1. **RPi auto-starts session →** captures frames.
2. **Local CV/AI →** MediaPipe landmarks + edge inference.
3. **Stream + results →** FastAPI via WebRTC/REST; persisted to DB.
4. **Dashboard →** real-time views + analytics.

---

## 📬 API Pattern

```ts
// Unified response contract
interface ApiResponse<T> {
  data: T | null;
  error: string | null;
  status?: number;
}

// Usage example
const res = await patientService.getById(patientId);
if (res.data) { /* handle success */ } else { /* handle error */ }
```

---

## 🌐 Deployment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Edge Devices    │    │ Cloud Backend   │    │ Web Frontend    │
│ (RPi 4)         │───▶│ AWS/Azure (API) │───▶│ Vercel/Netlify  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                       ┌─────────────────┐
                       │ Database        │
                       │ Supabase/Postgres
                       └─────────────────┘
```

---

## ⚙️ Troubleshooting

* **CORS errors:** Add your frontend origin to backend CORS settings.
* **WebRTC not connecting:** Check camera permissions and HTTPS on prod.
* **DB issues:** Verify Supabase keys/URL in `.env`.
* **Port mix-ups:** Backend runs on `8000`, Frontend on `3000`.

---

## 📚 Documentation Links

* **Backend (Local):** [http://localhost:8000/docs](http://localhost:8000/docs)
* **Frontend (Local):** [http://localhost:3000](http://localhost:3000)
* **Backend (Production):** [https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs](https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net/docs)
* **Frontend (Production):** [https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net](https://nextjsfrontend-c0cydrgwa3ckdxgp.westus3-01.azurewebsites.net)
* **Backend Docs:** `./Back-End/README.md`
* **Frontend Docs:** `./Front-End/README.md`
* **Raspberry Pi Docs:** `./Raspberry-Pi/README.md`
* **Dev Guidelines:** `./.github/instructions/copilot-instructions.md`

> Production links may be offline if not currently deployed.

---

## 📈 Future Roadmap

* [ ] Mobile companion app
* [ ] Model variants for specific conditions
* [ ] Hospital systems integration
* [ ] Real-time analytics & reporting
* [ ] Internationalization / localization

---

## 📜 Licenses

* **MediaPipe** — Apache 2.0
* **Supabase** — Apache 2.0
* **OpenCV** — Apache 2.0
* **This Repository** — *(add license type, e.g., MIT)*

---

## 🪞 Results & Future Improvements

* **Performance:** Real-time posture inference at ~20–25 FPS on RPi 4.
* **Accuracy:** Model achieves >85% balanced accuracy across posture classes (benchmarked on validation split).
* **Limitations:** Lighting and occlusion affect precision; future work includes domain adaptation for varied ambulance conditions.
* **Next Steps:** Integrate hand landmark detection and refine multi-view fusion for 360° coverage.

---

© 2025 STEMSight Project – California State University, Sacramento
