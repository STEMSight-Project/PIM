# WebRTC Broadcaster Usage Guide

The broadcaster.py has been updated to work with the new streaming implementation that includes:

- Automatic session creation when rooms are created
- Auto-disconnect handling with reconnection capability
- Better error handling and status monitoring

## Basic Usage

### 1. Start a stream with default device:

```bash
python broadcaster.py --room patient123
```

### 2. Start a stream with specific device name:

```bash
python broadcaster.py --room patient123 --device_name "RaspberryPi-Camera-01"
```

### 3. Start a stream with custom video device:

```bash
python broadcaster.py --room patient123 --video_device "Logitech BRIO" --device_name "Lab-Camera-01"
```

### 4. Check room status before streaming:

```bash
python broadcaster.py --room patient123 --check_status --device_name "Test-Device"
```

### 5. Use custom server URL:

```bash
python broadcaster.py --room patient123 --signaling http://192.168.1.100:8000 --device_name "Remote-Camera"
```

## New Features

### Automatic Session Management

- When you create a room, it automatically creates a streaming session in the database
- Session is properly ended when you stop the stream (Ctrl+C)
- Sessions track device information and connection status

### Reconnection Handling

- If the network connection fails, the room can be reconnected
- The broadcaster will automatically try to reconnect to existing rooms
- Maximum of 3 reconnection attempts before permanent closure

### Better Logging

- Detailed connection status information
- Session ID tracking
- Room status monitoring
- Connection state monitoring every 5 seconds

### Error Handling

- Graceful handling of connection failures
- Automatic retry for streamer conflicts
- Proper cleanup of resources

## Example Output

```
🎥 Starting WebRTC Broadcaster
📡 Room ID: patient123
🌐 Server: http://localhost:8000
📹 Video Device: Default
🎤 Audio Device: Default
🏷️  Device Name: TestDevice-Broadcaster
==================================================
INFO:publisher:Room created/connected: {'room_id': 'patient123', 'session_id': 'uuid-456', 'created': True}
INFO:publisher:Streaming session created: uuid-456
INFO:publisher:New room and session created
INFO:publisher:Streaming started successfully! Session ID: uuid-456
INFO:publisher:Press Ctrl+C to stop streaming...
```

## Database Integration

The updated broadcaster now works seamlessly with the streaming_sessions table:

- Creates sessions with patient_id, room_id, device_name
- Tracks session status (active, ended, error, disconnected)
- Records start and end timestamps
- Maintains connection state information

## Testing

You can test the streaming with different scenarios:

1. Normal streaming session
2. Network disconnection simulation
3. Multiple device connections
4. Room status monitoring
5. Session cleanup verification
