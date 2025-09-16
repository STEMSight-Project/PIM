import argparse
import cv2
import mediapipe as mp
import torch
import numpy as np
import os
import glob
from model.backbone_unik import UNIK

from run_unik import Processor, get_parser, init_seed

# Penn Action joint order used by data_gen/penn_gendata.py
# ['head','nose','Neck','Chest','Mhip','Lsho','Rsho','Lelb','Relb','Lwri','Rwri','Lhip','Rhip','Lkne','Rkne','Lank','Rank']
PENN_JOINTS = [
    'head','nose','Neck','Chest','Mhip',
    'Lsho','Rsho','Lelb','Relb','Lwri','Rwri',
    'Lhip','Rhip','Lkne','Rkne','Lank','Rank'
]

class MediaPipePoseExtractor:
    """Extracts and processes poses from camera input using MediaPipe"""
    def __init__(self, target_format='penn'):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.target_format = target_format
    
    def extract_landmarks(self, frame):
        """Process a frame and extract MediaPipe (33,3) landmarks in image-normalized coords."""
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.pose.process(image_rgb)
        
        if not results.pose_landmarks:
            return None
        
        landmarks = []
        for landmark in results.pose_landmarks.landmark:
            landmarks.append([landmark.x, landmark.y, landmark.z])
        return np.array(landmarks)  # (33, 3), coords in [0,1] relative to image size
    
    @staticmethod
    def normalize_screen_coordinates_xy(xy_pixels: np.ndarray, w: int, h: int) -> np.ndarray:
        """Replicate data_gen.preprocess.normalize_screen_coordinates for (N,2) XY in pixels.
        Maps x:[0..w], y:[0..h] -> approximately [-1..1] range preserving aspect ratio.
        """
        assert xy_pixels.shape[-1] == 2
        center = xy_pixels / np.array([w, w], dtype=np.float32) * 2.0 - np.array([1.0, h / w], dtype=np.float32)
        # Zero-out entries where original was exactly 0 (missing)
        zeros = (xy_pixels == 0)
        center[zeros] = 0
        return center

    def convert_to_penn_17(self, mediapipe_landmarks: np.ndarray, frame_width: int, frame_height: int) -> np.ndarray:
        """Convert MediaPipe 33 landmarks (normalized) into Penn's 17 joints in the same
        normalization used by penn_gendata.py (2D, normalized coordinates).

        Returns: np.ndarray shape (17, 2) in normalized coords (matching training).
        """
        if mediapipe_landmarks is None or mediapipe_landmarks.shape[0] < 33:
            return None

        lm = mediapipe_landmarks
        # Convert [0,1] normalized to pixel space
        xy_pixels = np.zeros((33, 2), dtype=np.float32)
        xy_pixels[:, 0] = lm[:, 0] * float(frame_width)
        xy_pixels[:, 1] = lm[:, 1] * float(frame_height)

        # Helper to get a landmark safely
        def L(idx):
            return xy_pixels[idx]

        # Compute midpoints
        neck_xy = (L(11) + L(12)) / 2.0  # shoulders midpoint
        mhip_xy = (L(23) + L(24)) / 2.0  # hips midpoint
        chest_xy = (neck_xy + mhip_xy) / 2.0
        # Approximate head as midpoint of ears if available, else nose
        left_ear, right_ear = L(7), L(8)
        if (left_ear != 0).any() and (right_ear != 0).any():
            head_xy = (left_ear + right_ear) / 2.0
        else:
            head_xy = L(0)  # nose fallback

        # Build Penn joint list in pixel coords
        penn_xy = np.stack([
            head_xy,          # 0 head
            L(0),             # 1 nose (will be overridden later during tensor prep to avg(head, neck))
            neck_xy,          # 2 Neck
            chest_xy,         # 3 Chest (avg of Neck & Mhip)
            mhip_xy,          # 4 Mhip (avg hips)
            L(11),            # 5 Lsho
            L(12),            # 6 Rsho
            L(13),            # 7 Lelb
            L(14),            # 8 Relb
            L(15),            # 9 Lwri
            L(16),            # 10 Rwri
            L(23),            # 11 Lhip
            L(24),            # 12 Rhip
            L(25),            # 13 Lkne
            L(26),            # 14 Rkne
            L(27),            # 15 Lank
            L(28),            # 16 Rank
        ], axis=0)

        # Now normalize XY like training does
        penn_xy_norm = self.normalize_screen_coordinates_xy(penn_xy, frame_width, frame_height)
        return penn_xy_norm  # (17,2)

    def extract_penn_frame(self, frame) -> np.ndarray:
        """Extract a single Penn-style (V=17, C=2) frame normalized like training.
        Returns None if no pose detected.
        """
        lm = self.extract_landmarks(frame)
        if lm is None:
            return None
        h, w = frame.shape[:2]
        xy = self.convert_to_penn_17(lm, w, h)
        return xy  # (17,2)

def find_latest_checkpoint(patterns):
    """Find the latest .pt checkpoint from a list of glob patterns."""
    files = []
    for p in patterns:
        files.extend(glob.glob(p))
    if not files:
        return None
    # try to sort by mtime then by numeric step in name
    files.sort(key=lambda f: (os.path.getmtime(f), f))
    return files[-1]

def load_model(weights_path, device):
    model = UNIK(num_joints=17, num_person=1, in_channels=2)
    if weights_path is not None:
        model.load_state_dict(torch.load(weights_path, map_location=device))
    model.to(device)
    model.eval()
    return model

def run_live_classification(args):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model = load_model(args.weights, device)

    extractor = MediaPipePoseExtractor()

    if args.video_path:
        cap = cv2.VideoCapture(args.video_path)
    else:
        cap = cv2.VideoCapture(args.camera)  # Open specified camera

    if not cap.isOpened():
        print("Error: Could not open video source.")
        return

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        xy = extractor.extract_penn_frame(frame)
        if xy is not None:
            input_tensor = torch.tensor(xy).reshape(1, 2, 1, 17, 1).to(device)
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
    extractor.pose.close()

def start_run_unik():
    parser = get_parser()
    arg = parser.parse_args()
    init_seed(0)
    processor = Processor(arg)
    processor.start()

def parse_args():
    parser = get_parser()
    parser.add_argument('--video_path', type=str, default=None, help='Path to video file. If not provided, camera will be used.')
    parser.add_argument('--camera', type=int, default=0, help='Camera index for live feed.')
    parser.add_argument('--run_unik', action='store_true', help='Run the UNIK processor with GUI.')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    if args.run_unik:
        start_run_unik()
    else:
        run_live_classification(args)
