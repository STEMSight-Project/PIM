# HLS Recording Flow: How Live Streams Become Videos

## 🎯 Overview

Live WebRTC streams are automatically converted to HLS (HTTP Live Streaming) videos and stored in Supabase. Here's the complete flow from camera connection to database storage.

---

## 📊 Complete Recording Pipeline

### 1. **Camera Connects (Broadcaster/RPi)**

```
RPi Device → POST /ambulance-streaming/camera/{room_id}/streamer
    ↓
Backend creates WebRTC connection (offer/answer)
    ↓
Room.add_peer_connection() adds streamer to room
    ↓
Triggers: _start_recording_when_track_ready()
```

**Code Location**: `services/streaming/room_service.py:448`

```python
# When streamer connects
if "streamer" in pc_type.lower():
    self.streamer_pcs.add(pc)
    # Trigger recording start
    asyncio.create_task(self._start_recording_when_track_ready())
```

### 2. **Recording Starts**

```
Wait for video track (up to 10 seconds, checking every 0.5s)
    ↓
Once video track available:
    ↓
recording_manager.start_session_recording()
    ↓
Creates SessionRecorder instance
    ↓
FFmpeg process starts with 2 outputs:
   1. HLS segments (segment-001.ts, segment-002.ts, etc.)
   2. MP4 file (recording.mp4)
```

**Code Location**: `services/streaming/recording_service.py:138-169`

**Recording Directory Structure**:

```
recordings/
└── room-{UUID}/              # e.g., room-8b502515-6668-4ef7-9993-4636e2bf668d/
    ├── playlist.m3u8         # HLS playlist (for live playback)
    ├── segment-001.ts        # 10-second segments
    ├── segment-002.ts
    ├── segment-003.ts
    └── recording.mp4         # Full MP4 (uploaded to Supabase)
```

**FFmpeg Command**:

```bash
ffmpeg \
  -f rawvideo -pixel_format yuv420p -video_size 640x480 -framerate 30 \
  -use_wallclock_as_timestamps 1 \
  -i pipe:0 \
  # HLS Output (live playback)
  -f hls -hls_time 10 -hls_list_size 0 \
  -hls_flags append_list+omit_endlist \
  -hls_segment_filename recordings/room-{UUID}/segment-%03d.ts \
  recordings/room-{UUID}/playlist.m3u8 \
  # MP4 Output (archive)
  -c:v libx264 -preset ultrafast -movflags +faststart \
  -f mp4 recordings/room-{UUID}/recording.mp4
```

### 3. **Live Streaming (During Recording)**

While recording is active:

```
WebRTC frames → FFmpeg stdin
    ↓
FFmpeg creates:
   - HLS segments every 10 seconds
   - MP4 file continuously written
    ↓
HLS Segment Monitor detects new segments
    ↓
Broadcasts SSE events to frontend
    ↓
Frontend HLS player fetches new segments
```

**Frontend can watch in real-time via**:

- HLS URL: `/videos/hls/{room_id}/playlist.m3u8`
- SSE updates: `/videos/hls/segments/{room_id}/events`

### 4. **Camera Disconnects**

```
Broadcaster disconnects WebRTC
    ↓
Room.remove_peer_connection() called
    ↓
Checks if last STREAMER disconnected:
   if len(streamer_pcs) == 0:
       ↓
       recording_manager.stop_session_recording(room_id)
```

**Code Location**: `services/streaming/room_service.py:485-500`

**CRITICAL**: Only **streamer** disconnection stops recording

- ✅ Streamer (RPi/broadcaster) disconnect → Stop recording
- ❌ Viewer (frontend) disconnect → Recording continues

### 5. **Recording Stops & Upload**

```
stop_session_recording()
    ↓
SessionRecorder.stop_recording()
    ↓
1. Stop frame processing task
2. Close FFmpeg stdin (signals FFmpeg to finish)
3. Wait for FFmpeg to complete
4. Stop HLS segment monitoring
5. Upload MP4 to Supabase Storage
6. Create database entry in ambulance_session_recordings
7. Clean up local HLS files
```

**Code Location**: `services/streaming/recording_service.py:334-390`

### 6. **Supabase Upload**

```
_upload_to_supabase_storage()
    ↓
1. Read recording.mp4 from disk
2. Upload to: recordings/{session_id}/{room_id}.mp4
3. Get public URL
4. Create database entry
```

**Database Entry** (`ambulance_session_recordings`):

```sql
INSERT INTO ambulance_session_recordings (
    session_id,        -- UUID of streaming session
    camera_id,         -- room_id (UUID)
    recording_path,    -- Local path: recordings/room-{UUID}
    storage_url,       -- Supabase public URL
    file_size,         -- Bytes
    duration,          -- Seconds
    session_start,     -- When recording started
    session_end,       -- When recording ended
    status             -- 'completed'
)
```

**Code Location**: `services/streaming/recording_service.py:470-550`

---

## ❓ Why Some Recordings Don't Show Up

### Common Issues:

#### 1. **Recording Never Started**

**Symptoms**: No recording folder created, no database entry
**Causes**:

- Video track never received within 10-second timeout
- FFmpeg failed to start
- WebRTC connection dropped before video track arrived

**Check Logs**:

```
❌ [RECORDING] Timeout waiting for video track for room {id}
```

**Debug**:

```bash
# Check if recording folder was created
ls recordings/

# Check FFmpeg errors
grep "FFmpeg" Back-End/logs/*.log
```

#### 2. **Recording Started But Not Uploaded**

**Symptoms**: HLS files exist locally, no database entry
**Causes**:

- FFmpeg process crashed during recording
- Upload to Supabase failed (network, auth, storage limit)
- Database insert failed

**Check Logs**:

```
❌ Failed to upload to Supabase: {error}
```

**Verify Files**:

```bash
# Check if MP4 exists
ls recordings/room-*/recording.mp4

# Check file size
du -sh recordings/room-*
```

#### 3. **Recording Uploaded But Not Visible**

**Symptoms**: Database entry exists, but not showing in frontend
**Causes**:

- Frontend querying wrong table/column
- Recording ID mismatch (UUID vs string)
- Status filter excluding completed recordings

**Check Database**:

```sql
-- See all recordings
SELECT * FROM ambulance_session_recordings
ORDER BY created_at DESC LIMIT 10;

-- Check specific session
SELECT * FROM ambulance_session_recordings
WHERE session_id = 'YOUR_SESSION_ID';
```

#### 4. **Recording Stopped Prematurely**

**Symptoms**: Very short recording duration
**Causes**:

- Streamer reconnected (triggers new recording, deletes old one)
- Session timeout (20 minutes no active cameras)
- Manual session end before stream finished

**Check Logs**:

```
🗑️ Removing existing recording directory: recordings/room-{id}
```

**IMPORTANT**: SessionRecorder **deletes existing folders** on initialization!

```python
# This happens EVERY time a new recording starts
def _cleanup_existing_directory(self):
    if self.recording_path.exists():
        shutil.rmtree(self.recording_path)  # ⚠️ Deletes everything!
```

---

## 🔍 Debugging Checklist

### Step 1: Verify Recording Started

```bash
# Check backend logs for recording start
grep "🎬 \[RECORDING\] Starting FFmpeg" logs/*.log

# Check if folder exists
ls recordings/room-*

# Should see:
# recordings/room-8b502515-6668-4ef7-9993-4636e2bf668d/
```

### Step 2: Verify FFmpeg Running

```bash
# Check if FFmpeg is processing frames
grep "Frame processing started" logs/*.log

# Check for FFmpeg errors
grep -i "ffmpeg.*error" logs/*.log
```

### Step 3: Verify Recording Stopped Cleanly

```bash
# Check for stop signal
grep "🛑 Stopping recording" logs/*.log

# Check FFmpeg finished
grep "FFmpeg finished" logs/*.log

# Should see code 0 for success
```

### Step 4: Verify Upload

```bash
# Check upload started
grep "📤 Uploading" logs/*.log

# Check upload succeeded
grep "✅ Upload complete" logs/*.log

# Check database entry created
grep "✅ Database entry created" logs/*.log
```

### Step 5: Query Database

```sql
-- Get latest recordings
SELECT
    id,
    session_id,
    camera_id,
    duration,
    file_size / (1024*1024) as size_mb,
    status,
    created_at
FROM ambulance_session_recordings
ORDER BY created_at DESC
LIMIT 10;

-- Check for specific camera
SELECT * FROM ambulance_session_recordings
WHERE camera_id = 'YOUR_ROOM_UUID';
```

---

## 🛠️ Common Fixes

### Fix 1: Increase Video Track Timeout

**Problem**: Recording never starts, timeout after 10 seconds

**Solution**: Increase wait time in `room_service.py:687`

```python
# Change from 20 to 40 (20 seconds total)
for i in range(40):  # Was: 20
    if self.video_track:
        # Start recording...
    await asyncio.sleep(0.5)
```

### Fix 2: Add Retry on Upload Failure

**Problem**: Upload fails due to network issues

**Solution**: Add retry logic in `recording_service.py:470`

```python
async def _upload_to_supabase_storage(self) -> Optional[str]:
    max_retries = 3
    for attempt in range(max_retries):
        try:
            # Upload code...
            return public_url
        except Exception as e:
            if attempt < max_retries - 1:
                await asyncio.sleep(5 * (attempt + 1))  # Backoff
                continue
            raise
```

### Fix 3: Don't Delete Existing Recordings

**Problem**: Reconnection deletes in-progress recording

**Solution**: Add timestamp to folder names in `recording_service.py:52`

```python
# Instead of just room_id, use timestamp
timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
self.recording_path = RECORDINGS_BASE_PATH / f"room-{room_id}-{timestamp}"
```

### Fix 4: Log More Details

**Problem**: Can't diagnose issues

**Solution**: Add more logging in critical sections

```python
# In stop_recording()
LOGGER.info(f"📊 Final stats: {self.frame_count} frames, {duration}s")
LOGGER.info(f"📁 MP4 size: {file_size_mb:.2f} MB")
LOGGER.info(f"🎯 Upload target: recordings/{self.session_id}/{self.room_id}.mp4")
```

---

## 📋 Recording Lifecycle Summary

| Stage                 | Location   | Duration | Output           |
| --------------------- | ---------- | -------- | ---------------- |
| **1. Wait for track** | Memory     | 0-10s    | None             |
| **2. Recording**      | Local disk | Variable | HLS + MP4        |
| **3. Upload**         | Network    | ~10-60s  | Supabase URL     |
| **4. Database**       | Supabase   | <1s      | DB entry         |
| **5. Cleanup**        | Local disk | <5s      | Delete HLS files |

**Total time from disconnect to database entry**: ~15-70 seconds

**Minimum recording length**: No minimum (can be 1 second)

**Maximum recording length**: No limit (stops when streamer disconnects or session times out)

---

## 🎯 Expected Behavior

### ✅ Successful Recording Flow:

```
1. Camera connects → Folder created
2. Video track received → FFmpeg starts
3. Frames processed → HLS segments + MP4 written
4. Camera disconnects → FFmpeg finishes
5. MP4 uploaded → Public URL generated
6. Database entry created → Recording visible in frontend
7. HLS files deleted → Disk space freed
```

### ❌ Failed Recording Flow:

```
1. Camera connects → Folder created
2. Video track timeout → No FFmpeg started
3. OR: FFmpeg crashes → Partial MP4 file
4. OR: Upload fails → MP4 exists locally only
5. OR: Database insert fails → Upload succeeded but not tracked
```

---

## 📝 Monitoring Commands

```bash
# Watch recordings folder
watch -n 1 'ls -lh recordings/room-*'

# Monitor FFmpeg processes
watch -n 1 'ps aux | grep ffmpeg'

# Tail backend logs
tail -f logs/backend.log | grep -i recording

# Check Supabase storage
# Visit: https://supabase.com/dashboard → Storage → ambulance-recordings
```

---

## 🔗 Key Files Reference

| File                                        | Purpose                            |
| ------------------------------------------- | ---------------------------------- |
| `services/streaming/recording_service.py`   | FFmpeg recording, upload, database |
| `services/streaming/room_service.py`        | WebRTC rooms, trigger recording    |
| `services/streaming/hls_segment_service.py` | Monitor HLS segments, SSE events   |
| `api_router/video.py`                       | HLS playback endpoints             |
| `api_router/ambulance_streaming.py`         | WebRTC signaling                   |

---

**Last Updated**: November 2025
**Status**: ✅ Recording system fully operational
