# Movement Detection Realtime API

## Overview

Real-time streaming of movement detection events using **Server-Sent Events (SSE)** with Supabase Realtime.

---

## 🔌 Endpoints

### 1. Movement Detections Realtime Stream

**Endpoint:** `GET /api/movement-detections/realtime`

**Alternative:** `GET /api/realtime/movement-detections`

**Description:** Stream real-time updates for movement detections

---

## 📋 Query Parameters

| Parameter           | Type          | Required | Description                                           |
| ------------------- | ------------- | -------- | ----------------------------------------------------- |
| `room_id`           | string (UUID) | No       | Filter detections by room                             |
| `recording_id`      | string (UUID) | No       | Filter detections by recording                        |
| `validation_status` | string        | No       | Filter by status: `pending`, `confirmed`, `dismissed` |

---

## 📡 Event Types

The stream sends JSON events with the following types:

### `connected`

Sent when connection is established

```json
{
  "type": "connected",
  "channel": "movement_detections_all",
  "filters": {
    "room_id": null,
    "recording_id": null,
    "validation_status": null
  }
}
```

### `INSERT`

Sent when a new detection is created

```json
{
  "type": "INSERT",
  "schema": "public",
  "table": "movement_detections",
  "commit_timestamp": "2025-11-05T05:08:36.349Z",
  "record": {
    "id": 1,
    "created_at": "2025-11-05T05:08:36.349524+00:00",
    "updated_at": "2025-11-05T05:08:36.349524+00:00",
    "timestamp": 15.0,
    "name": "tremor",
    "confidence": 0.98,
    "validation_status": "pending",
    "room_id": "0f30f577-61a3-4a81-8c9f-64a952f718a1",
    "recording_id": "1bce4928-82fe-4252-99ce-789e2783d1bc"
  }
}
```

### `UPDATE`

Sent when a detection is updated (e.g., validation status changed)

```json
{
  "type": "UPDATE",
  "schema": "public",
  "table": "movement_detections",
  "commit_timestamp": "2025-11-05T05:10:15.123Z",
  "record": {
    "id": 1,
    "validation_status": "confirmed"
    // ... other fields
  },
  "old_record": {
    "id": 1,
    "validation_status": "pending"
    // ... other fields
  }
}
```

### `DELETE`

Sent when a detection is deleted

```json
{
  "type": "DELETE",
  "schema": "public",
  "table": "movement_detections",
  "commit_timestamp": "2025-11-05T05:15:30.456Z",
  "old_record": {
    "id": 1,
    "timestamp": 15.0,
    "name": "tremor"
    // ... other fields
  }
}
```

### `heartbeat`

Sent every 30 seconds to keep connection alive

```json
{
  "type": "heartbeat",
  "timestamp": 1730784536.789
}
```

### `error`

Sent when an error occurs

```json
{
  "type": "error",
  "error": "Error message here"
}
```

---

## 💻 Usage Examples

### JavaScript (Browser)

```javascript
// Connect to stream
const eventSource = new EventSource(
  "http://localhost:8000/api/movement-detections/realtime?room_id=0f30f577-61a3-4a81-8c9f-64a952f718a1"
);

// Listen for events
eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);

  if (data.type === "INSERT") {
    console.log("New detection:", data.record);
    // Update UI with new detection
  } else if (data.type === "UPDATE") {
    console.log("Detection updated:", data.record);
    // Update UI with changed detection
  } else if (data.type === "DELETE") {
    console.log("Detection deleted:", data.old_record.id);
    // Remove detection from UI
  }
};

eventSource.onerror = (error) => {
  console.error("Connection error:", error);
  eventSource.close();
};

// Disconnect
eventSource.close();
```

### Python (aiohttp)

```python
import asyncio
import aiohttp
import json

async def stream_detections(room_id):
    url = f"http://localhost:8000/api/movement-detections/realtime?room_id={room_id}"

    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            async for line in response.content:
                line = line.decode('utf-8').strip()

                if line.startswith('data: '):
                    data = json.loads(line[6:])

                    if data['type'] == 'INSERT':
                        print(f"New: {data['record']['name']} - {data['record']['confidence']:.2%}")
                    elif data['type'] == 'UPDATE':
                        print(f"Updated: ID {data['record']['id']}")

asyncio.run(stream_detections("0f30f577-61a3-4a81-8c9f-64a952f718a1"))
```

### React (TypeScript)

```typescript
import { useEffect, useState } from "react";

interface MovementDetection {
  id: number;
  timestamp: number;
  name: string;
  confidence: number;
  validation_status: string;
  room_id: string;
  recording_id: string;
}

function useMovementDetections(roomId: string) {
  const [detections, setDetections] = useState<MovementDetection[]>([]);

  useEffect(() => {
    const eventSource = new EventSource(
      `http://localhost:8000/api/movement-detections/realtime?room_id=${roomId}`
    );

    eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);

      if (data.type === "INSERT") {
        setDetections((prev) => [...prev, data.record]);
      } else if (data.type === "UPDATE") {
        setDetections((prev) =>
          prev.map((d) => (d.id === data.record.id ? data.record : d))
        );
      } else if (data.type === "DELETE") {
        setDetections((prev) =>
          prev.filter((d) => d.id !== data.old_record.id)
        );
      }
    };

    return () => eventSource.close();
  }, [roomId]);

  return detections;
}
```

---

## 🧪 Testing

### 1. Using Python Test Script

```bash
cd Back-End
python test_movement_realtime.py
```

Choose from menu:

1. Monitor all detections
2. Monitor specific room
3. Monitor specific recording
4. Monitor by validation status
5. Custom filters

### 2. Using HTML Test Page

```bash
# Open in browser
open test_movement_realtime.html
```

Features:

- Real-time event display
- Filter by room/recording/status
- Event counter
- Visual event cards with animations
- Confidence bar charts

### 3. Using cURL

```bash
# Monitor all detections
curl -N http://localhost:8000/api/movement-detections/realtime

# Monitor specific room
curl -N "http://localhost:8000/api/movement-detections/realtime?room_id=0f30f577-61a3-4a81-8c9f-64a952f718a1"

# Monitor pending detections only
curl -N "http://localhost:8000/api/movement-detections/realtime?validation_status=pending"
```

---

## 🔄 Integration with Frontend

### Next.js Example

```typescript
// hooks/useRealtimeDetections.ts
import { useEffect, useState } from "react";

export function useRealtimeDetections(roomId?: string, recordingId?: string) {
  const [detections, setDetections] = useState<MovementDetection[]>([]);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams();
    if (roomId) params.append("room_id", roomId);
    if (recordingId) params.append("recording_id", recordingId);

    const eventSource = new EventSource(
      `${process.env.NEXT_PUBLIC_API_URL}/api/movement-detections/realtime?${params}`
    );

    eventSource.onopen = () => setIsConnected(true);
    eventSource.onerror = () => setIsConnected(false);

    eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);

      switch (data.type) {
        case "connected":
          console.log("Connected to channel:", data.channel);
          break;
        case "INSERT":
          setDetections((prev) => [data.record, ...prev]);
          break;
        case "UPDATE":
          setDetections((prev) =>
            prev.map((d) => (d.id === data.record.id ? data.record : d))
          );
          break;
        case "DELETE":
          setDetections((prev) =>
            prev.filter((d) => d.id !== data.old_record.id)
          );
          break;
      }
    };

    return () => {
      eventSource.close();
      setIsConnected(false);
    };
  }, [roomId, recordingId]);

  return { detections, isConnected };
}
```

---

## 🔧 Configuration

### Supabase Setup

Ensure realtime is enabled for the `movement_detections` table:

```sql
-- Enable realtime for movement_detections table
ALTER PUBLICATION supabase_realtime ADD TABLE movement_detections;
```

### Backend Requirements

- Supabase client configured in `core/common.py`
- `realtime_service` running in `services/realtime/`
- FastAPI with `StreamingResponse` support

---

## 📊 Performance

- **Heartbeat interval:** 30 seconds
- **Connection timeout:** Auto-reconnect on disconnect
- **Event latency:** < 100ms (Supabase Realtime)
- **Concurrent connections:** Unlimited (SSE-based)

---

## 🚨 Error Handling

### Client disconnection

The server detects client disconnection via `request.is_disconnected()` and automatically cleans up resources.

### Network errors

Clients should implement reconnection logic:

```javascript
let eventSource;
let reconnectAttempts = 0;
const maxReconnectAttempts = 5;

function connect() {
  eventSource = new EventSource(url);

  eventSource.onerror = () => {
    eventSource.close();

    if (reconnectAttempts < maxReconnectAttempts) {
      reconnectAttempts++;
      setTimeout(connect, 2000 * reconnectAttempts);
    }
  };

  eventSource.onopen = () => {
    reconnectAttempts = 0; // Reset on successful connection
  };
}
```

---

## 🔐 Security Notes

- Add authentication middleware if needed (`Depends(current_user)`)
- Validate UUIDs in query parameters
- Rate limit connections per user
- Use CORS for production deployments

---

## 📝 Related Endpoints

- `POST /api/movement-detections` - Create detection
- `GET /api/movement-detections/{id}` - Get single detection
- `PATCH /api/movement-detections/{id}` - Update detection
- `DELETE /api/movement-detections/{id}` - Delete detection
- `GET /api/movement-detections/recording/{recording_id}` - List by recording

---

## 🐛 Troubleshooting

### Events not received

1. Check Supabase realtime is enabled: `ALTER PUBLICATION supabase_realtime ADD TABLE movement_detections;`
2. Verify backend is running: `http://localhost:8000/docs`
3. Check browser console for errors
4. Test with cURL to isolate client issues

### Connection drops

- Check network stability
- Increase heartbeat timeout if needed
- Implement reconnection logic in client

### High latency

- Verify Supabase connection
- Check database load
- Use filters to reduce event volume

---

## 📚 Additional Resources

- [MDN: Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [FastAPI Streaming Response](https://fastapi.tiangolo.com/advanced/custom-response/#streamingresponse)

---

**Created:** 2025-11-05  
**Last Updated:** 2025-11-05  
**Status:** ✅ Production Ready
