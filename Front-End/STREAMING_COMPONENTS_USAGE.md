# 🎥 Streaming Components - Usage Guide

## Overview
All streaming components now use **room-based architecture** instead of session-based. This matches the backend test player endpoints.

---

## ✅ Updated Components

### 1. **HLSPlayer** (Full-featured player)
**File:** `components/HLSPlayer.tsx`

**Props:**
```typescript
interface HLSPlayerProps {
  roomId: string | null;           // Room ID (e.g., "AMB-001-ROOM-001")
  autoPlay?: boolean;               // Default: false
  showControls?: boolean;           // Default: true
  showStatus?: boolean;             // Default: true
  showStats?: boolean;              // Default: false
  lowLatencyMode?: boolean;         // Default: false
  className?: string;
  debug?: boolean;
  onReady?: () => void;
  onError?: (error: string) => void;
}
```

**Usage:**
```tsx
import { HLSPlayer } from "@/components/HLSPlayer";

<HLSPlayer
  roomId="AMB-001-ROOM-001"
  autoPlay={false}
  showControls={true}
  showStatus={true}
  showStats={true}
  className="w-full"
/>
```

**Features:**
- ✅ Built-in controls and status display
- ✅ Real-time segment count updates
- ✅ Recording status polling
- ✅ Error recovery with retry button
- ✅ Live indicator when active

---

### 2. **HLSVideoPlayer** (Simple player)
**File:** `components/HLSVideoPlayer.tsx`

**Props:**
```typescript
interface HLSVideoPlayerProps {
  roomId: string | null;            // Room ID
  autoPlay?: boolean;               // Default: false
  controls?: boolean;               // Default: true (native controls)
  lowLatencyMode?: boolean;         // Default: false
  className?: string;
  aspectRatio?: string;             // Default: "aspect-video"
  onReady?: () => void;
  onError?: (error: string) => void;
}
```

**Usage:**
```tsx
import { HLSVideoPlayer } from "@/components/HLSVideoPlayer";

<HLSVideoPlayer
  roomId="AMB-001-ROOM-001"
  autoPlay={false}
  controls={true}
  className="w-full rounded-lg"
/>
```

**Features:**
- ✅ Minimal UI (just video element)
- ✅ Native browser controls
- ✅ Loading and error overlays
- ✅ Lightweight and fast

---

### 3. **HybridStreamPlayer** (Live + Playback)
**File:** `components/HybridStreamPlayer.tsx`

**Props:**
```typescript
interface HybridStreamPlayerProps {
  ambulanceId: string;              // Ambulance ID for live streaming
  roomId: string;                   // Room ID for both live and playback
  className?: string;
  showAdvancedControls?: boolean;   // Default: false (skip buttons)
  debug?: boolean;                  // Default: false
}
```

**Usage:**
```tsx
import { HybridStreamPlayer } from "@/components/HybridStreamPlayer";

<HybridStreamPlayer
  ambulanceId="AMB-001"
  roomId="AMB-001-ROOM-001"
  showAdvancedControls={true}
  debug={false}
/>
```

**Features:**
- ✅ Seamless switch between Live WebRTC and HLS Playback
- ✅ Timeline scrubbing with live edge indicator
- ✅ "Go Live" button to jump back to live
- ✅ Time-behind-live display
- ✅ Auto-start live streaming on mount
- ✅ DVR-style playback with seek controls

**View Modes:**
- **Live Mode**: WebRTC real-time streaming (low latency)
- **Playback Mode**: HLS recorded footage (seekable)

**User Flow:**
1. Component loads → Auto-starts **Live Mode**
2. User clicks **Pause** → Switches to **Playback Mode**
3. User scrubs timeline → Stays in **Playback Mode**
4. User clicks **Go Live** → Returns to **Live Mode**

---

## 🔄 Migration Guide

### Before (Session-based) ❌
```tsx
// OLD - Don't use this anymore
<HLSPlayer sessionId={currentSessionId} />
<HLSVideoPlayer sessionId={sessionId} />
<HybridStreamPlayer
  ambulanceId="AMB-001"
  sessionId={sessionId}
  roomId="AMB-001-ROOM-001"
/>
```

### After (Room-based) ✅
```tsx
// NEW - Use room ID directly
<HLSPlayer roomId={selectedRoomId} />
<HLSVideoPlayer roomId={roomId} />
<HybridStreamPlayer
  ambulanceId="AMB-001"
  roomId="AMB-001-ROOM-001"
/>
```

---

## 📡 Backend Endpoints Used

All components use these room-based endpoints:

```
GET  /videos/hls/{room_id}/playlist.m3u8  # HLS playlist
GET  /videos/hls/{room_id}/segment-*.ts   # HLS segments
GET  /videos/hls/{room_id}/status         # Recording status
GET  /videos/hls/list                     # List all recordings
```

**Example API Response:**
```json
{
  "room_id": "AMB-001-ROOM-001",
  "session_id": "uuid-here",
  "status": "recording",
  "is_active": true,
  "duration": 120,
  "segment_count": 60,
  "hls_ready": true,
  "playlist_url": "/videos/hls/AMB-001-ROOM-001/playlist.m3u8"
}
```

---

## 🎯 Recommended Usage

### For Simple Playback
Use **HLSVideoPlayer** when you just need a basic video player:
```tsx
<HLSVideoPlayer roomId={roomId} controls={true} />
```

### For Dashboard Monitoring
Use **HLSPlayer** when you need status info and statistics:
```tsx
<HLSPlayer
  roomId={roomId}
  showStatus={true}
  showStats={true}
/>
```

### For Live + Playback Hybrid
Use **HybridStreamPlayer** for the best user experience:
```tsx
<HybridStreamPlayer
  ambulanceId={ambulanceId}
  roomId={selectedRoomId}
/>
```

---

## 🧪 Testing

Test the updated components:

1. **Start Backend:**
   ```bash
   cd Back-End
   python -m uvicorn main:app --reload
   ```

2. **Start Frontend:**
   ```bash
   cd Front-End
   npm run dev
   ```

3. **Start Broadcaster:**
   ```bash
   cd Back-End/Testing_files
   python broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
   ```

4. **Test Playback:**
   - Go to: http://localhost:3000/streamingDash/AMB-001?room=AMB-001-ROOM-001
   - Toggle to "Playback (HLS)" mode
   - Should see recorded footage with controls

5. **Test Test Player:**
   - Go to: http://localhost:8000/api/videos/test-player/AMB-001-ROOM-001
   - Click "Check Playlist"
   - Click "Load Stream"

---

## 🐛 Troubleshooting

### "No recording available"
- Check if broadcaster is running
- Wait 10-15 seconds for FFmpeg to create playlist
- Check backend logs for recording errors

### "Playlist not found"
- Verify room ID is correct (e.g., "AMB-001-ROOM-001")
- Check recordings directory: `Back-End/recordings/room-{room_id}/`
- Ensure FFmpeg is installed and in PATH

### "HLS not supported"
- Update browser (Chrome 34+, Safari 8+, Firefox 42+)
- Check console for HLS.js errors
- Try native HLS in Safari

---

## 📚 Related Files

- `hooks/useHLS.ts` - HLS playback hook
- `hooks/useStreaming.ts` - WebRTC streaming hook
- `services/hlsService.ts` - HLS API service
- `api_router/video.py` - Backend HLS endpoints

---

**Last Updated:** 2025-10-28  
**Architecture:** Room-based (not session-based)  
**Status:** ✅ All components updated and tested
