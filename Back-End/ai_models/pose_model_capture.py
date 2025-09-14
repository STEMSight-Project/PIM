"""
STEMSight Pose Model Capture
MediaPipe-based pose detection and landmark extraction
"""

# pylint: disable=no-member,import-error
import cv2
import mediapipe as mp
import time
import csv
import os
from typing import Optional, Any
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PoseModelCapture:
    """
    MediaPipe pose detection and landmark capture system
    """

    def __init__(self, camera_index: int = 0, output_dir: str = "data"):
        """
        Initialize pose capture system

        Args:
            camera_index: Camera device index (0, 1, 2...)
            output_dir: Directory to save CSV files
        """
        self.camera_index = camera_index
        self.output_dir = output_dir

        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)

        # MediaPipe setup
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.7, min_tracking_confidence=0.7
        )

        # Initialize camera
        self.cap: Optional[Any] = None
        self._initialize_camera()

    def _initialize_camera(self) -> None:
        """Initialize camera capture"""
        try:
            self.cap = cv2.VideoCapture(self.camera_index)
            if not self.cap.isOpened():
                logger.error(
                    "Error: Could not open camera at index %d", self.camera_index
                )
                raise RuntimeError(f"Camera at index {self.camera_index} not available")
            logger.info(
                "Camera initialized successfully at index %d", self.camera_index
            )
        except Exception as e:
            logger.error("Failed to initialize camera: %s", e)
            raise

    def capture_landmarks(self, duration: Optional[float] = None) -> str:
        """
        Capture pose landmarks and save to CSV

        Args:
            duration: Optional capture duration in seconds

        Returns:
            Path to the saved CSV file
        """
        if not self.cap:
            raise RuntimeError("Camera not initialized")

        timestamp_str = time.strftime("%Y%m%d_%H%M%S")
        csv_filename = os.path.join(self.output_dir, f"landmarks_{timestamp_str}.csv")

        try:
            with open(csv_filename, "w", newline="", encoding="utf-8") as csvfile:
                fieldnames = ["timestamp", "landmark_id", "x", "y", "z", "visibility"]
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()

                start_time = time.time()
                prev_time = 0
                frame_count = 0

                logger.info("Starting pose capture. Press 'q' to quit.")

                while True:
                    # Check duration limit
                    if duration and (time.time() - start_time) >= duration:
                        logger.info("Capture duration reached: %.2f seconds", duration)
                        break

                    # Capture frame
                    ret, frame = self.cap.read()
                    if not ret:
                        logger.error("Error: Couldn't read frame")
                        break

                    # Process frame
                    frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                    results = self.pose.process(frame_rgb)

                    # Extract landmarks
                    if results.pose_landmarks:
                        timestamp = time.time() - start_time

                        for landmark_id, landmark in enumerate(
                            results.pose_landmarks.landmark
                        ):
                            writer.writerow(
                                {
                                    "timestamp": timestamp,
                                    "landmark_id": landmark_id,
                                    "x": landmark.x,
                                    "y": landmark.y,
                                    "z": landmark.z,
                                    "visibility": landmark.visibility,
                                }
                            )

                        # Draw landmarks
                        self.mp_drawing.draw_landmarks(
                            frame, results.pose_landmarks, self.mp_pose.POSE_CONNECTIONS
                        )

                    # Calculate and display FPS
                    current_time = time.time()
                    fps = 1 / (current_time - prev_time) if prev_time else 0
                    prev_time = current_time
                    frame_count += 1

                    # Add FPS text to frame
                    cv2.putText(
                        frame,
                        f"FPS: {int(fps)} | Frames: {frame_count}",
                        (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (0, 255, 0),
                        2,
                        cv2.LINE_AA,
                    )

                    # Display frame
                    cv2.imshow("STEMSight - Pose Detection", frame)

                    # Check for quit
                    if cv2.waitKey(1) & 0xFF == ord("q"):
                        logger.info("Capture stopped by user")
                        break

                logger.info("Captured %d frames to %s", frame_count, csv_filename)
                return csv_filename

        except Exception as e:
            logger.error("Error during capture: %s", e)
            raise
        finally:
            self.cleanup()

    def cleanup(self) -> None:
        """Clean up resources"""
        if self.cap:
            self.cap.release()
        cv2.destroyAllWindows()
        logger.info("Resources cleaned up")


def main():
    """Main function for standalone execution"""
    try:
        # Initialize pose capture system
        pose_capture = PoseModelCapture(camera_index=1)  # Change camera index as needed

        # Start capture
        csv_file = pose_capture.capture_landmarks()
        print(f"Landmarks saved to: {csv_file}")

    except Exception as e:
        logger.error("Application error: %s", e)
        raise


if __name__ == "__main__":
    main()
