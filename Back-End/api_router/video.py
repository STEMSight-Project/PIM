from datetime import datetime
from typing import Optional, List
from pathlib import Path
from uuid import uuid4
from pydantic import BaseModel
from core.common import supabase, logger
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import FileResponse, StreamingResponse
from security.jwt_verify import current_user
from services.video_service import VideoService
from services.streaming.recording_service import recording_manager, RECORDINGS_BASE_PATH
from services.streaming.hls_segment_service import hls_segment_service

router = APIRouter()


class Video(BaseModel):
    id: str
    patient_id: str
    description: Optional[str]
    file_path: str
    public_video_url: str
    created_at: datetime


class VideoUpload(BaseModel):
    patient_id: str
    video_path: str
    description: str = None


# New models for ambulance recordings
class RecordingResponse(BaseModel):
    """Response model for ambulance session recordings"""

    id: str
    session_id: str
    session_name: Optional[str]
    ambulance_number: Optional[str]
    camera_id: Optional[str] = None  # Camera identifier (e.g., "ROOM-001")
    file_path: Optional[str]
    recording_path: Optional[str] = None  # HLS playlist path
    public_video_url: Optional[str]
    duration: Optional[int]  # Duration in seconds
    file_size: Optional[int]  # File size in bytes
    session_start: Optional[datetime]
    session_end: Optional[datetime]
    created_at: datetime
    is_archived: bool  # True if uploaded to Supabase Storage


# ============================================================================
# AMBULANCE RECORDINGS ENDPOINTS (New - from Supabase Storage)
# ============================================================================


@router.get("/recordings", response_model=List[RecordingResponse])
async def get_all_recordings():
    """
    Get all ambulance session recordings with public URLs from Supabase Storage.
    Returns both archived (uploaded to Supabase) and live (HLS) recordings.
    """
    try:
        recordings = await VideoService.get_all_recordings()
        return recordings
    except Exception as e:
        logger.error("Error getting all recordings: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/archived", response_model=List[RecordingResponse])
async def get_archived_recordings():
    """
    Get only archived recordings (uploaded to Supabase Storage).
    Excludes live/ongoing recordings.
    """
    try:
        recordings = await VideoService.get_archived_recordings()
        return recordings
    except Exception as e:
        logger.error("Error getting archived recordings: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/{recording_id}", response_model=RecordingResponse)
async def get_recording_by_id(recording_id: str):
    """
    Get a specific recording by ID with public URL from Supabase Storage.
    """
    try:
        recording = await VideoService.get_recording_by_id(recording_id)
        if not recording:
            raise HTTPException(status_code=404, detail="Recording not found")
        return recording
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Error getting recording %s: %s", recording_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/recordings/session/{session_id}", response_model=List[RecordingResponse])
async def get_recordings_by_session(session_id: str):
    """
    Get all recordings for a specific ambulance session from database.
    Returns camera recordings with storage URLs.
    """
    try:
        recordings = await VideoService.get_recordings_by_session(session_id)
        logger.info(f"Found {len(recordings)} recordings for session {session_id}")
        return recordings
    except Exception as e:
        logger.error("Error getting recordings for session %s: %s", session_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get(
    "/recordings/ambulance/{ambulance_id}", response_model=List[RecordingResponse]
)
async def get_recordings_by_ambulance(ambulance_id: str):
    """
    Get all recordings for a specific ambulance.
    """
    try:
        recordings = await VideoService.get_recordings_by_ambulance(ambulance_id)
        return recordings
    except Exception as e:
        logger.error("Error getting recordings for ambulance %s: %s", ambulance_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/recordings/{recording_id}")
async def delete_recording(recording_id: str):
    """
    Delete a recording from the database.
    Note: This does NOT delete the file from Supabase Storage.
    """
    try:
        await VideoService.delete_recording(recording_id)
        return {
            "data": {"message": "Recording deleted successfully"},
            "error": None,
        }
    except Exception as e:
        logger.error("Error deleting recording %s: %s", recording_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ============================================================================
# LEGACY PATIENT VIDEO ENDPOINTS (Old - keep for backward compatibility)
# ============================================================================


@router.get("/", response_model=list[Video])
def get_all_videos():
    try:
        response = supabase.table("video").select("*").execute()
        videos: list[Video] = []
        for obj in response.data:
            video_url = supabase.storage.from_("recorded.videos").get_public_url(
                obj["file_path"]
            )
            video = Video(
                id=obj["id"],
                patient_id=obj["patient_id"],
                description=obj["description"],
                file_path=obj["file_path"],
                public_video_url=video_url,
                created_at=obj["created_at"],
            )
            videos.append(video)
        return videos
    except Exception as e:
        logger.error("Error getting all videos: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.get("/{patient_id}/videos", response_model=list[Video])
def get_videos_for_patient(patient_id: str):
    try:
        response_database = (
            supabase.table("video").select("*").eq("patient_id", patient_id).execute()
        )
        videos: list[Video] = []
        for obj in response_database.data:
            video_url = supabase.storage.from_("recorded.videos").get_public_url(
                obj["file_path"]
            )
            video = Video(
                id=obj["id"],
                patient_id=obj["patient_id"],
                description=obj["description"],
                file_path=obj["file_path"],
                public_video_url=video_url,
                created_at=obj["created_at"],
            )
            videos.append(video)

        return videos

    except Exception as e:
        logger.error("Error getting videos for patient %s: %s", patient_id, e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/", response_model=Video)
async def create_video(video_upload: VideoUpload):
    try:
        # Save the video to the server
        file_content = video_upload.video.read()
    except Exception as e:
        logger.error("Error reading video file: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e

    try:
        response = await supabase.storage.from_("recorded.videos").upload(
            video_upload.video_path,
            file_content,
            {
                "upsert": True,
            },
        )
        if not response:
            raise HTTPException(status_code=500, detail="Error uploading video")
        videoURL = await supabase.storage.from_("recorded.videos").get_public_url(
            video_upload.video_path
        )
        if not videoURL:
            raise HTTPException(
                status_code=500, detail="Error getting public video URL"
            )
        video_response = (
            supabase.table("video")
            .upsert(
                {
                    "patient_id": video_upload.patient_id,
                    "file_path": video_upload.video_path,
                    "description": video_upload.description,
                    "public_video_url": videoURL,
                }
            )
            .execute()
        )
        return video_response.data[0]
    except Exception as e:
        logger.error("Error uploading video: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.delete("/{video_id}")
async def delete_video(video_id: str):
    try:
        video_response = (
            supabase.table("video").select("*").eq("id", video_id).execute()
        )

        await supabase.storage.from_("recorded.videos").remove(
            [video_response.data.file_path]
        )

        (supabase.table("video").delete().eq("id", video_id).execute())
        return {"message": "Video deleted successfully"}
    except Exception as e:
        logger.error("Error deleting video: %s", e)
        raise HTTPException(status_code=500, detail=str(e)) from e


# ============================================================================
# HLS PLAYBACK ENDPOINTS (For existing recording_service.py recordings)
# ============================================================================


@router.get("/hls/{room_id}/playlist.m3u8")
async def get_hls_playlist(room_id: str):
    """
    Get HLS playlist for a recorded camera room

    Usage in video player:
        <video>
            <source src="/videos/hls/{room_id}/playlist.m3u8" type="application/x-mpegURL">
        </video>
    """
    try:
        playlist_path = RECORDINGS_BASE_PATH / f"room-{room_id}" / "playlist.m3u8"

        if not playlist_path.exists():
            raise HTTPException(
                status_code=404,
                detail=f"HLS playlist not found for room {room_id}",
            )

        return FileResponse(
            path=playlist_path,
            media_type="application/vnd.apple.mpegurl",
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0",
                "Access-Control-Allow-Origin": "*",
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error serving HLS playlist for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hls/segments/{room_id}/events")
async def hls_segment_events(request: Request, room_id: str):
    """
    Server-Sent Events (SSE) endpoint for real-time HLS segment notifications.

    Clients can connect to this endpoint to receive events when new HLS segments
    are created during recording. This enables real-time HLS playback updates.

    Event Types:
    - connected: Initial connection confirmation
    - new_segment: New HLS segment created
    - heartbeat: Keep-alive ping every 30 seconds
    - error: Error occurred

    Args:
        request: FastAPI request object
        room_id: Camera room ID

    Returns:
        StreamingResponse with SSE events

    ⚠️ IMPORTANT: This route MUST be defined BEFORE the catch-all segment route
    to prevent /segments/{room_id}/events from being captured as a segment file.

    Example client usage (JavaScript):
    ```javascript
    const eventSource = new EventSource('/videos/hls/segments/AMB-001-ROOM-001/events');

    eventSource.addEventListener('message', (event) => {
        const data = JSON.parse(event.data);

        if (data.type === 'new_segment') {
            console.log('New segment:', data.segment_name);
            // Reload HLS player to get latest segments
            hls.loadSource('/videos/hls/AMB-001-ROOM-001/playlist.m3u8');
        }
    });
    ```
    """
    try:
        # Get segment monitor for this room
        monitor = hls_segment_service.get_monitor(room_id)

        if not monitor:
            raise HTTPException(
                status_code=404, detail=f"No active recording found for room {room_id}"
            )

        # Generate unique client ID
        client_id = str(uuid4())

        # Create SSE stream
        return StreamingResponse(
            monitor.create_sse_stream(request, client_id),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
                "X-Accel-Buffering": "no",  # Disable nginx buffering
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating SSE stream for room {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hls/segments/stats")
async def get_segment_service_stats():
    """
    Get statistics about active HLS segment monitoring.

    Useful for debugging and monitoring the segment service health.

    Returns:
        Statistics including active monitors, SSE clients, and segment counts

    ⚠️ IMPORTANT: This route MUST be defined BEFORE the catch-all segment route.
    """
    try:
        stats = hls_segment_service.get_stats()
        return {"data": stats, "error": None}
    except Exception as e:
        logger.error(f"Error getting segment service stats: {e}")
        return {"data": None, "error": str(e)}


@router.get("/hls/{room_id}/status")
async def get_recording_status(room_id: str):
    """
    Get status of a camera room recording (active or completed)
    Includes real-time segment count for monitoring HLS creation

    ⚠️ IMPORTANT: This route MUST be defined BEFORE the catch-all segment route
    to prevent /status from being captured as a segment name.
    """
    try:
        # Check if recording is active
        recorder = recording_manager.get_recorder(room_id)

        if recorder:
            # Recording is active - include real-time segment info
            return {
                "room_id": room_id,
                "session_id": recorder.session_id,
                "status": "recording",
                "is_active": True,
                "duration": recorder.get_duration(),
                "segment_count": recorder.get_segment_count(),
                "hls_ready": recorder.is_hls_ready(),
                "playlist_url": recorder.get_playlist_url(),
                "recording_path": str(recorder.recording_path),
            }

        # Check if recording exists on disk
        playlist_path = RECORDINGS_BASE_PATH / f"room-{room_id}" / "playlist.m3u8"

        if playlist_path.exists():
            # Recording completed
            segments = list(
                (RECORDINGS_BASE_PATH / f"room-{room_id}").glob("segment-*.ts")
            )
            total_size = sum(seg.stat().st_size for seg in segments)

            return {
                "room_id": room_id,
                "status": "completed",
                "is_active": False,
                "segment_count": len(segments),
                "file_size": total_size,
                "playlist_url": f"/videos/hls/{room_id}/playlist.m3u8",
            }

        # Recording not found
        raise HTTPException(status_code=404, detail="Recording not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting recording status for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hls/{room_id}/{segment_name:path}")
async def get_hls_segment(room_id: str, segment_name: str):
    """
    Get HLS segment file for playback

    ⚠️ IMPORTANT: This catch-all route MUST be defined AFTER specific routes
    like /status, /playlist.m3u8 to prevent path conflicts.

    Args:
        room_id: Camera room identifier
        segment_name: Segment filename (e.g., segment-001.ts)
    """
    try:
        # Debug logging
        logger.info(
            f"[HLS] Segment request - Room: {room_id}, Raw segment: '{segment_name}'"
        )

        # Clean segment name: Remove leading/trailing slashes and backslashes
        segment_name = segment_name.strip("/\\")

        if debug := True:  # Enable for troubleshooting
            logger.info(f"[HLS] Cleaned segment name: '{segment_name}'")

        # Security validation AFTER cleaning
        # Prevent directory traversal
        if ".." in segment_name:
            logger.warning(f"[HLS] Directory traversal attempted: {segment_name}")
            raise HTTPException(
                status_code=400,
                detail="Invalid segment name - directory traversal not allowed",
            )

        # Prevent subdirectories (after cleaning, no slashes should remain)
        if "/" in segment_name or "\\" in segment_name:
            logger.warning(
                f"[HLS] Segment name contains path separators after cleaning: {segment_name}"
            )
            raise HTTPException(
                status_code=400,
                detail="Invalid segment name - no subdirectories allowed",
            )

        # Validate file extension (.ts or .m3u8 for playlist)
        if not (
            segment_name.lower().endswith(".ts")
            or segment_name.lower().endswith(".m3u8")
        ):
            logger.warning(f"[HLS] Invalid file type requested: {segment_name}")
            raise HTTPException(
                status_code=400,
                detail=f"Invalid segment name - only .ts or .m3u8 files allowed",
            )

        segment_path = RECORDINGS_BASE_PATH / f"room-{room_id}" / segment_name

        if not segment_path.exists():
            logger.warning(f"Segment not found: {segment_path}")
            raise HTTPException(
                status_code=404, detail=f"Segment not found: {segment_name}"
            )

        return FileResponse(
            path=segment_path,
            media_type="video/MP2T",
            headers={
                "Cache-Control": "public, max-age=31536000",
                "Access-Control-Allow-Origin": "*",
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error serving segment {segment_name} for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# MP4 PLAYBACK ENDPOINTS (Serve recorded MP4 files)
# ============================================================================


@router.get("/mp4/{room_id}/recording.mp4")
async def get_mp4_recording(room_id: str):
    """
    Serve MP4 recording for playback

    Args:
        room_id: Room identifier (e.g., "AMB-001-ROOM-001")

    Returns:
        MP4 file for streaming playback
    """
    try:
        # Construct file path
        recording_dir = RECORDINGS_BASE_PATH / f"room-{room_id}"
        mp4_path = recording_dir / "recording.mp4"

        # Check if file exists
        if not mp4_path.exists():
            logger.warning(f"MP4 not found for room {room_id}: {mp4_path}")
            raise HTTPException(
                status_code=404, detail=f"Recording not found for room {room_id}"
            )

        # Return MP4 file with proper headers for streaming
        return FileResponse(
            path=str(mp4_path),
            media_type="video/mp4",
            headers={
                "Accept-Ranges": "bytes",  # Enable seeking
                "Cache-Control": "no-cache",
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error serving MP4 for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/mp4/{room_id}/status")
async def get_mp4_status(room_id: str):
    """
    Check if MP4 recording is available for playback

    Returns:
        {
            "available": bool,
            "file_size": int,
            "duration": int,
            "url": str
        }
    """
    try:
        recording_dir = RECORDINGS_BASE_PATH / f"room-{room_id}"
        mp4_path = recording_dir / "recording.mp4"

        if mp4_path.exists():
            file_size = mp4_path.stat().st_size
            created_at = datetime.fromtimestamp(mp4_path.stat().st_ctime)

            return {
                "available": True,
                "file_size": file_size,
                "created_at": created_at.isoformat(),
                "url": f"/videos/mp4/{room_id}/recording.mp4",
                "room_id": room_id,
            }
        else:
            return {
                "available": False,
                "room_id": room_id,
            }

    except Exception as e:
        logger.error(f"Error checking MP4 status for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hls/list")
async def list_hls_recordings():
    """
    List all available HLS recordings on disk

    Returns:
        List of room IDs with recording metadata
    """
    try:
        recordings = []

        if not RECORDINGS_BASE_PATH.exists():
            return recordings

        for room_dir in RECORDINGS_BASE_PATH.iterdir():
            if room_dir.is_dir() and room_dir.name.startswith("room-"):
                room_id = room_dir.name.replace("room-", "")
                playlist_path = room_dir / "playlist.m3u8"

                if playlist_path.exists():
                    # Get metadata
                    segments = list(room_dir.glob("segment-*.ts"))
                    total_size = sum(seg.stat().st_size for seg in segments)
                    created_at = datetime.fromtimestamp(playlist_path.stat().st_ctime)

                    recordings.append(
                        {
                            "room_id": room_id,
                            "playlist_url": f"/videos/hls/{room_id}/playlist.m3u8",
                            "segment_count": len(segments),
                            "file_size": total_size,
                            "created_at": created_at.isoformat(),
                            "status": "completed",
                        }
                    )

        return recordings

    except Exception as e:
        logger.error(f"Error listing HLS recordings: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/hls/{room_id}")
async def delete_hls_recording(room_id: str):
    """
    Delete HLS recording from disk

    Args:
        room_id: Camera room identifier to delete
    """
    try:
        import shutil

        recording_path = RECORDINGS_BASE_PATH / f"room-{room_id}"

        if not recording_path.exists():
            raise HTTPException(status_code=404, detail="Recording not found")

        # Check if recording is still active
        if recording_manager.get_recorder(room_id):
            raise HTTPException(
                status_code=400,
                detail="Cannot delete active recording. Stop recording first.",
            )

        # Delete the entire recording directory
        shutil.rmtree(recording_path)

        logger.info(f"Deleted HLS recording for room {room_id}")

        return {
            "success": True,
            "room_id": room_id,
            "message": "Recording deleted successfully",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting recording for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ============================================================================
# PUBLIC HLS ENDPOINTS (No Authentication Required)
# ============================================================================

# Create a separate router for public HLS endpoints (no auth)
public_hls_router = APIRouter()


@public_hls_router.get("/hls/{room_id}/playlist.m3u8")
async def serve_hls_playlist_public(room_id: str):
    """Serve HLS playlist file (public endpoint)"""
    return await get_hls_playlist(room_id)


@public_hls_router.get("/hls/{room_id}/{segment_name:path}")
async def serve_hls_segment_public(room_id: str, segment_name: str):
    """Serve HLS segment file (public endpoint)"""
    return await get_hls_segment(room_id, segment_name)


@public_hls_router.get("/hls/{room_id}/status")
async def get_recording_status_public(room_id: str):
    """Get recording status (public endpoint)"""
    try:
        # Check if recording is active
        recorder = recording_manager.get_recorder(room_id)

        if recorder:
            # Recording is active - include real-time segment info
            return {
                "room_id": room_id,
                "session_id": recorder.session_id,
                "status": "recording",
                "is_active": True,
                "duration": recorder.get_duration(),
                "segment_count": recorder.get_segment_count(),
                "hls_ready": recorder.is_hls_ready(),
                "playlist_url": recorder.get_playlist_url(),
                "recording_path": str(recorder.recording_path),
            }

        # Check if recording exists on disk
        playlist_path = RECORDINGS_BASE_PATH / f"room-{room_id}" / "playlist.m3u8"

        if playlist_path.exists():
            # Recording completed
            segments = list(
                (RECORDINGS_BASE_PATH / f"room-{room_id}").glob("segment-*.ts")
            )
            total_size = sum(seg.stat().st_size for seg in segments)

            return {
                "room_id": room_id,
                "status": "completed",
                "is_active": False,
                "segment_count": len(segments),
                "file_size": total_size,
                "playlist_url": f"/videos/hls/{room_id}/playlist.m3u8",
            }

        # Recording not found
        raise HTTPException(status_code=404, detail="Recording not found")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting recording status for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@public_hls_router.get("/hls/list")
async def list_hls_recordings_public():
    """List all available HLS recordings (public endpoint)"""
    return await list_hls_recordings()


@public_hls_router.get("/hls/segments/{room_id}/events")
async def hls_segment_events_public(request: Request, room_id: str):
    """Public endpoint for HLS segment SSE (no authentication required)"""
    return await hls_segment_events(request, room_id)


# ============================================================================
# TEST ENDPOINTS
# ============================================================================


@public_hls_router.get("/test-player/{room_id}")
async def get_test_player(room_id: str):
    """
    Serve a test HTML page for HLS playback testing

    Example: http://localhost:8000/videos/test-player/AMB-003-ROOM-001
    """
    from fastapi.responses import HTMLResponse

    html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HLS Test Player - {room_id}</title>
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }}
        .container {{
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #333;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }}
        .info {{
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }}
        video {{
            width: 100%;
            max-width: 800px;
            border-radius: 5px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            background: #000;
        }}
        .controls {{
            margin: 20px 0;
        }}
        button {{
            background: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
        }}
        button:hover {{
            background: #45a049;
        }}
        .status {{
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }}
        .status.success {{
            background: #d4edda;
            color: #155724;
        }}
        .status.error {{
            background: #f8d7da;
            color: #721c24;
        }}
        .status.info {{
            background: #d1ecf1;
            color: #0c5460;
        }}
        code {{
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
        }}
        #logs {{
            background: #f4f4f4;
            padding: 15px;
            border-radius: 5px;
            max-height: 300px;
            overflow-y: auto;
            font-family: monospace;
            font-size: 12px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎥 HLS Recording Test Player</h1>
        
        <div class="info">
            <strong>Room ID:</strong> <code>{room_id}</code><br>
            <strong>Playlist URL:</strong> <code id="playlistUrl">http://localhost:8000/videos/hls/{room_id}/playlist.m3u8</code>
        </div>

        <div id="status" class="status info">
            ⏳ Ready to test...
        </div>

        <div class="controls">
            <button onclick="checkPlaylist()">🔍 Check Playlist</button>
            <button onclick="loadVideo()">▶️ Load Stream</button>
            <button onclick="location.reload()">🔄 Refresh</button>
        </div>

        <video id="video" controls autoplay muted></video>

        <h2>📋 Debug Logs</h2>
        <div id="logs">
            <div style="color: #666;">Waiting for actions...</div>
        </div>
    </div>

    <script>
        const video = document.getElementById('video');
        const statusDiv = document.getElementById('status');
        const logsDiv = document.getElementById('logs');
        const playlistUrl = 'http://localhost:8000/videos/hls/{room_id}/playlist.m3u8';
        let hls;

        function log(message, type = 'info') {{
            const timestamp = new Date().toLocaleTimeString();
            const color = type === 'error' ? '#d32f2f' : type === 'success' ? '#388e3c' : '#666';
            logsDiv.innerHTML += `<div style="color: ${{color}}; margin: 5px 0;">[$${{timestamp}}] $${{message}}</div>`;
            logsDiv.scrollTop = logsDiv.scrollHeight;
        }}

        function setStatus(message, type = 'info') {{
            statusDiv.className = `status ${{type}}`;
            statusDiv.innerHTML = message;
        }}

        async function checkPlaylist() {{
            log('🔍 Checking playlist...', 'info');
            try {{
                const response = await fetch(playlistUrl);
                if (response.ok) {{
                    const content = await response.text();
                    log('✅ Playlist found! (' + content.length + ' bytes)', 'success');
                    setStatus('✅ Playlist is available!', 'success');
                }} else {{
                    log('❌ Playlist not found. Status: ' + response.status, 'error');
                    setStatus('❌ Recording not found. Has the stream started?', 'error');
                }}
            }} catch (error) {{
                log('❌ Error: ' + error.message, 'error');
                setStatus('❌ Error: ' + error.message, 'error');
            }}
        }}

        function loadVideo() {{
            if (Hls.isSupported()) {{
                log('✅ HLS.js supported', 'success');
                hls = new Hls({{ debug: true }});
                hls.loadSource(playlistUrl);
                hls.attachMedia(video);

                hls.on(Hls.Events.MANIFEST_PARSED, function() {{
                    log('✅ Stream loaded!', 'success');
                    setStatus('✅ Playing...', 'success');
                    video.play();
                }});

                hls.on(Hls.Events.ERROR, function(event, data) {{
                    log('❌ HLS Error: ' + data.details, 'error');
                    setStatus('❌ Playback error: ' + data.details, 'error');
                }});
            }} else if (video.canPlayType('application/vnd.apple.mpegurl')) {{
                log('✅ Native HLS (Safari)', 'success');
                video.src = playlistUrl;
                video.play();
            }} else {{
                log('❌ HLS not supported', 'error');
                setStatus('❌ Browser not supported', 'error');
            }}
        }}

        // Auto-check on load
        window.addEventListener('load', checkPlaylist);
    </script>
</body>
</html>
    """

    return HTMLResponse(content=html_content)
