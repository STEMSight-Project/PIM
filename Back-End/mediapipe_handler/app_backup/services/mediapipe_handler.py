#
# Video processing pipeline
#

import cv2
import mediapipe as mp


class MediaPipeHandler:
    def __init__(self):
        self.mp_face = mp.solutions.face_mesh.FaceMesh()

    def process(self, frame):
        # Process each frame through mediapipe
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        result = self.mp_face.process(rgb)
        return result
