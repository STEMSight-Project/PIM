# 🎥 Raspberry Pi Broadcaster - START HERE

## 🚀 New User? Quick Start in 3 Steps

### Step 1: Read Quick Reference
**Open: [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md)**
- Quick start commands
- Common issues and fixes
- Testing instructions

### Step 2: Run Pre-Flight Check (Windows Only)
```powershell
.\test_broadcaster.ps1
```

### Step 3: Choose Your Path

#### 🆕 First-Time Raspberry Pi Setup
```bash
# Upload and run automated setup
scp one_time_setup.sh pi@raspberrypi.local:/home/pi/
ssh pi@raspberrypi.local "chmod +x one_time_setup.sh && sudo ./one_time_setup.sh"
```
**✅ Done! Service starts automatically on boot.**

#### 💻 Windows Development Testing
```powershell
# Setup environment
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements-rpi.txt

# Test single camera
python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"

# Test multi-camera
python rpi_multi_broadcaster.py --config config\multi_camera_config.json
```

#### 🎥 Multi-Camera Setup
**Read: [`MULTI_CAMERA_SETUP.md`](MULTI_CAMERA_SETUP.md)**

## 📚 Complete Documentation Index

| Document | Purpose | Who Should Read |
|----------|---------|-----------------|
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** ⭐ | Quick start & commands | **Everyone - START HERE** |
| [TESTING_GUIDE.md](TESTING_GUIDE.md) | Comprehensive testing | Developers, QA |
| [MULTI_CAMERA_SETUP.md](MULTI_CAMERA_SETUP.md) | Multi-camera architecture | Multi-camera deployments |
| [FILE_ORGANIZATION.md](FILE_ORGANIZATION.md) | File purpose & structure | Maintainers, new developers |
| [README.md](README.md) | Project overview | General information |
| [CLEANUP_COMPLETE.md](CLEANUP_COMPLETE.md) | Cleanup summary | Code reviewers |

## 🎯 Common Tasks

### I want to...

**...test on my Windows computer**
1. Run `.\test_broadcaster.ps1`
2. Read `QUICK_REFERENCE.md` → "Testing on Windows"
3. Follow Step 2-4 in the quick start section

**...deploy to a new Raspberry Pi**
1. Upload `one_time_setup.sh`
2. Run `sudo ./one_time_setup.sh`
3. Service starts automatically

**...set up multiple cameras**
1. Read `MULTI_CAMERA_SETUP.md`
2. Copy `config/multi_camera_config.example.json`
3. Run `rpi_multi_broadcaster.py`

**...troubleshoot an issue**
1. Check `TESTING_GUIDE.md` → "Common Issues"
2. Check systemd logs: `sudo journalctl -u stemsight-broadcaster.service -f`
3. Verify environment: `.\test_broadcaster.ps1`

**...update configuration**
1. Edit files in `config/` directory
2. Restart service: `sudo systemctl restart stemsight-broadcaster.service`
3. Or re-run `setup_config.py`

**...understand the file structure**
1. Read `FILE_ORGANIZATION.md`
2. See directory tree and file purposes

## 📦 Core Files Reference

| File | Use Case | Command |
|------|----------|---------|
| `rpi_broadcaster.py` | Single camera | `python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device "Camera"` |
| `rpi_multi_broadcaster.py` | Multi-camera | `python rpi_multi_broadcaster.py --config config/multi_camera_config.json` |
| `one_time_setup.sh` | First setup | `sudo ./one_time_setup.sh` |
| `test_broadcaster.ps1` | Environment check | `.\test_broadcaster.ps1` |

## 🆘 Quick Troubleshooting

### Backend not running
```powershell
cd ..\Back-End
uvicorn main:app --reload
```

### Frontend not running
```powershell
cd ..\Front-End
npm run dev
```

### Camera not detected
```powershell
# List cameras
ffmpeg -list_devices true -f dshow -i dummy
```

### Dependencies missing
```powershell
.\venv\Scripts\Activate.ps1
pip install -r requirements-rpi.txt
```

## ✅ Environment Status

Run `.\test_broadcaster.ps1` to check:
- ✅ Backend running (port 8000)
- ✅ Frontend running (port 3000)
- ✅ Python virtual environment
- ✅ FFMPEG installed

## 🎓 Learning Path

### Beginner
1. Read `QUICK_REFERENCE.md`
2. Run `test_broadcaster.ps1`
3. Test single camera on Windows

### Intermediate
1. Deploy to Raspberry Pi with `one_time_setup.sh`
2. Read `TESTING_GUIDE.md`
3. Configure systemd service

### Advanced
1. Read `MULTI_CAMERA_SETUP.md`
2. Deploy multi-camera setup
3. Optimize performance settings

## 📞 Support Resources

- **Quick answers**: `QUICK_REFERENCE.md`
- **Detailed testing**: `TESTING_GUIDE.md`
- **Multi-camera**: `MULTI_CAMERA_SETUP.md`
- **File reference**: `FILE_ORGANIZATION.md`
- **Backend API**: `http://localhost:8000/docs`

---

## 🎉 Current Status

✨ **All files cleaned and organized**
📚 **5 comprehensive documentation guides**
🧪 **Automated testing tools included**
🚀 **Ready for production deployment**

**Start with:** [`QUICK_REFERENCE.md`](QUICK_REFERENCE.md) ⭐
