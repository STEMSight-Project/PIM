"""
Unit tests for recording_service.py
Tests HLS recording functionality including FFmpeg pipeline, database operations, and file management.
"""
import pytest
import asyncio
from pathlib import Path
from unittest.mock import Mock, MagicMock, AsyncMock, patch, mock_open
from datetime import datetime

from services.streaming.recording_service import SessionRecorder, RecordingManager


class TestSessionRecorder:
    """Test SessionRecorder class"""

    def test_init(self, sample_session_data):
        """Test SessionRecorder initialization"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        assert recorder.session_id == sample_session_data["session_id"]
        assert recorder.room_id == sample_session_data["room_id"]
        assert recorder.ambulance_number == sample_session_data["ambulance_number"]
        assert recorder.is_recording is False
        assert recorder.frame_count == 0

    def test_get_duration_no_start_time(self, sample_session_data):
        """Test get_duration when recording hasn't started"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        assert recorder.get_duration() == 0

    def test_get_duration_with_start_time(self, sample_session_data):
        """Test get_duration with active recording"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        recorder.start_time = datetime.utcnow()
        duration = recorder.get_duration()
        
        assert duration >= 0
        assert isinstance(duration, int)

    def test_get_segment_count_no_directory(self, sample_session_data, tmp_path):
        """Test get_segment_count when recording directory doesn't exist"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        # Override recording path to non-existent directory
        recorder.recording_path = tmp_path / "non-existent"
        
        assert recorder.get_segment_count() == 0

    def test_get_segment_count_with_segments(self, sample_session_data, temp_recording_dir):
        """Test get_segment_count with existing segments"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        recorder.recording_path = temp_recording_dir
        
        # Create mock segment files
        for i in range(5):
            (temp_recording_dir / f"segment-{i:03d}.ts").touch()
        
        assert recorder.get_segment_count() == 5

    def test_is_hls_ready_false(self, sample_session_data, temp_recording_dir):
        """Test is_hls_ready returns False without playlist"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        recorder.recording_path = temp_recording_dir
        recorder.playlist_path = temp_recording_dir / "playlist.m3u8"
        
        assert recorder.is_hls_ready() is False

    def test_is_hls_ready_true(self, sample_session_data, temp_recording_dir):
        """Test is_hls_ready returns True with playlist and segments"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        recorder.recording_path = temp_recording_dir
        recorder.playlist_path = temp_recording_dir / "playlist.m3u8"
        
        # Create playlist and segments
        recorder.playlist_path.touch()
        for i in range(5):
            (temp_recording_dir / f"segment-{i:03d}.ts").touch()
        
        assert recorder.is_hls_ready() is True

    def test_get_playlist_url(self, sample_session_data):
        """Test get_playlist_url returns correct URL"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        expected_url = f"/videos/hls/{sample_session_data['room_id']}/playlist.m3u8"
        assert recorder.get_playlist_url() == expected_url

    @pytest.mark.asyncio
    async def test_upload_to_supabase_storage_no_file(self, sample_session_data, tmp_path, mock_supabase):
        """Test upload fails gracefully when MP4 doesn't exist"""
        with patch('services.streaming.recording_service.SUPABASE_ADMIN', mock_supabase):
            recorder = SessionRecorder(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"]
            )
            
            recorder.mp4_path = tmp_path / "non-existent.mp4"
            
            result = await recorder._upload_to_supabase_storage()
            
            assert result is None

    @pytest.mark.asyncio
    async def test_upload_to_supabase_storage_success(self, sample_session_data, temp_recording_dir, mock_supabase):
        """Test successful upload to Supabase"""
        with patch('services.streaming.recording_service.SUPABASE_ADMIN', mock_supabase):
            recorder = SessionRecorder(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"]
            )
            
            recorder.start_time = datetime.utcnow()
            recorder.mp4_path = temp_recording_dir / "recording.mp4"
            
            # Create dummy MP4 file
            recorder.mp4_path.write_bytes(b"fake video data" * 1000)
            
            result = await recorder._upload_to_supabase_storage()
            
            assert result is not None
            assert "https://" in result

    @pytest.mark.asyncio
    async def test_create_recording_database_entry(self, sample_session_data, mock_supabase):
        """Test database entry creation"""
        with patch('services.streaming.recording_service.SUPABASE_ADMIN', mock_supabase):
            recorder = SessionRecorder(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"]
            )
            
            recorder.start_time = datetime.utcnow()
            
            await recorder._create_recording_database_entry(
                storage_url="https://storage.supabase.co/test.mp4",
                storage_path="recordings/session/room.mp4",
                file_size=1024 * 1024,
                duration=120
            )
            
            # Verify insert was called
            mock_supabase.table.assert_called_with("ambulance_session_recordings")

    @pytest.mark.asyncio
    async def test_cleanup_hls_files(self, sample_session_data, temp_recording_dir):
        """Test HLS file cleanup"""
        recorder = SessionRecorder(
            session_id=sample_session_data["session_id"],
            room_id=sample_session_data["room_id"],
            ambulance_number=sample_session_data["ambulance_number"]
        )
        
        recorder.recording_path = temp_recording_dir
        recorder.playlist_path = temp_recording_dir / "playlist.m3u8"
        recorder.mp4_path = temp_recording_dir / "recording.mp4"
        
        # Create files to clean up
        recorder.playlist_path.touch()
        recorder.mp4_path.write_bytes(b"video data")
        for i in range(3):
            (temp_recording_dir / f"segment-{i:03d}.ts").touch()
        
        await recorder._cleanup_hls_files()
        
        # Verify files are deleted
        assert not recorder.playlist_path.exists()
        assert not recorder.mp4_path.exists()
        assert len(list(temp_recording_dir.glob("segment-*.ts"))) == 0


class TestRecordingManager:
    """Test RecordingManager class"""

    def test_init(self):
        """Test RecordingManager initialization"""
        manager = RecordingManager()
        
        assert isinstance(manager.active_recorders, dict)
        assert len(manager.active_recorders) == 0

    @pytest.mark.asyncio
    async def test_start_session_recording(self, sample_session_data, mock_video_track):
        """Test starting a session recording"""
        with patch('services.streaming.recording_service.SessionRecorder.start_recording', new_callable=AsyncMock):
            manager = RecordingManager()
            
            recorder = await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"],
                video_track=mock_video_track
            )
            
            assert sample_session_data["room_id"] in manager.active_recorders
            assert recorder is not None

    @pytest.mark.asyncio
    async def test_start_session_recording_already_active(self, sample_session_data, mock_video_track):
        """Test starting recording when already active returns existing recorder"""
        with patch('services.streaming.recording_service.SessionRecorder.start_recording', new_callable=AsyncMock):
            manager = RecordingManager()
            
            # Start first recording
            recorder1 = await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"],
                video_track=mock_video_track
            )
            
            # Try to start again
            recorder2 = await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"],
                video_track=mock_video_track
            )
            
            assert recorder1 is recorder2

    @pytest.mark.asyncio
    async def test_stop_session_recording(self, sample_session_data, mock_video_track):
        """Test stopping a session recording"""
        with patch('services.streaming.recording_service.SessionRecorder.start_recording', new_callable=AsyncMock), \
             patch('services.streaming.recording_service.SessionRecorder.stop_recording', new_callable=AsyncMock):
            
            manager = RecordingManager()
            
            # Start recording
            await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id=sample_session_data["room_id"],
                ambulance_number=sample_session_data["ambulance_number"],
                video_track=mock_video_track
            )
            
            # Stop recording
            await manager.stop_session_recording(sample_session_data["room_id"])
            
            assert sample_session_data["room_id"] not in manager.active_recorders

    @pytest.mark.asyncio
    async def test_stop_session_recording_not_found(self, sample_session_data):
        """Test stopping non-existent recording handles gracefully"""
        manager = RecordingManager()
        
        # Should not raise exception
        await manager.stop_session_recording("non-existent-room")

    def test_get_recorder(self, sample_session_data):
        """Test getting active recorder"""
        manager = RecordingManager()
        
        # Add mock recorder
        mock_recorder = MagicMock()
        manager.active_recorders[sample_session_data["room_id"]] = mock_recorder
        
        result = manager.get_recorder(sample_session_data["room_id"])
        
        assert result is mock_recorder

    def test_get_recorder_not_found(self):
        """Test getting non-existent recorder returns None"""
        manager = RecordingManager()
        
        result = manager.get_recorder("non-existent-room")
        
        assert result is None

    @pytest.mark.asyncio
    async def test_stop_all_recordings(self, sample_session_data, mock_video_track):
        """Test stopping all active recordings"""
        with patch('services.streaming.recording_service.SessionRecorder.start_recording', new_callable=AsyncMock), \
             patch('services.streaming.recording_service.SessionRecorder.stop_recording', new_callable=AsyncMock):
            
            manager = RecordingManager()
            
            # Start multiple recordings
            await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id="AMB-001-ROOM-001",
                ambulance_number="001",
                video_track=mock_video_track
            )
            
            await manager.start_session_recording(
                session_id=sample_session_data["session_id"],
                room_id="AMB-001-ROOM-002",
                ambulance_number="001",
                video_track=mock_video_track
            )
            
            # Stop all
            await manager.stop_all_recordings()
            
            assert len(manager.active_recorders) == 0
