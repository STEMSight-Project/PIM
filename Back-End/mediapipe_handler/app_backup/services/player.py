#
# handles playback logic (pause, rewind, scrub)
#

import cv2


class VideoPlayer:
    def __init__(self, filepath):
        self.cap = cv2.VideoCapture(filepath)
        self.paused = False

    def play(self):
        while self.cap.isOpened():
            if not self.paused:
                ret, frame = self.cap.read()
                if not ret:
                    break
                cv2.imshow("Playback", frame)
            key = cv2.waitKey(30) & 0xFF
            if key == ord("p"):  # pause
                self.paused = not self.paused
            elif key == ord("r"):  # rewind
                self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            elif key == ord("q"):
                break
        self.cap.release()
        cv2.destroyAllWindows()
