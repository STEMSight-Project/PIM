# 📝 Copilot Instructions Update - October 2025

## ✅ Update Summary

Added comprehensive documentation to `.github/instructions/copilot-instructions.md` covering all recent streaming architecture work.

### 📊 Changes

- **Before:** 866 lines
- **After:** 1012 lines
- **Added:** 146 lines of new documentation

### 📚 New Section Added: "🎥 Recent Updates: Ambulance Streaming Architecture (October 2025)"

## 🎯 What Was Documented

### 1. Database Migration (Patient → Ambulance Model)

**New Tables:**
- `ambulances` - Ambulance records
- `ambulance_cameras` - Multiple cameras per ambulance
- `ambulance_streaming_sessions` - Active streaming sessions
- `ambulance_camera_rooms` - WebRTC room tracking

**Key Change:**
- Migrated from patient-based to ambulance-based streaming
- Room IDs now: `AMB-{number}-ROOM-{number}`
- Use `/ambulance-streaming/*` endpoints

### 2. Backend API Structure

**Documented Endpoints:**
- Session management (`POST/GET /ambulance-streaming/ambulance-sessions`)
- Room management (`POST/GET /ambulance-streaming/camera-rooms`)
- WebRTC streaming (`/camera/{room_id}/streamer` and `/viewer`)
- Real-time SSE (`/realtime/sessions` and `/realtime/rooms`)

**Service Layer:**
- `Room` class - WebRTC connection management
- `SessionService` - Session lifecycle management
- Auto-update room.connected status

### 3. Frontend Real-time Updates

**SSE Integration:**
- Event type parsing fix documented
- Correct field: `eventData.event` (not `eventData.type`)
- Event structure: `{type: "database_change", event: "UPDATE", new: {...}}`

**Video Data Timeout:**
- 2-second timeout implementation
- Video element event listeners (loadeddata, playing)
- UI feedback for waiting/disconnected states

### 4. Raspberry Pi Broadcaster

**Single Camera Broadcaster:**
- File: `Raspberry-Pi/rpi_broadcaster.py`
- Matches main broadcaster logic
- 3-retry connection strategy
- V4L2 optimization for RPi cameras
- Configuration file support

**Setup Process:**
- `one_time_setup.sh` automated deployment
- Systemd service configuration
- Configuration wizard
- Helper scripts (start, stop, status)

### 5. Testing & Documentation

**Files Created:**
- `QUICK_REFERENCE.md` - Quick start guide
- `TESTING_GUIDE.md` - Comprehensive testing
- `FILE_ORGANIZATION.md` - File structure
- `INDEX.md` - Navigation entry point
- `test_broadcaster.ps1` - Automated pre-flight checks

### 6. Key Implementation Lessons

**Bug Fixes Documented:**
1. **Event Type Parsing:**
   - Problem: SSE updates not working
   - Root cause: Field name mismatch
   - Solution: Check `eventData.event` field

2. **Video Data Timeout:**
   - Problem: No feedback when stream connected but no data
   - Solution: 2-second timeout with video element listeners

3. **Room vs Session Lifecycle:**
   - Sessions created/ended by RPi devices
   - Rooms have connected status based on peer connections
   - Frontend only watches, never creates/ends sessions

### 7. Migration Checklist

**Important Guidelines:**
- ✅ Use `ambulance_id` not `patient_id`
- ✅ Use `/ambulance-streaming/*` endpoints
- ✅ Check `eventData.event` for SSE event types
- ✅ Room IDs format: `AMB-{number}-ROOM-{number}`
- ✅ Frontend uses "Watch" terminology, not "Stream"
- ✅ RPi broadcaster creates sessions, frontend only views

### 8. Deployment Workflows

**Production (Raspberry Pi):**
```bash
scp one_time_setup.sh pi@raspberrypi.local:/home/pi/
ssh pi@raspberrypi.local
sudo ./one_time_setup.sh
```

**Development (Windows):**
```powershell
.\test_broadcaster.ps1
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements-rpi.txt
python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
```

## 🎯 Benefits for Future Development

### For AI Assistants (GitHub Copilot, etc.)

Now AI tools will understand:
1. **Ambulance-based architecture** - No more patient-based streaming suggestions
2. **Correct event structure** - Proper SSE event handling
3. **Room lifecycle** - Proper connection status management
4. **RPi deployment** - Complete setup and testing procedures
5. **Testing patterns** - Pre-flight checks and validation
6. **Migration path** - Clear guidelines for new features

### For Human Developers

Quick reference for:
- Database schema changes
- API endpoint structure
- Real-time update patterns
- Raspberry Pi deployment
- Testing procedures
- Common bugs and solutions

### For Code Reviews

Clear documentation of:
- Architectural decisions
- Known issues and fixes
- Testing requirements
- Deployment procedures

## 📋 What's NOT Included (Intentionally)

As requested, **multi-camera streaming** is NOT yet documented in copilot instructions:
- `rpi_multi_broadcaster.py` usage
- Multi-camera configuration
- Multi-camera architecture decisions

This will be added after multi-camera implementation is finalized.

## ✅ Verification

**File Status:**
- ✅ Updated: `.github/instructions/copilot-instructions.md`
- ✅ Lines added: 146
- ✅ Total lines: 1012
- ✅ All critical implementations documented
- ✅ Bug fixes and solutions included
- ✅ Migration guidelines clear
- ✅ Testing procedures documented

## 🚀 Next Steps

1. ✅ Copilot instructions updated
2. ⬜ Implement multi-camera streaming (when ready)
3. ⬜ Update copilot instructions with multi-camera details
4. ⬜ Add performance optimization guidelines

---

**Status: Documentation Complete** ✨

All recent streaming architecture work is now properly documented in the copilot instructions file, ensuring AI assistants stay in sync with the current project state.
