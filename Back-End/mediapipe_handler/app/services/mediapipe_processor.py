from typing import Optional

import cv2
import mediapipe as mp
from aiortc import VideoFrame


class MediaPipeVideoProcessor:
    """
    Lightweight wrapper around MediaPipe solutions for real-time streaming.
    Supported models: 'hands', 'pose', 'face', or None
    """

    def __init__(self, model: Optional[str] = "hands", draw_landmarks: bool = True):
        self.model = model
        self.draw = draw_landmarks
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles

        if model == "hands":
            self._mp_sol = mp.solutions.hands.Hands(
                static_image_mode=False,
                max_num_hands=2,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5,
            )
            self.connections = mp.solutions.hands.HAND_CONNECTIONS

        elif model == "pose":
            self._mp_sol = mp.solutions.pose.Pose(
                static_image_mode=False,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5,
            )
            self.connections = mp.solutions.pose.POSE_CONNECTIONS

        elif model == "face":
            self._mp_sol = mp.solutions.face_mesh.FaceMesh(
                static_image_mode=False,
                max_num_faces=1,
                refine_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5,
            )
            self.connections = None

        else:
            self._mp_sol = None  # passthrough only
            self.connections = None

    def process_frame(self, frame: VideoFrame) -> VideoFrame:
        """
        Process an aiortc VideoFrame and return a processed VideoFrame.

        Keeps PTS & time_base for WebRTC timing.
        """
        img = frame.to_ndarray(format="bgr24")

        if self._mp_sol is None:
            return frame  # passthrough frame when model=None

        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        mp_result = self._mp_sol.process(rgb)

        if self.draw and mp_result:
            if (
                hasattr(mp_result, "multi_hand_landmarks")
                and mp_result.multi_hand_landmarks
            ):
                for lm in mp_result.multi_hand_landmarks:
                    self.mp_drawing.draw_landmarks(
                        img,
                        lm,
                        self.connections,
                        self.mp_drawing_styles.get_default_hand_landmarks_style(),
                        self.mp_drawing_styles.get_default_hand_connections_style(),
                    )

            elif hasattr(mp_result, "pose_landmarks") and mp_result.pose_landmarks:
                self.mp_drawing.draw_landmarks(
                    img, mp_result.pose_landmarks, self.connections
                )

            elif (
                hasattr(mp_result, "multi_face_landmarks")
                and mp_result.multi_face_landmarks
            ):
                for lm in mp_result.multi_face_landmarks:
                    self.mp_drawing.draw_landmarks(img, lm)

        # Convert result back to a WebRTC VideoFrame
        new_frame = VideoFrame.from_ndarray(img, format="bgr24")
        new_frame.pts = frame.pts
        new_frame.time_base = frame.time_base
        return new_frame

    def close(self):
        if self._mp_sol is not None:
            self._mp_sol.close()
