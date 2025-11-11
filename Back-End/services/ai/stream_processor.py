"""
Stream Movement Processor
Automatically processes video streams for movement detection
Integrates MediaPipe → AI Classifier → Database
"""

import asyncio
import numpy as np
from collections import deque
from typing import Optional, Dict, List
from datetime import datetime
import logging

from services.ai.pim_classifier_service import get_classifier_service
from services.ai.ai_detection_service import AIDetectionService

logger = logging.getLogger(__name__)


class StreamMovementProcessor:
    """
    Processes video streams for automatic movement detection.
    Buffers skeleton data and triggers AI classification.

    Note: room_id parameter stores the room_name (display name like "AMB-001-ROOM-001").
    """

    def __init__(
        self,
        session_id: str,
        camera_id: str,
        video_id: int,
        patient_id: int,
        room_id: str = None,  # This is actually room_name (e.g., "AMB-001-ROOM-001")
        window_size: int = 60,
        stride: int = 30,
        min_confidence: float = 0.70,
    ):
        """
        Initialize stream processor

        Args:
            session_id: Streaming session ID
            camera_id: Camera ID
            video_id: ID of the video being processed
            patient_id: ID of the patient
            room_id: Optional room name (e.g., "AMB-001-ROOM-001")
            window_size: Number of frames to collect before prediction
            stride: Number of frames to move window (for overlapping detection)
            min_confidence: Minimum confidence to save detection
        """
        self.session_id = session_id
        self.camera_id = camera_id
        self.video_id = video_id
        self.patient_id = patient_id
        self.room_id = room_id
        self.window_size = window_size
        self.stride = stride
        self.min_confidence = min_confidence

        # Frame buffer (sliding window)
        self.frame_buffer = deque(maxlen=window_size)

        # Classifier service
        self.classifier = get_classifier_service()

        # Detection tracking
        self.detection_count = 0
        self.last_detection_time = None
        self.processing = False

        logger.info(
            f"StreamProcessor initialized: session={session_id}, camera={camera_id}, "
            f"video={video_id}, patient={patient_id}, window={window_size}, stride={stride}"
        )

    def add_frame(self, skeleton_landmarks: List[List[float]]) -> bool:
        """
        Add a skeleton frame to the buffer

        Args:
            skeleton_landmarks: List of 33 landmarks [[x, y, vis], ...]

        Returns:
            True if buffer is ready for prediction
        """
        if len(skeleton_landmarks) != 33:
            logger.warning(
                f"Invalid skeleton: expected 33 landmarks, got {len(skeleton_landmarks)}"
            )
            return False

        self.frame_buffer.append(skeleton_landmarks)

        # Check if buffer is ready
        return len(self.frame_buffer) == self.window_size

    async def process_buffer(self, save_to_db: bool = True) -> Optional[Dict]:
        """
        Process current buffer and detect movement

        Args:
            save_to_db: Whether to save result to database

        Returns:
            Detection result dict or None
        """
        if len(self.frame_buffer) < self.window_size:
            logger.warning(
                f"Buffer not ready: {len(self.frame_buffer)}/{self.window_size}"
            )
            return None

        if self.processing:
            logger.warning("Already processing, skipping...")
            return None

        try:
            self.processing = True

            # Convert buffer to numpy array
            skeleton_data = np.array(list(self.frame_buffer))  # (frames, 33, 3)

            # Make prediction
            prediction = self.classifier.predict(
                skeleton_data,
                metadata={
                    "video_id": self.video_id,
                    "patient_id": self.patient_id,
                    "timestamp": datetime.now().isoformat(),
                },
            )

            # Check minimum confidence
            if prediction.confidence < self.min_confidence:
                logger.info(
                    f"Low confidence prediction skipped: {prediction.predicted_class} "
                    f"({prediction.confidence:.1%})"
                )
                return None

            # Save to database if requested
            if save_to_db:
                detection_record = await AIDetectionService.create_detection(
                    session_id=self.session_id,
                    camera_id=self.camera_id,
                    video_id=self.video_id,
                    patient_id=self.patient_id,
                    movement_type=prediction.predicted_class,
                    movement_id=prediction.movement_id,
                    confidence_score=prediction.confidence,
                    model_accuracy=prediction.model_accuracy,
                    tier=prediction.tier,
                    recommendation=prediction.recommendation,
                    all_probabilities=prediction.all_probabilities,
                    requires_review=prediction.requires_review(),
                    room_id=self.room_id,
                    frame_timestamp=datetime.now(),
                    metadata=prediction.metadata,
                )

                if detection_record:
                    self.detection_count += 1
                    self.last_detection_time = datetime.now()

                    logger.info(
                        f"✅ Detection #{self.detection_count} saved: "
                        f"{prediction.predicted_class} ({prediction.confidence:.1%})"
                    )

                    return detection_record
            else:
                # Return prediction without saving
                return prediction.to_dict()

        except Exception as e:
            logger.error(f"Error processing buffer: {str(e)}")
            return None

        finally:
            self.processing = False

            # Slide window by stride
            if self.stride < self.window_size:
                # Keep some frames for overlap
                frames_to_keep = self.window_size - self.stride
                self.frame_buffer = deque(
                    list(self.frame_buffer)[-frames_to_keep:], maxlen=self.window_size
                )

    async def process_frame_and_detect(
        self, skeleton_landmarks: List[List[float]], save_to_db: bool = True
    ) -> Optional[Dict]:
        """
        Add frame and automatically trigger detection when ready

        Args:
            skeleton_landmarks: Skeleton data for one frame
            save_to_db: Whether to save detection to database

        Returns:
            Detection result if prediction was made, None otherwise
        """
        # Add frame to buffer
        is_ready = self.add_frame(skeleton_landmarks)

        # Process if ready
        if is_ready:
            return await self.process_buffer(save_to_db)

        return None

    def get_status(self) -> Dict:
        """Get processor status"""
        return {
            "session_id": self.session_id,
            "camera_id": self.camera_id,
            "video_id": self.video_id,
            "patient_id": self.patient_id,
            "room_id": self.room_id,
            "buffer_size": len(self.frame_buffer),
            "window_size": self.window_size,
            "ready_for_detection": len(self.frame_buffer) == self.window_size,
            "processing": self.processing,
            "detection_count": self.detection_count,
            "last_detection": (
                self.last_detection_time.isoformat()
                if self.last_detection_time
                else None
            ),
            "min_confidence": self.min_confidence,
        }

    def reset(self):
        """Reset the processor (clear buffer)"""
        self.frame_buffer.clear()
        self.processing = False
        logger.info(f"Processor reset for video {self.video_id}")


# ============================================================
# Processor Manager (Multiple Streams)
# ============================================================


class StreamProcessorManager:
    """
    Manages multiple stream processors
    One processor per active video stream
    """

    def __init__(self):
        self.processors: Dict[int, StreamMovementProcessor] = {}
        logger.info("StreamProcessorManager initialized")

    def create_processor(
        self,
        session_id: str,
        camera_id: str,
        video_id: int,
        patient_id: int,
        room_id: str = None,
        **kwargs,
    ) -> StreamMovementProcessor:
        """
        Create a new processor for a video stream

        Args:
            session_id: Streaming session ID
            camera_id: Camera ID
            video_id: ID of the video
            patient_id: ID of the patient
            room_id: Optional room ID
            **kwargs: Additional processor options

        Returns:
            StreamMovementProcessor instance
        """
        if video_id in self.processors:
            logger.warning(f"Processor for video {video_id} already exists")
            return self.processors[video_id]

        processor = StreamMovementProcessor(
            session_id=session_id,
            camera_id=camera_id,
            video_id=video_id,
            patient_id=patient_id,
            room_id=room_id,
            **kwargs,
        )

        self.processors[video_id] = processor

        logger.info(f"Created processor for video {video_id}")
        return processor

    def get_processor(self, video_id: int) -> Optional[StreamMovementProcessor]:
        """Get processor for a video"""
        return self.processors.get(video_id)

    def remove_processor(self, video_id: int) -> bool:
        """Remove processor for a video"""
        if video_id in self.processors:
            del self.processors[video_id]
            logger.info(f"Removed processor for video {video_id}")
            return True
        return False

    def get_all_status(self) -> List[Dict]:
        """Get status of all active processors"""
        return [processor.get_status() for processor in self.processors.values()]

    def get_active_count(self) -> int:
        """Get number of active processors"""
        return len(self.processors)


# ============================================================
# Singleton Manager Instance
# ============================================================

_processor_manager = None


def get_processor_manager() -> StreamProcessorManager:
    """Get singleton processor manager instance"""
    global _processor_manager

    if _processor_manager is None:
        _processor_manager = StreamProcessorManager()

    return _processor_manager
