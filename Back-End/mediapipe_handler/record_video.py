import datetime
import os

import cv2
import mediapipe as mp


def run(output_dir="videos"):
    mp_hands = mp.solutions.hands
    mp_drawing = mp.solutions.drawing_utils

    cap = cv2.VideoCapture(0)

    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS) or 30

    filename = datetime.datetime.now().strftime("output_%Y%m%d_%H%M%S.avi")
    filepath = os.path.join(output_dir, filename)

    fourcc = cv2.VideoWriter_fourcc(*"XVID")
    out = cv2.VideoWriter(filepath, fourcc, fps, (frame_width, frame_height))

    with mp_hands.Hands(
        static_image_mode=False,
        max_num_hands=2,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    ) as hands:
        print("Recording... press ESC to stop.")
        while cap.isOpened():
            success, image = cap.read()
            if not success:
                break

            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results = hands.process(image_rgb)

            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    mp_drawing.draw_landmarks(
                        image, hand_landmarks, mp_hands.HAND_CONNECTIONS
                    )

            cv2.imshow("Recording", image)
            out.write(image)

            if cv2.waitKey(5) & 0xFF == 27:  # ESC
                break

    cap.release()
    out.release()
    cv2.destroyAllWindows()
    print(f"Saved recording to {filepath}")
