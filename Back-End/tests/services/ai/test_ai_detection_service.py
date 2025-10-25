"""
Pytest tests for AI Detection Service
Tests database operations for AI detection records
"""

import pytest
from unittest.mock import Mock, patch, AsyncMock
from services.ai.ai_detection_service import AIDetectionService


class TestAIDetectionService:
    """Test AI Detection database service"""

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_create_detection(self, mock_supabase):
        """Test creating a detection record"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {
                "id": 1,
                "video_id": 1,
                "patient_id": 1,
                "movement_type": "tremor",
                "confidence_score": 0.95,
            }
        ]

        mock_table = Mock()
        mock_table.insert = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Create detection
        result = await AIDetectionService.create_detection(
            video_id=1,
            patient_id=1,
            movement_type="tremor",
            movement_id=8,
            confidence_score=0.95,
            model_accuracy=100.0,
            tier="excellent",
            recommendation="High confidence",
            all_probabilities={"tremor": 0.95},
            requires_review=False,
        )

        # Verify
        assert result is not None
        assert result["movement_type"] == "tremor"
        mock_table.insert.assert_called_once()

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_get_detections_by_video(self, mock_supabase):
        """Test getting detections for a video"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {"id": 1, "video_id": 1, "movement_type": "tremor"},
            {"id": 2, "video_id": 1, "movement_type": "dystonia"},
        ]

        mock_table = Mock()
        mock_table.select = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.order = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Get detections
        result = await AIDetectionService.get_detections_by_video(video_id=1)

        # Verify
        assert len(result) == 2
        assert result[0]["movement_type"] == "tremor"
        mock_table.eq.assert_called_with("video_id", 1)

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_get_detections_by_patient(self, mock_supabase):
        """Test getting detections for a patient"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {"id": 1, "patient_id": 1, "movement_type": "tremor"},
            {"id": 2, "patient_id": 1, "movement_type": "myoclonus"},
        ]

        mock_table = Mock()
        mock_table.select = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.order = Mock(return_value=mock_table)
        mock_table.limit = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Get detections
        result = await AIDetectionService.get_detections_by_patient(
            patient_id=1, limit=50
        )

        # Verify
        assert len(result) == 2
        mock_table.eq.assert_called_with("patient_id", 1)
        mock_table.limit.assert_called_with(50)

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_get_detections_requiring_review(self, mock_supabase):
        """Test getting detections requiring review"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {
                "id": 1,
                "requires_review": True,
                "reviewed": False,
                "movement_type": "myoclonus",
            }
        ]

        mock_table = Mock()
        mock_table.select = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.order = Mock(return_value=mock_table)
        mock_table.limit = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Get detections
        result = await AIDetectionService.get_detections_requiring_review(limit=100)

        # Verify
        assert len(result) == 1
        assert result[0]["requires_review"] is True

        # Verify eq was called twice (for requires_review and reviewed)
        assert mock_table.eq.call_count == 2

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_mark_as_reviewed(self, mock_supabase):
        """Test marking detection as reviewed"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {"id": 1, "reviewed": True, "physician_diagnosis": "Confirmed tremor"}
        ]

        mock_table = Mock()
        mock_table.update = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Mark as reviewed
        result = await AIDetectionService.mark_as_reviewed(
            detection_id=1,
            reviewed_by=10,
            physician_diagnosis="Confirmed tremor",
            physician_notes="Patient shows classic tremor symptoms",
        )

        # Verify
        assert result is not None
        assert result["reviewed"] is True
        mock_table.update.assert_called_once()
        mock_table.eq.assert_called_with("id", 1)

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_get_detection_statistics(self, mock_supabase):
        """Test getting detection statistics"""
        # Mock response
        mock_result = Mock()
        mock_result.data = [
            {
                "tier": "excellent",
                "movement_type": "tremor",
                "requires_review": False,
                "reviewed": False,
                "confidence_score": 0.95,
            },
            {
                "tier": "excellent",
                "movement_type": "tremor",
                "requires_review": False,
                "reviewed": True,
                "confidence_score": 0.90,
            },
            {
                "tier": "needs_review",
                "movement_type": "myoclonus",
                "requires_review": True,
                "reviewed": False,
                "confidence_score": 0.70,
            },
        ]

        mock_table = Mock()
        mock_table.select = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Get statistics
        stats = await AIDetectionService.get_detection_statistics()

        # Verify
        assert stats["total_detections"] == 3
        assert stats["by_tier"]["excellent"] == 2
        assert stats["by_tier"]["needs_review"] == 1
        assert stats["by_movement"]["tremor"] == 2
        assert stats["by_movement"]["myoclonus"] == 1
        assert stats["requiring_review"] == 1
        assert stats["reviewed"] == 1
        assert 0.8 < stats["avg_confidence"] < 0.9  # Average of 0.95, 0.90, 0.70

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_get_statistics_with_patient_filter(self, mock_supabase):
        """Test getting statistics filtered by patient"""
        mock_result = Mock()
        mock_result.data = []

        mock_table = Mock()
        mock_table.select = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Get statistics for specific patient
        stats = await AIDetectionService.get_detection_statistics(patient_id=1)

        # Verify patient filter was applied
        mock_table.eq.assert_called_with("patient_id", 1)
        assert stats["total_detections"] == 0

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_delete_detection(self, mock_supabase):
        """Test deleting a detection"""
        mock_result = Mock()

        mock_table = Mock()
        mock_table.delete = Mock(return_value=mock_table)
        mock_table.eq = Mock(return_value=mock_table)
        mock_table.execute = Mock(return_value=mock_result)
        mock_supabase.table = Mock(return_value=mock_table)

        # Delete detection
        result = await AIDetectionService.delete_detection(detection_id=1)

        # Verify
        assert result is True
        mock_table.delete.assert_called_once()
        mock_table.eq.assert_called_with("id", 1)

    @pytest.mark.asyncio
    @patch("services.ai.ai_detection_service.supabase")
    async def test_create_detection_error_handling(self, mock_supabase):
        """Test error handling when creating detection"""
        mock_supabase.table.side_effect = Exception("Database connection error")

        # Should raise exception
        with pytest.raises(Exception, match="Database connection error"):
            await AIDetectionService.create_detection(
                video_id=1,
                patient_id=1,
                movement_type="tremor",
                movement_id=8,
                confidence_score=0.95,
                model_accuracy=100.0,
                tier="excellent",
                recommendation="Test",
                all_probabilities={},
                requires_review=False,
            )
