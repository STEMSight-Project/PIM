#
# handles WebRTC session
#

import asyncio

import cv2
from aiortc import VideoStreamTrack
from app.services.camera_stream import CameraStream
from app.services.mediapipe_handler import MediaPipeHandler
from app.services.recorder import VideoRecorder
from av import VideoFrame


class MediaPipeStream(VideoStreamTrack):
    # WebRTC video stream track with MediaPipe processing and recording support.
    def __init__(self):
        super().__init__()
        self.cap = cv2.VideoCapture(0)
        self.mp_handler = MediaPipeHandler()
        self.camera = CameraStream()
        self.camera.start()
        self.recorder = None
        self.recording = False

    async def recv(self):
        frame = self.camera.get_frame()
        if frame is None:
            await asyncio.sleep(0.01)
            return None

        ret, frame = self.cap.read()
        if not ret:
            await asyncio.sleep(0.01)
            return None

        # Apply MediaPipe processing (optional)
        _ = self.mp_handler.process(frame)

        # Write frame to recorder if active
        if self.recording and self.recorder:
            self.recorder.write_frame(frame)

        # Convert to WebRTC-compatible frame
        new_frame = VideoFrame.from_ndarray(frame, format="bgr24")
        new_frame.pts, new_frame.time_base = self.next_timestamp()
        return new_frame

    def start_recording(self):
        if not self.recording:
            width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            self.recorder = VideoRecorder(frame_size=(width, height))
            self.recording = True

    def stop_recording(self):
        if self.recording and self.recorder:
            path = self.recorder.stop()
            self.recording = False
            return path
        return None
