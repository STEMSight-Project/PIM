"""
MediaPipe Multi-View Video Processing with PIM Detection

This module processes pre-recorded video clips with multiple views, extracts landmarks
using MediaPipe, and integrates with advanced PIM (Patient Involuntary Movement) detection.

Based on advanced PIM detection system with LSTM neural networks for movement classification.
"""

import cv2
import mediapipe as mp
import time
import csv
import os
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.model_selection import train_test_split
import pandas as pd
import collections
import argparse
import json
import glob
from datetime import datetime
from tqdm import tqdm
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# PIM Detection Configuration
PIM_MOVEMENTS = {
    'normal': 0, 'decorticate': 1, 'dystonia': 2, 'chorea': 3,
    'myoclonus': 4, 'decerebrate': 5, 'fencer posture': 6,
    'ballistic': 7, 'tremor': 8, 'versive head': 9
}

class PIMDetectorLSTM(nn.Module):
    """LSTM for Patient Involuntary Movement Detection"""
    def __init__(self, input_dim=3, hidden_dim=128, num_layers=3, num_classes=7):
        super(PIMDetectorLSTM, self).__init__()
        self.num_keypoints, self.feature_dim = 33, input_dim * 33

        self.lstm = nn.LSTM(
            input_size=self.feature_dim, hidden_size=hidden_dim,
            num_layers=num_layers, batch_first=True, dropout=0.3
        )
        self.attention = nn.MultiheadAttention(hidden_dim, 8, batch_first=True, dropout=0.2)
        self.feature_layers = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2), nn.ReLU(), nn.Dropout(0.3),
            nn.Linear(hidden_dim // 2, hidden_dim // 4), nn.ReLU(), nn.Dropout(0.2)
        )
        self.classifier = nn.Linear(hidden_dim // 4, num_classes)
        self.confidence_head = nn.Sequential(nn.Linear(hidden_dim // 4, 1), nn.Sigmoid())

    def forward(self, x):
        batch_size, seq_length, num_keypoints, input_dim = x.size()
        x = x.view(batch_size, seq_length, -1)
        lstm_out, _ = self.lstm(x)
        attended_out, _ = self.attention(lstm_out, lstm_out, lstm_out)
        features = self.feature_layers(attended_out[:, -1, :])
        return self.classifier(features), self.confidence_head(features)

class JointBoneEnsembleLSTM(nn.Module):
    """LSTM model processing both joint positions and bone vectors"""
    def __init__(self, input_dim=3, hidden_dim=128, num_layers=3, num_classes=7):
        super(JointBoneEnsembleLSTM, self).__init__()
        self.pose_connections = [
            (0, 1), (1, 2), (2, 3), (3, 7), (0, 4), (4, 5), (5, 6), (6, 8),
            (9, 10), (11, 13), (13, 15), (15, 17), (15, 19), (15, 21), (17, 19),
            (12, 14), (14, 16), (16, 18), (16, 20), (16, 22), (18, 20),
            (11, 23), (12, 24), (23, 24), (23, 25), (24, 26), (25, 27),
            (26, 28), (27, 29), (28, 30), (29, 31), (30, 32), (27, 31), (28, 32)
        ]
        self.num_keypoints, self.num_bones = 33, len(self.pose_connections)
        self.joint_feature_dim = input_dim * self.num_keypoints
        self.bone_feature_dim = input_dim * self.num_bones

        self.joint_lstm = nn.LSTM(input_size=self.joint_feature_dim, hidden_size=hidden_dim,
                                  num_layers=num_layers, batch_first=True, dropout=0.3)
        self.bone_lstm = nn.LSTM(input_size=self.bone_feature_dim, hidden_size=hidden_dim,
                                 num_layers=num_layers, batch_first=True, dropout=0.3)

        self.joint_attention = nn.MultiheadAttention(hidden_dim, 8, batch_first=True)
        self.bone_attention = nn.MultiheadAttention(hidden_dim, 8, batch_first=True)

        self.fusion_layer = nn.Sequential(
            nn.Linear(hidden_dim * 2, hidden_dim), nn.ReLU(), nn.Dropout(0.3)
        )
        self.feature_layers = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2), nn.ReLU(), nn.Dropout(0.3)
        )
        self.classifier = nn.Linear(hidden_dim // 2, num_classes)
        self.confidence_head = nn.Sequential(nn.Linear(hidden_dim // 2, 1), nn.Sigmoid())

    def _extract_bone_features(self, joint_data):
        batch_size, seq_length = joint_data.shape[0], joint_data.shape[1]
        bone_features = torch.zeros(batch_size, seq_length, len(self.pose_connections),
                                    3, device=joint_data.device)
        for i, (joint_a, joint_b) in enumerate(self.pose_connections):
            bone_features[:, :, i, :] = joint_data[:, :, joint_b, :] - joint_data[:, :, joint_a, :]
        return bone_features

    def forward(self, x):
        batch_size, seq_length, num_keypoints, input_dim = x.size()

        # Process joints
        joint_features = x.view(batch_size, seq_length, -1)
        joint_lstm_out, _ = self.joint_lstm(joint_features)
        joint_attended, _ = self.joint_attention(joint_lstm_out, joint_lstm_out, joint_lstm_out)

        # Process bones
        bone_features = self._extract_bone_features(x)
        bone_features = bone_features.view(batch_size, seq_length, -1)
        bone_lstm_out, _ = self.bone_lstm(bone_features)
        bone_attended, _ = self.bone_attention(bone_lstm_out, bone_lstm_out, bone_lstm_out)

        # Fuse streams and classify
        fused = self.fusion_layer(torch.cat([joint_attended[:, -1, :], bone_attended[:, -1, :]], dim=1))
        features = self.feature_layers(fused)
        return self.classifier(features), self.confidence_head(features)

class MultiViewPIMProcessor:
    """
    Enhanced MediaPipe processor for multi-view videos with PIM detection capabilities.
    
    This processor handles videos with multiple views, crops unnecessary frames,
    and extracts landmarks from synchronized views for PIM movement analysis.
    """
    
    def __init__(self, 
                 pose_detection: bool = True,
                 hand_detection: bool = False,  # Focus on pose for PIM
                 face_detection: bool = False,  # Focus on pose for PIM
                 num_views: int = 3):
        """
        Initialize the multi-view PIM processor.
        
        Args:
            pose_detection (bool): Enable pose landmark detection
            hand_detection (bool): Enable hand landmark detection  
            face_detection (bool): Enable face landmark detection
            num_views (int): Number of views to extract (default: 3 from 4-view video)
        """
        self.num_views = num_views
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        
        # Initialize MediaPipe solutions
        if pose_detection:
            self.mp_pose = mp.solutions.pose
            self.pose = self.mp_pose.Pose(
                static_image_mode=False,
                model_complexity=1,  # Optimized for PIM detection
                enable_segmentation=False,
                min_detection_confidence=0.5
            )
        
        if hand_detection:
            self.mp_hands = mp.solutions.hands
            self.hands = self.mp_hands.Hands(
                static_image_mode=False,
                max_num_hands=2,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5
            )
        
        if face_detection:
            self.mp_face_mesh = mp.solutions.face_mesh
            self.face_mesh = self.mp_face_mesh.FaceMesh(
                static_image_mode=False,
                max_num_faces=1,
                refine_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5
            )
    
    def crop_video_views(self, frame: np.ndarray) -> List[np.ndarray]:
        """
        Crop the input frame to extract useful views, removing the rightmost view.
        
        Args:
            frame (np.ndarray): Input frame with 4 views
            
        Returns:
            List[np.ndarray]: List of cropped frames (default: 3 views)
        """
        height, width = frame.shape[:2]
        
        # Assume 4 equal-width views arranged horizontally
        view_width = width // 4
        
        # Extract first 3 views (left, center-left, center-right)
        views = []
        for i in range(self.num_views):
            view = frame[:, i*view_width:(i+1)*view_width]
            views.append(view)
        
        return views
    
    def extract_pose_landmarks_from_frame(self, frame: np.ndarray) -> Optional[np.ndarray]:
        """
        Extract pose landmarks from a single frame using MediaPipe.
        
        Args:
            frame (np.ndarray): Input frame for landmark extraction
            
        Returns:
            Optional[np.ndarray]: Array of pose landmarks [33, 3] or None if no pose detected
        """
        if not hasattr(self, 'pose'):
            return None
            
        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Process pose landmarks
        pose_results = self.pose.process(rgb_frame)
        if pose_results.pose_landmarks:
            landmarks = np.array([[lm.x, lm.y, lm.z] for lm in pose_results.pose_landmarks.landmark], 
                               dtype=np.float32)
            return landmarks
        return None
    
    def process_multi_view_video_for_pim(self, video_path: str, movement_name: str, 
                                        output_dir: str = "pose_data") -> bool:
        """
        Process a multi-view video file for PIM detection, extracting pose landmarks from all views.
        
        Args:
            video_path (str): Path to the input video file
            movement_name (str): Name of the movement type for labeling
            output_dir (str): Directory to save processed results
            
        Returns:
            bool: True if processing successful, False otherwise
        """
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            logger.error(f"Could not open video file: {video_path}")
            return False
        
        os.makedirs(output_dir, exist_ok=True)
        video_id = os.path.basename(video_path).replace('.mkv', '').replace('.mp4', '').replace(' ', '_')
        timestamp = int(time.time())
        
        # Create separate CSV files for each view
        output_files = []
        csv_writers = []
        file_handles = []
        
        for view_idx in range(self.num_views):
            output_file = os.path.join(output_dir, f"{movement_name}_{video_id}_view{view_idx}_{timestamp}_data.csv")
            output_files.append(output_file)
            
            file_handle = open(output_file, 'w', newline='')
            file_handles.append(file_handle)
            
            writer = csv.DictWriter(file_handle, ['timestamp', 'landmark_id', 'x', 'y', 'z'])
            writer.writeheader()
            csv_writers.append(writer)
        
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        logger.info(f"Processing multi-view video: {video_path} ({frame_count} frames @ {fps} FPS)")
        
        successful_frames = 0
        
        for frame_idx in tqdm(range(frame_count), desc=f"Processing {movement_name}"):
            ret, frame = cap.read()
            if not ret:
                break

            # Calculate timestamp from frame index and fps
            frame_timestamp = frame_idx / fps
            ts = round(frame_timestamp, 3)
            
            # Crop frame into multiple views
            views = self.crop_video_views(frame)
            
            # Process each view
            for view_idx, view in enumerate(views):
                landmarks = self.extract_pose_landmarks_from_frame(view)
                
                if landmarks is not None:
                    # Write landmarks for this view
                    for landmark_id, landmark_coords in enumerate(landmarks):
                        csv_writers[view_idx].writerow({
                            'timestamp': ts,
                            'landmark_id': landmark_id,
                            'x': float(landmark_coords[0]),
                            'y': float(landmark_coords[1]),
                            'z': float(landmark_coords[2])
                        })
                    
                    if view_idx == 0:  # Count successful frames only once
                        successful_frames += 1

        # Close all files
        for file_handle in file_handles:
            file_handle.close()
            
        cap.release()
        
        logger.info(f"Processing complete. Successfully processed {successful_frames}/{frame_count} frames")
        for output_file in output_files:
            logger.info(f"Data saved to {output_file}")
        
        return successful_frames > 0

def prepare_sequences(file_path, seq_length=30, overlap=15):
    """Prepare sequences from CSV landmark data for training."""
    df = pd.read_csv(file_path)
    if 'timestamp' not in df.columns or 'landmark_id' not in df.columns:
        raise ValueError(f"Bad file format: {file_path}")

    # Make matching robust against float precision: round and sort.
    df['timestamp'] = pd.to_numeric(df['timestamp'], errors='coerce').round(3)
    df = df.sort_values('timestamp').reset_index(drop=True)
    timestamps = df['timestamp'].unique()

    sequences = []
    for i in range(0, len(timestamps) - seq_length + 1, max(1, seq_length - overlap)):
        sequence_timestamps = timestamps[i:i+seq_length]
        sequence = np.zeros((seq_length, 33, 3), dtype=np.float32)

        for t_idx, t in enumerate(sequence_timestamps):
            frame_data = df[df['timestamp'] == t]
            for _, row in frame_data.iterrows():
                landmark_id = int(row['landmark_id'])
                if 0 <= landmark_id < 33:
                    sequence[t_idx, landmark_id, 0] = float(row['x'])
                    sequence[t_idx, landmark_id, 1] = float(row['y'])
                    sequence[t_idx, landmark_id, 2] = float(row['z'])
        sequences.append(sequence)
    return np.array(sequences, dtype=np.float32)


def main():
    """
    Main function to demonstrate video processing workflow.
    
    Replace this with your specific video processing logic.
    """
    # Initialize the processor
    processor = MediaPipeVideoProcessor(
        pose_detection=True,
        hand_detection=True,
        face_detection=True
    )
    
    # TODO: Replace with your actual video file path
    video_path = "path/to/your/video.mp4"
    
    try:
        # Process single video
        landmarks_df = processor.process_video(video_path)
        print(f"Extracted landmarks from {len(landmarks_df)} frames")
        
        # Or process multiple videos
        # results = processor.batch_process_videos("path/to/video/directory")
        # print(f"Processed {len(results)} videos")
        
    except FileNotFoundError:
        print("Please provide valid video file paths")
    except Exception as e:
        print(f"Error during processing: {str(e)}")


if __name__ == "__main__":
    main()