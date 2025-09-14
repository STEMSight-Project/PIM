"""
Example usage of PoseModelCapture for STEMSight Backend
"""

from ai_models.pose_model_capture import PoseModelCapture
from core.common import logger


def capture_patient_pose_data(patient_id: str, duration: float = 60.0) -> str:
    """
    Capture pose data for a specific patient

    Args:
        patient_id: Patient identifier
        duration: Capture duration in seconds

    Returns:
        Path to saved CSV file
    """
    try:
        # Create patient-specific output directory
        output_dir = f"data/patients/{patient_id}/pose_data"

        # Initialize pose capture
        pose_capture = PoseModelCapture(
            camera_index=0, output_dir=output_dir  # Default camera
        )

        logger.info("Starting pose capture for patient %s", patient_id)

        # Capture landmarks for specified duration
        csv_file = pose_capture.capture_landmarks(duration=duration)

        logger.info("Pose capture completed for patient %s: %s", patient_id, csv_file)
        return csv_file

    except Exception as e:
        logger.error("Error capturing pose data for patient %s: %s", patient_id, e)
        raise


def quick_pose_test() -> None:
    """Quick test of pose capture system"""
    try:
        pose_capture = PoseModelCapture(camera_index=0)
        logger.info("Starting quick pose test - press 'q' to quit")
        csv_file = pose_capture.capture_landmarks()
        print(f"Test completed! Data saved to: {csv_file}")
    except (RuntimeError, OSError) as e:
        logger.error("Test failed: %s", e)


if __name__ == "__main__":
    # Run quick test
    quick_pose_test()
