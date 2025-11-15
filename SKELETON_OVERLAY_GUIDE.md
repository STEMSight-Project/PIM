# MediaPipe Skeleton Overlay Implementation Guide

## Overview

Add toggleable MediaPipe skeleton visualization on top of the live camera stream.

**Architecture**: Client-side rendering (recommended for performance)

- Backend extracts pose landmarks using MediaPipe
- Landmarks sent via WebRTC data channel (low bandwidth)
- Frontend draws skeleton using HTML5 Canvas
- Toggle on/off without reconnecting

---

## Step 1: Backend - Extract & Send Landmarks

### Modify `Back-End/Testing_files/broadcaster.py`

Add MediaPipe processing to the broadcaster:

```python
# Add at top of file
import mediapipe as mp
import json

# Add to publish() function - after MediaPlayer initialization
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(
    static_image_mode=False,
    model_complexity=2,  # Best accuracy
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7
)

# Create data channel for landmarks
data_channel = pc.createDataChannel("pose_landmarks")

@data_channel.on("open")
def on_datachannel_open():
    LOGGER.info("📡 Data channel opened for pose landmarks")

# Add frame processing loop (in the video track)
async def process_frame(frame):
    """Process each frame and extract landmarks"""
    # Convert frame to numpy array
    img = frame.to_ndarray(format="bgr24")

    # Run MediaPipe
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = pose.process(img_rgb)

    # Send landmarks via data channel if detected
    if results.pose_landmarks:
        landmarks = []
        for lm in results.pose_landmarks.landmark:
            landmarks.append({
                "x": lm.x,
                "y": lm.y,
                "z": lm.z,
                "visibility": lm.visibility
            })

        # Send as JSON
        if data_channel.readyState == "open":
            data_channel.send(json.dumps({
                "type": "pose_landmarks",
                "landmarks": landmarks,
                "timestamp": time.time()
            }))

    return frame  # Return original frame unchanged
```

**Note**: This adds ~10-20ms per frame on Raspberry Pi 4. For better performance, run at lower FPS (e.g., process every 2-3 frames).

---

## Step 2: Frontend - Receive & Display Skeleton

### Update `useStreaming` Hook

Modify `Front-End/src/hooks/useStreaming.ts`:

```typescript
// Add state for landmarks
const [poseLandmarks, setPoseLandmarks] = useState<any[] | null>(null);

// In createPeerConnection function, add data channel handler
pc.ondatachannel = (event) => {
  const channel = event.channel;

  if (channel.label === "pose_landmarks") {
    channel.onmessage = (evt) => {
      try {
        const data = JSON.parse(evt.data);
        if (data.type === "pose_landmarks") {
          setPoseLandmarks(data.landmarks);
        }
      } catch (err) {
        console.error("Failed to parse landmark data:", err);
      }
    };
  }
};

// Return landmarks in hook
return {
  // ... existing returns
  poseLandmarks,
};
```

### Update `HybridStreamPlayer` Component

Modify `Front-End/src/components/HybridStreamPlayer.tsx`:

```tsx
import { SkeletonOverlay } from "./SkeletonOverlay";
import { EyeIcon, EyeSlashIcon } from "@heroicons/react/24/outline";

// Add state for skeleton toggle
const [skeletonEnabled, setSkeletonEnabled] = useState(false);

// Get landmarks from useStreaming hook
const { poseLandmarks } = useStreaming();

// Add toggle button in controls section (after "Go Live" button)
<button
  onClick={() => setSkeletonEnabled(!skeletonEnabled)}
  className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold shadow-lg transition-all ${
    skeletonEnabled
      ? "bg-green-600 hover:bg-green-700 text-white"
      : "bg-gray-600 hover:bg-gray-700 text-white"
  }`}
  title={skeletonEnabled ? "Hide Skeleton" : "Show Skeleton"}
>
  {skeletonEnabled ? (
    <>
      <EyeSlashIcon className="w-4 h-4" />
      <span>Hide Skeleton</span>
    </>
  ) : (
    <>
      <EyeIcon className="w-4 h-4" />
      <span>Show Skeleton</span>
    </>
  )}
</button>

// Add SkeletonOverlay component inside video container
<div className="relative bg-black rounded-xl overflow-hidden shadow-2xl">
  {/* Live Video */}
  <video ref={liveVideoRef} ... />

  {/* HLS Video */}
  <video ref={hlsVideoRef} ... />

  {/* Skeleton Overlay - only show in live mode */}
  {viewMode === "live" && (
    <SkeletonOverlay
      videoRef={liveVideoRef}
      landmarks={poseLandmarks}
      enabled={skeletonEnabled}
    />
  )}

  {/* Other overlays... */}
</div>
```

---

## Step 3: Testing

### Backend Test

```bash
cd Back-End
python Testing_files/broadcaster.py --ambulance_number 001 --room 001
```

Check console for:

- ✅ "MediaPipe Pose initialized"
- ✅ "Data channel opened for pose landmarks"

### Frontend Test

1. Navigate to streaming page: `http://localhost:3000/streamingDash/AMB-001?room=AMB-001-ROOM-001`
2. Click "Show Skeleton" button
3. Should see green lines (bones) and red dots (joints) overlaid on video

---

## Performance Optimization

### Backend Options:

1. **Reduce processing frequency**:

```python
frame_count = 0
PROCESS_EVERY_N_FRAMES = 3  # Process every 3rd frame

if frame_count % PROCESS_EVERY_N_FRAMES == 0:
    # Run MediaPipe
    results = pose.process(img_rgb)
frame_count += 1
```

2. **Use lite model**:

```python
pose = mp_pose.Pose(
    model_complexity=0,  # Lite model (faster, less accurate)
    # ...
)
```

3. **Lower detection confidence**:

```python
pose = mp_pose.Pose(
    min_detection_confidence=0.5,  # Lower threshold
    min_tracking_confidence=0.5,
    # ...
)
```

### Frontend Options:

1. **Throttle rendering**:

```typescript
// Only update skeleton every 100ms
const [lastUpdate, setLastUpdate] = useState(0);

useEffect(() => {
  const now = Date.now();
  if (now - lastUpdate < 100) return; // Skip if too soon

  setLastUpdate(now);
  // Draw skeleton...
}, [poseLandmarks]);
```

2. **Reduce line width/quality**:

```typescript
ctx.lineWidth = 2; // Thinner lines
// Skip small landmarks
if (landmark.visibility < 0.7) continue;
```

---

## Troubleshooting

### No skeleton appears:

- Check browser console for landmark data: `console.log(poseLandmarks)`
- Verify data channel is open (backend logs)
- Ensure person is visible in camera frame

### Performance issues:

- Try `PROCESS_EVERY_N_FRAMES = 5` in backend
- Use `model_complexity=0` (lite model)
- Reduce video resolution in broadcaster

### Skeleton misaligned:

- Canvas size must match video display size
- Check `resizeObserver` in SkeletonOverlay
- Verify landmark coordinates are normalized (0-1 range)

---

## Alternative: Server-Side Overlay

If client-side is too complex, draw skeleton directly on video frames in broadcaster:

```python
import cv2

if results.pose_landmarks:
    # Draw skeleton on frame
    mp.solutions.drawing_utils.draw_landmarks(
        img,
        results.pose_landmarks,
        mp_pose.POSE_CONNECTIONS,
        mp.solutions.drawing_styles.get_default_pose_landmarks_style()
    )

# Return modified frame
return av.VideoFrame.from_ndarray(img, format="bgr24")
```

**Pros**: Simple, works everywhere
**Cons**: Higher CPU usage, can't toggle without reconnecting, baked into video

---

## Future Enhancements

1. **Confidence visualization**: Color-code skeleton by detection confidence
2. **Multi-person support**: Draw multiple skeletons if >1 person detected
3. **Landmark labels**: Show joint names on hover
4. **Recording with skeleton**: Save skeleton overlay in HLS recordings
5. **Custom colors**: Let user choose skeleton color scheme

---

## Files Modified

- ✅ Created: `Front-End/src/components/SkeletonOverlay.tsx`
- ⚠️ To modify: `Back-End/Testing_files/broadcaster.py`
- ⚠️ To modify: `Front-End/src/hooks/useStreaming.ts`
- ⚠️ To modify: `Front-End/src/components/HybridStreamPlayer.tsx`

---

## Resources

- [MediaPipe Pose Documentation](https://google.github.io/mediapipe/solutions/pose.html)
- [WebRTC Data Channels](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)
- [HTML5 Canvas Tutorial](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial)
