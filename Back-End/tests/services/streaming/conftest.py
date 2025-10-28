"""
Pytest fixtures for streaming service tests
"""
import asyncio
import pytest
from pathlib import Path
from unittest.mock import Mock, MagicMock, AsyncMock, patch
from datetime import datetime


@pytest.fixture
def event_loop():
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
def mock_supabase():
    """Mock Supabase client"""
    mock = MagicMock()
    
    # Mock table operations
    mock_table = MagicMock()
    mock_table.insert.return_value.execute.return_value.data = [{"id": "test-id-123"}]
    mock_table.update.return_value.eq.return_value.execute.return_value.data = [{"id": "test-id-123"}]
    mock_table.select.return_value.eq.return_value.execute.return_value.data = []
    
    mock.table.return_value = mock_table
    
    # Mock storage operations
    mock_storage = MagicMock()
    mock_storage.upload.return_value = {"path": "test/path.mp4"}
    mock_storage.get_public_url.return_value = "https://storage.supabase.co/test/path.mp4"
    
    mock.storage.from_.return_value = mock_storage
    
    return mock


@pytest.fixture
def mock_ffmpeg_process():
    """Mock FFmpeg subprocess"""
    mock = MagicMock()
    mock.pid = 12345
    mock.stdin = MagicMock()
    mock.stdout = MagicMock()
    mock.stderr = MagicMock()
    mock.returncode = 0
    mock.wait = MagicMock()
    mock.terminate = MagicMock()
    mock.kill = MagicMock()
    return mock


@pytest.fixture
def mock_video_track():
    """Mock WebRTC video track"""
    mock = AsyncMock()
    
    # Mock frame
    mock_frame = MagicMock()
    mock_frame.to_ndarray.return_value = MagicMock()
    
    mock.recv.return_value = mock_frame
    return mock


@pytest.fixture
def temp_recording_dir(tmp_path):
    """Create temporary recording directory"""
    recording_dir = tmp_path / "recordings"
    recording_dir.mkdir()
    return recording_dir


@pytest.fixture
def sample_session_data():
    """Sample session data for testing"""
    return {
        "session_id": "test-session-uuid-1234",
        "room_id": "AMB-001-ROOM-001",
        "ambulance_number": "001",
        "camera_id": "AMB-001-CAM-01"
    }


@pytest.fixture
def sample_recording_metadata():
    """Sample recording metadata"""
    return {
        "duration": 120,
        "file_size": 1024 * 1024 * 10,  # 10 MB
        "segment_count": 4,
        "started_at": datetime.utcnow().isoformat(),
        "ended_at": datetime.utcnow().isoformat(),
        "status": "completed"
    }
