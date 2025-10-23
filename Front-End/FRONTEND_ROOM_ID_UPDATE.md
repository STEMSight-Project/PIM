# 🎨 Frontend Update - Using room_id as Camera Identifier

## Overview

Updated the frontend to use `room_id` as the camera identifier when connecting to WebRTC streaming endpoints, aligning with the backend architecture where **room_id IS the camera_id**.

## Key Changes

### 1. **Service Layer** (`streamingService.ts`)

Updated documentation to clarify parameter usage:

```typescript
/**
 * Connect as a camera viewer (for dashboard monitoring)
 *
 * @param cameraId - Actually the room_id (e.g., "AMB-001-ROOM-001")
 *                   In our system, room_id IS the camera identifier
 */
async connectCameraViewer(
  cameraId: string,  // This is room_id
  sdpData: SDPData
): Promise<ApiResponse<StreamResponse>> {
  return api.post<StreamResponse>(
    `/ambulance-streaming/camera/${cameraId}/viewer`,
    sdpData
  );
}
```

### 2. **Streaming Hook** (`useStreaming.ts`)

#### Updated `startStreaming` Function

**Before:**

```typescript
async (ambulanceId: string, cameraId?: string): Promise<void> => {
  // Get cameras for ambulance
  const camerasResponse = await ambulanceStreamingService.getAmbulanceCameras(
    ambulanceId
  );
  targetCameraId = camerasResponse.data[0].id; // UUID

  const pc = await createPeerConnection(targetCameraId);
};
```

**After:**

```typescript
async (ambulanceId: string, roomId?: string): Promise<void> => {
  // Get camera rooms for ambulance session
  const roomsResponse = await ambulanceStreamingService.getCameraRooms({
    session_id: session.id,
  });

  // Use the first connected room, or first room if none connected
  const connectedRoom = roomsResponse.data.find((r) => r.connected);
  targetRoomId = (connectedRoom || roomsResponse.data[0]).room_id;

  // room_id is used as the camera_id parameter
  const pc = await createPeerConnection(targetRoomId);
};
```

#### Updated `createPeerConnection` Function

**Before:**

```typescript
async (cameraId: string): Promise<RTCPeerConnection> => {
  const response = await ambulanceStreamingService.connectCameraViewer(
    cameraId, // UUID
    { sdp: pc.localDescription!.sdp, type: pc.localDescription!.type }
  );
};
```

**After:**

```typescript
async (roomId: string): Promise<RTCPeerConnection> => {
  // Note: roomId is used as camera_id in the API endpoint
  // In our system: room_id IS the camera identifier (e.g., "AMB-001-ROOM-001")

  const response = await ambulanceStreamingService.connectCameraViewer(
    roomId, // e.g., "AMB-001-ROOM-001"
    { sdp: pc.localDescription!.sdp, type: pc.localDescription!.type }
  );
};
```

### 3. **Streaming Dashboard Page** (`streamingDash/[slug]/page.tsx`)

**Before:**

```typescript
const handleStartStream = () => {
  if (selectedRoomId) {
    startStreaming(ambulanceId); // Didn't pass room_id
  }
};
```

**After:**

```typescript
const handleStartStream = () => {
  if (selectedRoomId) {
    // Pass both ambulanceId and the selected room_id
    // room_id will be used as the camera_id parameter in the API
    startStreaming(ambulanceId, selectedRoomId);
  }
};
```

## Data Flow

### Complete Frontend → Backend Flow

```
┌─────────────────────────────────────────────────────────┐
│ User clicks "Start Watching" on streamingDash page      │
│ Selected Room: "AMB-003-ROOM-001"                       │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ handleStartStream()                                     │
│ → startStreaming(ambulanceId, "AMB-003-ROOM-001")      │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ useStreaming Hook                                       │
│ 1. Find active ambulance session                        │
│ 2. Use provided roomId: "AMB-003-ROOM-001"             │
│ 3. Store in currentCameraIdRef (for reconnection)       │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ createPeerConnection("AMB-003-ROOM-001")                │
│ 1. Create RTCPeerConnection                             │
│ 2. Create SDP offer                                     │
│ 3. Wait for ICE gathering                               │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ ambulanceStreamingService.connectCameraViewer()         │
│ Parameter: cameraId = "AMB-003-ROOM-001" (room_id)      │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ API Call:                                               │
│ POST /ambulance-streaming/camera/AMB-003-ROOM-001/viewer │
│ Body: { sdp: "...", type: "offer" }                     │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Backend Endpoint:                                       │
│ camera_viewer(camera_id: str)                           │
│ room_id = camera_id  # "AMB-003-ROOM-001"              │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Database Query:                                         │
│ get_camera_room_by_room_id("AMB-003-ROOM-001")         │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ WebRTC Setup:                                           │
│ 1. Get/Create WebRTC room                               │
│ 2. Create peer connection                               │
│ 3. Process SDP offer → Generate SDP answer              │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Response to Frontend:                                   │
│ { sdp: "...", type: "answer" }                          │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Frontend:                                               │
│ 1. Set remote description (SDP answer)                  │
│ 2. Start receiving video stream                         │
│ 3. Display in <video> element                           │
└─────────────────────────────────────────────────────────┘
```

## Room Selection Workflow

### How Room Selection Works

```tsx
// 1. Available rooms displayed in UI
{availableRooms.map((room) => (
  <div
    className={selectedRoomId === room.room_id ? "active" : ""}
    onClick={() => handleRoomSelect(room.room_id)}
  >
    <h3>{room.room_id}</h3>
    <Badge>{room.connected ? "Connected" : "Offline"}</Badge>
  </div>
))}

// 2. User clicks on a room
handleRoomSelect("AMB-003-ROOM-001")
→ setSelectedRoomId("AMB-003-ROOM-001")
→ Update URL: ?room=AMB-003-ROOM-001

// 3. User clicks "Start Watching"
handleStartStream()
→ startStreaming(ambulanceId, "AMB-003-ROOM-001")
→ Backend receives room_id as camera_id parameter
```

## Type Definitions

### Camera Room Interface

```typescript
export interface CameraRoom {
  id: string; // Internal database UUID
  session_id: string; // Links to ambulance session
  camera_id: string; // References cameras table (internal)
  room_id: string; // WebRTC room identifier ← USED IN API
  camera_name: string;
  connected: boolean;
  connection_started_at: string;
  current_fps?: number;
  current_bitrate?: number;
  latency_ms?: number;
  // ... other fields
}
```

## Benefits of This Approach

### ✅ Consistent with Backend

- Frontend uses same identifier as backend expects
- No UUID → room_id translation needed
- Direct 1:1 mapping between frontend and backend

### ✅ User-Friendly Room Identifiers

- Room IDs like `"AMB-003-ROOM-001"` are human-readable
- Easier to debug and trace connections
- Clear association with ambulance number

### ✅ Simplified Code

- No complex lookup logic
- Direct room selection → API call
- Fewer potential points of failure

### ✅ Better Room Management

- Frontend can select specific rooms
- Handles multiple cameras per ambulance
- Prioritizes connected rooms when auto-selecting

## Testing the Changes

### 1. Test Room Selection

```typescript
// Open streaming dashboard
http://localhost:3000/streamingDash/AMB-003

// Select a room from the list
// Click "AMB-003-ROOM-001"

// Verify:
// ✓ Room highlighted as selected
// ✓ URL updated: ?room=AMB-003-ROOM-001
```

### 2. Test Streaming Connection

```typescript
// With room selected, click "Start Watching"

// Check browser console:
console.log("Looking for active ambulance camera...");
console.log("Found camera room: AMB-003-ROOM-001");
console.log(
  "Connecting to: /ambulance-streaming/camera/AMB-003-ROOM-001/viewer"
);
console.log("Received remote stream");

// Verify:
// ✓ No UUID parsing errors
// ✓ WebRTC connection established
// ✓ Video element receives stream
```

### 3. Test Auto-Selection

```typescript
// Open streaming dashboard without room parameter
//localhost:3000/streamingDash/AMB-003

// Click "Start Watching" without selecting room

// Frontend should:
// 1. Get all camera rooms for ambulance
// 2. Find first connected room (or first room if none connected)
// 3. Use that room's room_id for streaming

// Check console:
http: console.log("Auto-selected room: AMB-003-ROOM-001");
```

## Updated Hook Parameters

### startStreaming Function

```typescript
/**
 * Start streaming from an ambulance camera
 *
 * @param ambulanceId - The ambulance ID to find active session
 * @param roomId - Optional specific room_id to connect to
 *                 If not provided, auto-selects first connected room
 */
async startStreaming(
  ambulanceId: string,
  roomId?: string
): Promise<void>
```

### createPeerConnection Function

```typescript
/**
 * Create WebRTC peer connection for camera streaming
 *
 * @param roomId - The room_id (used as camera_id in API)
 *                 Example: "AMB-001-ROOM-001"
 */
async createPeerConnection(
  roomId: string
): Promise<RTCPeerConnection>
```

## Error Handling

### No Rooms Found

```typescript
if (!roomsResponse.data || roomsResponse.data.length === 0) {
  throw new Error("No camera rooms found for this ambulance session");
}

// UI displays:
("No camera rooms available. Please ensure cameras are configured.");
```

### Room Not Connected

```typescript
// Frontend checks room.connected status
if (selectedRoom && !selectedRoom.connected) {
  // Show warning overlay on video
  <div className="disconnected-overlay">Camera is currently offline</div>;
}
```

### Invalid Room ID

```typescript
// Backend returns 404
{
  "detail": "Camera room not found for room_id: AMB-003-ROOM-999"
}

// Frontend displays:
"Camera room not found. Please select a different room."
```

## Files Modified

1. ✅ **`Front-End/src/services/streamingService.ts`**

   - Updated JSDoc comments
   - Clarified `cameraId` parameter is actually `room_id`

2. ✅ **`Front-End/src/hooks/useStreaming.ts`**

   - Changed parameter from `cameraId` to `roomId`
   - Updated to get camera rooms instead of cameras
   - Auto-select connected room when no specific room provided
   - Updated console logs to show `room_id`

3. ✅ **`Front-End/src/app/streamingDash/[slug]/page.tsx`**
   - Pass `selectedRoomId` to `startStreaming()`
   - Added comment explaining room_id usage

## Summary

| Aspect        | Before                     | After                                    |
| ------------- | -------------------------- | ---------------------------------------- |
| **Parameter** | `cameraId` (UUID)          | `roomId` (string)                        |
| **Value**     | `"abc-123-def-456"`        | `"AMB-003-ROOM-001"`                     |
| **Lookup**    | Get cameras → Use first ID | Get camera rooms → Use room_id           |
| **API Call**  | `/camera/{UUID}/viewer`    | `/camera/AMB-003-ROOM-001/viewer`        |
| **Selection** | Auto first camera          | User selects room OR auto connected room |

🎉 **Result**: Frontend now correctly uses `room_id` as the camera identifier, matching the backend architecture where room_id IS the camera_id!
