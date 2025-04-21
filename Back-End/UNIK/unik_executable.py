import argparse
import cv2
import mediapipe as mp
import torch
import numpy as np
from model.backbone_unik import UNIK
import run_unik

from run_unik import Processor, get_parser, init_seed

def load_model(weights_path, device):
    model = UNIK()  
    model.load_state_dict(torch.load(weights_path, map_location=device))
    model.to(device)
    model.eval()
    return model

def mediapipe_landmarks(frame, pose):
    image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = pose.process(image_rgb)
    if results.pose_landmarks:
        landmarks = results.pose_landmarks.landmark
        coords = []
        for lm in landmarks:
            coords.extend([lm.x, lm.y, lm.z, lm.visibility])
        return np.array(coords, dtype=np.float32)
    else:
        return None

def run_live_classification(args):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = load_model(args.weights, device)

    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(static_image_mode=False, min_detection_confidence=0.5)

    if args.video_path:
        cap = cv2.VideoCapture(args.video_path)
    else:
        cap = cv2.VideoCapture(0)  # Default webcam

    if not cap.isOpened():
        print("Error: Could not open video source.")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        landmarks = mediapipe_landmarks(frame, pose)
        if landmarks is not None:
            input_tensor = torch.tensor(landmarks).unsqueeze(0).to(device)
            with torch.no_grad():
                output = model(input_tensor)
                pred = torch.argmax(output, dim=1).item()
            cv2.putText(frame, f'Class: {pred}', (30, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

        cv2.imshow('UNIK Model Classification', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    pose.close()

def start_run_unik():
    parser = get_parser()
    arg = parser.parse_args()
    init_seed(0)
    processor = Processor(arg)
    processor.start()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='UNIK executable with GUI and run_unik processor')
    parser.add_argument('--weights', type=str, help='Path to trained UNIK model weights for live classification')
    parser.add_argument('--video_path', type=str, default=None, help='Path to video file. If not set, webcam is used.')
    parser.add_argument('--run_unik', action='store_true', help='Run the run_unik processor')
    args = parser.parse_args()

    if args.run_unik:
        start_run_unik()
    else:
        if not args.weights:
            print("Error: --weights argument is required for live classification mode.")
        else:
            run_live_classification(args)
