"""
Test suite for first frame verification before room status update.

This ensures that camera rooms are only marked as "connected" after
actual video data is received, not just when the WebRTC connection is established.
"""

import pytest
import asyncio
from unittest.mock import Mock, AsyncMock, patch
from services.streaming.room_service import Room, RoomManager
from aiortc import RTCPeerConnection


@pytest.fixture
def mock_db_service():
    """Mock database service for testing."""
    with patch(
        "services.streaming.room_service.StreamingDatabaseService"
    ) as mock_service:
        mock_instance = Mock()
        mock_instance.update_camera_room_status = AsyncMock()
        mock_instance.end_ambulance_session = AsyncMock()
        mock_service.return_value = mock_instance
        yield mock_instance


@pytest.fixture
def test_room(mock_db_service):
    """Create a test room instance."""
    room = Room(
        room_id="AMB-001-ROOM-001", session_id="test-session-123", room_db_id="room-db-1"
    )
    room._db_service = mock_db_service
    return room


class TestFirstFrameVerification:
    """Test suite for first frame verification logic."""

    @pytest.mark.asyncio
    async def test_room_initialization_with_first_frame_flags(self, test_room):
        """Test that room initializes with correct first frame tracking flags."""
        assert test_room._first_frame_received == False
        assert test_room._waiting_for_first_frame == False
        assert test_room.room_db_id == "room-db-1"

    @pytest.mark.asyncio
    async def test_streamer_connection_waits_for_first_frame(
        self, test_room, mock_db_service
    ):
        """Test that adding streamer connection does NOT immediately update database."""
        # Create mock peer connection
        mock_pc = Mock(spec=RTCPeerConnection)

        # Add streamer connection
        test_room.add_peer_connection(mock_pc, is_streamer=True)

        # Give async tasks time to run
        await asyncio.sleep(0.1)

        # Verify streamer was added
        assert len(test_room.streamer_pcs) == 1
        assert test_room._waiting_for_first_frame == True
        assert test_room._first_frame_received == False

        # Verify database was NOT updated yet (waiting for first frame)
        mock_db_service.update_camera_room_status.assert_not_called()

    @pytest.mark.asyncio
    async def test_first_frame_triggers_database_update(
        self, test_room, mock_db_service
    ):
        """Test that receiving first frame triggers database update to connected."""
        # Setup: Add streamer connection first
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)

        # Reset mock to clear any potential calls during setup
        mock_db_service.update_camera_room_status.reset_mock()

        # Simulate receiving first frame
        test_room.update_stream_activity()

        # Give async task time to run
        await asyncio.sleep(0.2)

        # Verify first frame flag was set
        assert test_room._first_frame_received == True

        # Verify database was updated to connected=True
        mock_db_service.update_camera_room_status.assert_called_once_with(
            "room-db-1", connected=True
        )

    @pytest.mark.asyncio
    async def test_subsequent_frames_dont_trigger_database_update(
        self, test_room, mock_db_service
    ):
        """Test that subsequent frames after first don't trigger redundant database updates."""
        # Setup: Add streamer and simulate first frame
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Reset mock to count only new calls
        mock_db_service.update_camera_room_status.reset_mock()

        # Simulate multiple subsequent frames
        test_room.update_stream_activity()
        test_room.update_stream_activity()
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify database was NOT updated again
        mock_db_service.update_camera_room_status.assert_not_called()

    @pytest.mark.asyncio
    async def test_viewer_connection_does_not_affect_first_frame_logic(
        self, test_room, mock_db_service
    ):
        """Test that adding viewers doesn't affect first frame verification."""
        # Add viewer connection (not a streamer)
        mock_viewer_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_viewer_pc, is_streamer=False)

        await asyncio.sleep(0.1)

        # Verify viewer was added but first frame flags not set
        assert len(test_room.viewer_pcs) == 1
        assert test_room._waiting_for_first_frame == False
        assert test_room._first_frame_received == False

        # Verify database was NOT updated
        mock_db_service.update_camera_room_status.assert_not_called()

    @pytest.mark.asyncio
    async def test_connection_info_includes_first_frame_status(self, test_room):
        """Test that get_connection_info includes first frame status."""
        # Add streamer
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)

        # Check connection info before first frame
        info = test_room.get_connection_info()
        assert info["first_frame_received"] == False
        assert info["waiting_for_first_frame"] == True

        # Simulate first frame
        test_room.update_stream_activity()
        await asyncio.sleep(0.1)

        # Check connection info after first frame
        info = test_room.get_connection_info()
        assert info["first_frame_received"] == True

    @pytest.mark.asyncio
    async def test_reconnection_preserves_first_frame_status(
        self, test_room, mock_db_service
    ):
        """Test that reconnection doesn't reset first frame status."""
        # Setup: Initial connection and first frame
        mock_pc1 = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc1, is_streamer=True)
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify first frame received
        assert test_room._first_frame_received == True
        
        # Record call count after first connection and first frame
        # Should be 1 call (connected=True on first frame)
        call_count_after_first = (
            mock_db_service.update_camera_room_status.call_count
        )
        assert call_count_after_first == 1
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=True
        )

        # Reset mock to track new calls
        mock_db_service.update_camera_room_status.reset_mock()

        # Simulate disconnection
        test_room.remove_peer_connection(mock_pc1)
        await asyncio.sleep(0.2)
        
        # Should have 1 disconnect call
        assert mock_db_service.update_camera_room_status.call_count == 1
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=False
        )

        # Reset mock again
        mock_db_service.update_camera_room_status.reset_mock()

        # Simulate reconnection
        mock_pc2 = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc2, is_streamer=True)
        await asyncio.sleep(0.2)

        # Verify first frame status preserved (no reset)
        assert test_room._first_frame_received == True
        assert test_room._waiting_for_first_frame == False
        
        # Should have 1 reconnection call (connected=True immediately since first frame already received)
        assert mock_db_service.update_camera_room_status.call_count == 1
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=True
        )

        # Simulate frame after reconnection
        mock_db_service.update_camera_room_status.reset_mock()
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify database NOT updated again (already marked as connected, first frame already received)
        assert mock_db_service.update_camera_room_status.call_count == 0

    @pytest.mark.asyncio
    async def test_no_database_update_without_room_db_id(self, mock_db_service):
        """Test that rooms without room_db_id don't attempt database updates."""
        # Create room without room_db_id
        room = Room(room_id="AMB-002-ROOM-001", session_id="test-session-456")
        room._db_service = mock_db_service

        # Add streamer
        mock_pc = Mock(spec=RTCPeerConnection)
        room.add_peer_connection(mock_pc, is_streamer=True)

        # Simulate first frame
        room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify database was NOT called (no room_db_id)
        mock_db_service.update_camera_room_status.assert_not_called()

    @pytest.mark.asyncio
    async def test_activity_monitor_starts_with_streamer(self, test_room):
        """Test that activity monitoring starts when streamer connects."""
        # Add streamer
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)

        # Verify activity monitor was started
        assert test_room.activity_monitor.is_monitoring == True

    @pytest.mark.asyncio
    async def test_multiple_streamers_only_one_database_update(
        self, test_room, mock_db_service
    ):
        """Test that adding multiple streamers only triggers one database update on first frame."""
        # Add first streamer
        mock_pc1 = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc1, is_streamer=True)

        # Add second streamer
        mock_pc2 = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc2, is_streamer=True)

        # Simulate first frame
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify database was updated only once
        assert mock_db_service.update_camera_room_status.call_count == 1
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=True
        )


class TestEndToEndScenario:
    """End-to-end scenario tests for realistic workflows."""

    @pytest.mark.asyncio
    async def test_complete_connection_flow(self, test_room, mock_db_service):
        """Test complete flow: connect → first frame → data streaming → disconnect."""
        # Step 1: Streamer connects
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)
        await asyncio.sleep(0.1)

        # Verify waiting for first frame
        assert test_room._waiting_for_first_frame == True
        assert test_room._first_frame_received == False
        assert mock_db_service.update_camera_room_status.call_count == 0

        # Step 2: First frame arrives
        test_room.update_stream_activity()
        await asyncio.sleep(0.2)

        # Verify database updated
        assert test_room._first_frame_received == True
        assert mock_db_service.update_camera_room_status.call_count == 1
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=True
        )

        # Step 3: More frames arrive (normal streaming)
        mock_db_service.update_camera_room_status.reset_mock()
        for _ in range(10):
            test_room.update_stream_activity()
        await asyncio.sleep(0.1)

        # Verify no additional database updates
        assert mock_db_service.update_camera_room_status.call_count == 0

        # Step 4: Streamer disconnects
        mock_db_service.update_camera_room_status.reset_mock()
        test_room.remove_peer_connection(mock_pc)
        await asyncio.sleep(0.2)

        # Verify database updated to disconnected
        mock_db_service.update_camera_room_status.assert_called_with(
            "room-db-1", connected=False
        )

    @pytest.mark.asyncio
    async def test_camera_fails_to_send_data(self, test_room, mock_db_service):
        """Test scenario where camera connects but never sends data."""
        # Streamer connects
        mock_pc = Mock(spec=RTCPeerConnection)
        test_room.add_peer_connection(mock_pc, is_streamer=True)
        await asyncio.sleep(0.1)

        # Wait some time (simulating no data)
        await asyncio.sleep(0.5)

        # Verify room is waiting but never marked as connected
        assert test_room._waiting_for_first_frame == True
        assert test_room._first_frame_received == False
        mock_db_service.update_camera_room_status.assert_not_called()

        # Disconnect
        test_room.remove_peer_connection(mock_pc)
        await asyncio.sleep(0.2)

        # Verify database updated to disconnected
        mock_db_service.update_camera_room_status.assert_called_once_with(
            "room-db-1", connected=False
        )


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
