import cv2


class Player:


"""
Simple playback UI using OpenCV window with a trackbar for scrubbing.
Controls:
p - pause/play
r - rewind to start
q or ESC - quit
left/right arrow - step backward/forward when paused
"""
def __init__(self, filepath: str, window_name: str = "Playback"):


self.filepath = filepath
self.window_name = window_name
self.cap = cv2.VideoCapture(self.filepath)
if not self.cap.isOpened():
raise RuntimeError(f"Unable to open {self.filepath}")
self.total = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))
self.paused = False
self.current = 0
cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)
cv2.createTrackbar("Frame", self.window_name, 0, max(
    1, self.total - 1), self._on_trackbar)


def _on_trackbar(self, val):


self.current = val
self.cap.set(cv2.CAP_PROP_POS_FRAMES, val)


def run(self):


print(f"Playing {self.filepath} ({
      self.total} frames). Controls: p pause, r rewind, q quit, left/right step.")
while True:
if not self.paused:
ret, frame = self.cap.read()
if not ret:
break
self.current = int(self.cap.get(cv2.CAP_PROP_POS_FRAMES))
cv2.imshow(self.window_name, frame)
cv2.setTrackbarPos("Frame", self.window_name, max(0, self.current - 1))
key = cv2.waitKey(30) & 0xFF
if key == ord('p'):
self.paused = not self.paused
elif key == ord('r'):
self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
self.current = 0
elif key in (ord('q'), 27):
break
elif key == 81:  # left arrow (may differ between systems)
if self.paused:
self.cap.set(cv2.CAP_PROP_POS_FRAMES, max(0, self.current - 2))
elif key == 83:  # right arrow
if self.paused:
self.cap.set(cv2.CAP_PROP_POS_FRAMES, min(self.total - 1, self.current + 1))


self.cap.release()
cv2.destroyWindow(self.window_name)
