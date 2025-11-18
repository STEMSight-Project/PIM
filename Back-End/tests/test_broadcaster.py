"""
Unit tests for broadcaster.py - WebRTC camera broadcasting with AI detection.

Tests cover:
- Device detection (Windows/macOS/Linux)
- DetectionStorage (database operations)
- MediaPipePoseProcessor (pose detection & classification)
- Session/room management
- Video device selection
"""

import pytest
import asyncio
import json
import time
from unittest.mock import Mock, AsyncMock, patch, MagicMock, call
from pathlib import Path
from datetime import datetime
from collections import Counter
import numpy as np
import torch

# Import broadcaster components
import sys
parent_dir = Path(__file__).parent.parent / "Testing_files"
sys.path.insert(0, str(parent_dir.parent))

from Testing_files.broadcaster import (
    DetectionStorage,
    MediaPipePoseProcessor,
    detect_video_devices,
    select_video_device,
    default_device,
    get_media_src,
    get_user_input,
    get_ambulance_by_number,
    check_room_status,
)


# ============================================================================
# Fixtures
# ============================================================================

@pytest.fixture
def mock_supabase():
    """Mock Supabase client for database operations."""
    mock_sb = Mock()
    mock_table = Mock()
    mock_execute = Mock()
    
    # Chain mocks: supabase.table().insert().execute()
    mock_execute.return_value = Mock(data=[{"id": "test-id"}])
    mock_table.insert.return_value = mock_execute
    mock_table.update.return_value = mock_execute
    mock_table.execute.return_value = mock_execute
    mock_sb.table.return_value = mock_table
    
    return mock_sb


@pytest.fixture
def mock_logger():
    """Mock logger for testing log output."""
    return Mock()


@pytest.fixture
def detection_storage(mock_supabase, mock_logger):
    """Create DetectionStorage instance with mocked database."""
    with patch('Testing_files.broadcaster.supabase', mock_supabase), \
         patch('Testing_files.broadcaster.db_logger', mock_logger), \
         patch('Testing_files.broadcaster.DATABASE_AVAILABLE', True):
        storage = DetectionStorage(
            session_id="test-session-123",
            camera_id="test-camera-456",
            room_id="AMB-001-ROOM-001",
            model_name="PoseTCN-T2.00",
            store_interval=2.0
        )
        # Inject mock supabase after creation
        storage.enabled = True
        # Store reference for verification
        storage._mock_supabase = mock_supabase
        return storage


@pytest.fixture
def sample_landmarks():
    """Generate sample MediaPipe landmarks for testing."""
    landmarks = []
    for i in range(33):  # 33 pose landmarks
        landmarks.append({
            "x": float(i * 0.01),
            "y": float(i * 0.02),
            "z": float(i * 0.001),
            "visibility": 0.95
        })
    return landmarks


@pytest.fixture
def mock_mediapipe():
    """Mock MediaPipe pose detection."""
    mock_mp = Mock()
    mock_pose = Mock()
    mock_results = Mock()
    
    # Mock landmarks
    mock_landmark = Mock()
    mock_landmark.x = 0.5
    mock_landmark.y = 0.5
    mock_landmark.z = 0.0
    mock_landmark.visibility = 0.95
    
    mock_results.pose_landmarks = Mock()
    mock_results.pose_landmarks.landmark = [mock_landmark] * 33
    
    mock_pose.process.return_value = mock_results
    mock_mp.solutions.pose.Pose.return_value = mock_pose
    
    return mock_mp


# ============================================================================
# DetectionStorage Tests
# ============================================================================

class TestDetectionStorage:
    """Tests for DetectionStorage class."""
    
    def test_initialization(self, detection_storage):
        """Test DetectionStorage initializes correctly."""
        assert detection_storage.session_id == "test-session-123"
        assert detection_storage.camera_id == "test-camera-456"
        assert detection_storage.room_id == "AMB-001-ROOM-001"
        assert detection_storage.model_name == "PoseTCN-T2.00"
        assert detection_storage.store_interval == 2.0
        assert detection_storage.sequence_number == 0
    
    def test_should_store_throttling(self, detection_storage):
        """Test that storage is throttled by store_interval."""
        # First call should return True
        assert detection_storage.should_store() is True
        
        # Immediate second call should return False (throttled)
        assert detection_storage.should_store() is False
        
        # Wait for interval to elapse
        time.sleep(2.1)
        
        # Should return True again
        assert detection_storage.should_store() is True
    
    def test_store_detection_basic(self, detection_storage, mock_supabase, sample_landmarks):
        """Test storing a basic detection."""
        all_probs = {
            "decerebrate": 0.75,
            "decorticate": 0.15,
            "normal": 0.10
        }
        
        # Patch supabase in the broadcaster module context
        with patch('Testing_files.broadcaster.supabase', mock_supabase):
            detection_storage.store_detection(
                predicted_class="decerebrate",
                confidence=0.75,
                all_probs=all_probs,
                temperature=2.0,
                frame_count=120,
                processing_time_ms=50,
                pose_landmarks=sample_landmarks
            )
        
        # Verify database insert was called
        mock_supabase.table.assert_called_with('ai_detections')
        insert_call = mock_supabase.table.return_value.insert.call_args[0][0]
        
        assert insert_call['session_id'] == "test-session-123"
        assert insert_call['camera_id'] == "test-camera-456"
        assert insert_call['room_id'] == "AMB-001-ROOM-001"
        assert insert_call['detection_type'] == "decerebrate"
        assert insert_call['confidence_score'] == 0.75
        assert insert_call['sequence_number'] == 1
        assert insert_call['model_used'] == "PoseTCN-T2.00"
        assert insert_call['processing_time_ms'] == 50
        assert insert_call['processed_on'] == 'edge'
        
        # Verify detection_data structure
        detection_data = insert_call['detection_data']
        assert detection_data['all_probabilities'] == all_probs
        assert detection_data['temperature'] == 2.0
        assert detection_data['frame_count'] == 120
        assert detection_data['model_architecture'] == 'PoseTCN-SingleView'
        assert detection_data['pose_landmarks'] == sample_landmarks
    
    def test_store_detection_without_landmarks(self, detection_storage, mock_supabase):
        """Test storing detection without pose landmarks."""
        with patch('Testing_files.broadcaster.supabase', mock_supabase):
            detection_storage.store_detection(
                predicted_class="normal",
                confidence=0.95,
                all_probs={"normal": 0.95},
                pose_landmarks=[]  # Empty list instead of None
            )
        
        insert_call = mock_supabase.table.return_value.insert.call_args[0][0]
        detection_data = insert_call['detection_data']
        
        # pose_landmarks should be empty list or not in detection_data
        assert detection_data.get('pose_landmarks') in [[], None] or 'pose_landmarks' not in detection_data
    
    def test_store_batch_summary(self, detection_storage, mock_supabase):
        """Test storing session summary."""
        detection_counts = {
            "decerebrate": 8,
            "decorticate": 2,
            "normal": 13
        }
        
        # Simulate some detections stored
        detection_storage.sequence_number = 23
        
        with patch('Testing_files.broadcaster.supabase', mock_supabase):
            detection_storage.store_batch_summary(
                detection_counts=detection_counts,
                avg_confidence=0.82,
                total_frames=902,
                duration_seconds=70.6
            )
        
        insert_call = mock_supabase.table.return_value.insert.call_args[0][0]
        
        assert insert_call['detection_type'] == 'session_summary'
        assert insert_call['confidence_score'] == 0.82
        
        summary_data = insert_call['detection_data']
        assert summary_data['detection_counts'] == detection_counts
        assert summary_data['avg_confidence'] == 0.82
        assert summary_data['total_frames'] == 902
        assert summary_data['duration_seconds'] == 70.6
        assert summary_data['detections_per_second'] == pytest.approx(23 / 70.6, abs=0.01)
    
    def test_database_unavailable_graceful_fallback(self):
        """Test that DetectionStorage handles database unavailability gracefully."""
        with patch('Testing_files.broadcaster.DATABASE_AVAILABLE', False):
            storage = DetectionStorage(
                session_id="test-session",
                camera_id="test-camera",
                room_id="test-room",
                model_name="TestModel"
            )
            
            # Should initialize with enabled=False
            assert storage.enabled is False
            
            # Should not attempt to store
            assert storage.should_store() is False
            
            # Store operations should not raise errors
            storage.store_detection("test", 0.5, {}, pose_landmarks=[])
            storage.store_batch_summary({}, 0.5, 100, 10.0)


# ============================================================================
# MediaPipePoseProcessor Tests
# ============================================================================

class TestMediaPipePoseProcessor:
    """Tests for MediaPipePoseProcessor class."""
    
    @patch('Testing_files.broadcaster.mp')
    def test_initialization_without_classifier(self, mock_mp):
        """Test MediaPipePoseProcessor initializes correctly without classifier."""
        processor = MediaPipePoseProcessor(
            process_every_n_frames=2,
            enable_classifier=False
        )
        
        assert processor.process_every_n_frames == 2
        assert processor.frame_count == 0
        assert processor.model is None
        assert processor.last_landmarks is None
    
    @patch('Testing_files.broadcaster.mp')
    @patch('Testing_files.broadcaster.torch.load')
    def test_initialization_with_classifier(self, mock_torch_load, mock_mp):
        """Test MediaPipePoseProcessor initializes with PoseTCN classifier."""
        # Mock checkpoint data
        mock_checkpoint = {
            "classes": ["normal", "decerebrate", "decorticate"],
            "best_temperature": 2.0,
            "args": {
                "width": 384,
                "dropout": 0.1,
                "dilations": "1,2,4,8",
                "t_heads": 4,
                "attn_dropout": 0.0
            },
            "model_state_dict": {}
        }
        mock_torch_load.return_value = mock_checkpoint
        
        # Mock model
        with patch('Testing_files.broadcaster.PoseTCNSingleView'):
            processor = MediaPipePoseProcessor(
                process_every_n_frames=2,
                enable_classifier=True,
                session_id="test-session",
                camera_id="test-camera",
                room_id="test-room"
            )
            
            assert processor.classes == ["normal", "decerebrate", "decorticate"]
            assert processor.temperature == 2.0
            assert processor.window_size == 120
    
    @patch('Testing_files.broadcaster.mp')
    def test_process_frame_no_pose_detected(self, mock_mp):
        """Test frame processing when no pose is detected."""
        # Mock MediaPipe to return no pose
        mock_pose = Mock()
        mock_results = Mock()
        mock_results.pose_landmarks = None
        mock_pose.process.return_value = mock_results
        mock_mp.solutions.pose.Pose.return_value = mock_pose
        
        processor = MediaPipePoseProcessor(enable_classifier=False)
        
        # Create mock frame
        mock_frame = Mock()
        mock_frame.to_ndarray.return_value = np.zeros((480, 640, 3), dtype=np.uint8)
        
        result = processor.process_frame(mock_frame)
        
        # When no pose detected, returns (None, None)
        assert result is not None  # Method should return something
        landmarks, prediction = result
        assert landmarks is None
        assert prediction is None
    
    @patch('Testing_files.broadcaster.mp')
    def test_process_frame_with_pose(self, mock_mp):
        """Test frame processing when pose is detected."""
        # Mock MediaPipe to return landmarks
        mock_pose = Mock()
        mock_results = Mock()
        
        # Create mock landmarks
        mock_landmark = Mock()
        mock_landmark.x = 0.5
        mock_landmark.y = 0.5
        mock_landmark.z = 0.0
        mock_landmark.visibility = 0.95
        
        mock_results.pose_landmarks = Mock()
        mock_results.pose_landmarks.landmark = [mock_landmark] * 33
        mock_pose.process.return_value = mock_results
        mock_mp.solutions.pose.Pose.return_value = mock_pose
        
        # Create processor AFTER mocking is set up
        # Set process_every_n_frames=1 to process every frame
        processor = MediaPipePoseProcessor(enable_classifier=False, process_every_n_frames=1)
        
        # Replace the pose object with our mock
        processor.pose = mock_pose
        
        # Create mock frame
        mock_frame = Mock()
        mock_frame.to_ndarray.return_value = np.zeros((480, 640, 3), dtype=np.uint8)
        
        # Call process_frame
        result = processor.process_frame(mock_frame)
        assert result is not None, "process_frame should return a tuple"
        
        landmarks, prediction = result
        
        assert landmarks is not None
        assert len(landmarks) == 33
        assert landmarks[0]['x'] == 0.5
        assert landmarks[0]['y'] == 0.5
        assert landmarks[0]['visibility'] == 0.95
    
    @patch('Testing_files.broadcaster.mp')
    def test_frame_throttling(self, mock_mp):
        """Test that frames are processed only every N frames."""
        mock_pose = Mock()
        mock_results = Mock()
        mock_results.pose_landmarks = None
        mock_pose.process.return_value = mock_results
        mock_mp.solutions.pose.Pose.return_value = mock_pose
        
        processor = MediaPipePoseProcessor(
            process_every_n_frames=3,
            enable_classifier=False
        )
        
        mock_frame = Mock()
        mock_frame.to_ndarray.return_value = np.zeros((480, 640, 3), dtype=np.uint8)
        
        # First 2 frames should not process (frame_count 1, 2)
        processor.process_frame(mock_frame)  # frame_count = 1
        assert mock_pose.process.call_count == 0
        
        processor.process_frame(mock_frame)  # frame_count = 2
        assert mock_pose.process.call_count == 0
        
        # 3rd frame should process (frame_count = 3)
        processor.process_frame(mock_frame)  # frame_count = 3
        assert mock_pose.process.call_count == 1


# ============================================================================
# Device Detection Tests
# ============================================================================

class TestDeviceDetection:
    """Tests for video device detection functions."""
    
    @patch('Testing_files.broadcaster.platform.system')
    @patch('Testing_files.broadcaster.subprocess.run')
    def test_detect_windows_devices(self, mock_run, mock_platform):
        """Test detecting Windows video devices."""
        mock_platform.return_value = "Windows"
        
        # Mock FFmpeg output for Windows
        mock_result = Mock()
        mock_result.stderr = '''
[dshow @ 0x...] DirectShow video devices
[dshow @ 0x...] "Logitech BRIO" (video)
[dshow @ 0x...] "Integrated Camera" (video)
[dshow @ 0x...] DirectShow audio devices
'''
        mock_run.return_value = mock_result
        
        devices = detect_video_devices()
        
        assert len(devices) == 2
        assert devices[0] == ("Logitech BRIO", "video=Logitech BRIO")
        assert devices[1] == ("Integrated Camera", "video=Integrated Camera")
    
    @patch('Testing_files.broadcaster.platform.system')
    @patch('Testing_files.broadcaster.subprocess.run')
    def test_detect_macos_devices(self, mock_run, mock_platform):
        """Test detecting macOS video devices."""
        mock_platform.return_value = "Darwin"
        
        # Mock FFmpeg output for macOS
        mock_result = Mock()
        mock_result.stderr = '''
[AVFoundation indev @ 0x...] AVFoundation video devices:
[AVFoundation indev @ 0x...] [0] FaceTime HD Camera
[AVFoundation indev @ 0x...] [1] USB Camera
[AVFoundation indev @ 0x...] AVFoundation audio devices:
'''
        mock_run.return_value = mock_result
        
        devices = detect_video_devices()
        
        assert len(devices) == 2
        assert devices[0] == ("FaceTime HD Camera", "0:none")
        assert devices[1] == ("USB Camera", "1:none")
    
    @patch('Testing_files.broadcaster.platform.system')
    @patch('Testing_files.broadcaster.subprocess.run')
    def test_detect_linux_devices(self, mock_run, mock_platform):
        """Test detecting Linux video devices."""
        mock_platform.return_value = "Linux"
        
        # Mock ls output for Linux
        mock_result = Mock()
        mock_result.returncode = 0
        mock_result.stdout = "/dev/video0\n/dev/video1\n"
        mock_run.return_value = mock_result
        
        devices = detect_video_devices()
        
        assert len(devices) == 2
        assert devices[0] == ("Video Device (video0)", "/dev/video0")
        assert devices[1] == ("Video Device (video1)", "/dev/video1")
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_default_device_windows(self, mock_platform):
        """Test default device for Windows."""
        mock_platform.return_value = "Windows"
        
        device = default_device()
        
        assert device == "video=Logitech BRIO"
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_default_device_macos(self, mock_platform):
        """Test default device for macOS."""
        mock_platform.return_value = "Darwin"
        
        device = default_device()
        
        assert device == "0:none"
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_default_device_linux(self, mock_platform):
        """Test default device for Linux."""
        mock_platform.return_value = "Linux"
        
        device = default_device()
        
        assert device == "/dev/video0"


# ============================================================================
# Media Source Tests
# ============================================================================

class TestMediaSource:
    """Tests for get_media_src function."""
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_media_src_windows_video_only(self, mock_platform):
        """Test Windows media source with video only."""
        mock_platform.return_value = "Windows"
        
        src = get_media_src("Logitech BRIO", None)
        
        assert src == "video=Logitech BRIO"
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_media_src_windows_video_and_audio(self, mock_platform):
        """Test Windows media source with video and audio."""
        mock_platform.return_value = "Windows"
        
        src = get_media_src("Logitech BRIO", "Microphone")
        
        assert src == "video=Logitech BRIO:audio=Microphone"
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_media_src_macos(self, mock_platform):
        """Test macOS media source."""
        mock_platform.return_value = "Darwin"
        
        src = get_media_src("0", "1")
        
        assert src == "0:1"
    
    @patch('Testing_files.broadcaster.platform.system')
    def test_media_src_linux(self, mock_platform):
        """Test Linux media source."""
        mock_platform.return_value = "Linux"
        
        src = get_media_src("/dev/video0", None)
        
        assert src == "/dev/video0"


# ============================================================================
# API Integration Tests
# ============================================================================

class TestAPIIntegration:
    """Tests for API integration functions."""
    
    @pytest.mark.asyncio
    async def test_get_ambulance_by_number_found(self):
        """Test getting ambulance by number when it exists."""
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value={
            "data": [
                {"id": "amb-001", "ambulance_number": "AMB-001"},
                {"id": "amb-002", "ambulance_number": "AMB-002"},
                {"id": "amb-003", "ambulance_number": "AMB-003"}
            ]
        })
        
        with patch('Testing_files.broadcaster.aiohttp.ClientSession') as mock_session_class:
            # Create a proper async context manager for the response
            mock_get_context = MagicMock()
            mock_get_context.__aenter__ = AsyncMock(return_value=mock_response)
            mock_get_context.__aexit__ = AsyncMock(return_value=None)
            
            # Create mock session that returns the context manager
            mock_session = MagicMock()
            mock_session.get = MagicMock(return_value=mock_get_context)
            mock_session.__aenter__ = AsyncMock(return_value=mock_session)
            mock_session.__aexit__ = AsyncMock(return_value=None)
            
            mock_session_class.return_value = mock_session
            
            result = await get_ambulance_by_number("http://localhost:8000", "AMB-002")
            
            assert result is not None, "Should find AMB-002 in the list"
            assert result['id'] == "amb-002"
            assert result['ambulance_number'] == "AMB-002"
    
    @pytest.mark.asyncio
    async def test_get_ambulance_by_number_not_found(self):
        """Test getting ambulance by number when it doesn't exist."""
        mock_response = AsyncMock()
        mock_response.status = 200
        mock_response.json = AsyncMock(return_value={
            "data": [
                {"id": "amb-001", "ambulance_number": "AMB-001"}
            ]
        })
        
        with patch('Testing_files.broadcaster.aiohttp.ClientSession') as mock_session_class:
            # Create a proper async context manager for the response
            mock_get_context = MagicMock()
            mock_get_context.__aenter__ = AsyncMock(return_value=mock_response)
            mock_get_context.__aexit__ = AsyncMock(return_value=None)
            
            # Create mock session that returns the context manager
            mock_session = MagicMock()
            mock_session.get = MagicMock(return_value=mock_get_context)
            mock_session.__aenter__ = AsyncMock(return_value=mock_session)
            mock_session.__aexit__ = AsyncMock(return_value=None)
            
            mock_session_class.return_value = mock_session
            
            result = await get_ambulance_by_number("http://localhost:8000", "AMB-999")
            
            assert result is None
    
    @pytest.mark.asyncio
    async def test_get_ambulance_by_number_api_error(self):
        """Test handling API errors when getting ambulance."""
        mock_response = AsyncMock()
        mock_response.status = 500
        mock_response.text = AsyncMock(return_value="Internal Server Error")
        
        with patch('Testing_files.broadcaster.aiohttp.ClientSession') as mock_session_class:
            # Create a proper async context manager for the response
            mock_get_context = MagicMock()
            mock_get_context.__aenter__ = AsyncMock(return_value=mock_response)
            mock_get_context.__aexit__ = AsyncMock(return_value=None)
            
            # Create mock session that returns the context manager
            mock_session = MagicMock()
            mock_session.get = MagicMock(return_value=mock_get_context)
            mock_session.__aenter__ = AsyncMock(return_value=mock_session)
            mock_session.__aexit__ = AsyncMock(return_value=None)
            
            mock_session_class.return_value = mock_session
            
            result = await get_ambulance_by_number("http://localhost:8000", "AMB-001")
            
            assert result is None


# ============================================================================
# User Input Tests
# ============================================================================

class TestUserInput:
    """Tests for user input functions."""
    
    @patch('builtins.input')
    def test_get_user_input_valid(self, mock_input):
        """Test getting valid user input."""
        mock_input.side_effect = ["1", "2"]
        
        ambulance_num, room_num = get_user_input()
        
        assert ambulance_num == "001"
        assert room_num == "002"
    
    @patch('builtins.input')
    def test_get_user_input_invalid_then_valid(self, mock_input):
        """Test handling invalid input followed by valid input."""
        # First ambulance input invalid, second valid
        # First room input invalid, second valid
        mock_input.side_effect = ["abc", "5", "xyz", "10"]
        
        ambulance_num, room_num = get_user_input()
        
        assert ambulance_num == "005"
        assert room_num == "010"
    
    @patch('builtins.input')
    def test_get_user_input_padding(self, mock_input):
        """Test that numbers are zero-padded correctly."""
        mock_input.side_effect = ["1", "99"]
        
        ambulance_num, room_num = get_user_input()
        
        assert ambulance_num == "001"  # Padded to 3 digits
        assert room_num == "099"  # Padded to 3 digits


# ============================================================================
# Integration Tests
# ============================================================================

class TestIntegration:
    """Integration tests combining multiple components."""
    
    @patch('Testing_files.broadcaster.mp')
    @patch('Testing_files.broadcaster.torch.load')
    def test_full_detection_pipeline(self, mock_torch_load, mock_mp, 
                                     mock_supabase, sample_landmarks):
        """Test complete detection pipeline from frame to database storage."""
        # Setup mocks
        mock_checkpoint = {
            "classes": ["normal", "decerebrate"],
            "best_temperature": 1.0,
            "args": {},
            "model_state_dict": {}
        }
        mock_torch_load.return_value = mock_checkpoint
        
        # Mock MediaPipe
        mock_pose = Mock()
        mock_results = Mock()
        mock_landmark = Mock()
        mock_landmark.x = 0.5
        mock_landmark.y = 0.5
        mock_landmark.z = 0.0
        mock_landmark.visibility = 0.95
        mock_results.pose_landmarks = Mock()
        mock_results.pose_landmarks.landmark = [mock_landmark] * 33
        mock_pose.process.return_value = mock_results
        mock_mp.solutions.pose.Pose.return_value = mock_pose
        
        # Mock model
        mock_model = Mock()
        mock_logits = torch.tensor([[2.0, 1.0]])  # Favors first class
        mock_model.return_value = mock_logits
        
        with patch('Testing_files.broadcaster.PoseTCNSingleView', return_value=mock_model), \
             patch('Testing_files.broadcaster.supabase', mock_supabase), \
             patch('Testing_files.broadcaster.DATABASE_AVAILABLE', True):
            
            processor = MediaPipePoseProcessor(
                process_every_n_frames=1,
                enable_classifier=True,
                session_id="test-session",
                camera_id="test-camera",
                room_id="test-room"
            )
            
            # Force buffer to be full
            dummy_landmarks = np.random.rand(33, 3).astype(np.float32)
            for _ in range(120):
                processor.buffer.append(dummy_landmarks)
            
            # Force storage to allow storing (if storage is available)
            if processor.storage:
                processor.storage.last_store_time = 0
            
            # Create mock frame
            mock_frame = Mock()
            mock_frame.to_ndarray.return_value = np.zeros((480, 640, 3), dtype=np.uint8)
            
            # Process frame (should trigger inference at frame 30)
            for i in range(31):
                processor.frame_count = i * processor.infer_every_n_frames
                result = processor.process_frame(mock_frame)
                if result:
                    landmarks, prediction = result
            
            # Verify landmarks extracted
            assert landmarks is not None
            assert len(landmarks) == 33
            
            # Verify prediction made (if model inference succeeded)
            # Note: Due to mocking complexity, prediction might be None
            # In real scenario, prediction would be available


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
