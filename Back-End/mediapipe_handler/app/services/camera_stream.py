import cv2
import threading
import time
import numpy as np


class CameraStream:


"""Threaded camera capture to avoid blocking read() calls and to share camera safely."""
def __init__(self, src: int = 0, name: str = "camera"):


self.src = src
self.cap = None
self.frame = None
self.lock = threading.Lock()
self.running = False
self.name = name
self._thread = None


def start(self):


if self.running:
return
self.cap = cv2.VideoCapture(self.src)
if not self.cap.isOpened():
raise RuntimeError(f"Unable to open camera source {self.src}")
# warm-up read
ret, frame = self.cap.read()
if not ret:
raise RuntimeError("Camera opened but cannot read frames")
with self.lock:
self.frame = frame
self.running = True
self._thread = threading.Thread(
    target=self._run, daemon=True, name=f"{self.name}-thread")
self._thread.start()


def _run(self):


while self.running:
ret, frame = self.cap.read()
if not ret:
time.sleep(0.01)
continue
with self.lock:
self.frame = frame


def get_frame(self) -> np.ndarray | None:


"""Return a copy of the most recent frame (BGR) or None if not ready."""
with self.lock:
if self.frame is None:
return None
return self.frame.copy()


def stop(self):


self.running = False
if self._thread and self._thread.is_alive():
self._thread.join(timeout=1.0)
if self.cap:
self.cap.release()
self.cap = None


def get_properties(self):


return width, height, fps
