#
# handles saving frames
#

import datetime
from pathlib import Path

import cv2


class VideoRecorder:
    def __init__(self, save_dir="static/recordings", fps=30, frame_size=(640, 480)):
        Path(save_dir).mkdir(parents=True, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{save_dir}/recording_{timestamp}.avi"
        self.writer = cv2.VideoWriter(
            filename, cv2.VideoWriter_fourcc(*"XVID"), fps, frame_size
        )
        self.active = True
        self.filename = filename

    def write_frame(self, frame):
        if self.active:
            self.writer.write(frame)

    def stop(self):
        self.active = False
        self.writer.release()
        return self.filename
