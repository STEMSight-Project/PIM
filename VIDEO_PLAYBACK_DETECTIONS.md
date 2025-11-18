# Video Playback with Timeline-Synced AI Detections

## Overview

The video playback system now displays **historical AI detections synchronized to the video timeline**. As you watch recorded camera footage, the system automatically shows which movements were detected at each moment in time.

## Architecture

### Components

#### 1. **HybridStreamPlayer** (Enhanced)

- **Location**: `Front-End/src/components/HybridStreamPlayer.tsx`
- **What it does**:
  - Plays live WebRTC streams and recorded HLS videos
  - Tracks current video timestamp via `currentTime` state
  - Passes `recordingId` (from `recordingStatus.session_id`) to TimelineSyncedDetectionPanel
  - Already has SkeletonOverlay for live streams
- **Key Props**:
  - `ambulanceId`: Ambulance identifier
  - `roomId`: Camera room UUID
  - `viewMode`: "live" or "playback"

#### 2. **TimelineSyncedDetectionPanel** (NEW)

- **Location**: `Front-End/src/components/TimelineSyncedDetectionPanel.tsx`
- **What it does**:
  - Loads ALL detections for a recording via `/movement-detections/recording/{id}`
  - Uses `movement_detections` table (has `recording_id` and `timestamp` fields)
  - Filters detections based on current video timestamp (simple comparison)
  - Shows detections within ±2 seconds of current video time
  - Updates automatically as video plays or user scrubs timeline
- **Key Features**:
  - Uses `recording_id` directly (no UUID → string conversion needed)
  - Simple timestamp comparison: `Math.abs(detection.timestamp - currentTimestamp)`
  - Sorts by proximity to current time (closest first)
  - Color-coded confidence levels (green ≥80%, yellow ≥60%, red <60%)
  - Shows validation status: pending, confirmed, rejected

### Data Flow

```
1. Video Playback Starts
   ↓
2. HybridStreamPlayer switches to "playback" mode
   ↓
3. HLS hook provides recordingStatus with session_id
   ↓
4. TimelineSyncedDetectionPanel mounts with recording_id
   ↓
5. Component fetches ALL detections for recording (once)
   Query: /movement-detections/recording/{recording_id}?limit=500
   ↓
6. Video currentTime updates (every frame)
   ↓
7. useEffect filters detections by timestamp
   Calculate: Math.abs(detection.timestamp - currentTimestamp)
   Find: detections where difference ≤ 2 seconds
   ↓
8. Display filtered detections (max 5 shown)
   Sort: Closest to current time first
```

### Timestamp Synchronization Logic

```typescript
// Simple timestamp comparison (no absolute time calculation needed)
const relevant = allDetections.filter((detection) => {
  const diffSeconds = Math.abs(detection.timestamp - currentTimestamp);
  return diffSeconds <= timeWindow; // Default: 2 seconds
});

// Sort by proximity (closest first)
relevant.sort((a, b) => {
  const diffA = Math.abs(a.timestamp - currentTimestamp);
  const diffB = Math.abs(b.timestamp - currentTimestamp);
  return diffA - diffB;
});
```

**Why this is simpler:**

- `movement_detections.timestamp` is already in seconds relative to video start
- No need to calculate absolute timestamps or convert Date objects
- Direct comparison: video at 45s → show detections at 43-47s

## User Experience

### Live Mode

- **Video**: Real-time WebRTC stream with skeleton overlay
- **Detections**: LiveAIDetectionPanel shows newest detections at top
- **Controls**: "Pause" button switches to playback mode

### Playback Mode

- **Video**: HLS playback of recorded footage
- **Detections**: TimelineSyncedDetectionPanel shows detections at current timestamp
- **Controls**: Play/pause, seek, skip forward/backward (10 seconds)
- **Timeline**: Scrub to any point - detections update instantly

### Detection Display

Each detection card shows:

- **Movement Type**: Class name badge (e.g., "tremor", "dystonia")
- **Confidence**: Percentage with color coding
  - Green (≥80%): High confidence
  - Yellow (≥60%): Medium confidence
  - Red (<60%): Low confidence
- **Timestamp**: Exact time in video when detected (e.g., "15.2s")
- **Validation Status**: pending, confirmed, or rejected (color-coded badge)

### Example Flow

```
User Actions:
1. Opens streaming dashboard → Live mode active
2. Clicks pause/timeline → Switches to playback mode
3. Scrubs to 45 seconds → Panel shows detections at 45s ±2s
4. Sees "tremor" detection at 44.2s (confidence: 89.3%)
5. Clicks play → Video continues, detections update automatically
6. Clicks "GO LIVE" → Returns to real-time streaming
```

## Implementation Details

### Props Interface

```typescript
interface TimelineSyncedDetectionPanelProps {
  recordingId: string; // UUID of the recording (from session_id)
  currentTimestamp: number; // Current video time (seconds)
  timeWindow?: number; // Detection window (default: 2 seconds)
  maxDetections?: number; // Max detections shown (default: 5)
}

interface MovementDetection {
  id: number; // Primary key
  timestamp: number; // Timestamp in video (seconds)
  name: string; // Movement type (e.g., 'tremor')
  confidence: number; // 0.0 to 1.0
  validation_status: string; // 'pending' | 'confirmed' | 'rejected'
  room_id: string; // UUID
  recording_id: string; // UUID
  created_at: string;
  updated_at: string;
}
```

### Integration in HybridStreamPlayer

```typescript
// In HybridStreamPlayer component
{
  viewMode === "playback" && recordingStatus?.session_id && (
    <div className="mt-4">
      <TimelineSyncedDetectionPanel
        recordingId={recordingStatus.session_id}
        currentTimestamp={currentTime}
        timeWindow={2}
        maxDetections={5}
      />
    </div>
  );
}
```

### Database Schema

**movement_detections Table:**

```sql
- id: SERIAL (primary key)
- timestamp: INTEGER (timestamp in video in seconds)
- name: VARCHAR (movement type name: 'tremor', 'dystonia', etc.)
- confidence: FLOAT (0.0-1.0)
- validation_status: VARCHAR ('pending', 'confirmed', 'rejected')
- room_id: UUID (foreign key to camera rooms)
- recording_id: UUID (foreign key to recordings/sessions) ← CRITICAL for sync
- created_at: TIMESTAMP
- updated_at: TIMESTAMP
```

**Why movement_detections is better than ai_detections:**

1. ✅ Has `recording_id` field - direct link to video recordings
2. ✅ Simple `timestamp` field (seconds in video) - no absolute time calculation
3. ✅ Has `validation_status` - medical staff can confirm/reject detections
4. ✅ Cleaner schema designed specifically for video playback
5. ✅ Already has service layer and API endpoints ready to use

**ambulance_streaming_sessions Table:**

```sql
- id: UUID (primary key) ← Used as recording_id
- ambulance_id: UUID
- started_at: TIMESTAMP
- ended_at: TIMESTAMP
- is_active: BOOLEAN
```

## Performance Considerations

### Optimization Strategies

1. **Load Once Pattern**

   - Fetch all detections on component mount (single query)
   - Store in `allDetections` state
   - Filter in-memory as video plays (no repeated API calls)

2. **Efficient Filtering**

   - Filter runs in useEffect dependent on `currentTimestamp`
   - Uses Date.getTime() for fast timestamp comparisons
   - Sorts by proximity for relevance

3. **Limited Results**
   - Shows max 5 detections per timestamp (configurable)
   - Reduces DOM rendering overhead
   - Prevents UI clutter

### Query Optimization

```typescript
// Good: Single query with recording_id
const response = await api.get<{ data: MovementDetection[] }>(
  `/movement-detections/recording/${recordingId}?limit=500`
);

// Bad: Repeated queries as video plays
// DON'T DO THIS:
useEffect(() => {
  fetchDetections(currentTimestamp); // ❌ Causes 30+ queries/second
}, [currentTimestamp]);
```

## Testing Scenarios

### Test 1: Basic Playback Sync

```
1. Start live stream (AMB-001-ROOM-001)
2. Broadcaster stores detections to database
3. Click pause → Switch to playback mode
4. Verify detections appear below video
5. Scrub timeline → Detections update with timestamp
```

### Test 2: Multiple Detection Types

```
1. Record session with varied movements (tremor, dystonia, etc.)
2. Play back recording
3. Verify different detection types appear at correct timestamps
4. Check confidence colors match actual scores
```

### Test 3: Edge Cases

```
Scenario A: No detections at timestamp
- Expected: "No detections at this timestamp" message

Scenario B: Many detections (>5) at same time
- Expected: Shows 5 closest detections, sorted by proximity

Scenario C: User seeks rapidly
- Expected: Component handles rapid timestamp changes smoothly
```

### Test 4: Simple Timestamp Sync

```
1. Record session with detections at known timestamps (e.g., 10s, 20s, 30s)
2. Play back recording
3. At video time 10s → Verify detection appears
4. At video time 20s → Verify different detection appears
5. Scrub to 30s → Verify correct detection shown
6. No complex time calculations needed - direct comparison
```

## Troubleshooting

### Issue: No detections showing

**Check:**

- Console logs: "📊 [Timeline] Loaded X detections for recording {id}"
- Database: `SELECT * FROM movement_detections WHERE recording_id = '{uuid}'`
- Recording ID available: Check `recordingStatus.session_id` is not null

### Issue: Wrong detections at timestamp

**Check:**

- Detection timestamp: `detection.timestamp` (should be in seconds)
- Current video time: `currentTimestamp` (should match video.currentTime)
- Time window setting (default: ±2 seconds)

### Issue: Detections not updating

**Check:**

- `currentTimestamp` prop changing (debug log it)
- useEffect dependency array includes `currentTimestamp`
- `allDetections` array populated (not empty)
- Recording ID correct: `recordingStatus.session_id`

## Future Enhancements

### Potential Features

1. **Skeleton Overlay in Playback**

   - Challenge: Need skeleton coordinates in recorded data
   - Options:
     - Store landmarks in detection_data JSONB field
     - Create separate skeleton_frames table
     - Reconstruct from MediaPipe on-the-fly (expensive)

2. **Detection Timeline Visualization**

   - Visual timeline above video showing detection clusters
   - Click timeline marker to jump to detection
   - Color-coded by detection type

3. **Detection Filtering**

   - Show only specific movement types
   - Filter by confidence threshold
   - Hide "normal" detections

4. **Detection Analytics**

   - Histogram of detection types per session
   - Confidence score distribution
   - Most frequent movements

5. **Export Functionality**
   - Export detections as CSV/JSON
   - Generate PDF report with timestamps
   - Video clips of specific detections

## Related Documentation

- **Live AI Detections**: `LIVE_AI_DETECTIONS_INTEGRATION.md`
- **Streaming Architecture**: `Front-End/STREAMING_COMPONENTS_USAGE.md`
- **Project Instructions**: `.github/instructions/copilot-instructions.md`
- **Database Schema**: `DatabaseSQL/create_ai_detections_table.sql`

## File Locations

```
Front-End/
├── src/
│   ├── components/
│   │   ├── HybridStreamPlayer.tsx          (Enhanced with timeline sync)
│   │   ├── TimelineSyncedDetectionPanel.tsx (NEW - this feature)
│   │   ├── LiveAIDetectionPanel.tsx         (For live streaming)
│   │   └── SkeletonOverlay.tsx              (For live pose visualization)
│   ├── hooks/
│   │   ├── useStreaming.ts                  (Provides currentSession)
│   │   └── useHLS.ts                        (Provides currentTime)
│   ├── services/
│   │   └── aiDetectionService.ts            (API queries)
│   └── app/
│       └── streamingDash/[slug]/page.tsx    (Uses HybridStreamPlayer)

Back-End/
├── api_router/
│   └── ai_detections.py                     (REST API endpoints)
└── Testing_files/
    └── broadcaster.py                       (Stores detections)
```

---

## Quick Start Guide

### For Developers

**Add timeline-synced detections to a page:**

```typescript
import { HybridStreamPlayer } from "@/components/HybridStreamPlayer";

<HybridStreamPlayer
  ambulanceId={ambulanceId}
  roomId={roomId}
  showAdvancedControls={true}
  debug={false}
/>;
// TimelineSyncedDetectionPanel automatically appears in playback mode
```

**Use standalone detection panel:**

```typescript
import TimelineSyncedDetectionPanel from "@/components/TimelineSyncedDetectionPanel";

<TimelineSyncedDetectionPanel
  recordingId={session.id} // Use session ID as recording ID
  currentTimestamp={videoElement.currentTime}
  timeWindow={3} // ±3 seconds
  maxDetections={10}
/>;
```

### For Testers

1. **Start broadcaster** with camera:

   ```bash
   cd Back-End/Testing_files
   python broadcaster.py --room AMB-001-ROOM-001 --video_device "Logitech BRIO"
   ```

2. **Open dashboard**:

   ```
   http://localhost:3000/streamingDash/AMB-001
   ```

3. **Test workflow**:
   - Watch live stream (see detections in LiveAIDetectionPanel)
   - Click pause or drag timeline
   - Verify TimelineSyncedDetectionPanel appears
   - Scrub timeline - detections update
   - Click GO LIVE - return to real-time

---

**Status**: ✅ Fully implemented and ready for testing
**Last Updated**: January 2025
