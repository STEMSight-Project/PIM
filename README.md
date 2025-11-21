# STEMSight PIM — Posture Involuntary Movement  

![Project Logo](https://github.com/user-attachments/assets/f02eda1f-1769-4865-ad06-d2790e286197)

---

## 🧠 Project Description  

**STEMSight PIM** is a **real-time AI application** designed to detect and classify abnormal postures and involuntary movements from live video streams. Using camera modules on Raspberry Pi 4 edge devices, the system analyzes patient movement through MediaPipe pose estimation and custom PyTorch neural networks.  

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
 main dashboard <img width="1307" height="866" alt="image" src="https://github.com/user-attachments/assets/77e40c0a-d051-4c48-95ba-0617de66d790" />

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

# STEMSight PIM - Verified Test Command Reference

This appendix lists all test execution commands and environments drawn directly from the System Test Report for **Project PIM (iddCuties Team)**.

---

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

---

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

---

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

---

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

---

## ⚙️ 3rd-Party Back-End Testing Libraries

* pytest ≥ 7.4.0
* pytest-asyncio ≥ 0.21.0
* pytest-cov ≥ 4.1.0
* pytest-mock ≥ 3.11.0

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

# 🚀 Deployment Appendix (Azure)

This app deploys **both** Frontend (Next.js) and Backend (FastAPI) to **Azure App Service** and uses **Supabase (PostgreSQL)** for data/storage. Raspberry Pi devices stream to the backend over WebRTC/REST.

---

## 🧩 Prerequisites

- Azure subscription + Azure CLI:
  
  ```bash
  az login
  az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
  ```

- **Backend**: Python 3.11, `uvicorn`, `requirements.txt`
- **Frontend**: Node 18+, `npm run build` succeeds locally
- **Supabase**: Project URL + keys (Anon and/or Service Role)

---

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

---

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

---

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

---

## 🔐 CORS, WebSockets & HTTPS

* Add frontend origins to backend `CORS_ORIGINS`.
* Enable WebSockets: Azure Portal → App Settings → **Web sockets ON**.
* Always use HTTPS for camera/mic access.

---

## 🧪 Post-Deployment Checks

1. Verify backend health at `/docs` endpoint.
2. Check that frontend `NEXT_PUBLIC_API_BASE_URL` points to production backend.
3. Confirm WebRTC streams connect and predictions appear.
4. Optionally simulate an ambulance camera stream:

   ```bash
   cd Back-End/Testing_files
   python broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
   ```

---

## 🧱 Optional: Deployment Slots

Create a staging slot:

```bash
az webapp deployment slot create -g pim-rg -n fastapibackend-amfucydqayg9h8gb --slot staging
```

Swap after validation:

```bash
az webapp deployment slot swap -g pim-rg -n fastapibackend-amfucydqayg9h8gb --slot staging
```

---

## 🧩 Common Issues

| Issue                        | Fix                                    |
| ---------------------------- | -------------------------------------- |
| **409 Conflict**             | Cancel concurrent deploys or use slots |
| **WebRTC not connecting**    | Enable WebSockets, check CORS & HTTPS  |
| **FFmpeg missing**           | Custom container or static binary      |
| **Environment vars ignored** | Restart the Web App                    |

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
