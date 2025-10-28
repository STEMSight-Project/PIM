import datetime
import os

import cv2
import mediapipe as mp


def run(output_dir="videos", source=0):
    """
    Record webcam with MediaPipe hand landmarks drawn.

    - output_dir: directory to save recordings
    - source: camera index or path passed to cv2.VideoCapture (default 0)
    """
    # ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils

    cap = cv2.VideoCapture(source)
    if not cap.isOpened():
        print(f"Error: Could not open video source: {source}")
        return

    # Read a first frame to get width/height and make sure the camera is providing frames
    ret, first_frame = cap.read()
    if not ret or first_frame is None:
        print("Error: Camera opened but failed to read the first frame.")
        cap.release()
        return

    frame_height, frame_width = first_frame.shape[:2]
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0

    filename = datetime.datetime.now().strftime("output_%Y%m%d_%H%M%S.avi")
    filepath = os.path.join(output_dir, filename)

    fourcc = cv2.VideoWriter_fourcc(*"XVID")
    out = cv2.VideoWriter(filepath, fourcc, float(fps), (frame_width, frame_height))

    with mp_hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    ) as hands:
        print("Recording... press ESC to stop.")
        # process the first frame we already read
        image = first_frame
        while True:
            # convert to RGB for MediaPipe
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = hands.process(image_rgb)

            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    mp_drawing.draw_landmarks(
                        image, hand_landmarks, mp_hands.HAND_CONNECTIONS
                    )

            cv2.imshow("Recording", image)
            out.write(image)

            # read next frame
            ret, image = cap.read()
            if not ret or image is None:
                # camera disconnected or file ended
                print("Warning: Failed to read next frame — stopping.")
                break

            if cv2.waitKey(5) & 0xFF == 27:  # ESC
                break

    cap.release()
    out.release()
    cv2.destroyAllWindows()

    print(f"Saved recording to {filepath}")


if __name__ == "__main__":
    # allow running directly for quick manual test
    run("videos", source=0)
