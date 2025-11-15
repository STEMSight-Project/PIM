# MediaPipe Skeleton Overlay - Implementation Complete ✅

## Overview

Successfully implemented **real-time MediaPipe skeleton overlay** for livestream video with the following architecture:

- **Backend**: MediaPipe Pose landmark extraction + WebRTC data channel transmission
- **Frontend**: Canvas-based skeleton rendering with toggle controls
- **Performance**: Client-side rendering, processes every 2nd frame for efficiency

---

## ✅ Completed Components

### 1. Backend: `Back-End/Testing_files/broadcaster.py`

**Changes Made**:

- ✅ Added MediaPipe Pose imports (`cv2`, `numpy`, `mediapipe`, `av.VideoFrame`)
- ✅ Created `MediaPipePoseProcessor` class
  - Initializes MediaPipe Pose with `model_complexity=2`
  - Processes every 2nd frame for performance
  - Extracts 33 pose landmarks with x, y, z, visibility
  - Handles frame conversion (RGB ↔ BGR) for MediaPipe
- ✅ Created `VideoTransformTrack` class
  - Wraps original video stream
  - Calls pose processor on each frame
  - Sends landmarks via data channel as JSON
- ✅ Added data channel creation (`"pose_landmarks"`)
  - Opens channel before adding video track
  - Sends landmark data with type + landmarks array
  - Includes open/close event handlers with logging
- ✅ Added cleanup in finally block (`pose_processor.close()`)

**Key Code Sections**:

```python
# Lines 313-368: MediaPipePoseProcessor class
class MediaPipePoseProcessor:
    def __init__(self):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=2,  # Heavy model for best accuracy
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7,
        )
        self.frame_count = 0

    def process_frame(self, frame):
        """Extract pose landmarks from video frame."""
        self.frame_count += 1

        # Process every 2nd frame for performance
        if self.frame_count % 2 != 0:
            return None

        # Convert BGR to RGB for MediaPipe
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(rgb_frame)

        if results.pose_landmarks:
            # Extract landmarks as list of dicts
            landmarks = []
            for lm in results.pose_landmarks.landmark:
                landmarks.append({
                    "x": lm.x,
                    "y": lm.y,
                    "z": lm.z,
                    "visibility": lm.visibility,
                })
            return landmarks
        return None

# Lines 425-495: Data channel + VideoTransformTrack integration
# Create data channel for pose landmarks
data_channel = pc.createDataChannel("pose_landmarks")
logger.info("Created data channel: pose_landmarks")

@data_channel.on("open")
def on_open():
    logger.info("✅ Data channel opened - ready to send pose landmarks")

@data_channel.on("close")
def on_close():
    logger.info("🔒 Data channel closed")

# Create pose processor
pose_processor = MediaPipePoseProcessor()

# Wrap video track with transformer
video_track = VideoTransformTrack(player.video, pose_processor, data_channel)
pc.addTrack(video_track)
```

### 2. Frontend Hook: `Front-End/src/hooks/useStreaming.ts`

**Changes Made**:

- ✅ Added `poseLandmarks` state: `useState<any[] | null>(null)`
- ✅ Updated `UseStreamingReturn` interface to include `poseLandmarks`
- ✅ Added `pc.ondatachannel` handler in `createPeerConnection`
  - Listens for "pose_landmarks" channel
  - Parses JSON messages
  - Updates `poseLandmarks` state with landmark data
  - Clears landmarks on channel close
- ✅ Returns `poseLandmarks` in hook's return object

**Key Code Sections**:

```typescript
// Line 132: Added state
const [poseLandmarks, setPoseLandmarks] = useState<any[] | null>(null);

// Lines 768-803: Data channel handler
pc.ondatachannel = (event) => {
  console.log("📡 [DATA-CHANNEL] Received data channel:", event.channel.label);

  if (event.channel.label === "pose_landmarks") {
    const dataChannel = event.channel;

    dataChannel.onopen = () => {
      console.log("✅ [DATA-CHANNEL] Pose landmarks channel opened");
    };

    dataChannel.onmessage = (messageEvent) => {
      try {
        const data = JSON.parse(messageEvent.data);
        if (data.type === "pose_landmarks") {
          setPoseLandmarks(data.landmarks);
        }
      } catch (err) {
        console.error("❌ [DATA-CHANNEL] Failed to parse message:", err);
      }
    };

    dataChannel.onerror = (error) => {
      console.error("❌ [DATA-CHANNEL] Error:", error);
    };

    dataChannel.onclose = () => {
      console.log("🔒 [DATA-CHANNEL] Pose landmarks channel closed");
      setPoseLandmarks(null);
    };
  }
};

// Line 1509: Return poseLandmarks
return {
  // ... other properties
  poseLandmarks, // NEW
};
```

### 3. UI Component: `Front-End/src/components/HybridStreamPlayer.tsx`

**Changes Made**:

- ✅ Added imports: `SkeletonOverlay`, `EyeIcon`, `EyeSlashIcon`
- ✅ Added `skeletonEnabled` state: `useState(false)`
- ✅ Destructured `poseLandmarks` from `useStreaming()` hook
- ✅ Wrapped live video element with container div
- ✅ Added `<SkeletonOverlay>` component below video element
  - Passes `videoRef={liveVideoRef}`
  - Passes `landmarks={poseLandmarks}`
  - Passes `enabled={skeletonEnabled}`
- ✅ Added skeleton toggle button in controls section
  - Only shows in "live" mode (not playback)
  - Icon changes: EyeIcon (show) / EyeSlashIcon (hide)
  - Button style changes: green (enabled) / gray (disabled)
  - Text updates: "Show Skeleton" / "Hide Skeleton"

**Key Code Sections**:

```tsx
// Lines 42-44: Added state
const [skeletonEnabled, setSkeletonEnabled] = useState(false);

// Lines 46-65: Destructure poseLandmarks
const {
  videoRef: liveVideoRef,
  // ... other properties
  poseLandmarks, // NEW
} = useStreaming();

// Lines 347-365: Wrapped video with overlay
<div className={cn("relative", viewMode !== "live" && "hidden")}>
  <video
    ref={liveVideoRef}
    className="w-full h-full object-contain aspect-video"
    autoPlay
    playsInline
    muted={false}
  />
  <SkeletonOverlay
    videoRef={liveVideoRef}
    landmarks={poseLandmarks}
    enabled={skeletonEnabled}
  />
</div>;

// Lines 620-639: Toggle button
{
  viewMode === "live" && (
    <button
      onClick={() => setSkeletonEnabled(!skeletonEnabled)}
      className={cn(
        "flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold shadow-lg transition-all hover:scale-105",
        skeletonEnabled
          ? "bg-green-600 hover:bg-green-700 text-white"
          : "bg-gray-700 hover:bg-gray-600 text-gray-300"
      )}
      title={skeletonEnabled ? "Hide Skeleton" : "Show Skeleton"}
    >
      {skeletonEnabled ? (
        <EyeSlashIcon className="w-4 h-4" />
      ) : (
        <EyeIcon className="w-4 h-4" />
      )}
      <span>{skeletonEnabled ? "Hide" : "Show"} Skeleton</span>
    </button>
  );
}
```

### 4. Skeleton Renderer: `Front-End/src/components/SkeletonOverlay.tsx`

**Status**: ✅ Already created (previous step)

**Key Features**:

- Canvas-based rendering overlaid on video
- Draws 33 MediaPipe pose landmarks
- Connects joints with green lines (POSE_CONNECTIONS)
- Draws red dots for joint positions
- Visibility filtering (>0.5 threshold)
- Responsive sizing with ResizeObserver
- Fixed type signature to accept nullable video ref

---

## 🧪 Testing Instructions

### Step 1: Start Backend Broadcaster

```powershell
cd Back-End
python Testing_files/broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
```

**Expected Console Output**:

```
📹 Initializing MediaPipe Pose for skeleton detection...
✅ MediaPipe Pose initialized successfully
🎥 Starting camera broadcaster for AMB-001...
📡 Created data channel: pose_landmarks
✅ Data channel opened - ready to send pose landmarks
🎬 Streaming started successfully
```

### Step 2: Open Frontend Streaming Page

1. Navigate to: `http://localhost:3000/streamingDash`
2. Find your ambulance (AMB-001) and camera (ROOM-001)
3. Click "Start Watching" to connect to live stream

### Step 3: Enable Skeleton Overlay

1. Wait for video connection (should see live camera feed)
2. Look for "Show Skeleton" button in top-right controls
3. Click button to toggle skeleton visualization

**Expected Behavior**:

- ✅ Button changes to green "Hide Skeleton" when active
- ✅ Green lines appear connecting body joints
- ✅ Red dots appear at joint positions (hands, elbows, knees, etc.)
- ✅ Skeleton follows body movements in real-time
- ✅ Console shows: `📡 [DATA-CHANNEL] Received data channel: pose_landmarks`
- ✅ Console shows: `✅ [DATA-CHANNEL] Pose landmarks channel opened`

### Step 4: Verify Performance

**Browser Console Checks**:

```javascript
// Check data channel status
console.log("Landmarks received:", poseLandmarks !== null);

// Monitor frame rate (should be ~30 FPS for video, ~15 FPS for landmarks)
// Landmarks process every 2nd frame for efficiency
```

**Expected Performance**:

- Video FPS: ~30 FPS (normal WebRTC stream)
- Landmark updates: ~15 FPS (every 2nd frame)
- CPU usage: Minimal (client-side Canvas rendering)
- Network overhead: ~5-10 KB/s for landmark data

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Backend (broadcaster.py)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Camera → VideoTransformTrack → MediaPipePoseProcessor          │
│              │                         │                        │
│              │                         ↓                        │
│              │                  Extract Landmarks               │
│              │                  (every 2nd frame)               │
│              │                         │                        │
│              ↓                         ↓                        │
│        WebRTC Video Track      Data Channel "pose_landmarks"    │
│              │                         │                        │
└──────────────┼─────────────────────────┼───────────────────────┘
               │                         │
               │   WebRTC Connection     │
               │                         │
┌──────────────┼─────────────────────────┼───────────────────────┐
│              ↓                         ↓                        │
│      <video> element         useStreaming.poseLandmarks         │
│              │                         │                        │
│              └──────────┬──────────────┘                        │
│                         ↓                                       │
│              <SkeletonOverlay> Component                        │
│                         │                                       │
│                         ↓                                       │
│              Canvas rendering (green lines + red dots)          │
│                                                                 │
│                  Frontend (HybridStreamPlayer.tsx)              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Configuration Options

### MediaPipe Settings (broadcaster.py)

```python
# Current configuration (line 319-324)
self.pose = self.mp_pose.Pose(
    static_image_mode=False,        # Video mode (not single images)
    model_complexity=2,             # 0=Lite, 1=Full, 2=Heavy (best accuracy)
    min_detection_confidence=0.7,   # 70% confidence for detection
    min_tracking_confidence=0.7,    # 70% confidence for tracking
)

# Frame processing (line 331)
if self.frame_count % 2 != 0:  # Process every 2nd frame
```

**Tuning for Performance**:

- **High Performance**: `model_complexity=0`, process every 3rd frame
- **Balanced** (current): `model_complexity=2`, process every 2nd frame
- **High Accuracy**: `model_complexity=2`, process every frame

### Skeleton Rendering (SkeletonOverlay.tsx)

```typescript
// Current settings (lines 77-84)
ctx.strokeStyle = "#00ff00"; // Green lines
ctx.lineWidth = 2; // Line thickness

ctx.fillStyle = "#ff0000"; // Red dots
ctx.beginPath();
ctx.arc(x, y, 4, 0, 2 * Math.PI); // 4px radius joints
```

**Customization Options**:

- Change colors: `strokeStyle`, `fillStyle`
- Adjust thickness: `lineWidth` (1-5 recommended)
- Joint size: `arc()` radius (2-8px recommended)

---

## 🐛 Known Issues & Limitations

### Current Limitations

1. **Skeleton only in Live Mode**

   - Toggle button hidden during HLS playback
   - Skeleton data only transmitted via live WebRTC
   - **Reason**: HLS recordings don't include data channel

2. **MediaPipe Model Size**

   - Using `model_complexity=2` (~30 MB model)
   - First-time load may take 2-3 seconds
   - **Mitigation**: Model cached after first initialization

3. **Visibility Filtering**
   - Joints with visibility <0.5 not drawn
   - May cause flickering if person partially occluded
   - **Improvement**: Add smoothing/interpolation for missing joints

### Potential Improvements

1. **Performance Optimization**

   ```python
   # Switch to Lite model for low-end devices
   model_complexity=0  # Instead of 2

   # Reduce frame rate
   if self.frame_count % 3 != 0:  # Every 3rd frame instead of 2nd
   ```

2. **Enhanced Visualization**

   ```typescript
   // Add joint labels
   ctx.fillText("Left Hand", x, y - 10);

   // Color-code body parts
   const colors = {
     face: "#ffff00",
     torso: "#00ff00",
     arms: "#0000ff",
     legs: "#ff00ff",
   };
   ```

3. **Recording with Skeleton**
   - Store landmarks alongside HLS segments
   - Replay skeleton during HLS playback
   - Requires database schema changes

---

## 📝 Related Documentation

- **Implementation Guide**: `SKELETON_OVERLAY_GUIDE.md` (architectural overview)
- **Copilot Instructions**: `.github/instructions/copilot-instructions.md` (MediaPipe standards)
- **MediaPipe Docs**: https://developers.google.com/mediapipe/solutions/vision/pose_landmarker

---

## ✅ Final Checklist

- [x] Backend MediaPipe integration complete
- [x] WebRTC data channel configured
- [x] Frontend hook receives landmarks
- [x] Skeleton overlay component functional
- [x] Toggle button UI implemented
- [x] Type errors resolved
- [x] Documentation complete
- [ ] End-to-end testing with camera (pending user verification)

---

## 🚀 Next Steps

1. **Test with Real Camera**:

   ```powershell
   python Back-End/Testing_files/broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"
   ```

2. **Verify Skeleton Rendering**:

   - Navigate to `http://localhost:3000/streamingDash`
   - Click "Start Watching" for AMB-001
   - Click "Show Skeleton" button
   - Confirm green lines and red dots appear

3. **Optional Enhancements**:
   - Add skeleton color customization in settings
   - Implement landmark smoothing for cleaner visualization
   - Add recording of skeleton data for playback mode

---

**Implementation Date**: December 2024  
**Status**: ✅ Complete - Ready for Testing  
**Backend Running**: ✅ Yes (FastAPI on http://localhost:8000)  
**Frontend Running**: ✅ Yes (Next.js on http://localhost:3000)
