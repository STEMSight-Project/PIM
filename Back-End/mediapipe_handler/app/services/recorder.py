import cv2
import datetime
from pathlib import Path
from typing import Optional, Tuple
import os


class Recorder:


"""
Write BGR frames to disk. Handles fps/frame size detection.
Use start() / write() / stop().
"""
def __init__(self, output_dir: str = "app/videos", filename: Optional[str] = None, codec: str = "XVID", fps: Optional[float] = None, frame_size: Optional[Tuple[int, int]] = None):


Path(output_dir).mkdir(parents=True, exist_ok=True)
if filename is None:
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
filename = f"recording_{timestamp}.avi"
self.filepath = os.path.join(output_dir, filename)
self.codec = codec
self._writer = None
self.fps = fps
self.frame_size = frame_size
self.active = False


def start(self, fps: float, frame_size: Tuple[int, int]):


"""Initialize writer with detected fps/frame_size"""
if self.active:
return
self.fps = fps or self.fps or 30.0
self.frame_size = frame_size or self.frame_size or (640, 480)
fourcc = cv2.VideoWriter_fourcc(*self.codec)
self._writer = cv2.VideoWriter(
    self.filepath, fourcc, self.fps, self.frame_size)
if not self._writer.isOpened():
raise RuntimeError("VideoWriter failed to open (check codecs).")
self.active = True


def write(self, frame_bgr):


if not self.active or self._writer is None:
return
h, w = frame_bgr.shape[:2]
if (w, h) != self.frame_size:
frame_bgr = cv2.resize(frame_bgr, self.frame_size)
self._writer.write(frame_bgr)


def stop(self):


if self._writer:
self._writer.release()
self.active = False
return self.filepath
