import cv2
"""
Lightweight wrapper around MediaPipe solutions.
model: 'hands', 'pose', 'face', or None
draw_landmarks: whether to draw landmarks onto the frame
"""
def __init__(self, model: Optional[str] = "hands", draw_landmarks: bool = True):


self.model = model
self.draw = draw_landmarks
self.mp_drawing = mp.solutions.drawing_utils
self.mp_drawing_styles = mp.solutions.drawing_styles


if model == "hands":
self._mp_sol = mp.solutions.hands.Hands(static_image_mode=False,
                                        max_num_hands=2,
                                        min_detection_confidence=0.5,
                                        min_tracking_confidence=0.5)
self.connections = mp.solutions.hands.HAND_CONNECTIONS
elif model == "pose":
self._mp_sol = mp.solutions.pose.Pose(static_image_mode=False,
                                      min_detection_confidence=0.5,
                                      min_tracking_confidence=0.5)
self.connections = mp.solutions.pose.POSE_CONNECTIONS
elif model == "face":
self._mp_sol = mp.solutions.face_mesh.FaceMesh(static_image_mode=False,
                                               max_num_faces=1,
                                               refine_landmarks=True,
                                               min_detection_confidence=0.5,
                                               min_tracking_confidence=0.5)
self.connections = None
else:
self._mp_sol = None
self.connections = None


def process(self, frame_bgr: np.ndarray) -> dict:


"""
Process BGR frame and optionally draw landmarks. Returns a dict with result object.
result keys:
- 'frame': possibly annotated BGR frame
- 'mp_result': the raw MediaPipe result object (or None)
"""
if self._mp_sol is None:
return {"frame": frame_bgr, "mp_result": None}


rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
mp_result = self._mp_sol.process(rgb)


out_frame = frame_bgr
if self.draw and mp_result:
if hasattr(mp_result, "multi_hand_landmarks") and mp_result.multi_hand_landmarks:
for landmarks in mp_result.multi_hand_landmarks:
self.mp_drawing.draw_landmarks(
    out_frame,
    landmarks,
    self.connections,
    self.mp_drawing_styles.get_default_hand_landmarks_style() if hasattr(
        self.mp_drawing_styles, "get_default_hand_landmarks_style") else None,
    self.mp_drawing_styles.get_default_hand_connections_style() if hasattr(
        self.mp_drawing_styles, "get_default_hand_connections_style") else None
)
elif hasattr(mp_result, "pose_landmarks") and mp_result.pose_landmarks:
self.mp_drawing.draw_landmarks(
    out_frame, mp_result.pose_landmarks, self.connections)
elif hasattr(mp_result, "multi_face_landmarks") and mp_result.multi_face_landmarks:
for flm in mp_result.multi_face_landmarks:
self.mp_drawing.draw_landmarks(out_frame, flm, self.connections)
return {"frame": out_frame, "mp_result": mp_result}


def close(self):


if self._mp_sol is not None:
self._mp_sol.close()
