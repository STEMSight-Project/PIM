import cv2


def run(filename):
    cap = cv2.VideoCapture(filename)

    if not cap.isOpened():
        print(f"Error: Could not open {filename}")
        return

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    paused = False
    current_frame = 0

    def on_trackbar(val):
        nonlocal current_frame
        current_frame = val
        cap.set(cv2.CAP_PROP_POS_FRAMES, val)

    cv2.namedWindow("Playback")
    cv2.createTrackbar("Frame", "Playback", 0, total_frames - 1, on_trackbar)

    print("Controls: p = pause/play | r = rewind | ESC = quit")

    while True:
        if not paused:
            ret, frame = cap.read()
            if not ret:
                break
            current_frame = int(cap.get(cv2.CAP_PROP_POS_FRAMES))
            cv2.imshow("Playback", frame)
            cv2.setTrackbarPos("Frame", "Playback", current_frame)

        key = cv2.waitKey(25) & 0xFF
        if key == 27:  # ESC
            break
        elif key == ord("p"):
            paused = not paused
        elif key == ord("r"):
            cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            current_frame = 0

    cap.release()
    cv2.destroyAllWindows()
