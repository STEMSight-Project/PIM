# PIM Broadcaster Clean - Quick Reference

## 🚀 Quick Start Commands

```bash
# 1. Start Backend (Terminal 1)
cd "C:\Users\Mike\PIM Detector\PIM"
.\.venv\Scripts\Activate.ps1
# Backend should already be running on http://localhost:8000

# 2. Start Frontend (Terminal 2)
# Frontend should already be running on http://localhost:3000

# 3. Start PIM Broadcaster (Terminal 3)
cd "Back-End\Testing_files"
python pim_broadcaster_clean.py --room "test-patient" --video_device "Logitech HD Webcam C525"

# 4. Connect Frontend
# Open: http://localhost:3000/streaming-test
# Click: "Connect via Backend API"
```

## 🎯 Essential Files

| File                            | Purpose                                 | Status  |
| ------------------------------- | --------------------------------------- | ------- |
| `pim_broadcaster_clean.py`      | **Main broadcaster** - Production ready | ✅ Keep |
| `ultra_simple_pim_broadcast.py` | PIM model reference test                | ✅ Keep |
| `broadcaster.py`                | Original WebRTC framework               | ✅ Keep |
| `BROADCASTER_USAGE.md`          | Original broadcaster docs               | ✅ Keep |
| `save_stream.py`                | Stream recording utility                | ✅ Keep |

## 🧠 PIM AI Model

**Architecture**: JointBoneEnsembleLSTM  
**Input**: 30 frames × 33 keypoints × 3D coordinates  
**Output**: 9 movement classifications + confidence  
**Model File**: `../models/pim_model_joint_bone.pth`

**Movement Classes**:

```python
['decorticate', 'dystonia', 'chorea', 'myoclonus',
 'decerebrate', 'fencer posture', 'ballistic',
 'tremor', 'versive head']
```

## 🔧 Configuration Options

```bash
# Required
--room "unique-room-id"              # Room identifier

# Optional
--video_device "Logitech HD Webcam C525"  # Camera device
--device_name "CleanPIM-Broadcaster"      # Broadcaster name
--signaling "http://localhost:8000"       # Backend URL
```

## 🌐 Network Flow

```
Broadcaster → Backend API → Frontend Dashboard
     ↓           ↓              ↓
Camera      Room Creation    Live Video
AI Model    Session Mgmt     Detection UI
WebRTC      Database         Controls
```

## 🐛 Common Issues & Solutions

| Issue                     | Solution                                           |
| ------------------------- | -------------------------------------------------- |
| "No active room found"    | Restart broadcaster, check room ID                 |
| Camera access error       | Close other apps using camera                      |
| Model loading error       | Verify `../models/pim_model_joint_bone.pth` exists |
| Backend connection error  | Ensure FastAPI running on port 8000                |
| Frontend connection fails | Use "Backend API" not "Direct" connection          |

## 📊 Success Indicators

✅ **Broadcaster Logs**:

```
INFO:pim_broadcaster:✅ PIM Model loaded: ['decorticate', 'dystonia', ...]
INFO:pim_broadcaster:✅ Room created: {'room_id': '...'}
INFO:pim_broadcaster:🎥 PIM Broadcasting active
```

✅ **Frontend Connection**:

- Status shows "Connected" (green)
- Video stream visible
- PIM detection overlays appearing

## 🔄 Development Workflow

1. **Backend**: `uvicorn main:app --reload` (port 8000)
2. **Frontend**: `npm run dev` (port 3000)
3. **Broadcaster**: `python pim_broadcaster_clean.py --room "dev-test"`
4. **Test**: Visit `http://localhost:3000/streaming-test`

## 📁 Project Structure

```
Back-End/Testing_files/
├── pim_broadcaster_clean.py     # 🎯 Main broadcaster
├── PIM_BROADCASTER_CLEAN_USAGE.md  # 📚 Full documentation
├── broadcaster.py               # 🔧 WebRTC framework
├── ultra_simple_pim_broadcast.py   # 🧪 Model test
└── save_stream.py              # 💾 Recording utility

Front-End/src/
├── app/streaming-test/          # 🧪 Test interface
├── hooks/useStreamingEnhanced.ts   # 🔗 Connection hook
└── services/streamingService.ts     # 🌐 API client
```

## 🎥 Camera Compatibility

**Tested Devices**:

- `"Logitech HD Webcam C525"` ✅
- `"Logitech BRIO"` ✅
- `"0"` (default camera) ✅

**Device Detection**:

```bash
# List available cameras
python -c "import cv2; [print(f'{i}: {cv2.VideoCapture(i).getBackendName()}') for i in range(5)]"
```

## 🚨 Production Checklist

- [ ] Backend running and accessible
- [ ] Database connections working
- [ ] Camera permissions granted
- [ ] Model file present and loadable
- [ ] Network firewall configured
- [ ] Logging configured for production
- [ ] Error handling and recovery tested
- [ ] Performance monitoring in place

---

**For full documentation**, see: `PIM_BROADCASTER_CLEAN_USAGE.md`
