from datetime import datetime
from typing import Optional, List
from pathlib import Path
from pydantic import BaseModel
from core.common import supabase, logger
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from security.jwt_verify import current_user
from services.video_service import VideoService
from services.streaming.recording_service import recording_manager, RECORDINGS_BASE_PATH

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
    file_path: Optional[str]
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
    Get all recordings for a specific ambulance session.
    """
    try:
        recordings = await VideoService.get_recordings_by_session(session_id)
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
                "Cache-Control": "public, max-age=3600",
                "Access-Control-Allow-Origin": "*",
            },
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error serving HLS playlist for {room_id}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hls/{room_id}/{segment_name}")
async def get_hls_segment(room_id: str, segment_name: str):
    """
    Get HLS segment file for playback

    Args:
        room_id: Camera room identifier
        segment_name: Segment filename (e.g., segment-001.ts)
    """
    try:
        # Security: Validate segment name to prevent path traversal
        if (
            not segment_name.endswith(".ts")
            or ".." in segment_name
            or "/" in segment_name
        ):
            raise HTTPException(status_code=400, detail="Invalid segment name")

        segment_path = RECORDINGS_BASE_PATH / f"room-{room_id}" / segment_name

        if not segment_path.exists():
            raise HTTPException(status_code=404, detail="Segment not found")

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


@router.get("/hls/{room_id}/status")
async def get_recording_status(room_id: str):
    """
    Get status of a camera room recording (active or completed)
    Includes real-time segment count for monitoring HLS creation
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


@public_hls_router.get("/hls/{room_id}/{segment_name}")
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
