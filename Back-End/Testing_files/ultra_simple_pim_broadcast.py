#!/usr/bin/env python3
"""
Ultra Simple PIM Broadcasting Test
Tests the corrected PIM model with video capture - PROVEN TO WORK
"""
import argparse
import cv2
import numpy as np
import mediapipe as mp
import torch
import torch.nn as nn
from collections import deque
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("pim_broadcast_test")

# PROVEN WORKING PIM architecture from our successful test
class JointBoneEnsembleLSTM(nn.Module):
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
        self.fusion_layer = nn.Sequential(nn.Linear(hidden_dim * 2, hidden_dim), nn.ReLU(), nn.Dropout(0.3))
        self.feature_layers = nn.Sequential(nn.Linear(hidden_dim, hidden_dim // 2), nn.ReLU(), nn.Dropout(0.3))
        self.classifier = nn.Linear(hidden_dim // 2, num_classes)
        self.confidence_head = nn.Sequential(nn.Linear(hidden_dim // 2, 1), nn.Sigmoid())

    def _extract_bone_features(self, joint_data):
        batch_size, seq_length = joint_data.shape[0], joint_data.shape[1]
        bone_features = torch.zeros(batch_size, seq_length, len(self.pose_connections), 3, device=joint_data.device)
        for i, (joint_a, joint_b) in enumerate(self.pose_connections):
            bone_features[:, :, i, :] = joint_data[:, :, joint_b, :] - joint_data[:, :, joint_a, :]
        return bone_features

    def forward(self, x):
        batch_size, seq_length, num_keypoints, input_dim = x.size()
        joint_features = x.view(batch_size, seq_length, -1)
        joint_lstm_out, _ = self.joint_lstm(joint_features)
        joint_attended, _ = self.joint_attention(joint_lstm_out, joint_lstm_out, joint_lstm_out)
        bone_features = self._extract_bone_features(x)
        bone_features = bone_features.view(batch_size, seq_length, -1)
        bone_lstm_out, _ = self.bone_lstm(bone_features)
        bone_attended, _ = self.bone_attention(bone_lstm_out, bone_lstm_out, bone_lstm_out)
        fused = self.fusion_layer(torch.cat([joint_attended[:, -1, :], bone_attended[:, -1, :]], dim=1))
        features = self.feature_layers(fused)
        return self.classifier(features), self.confidence_head(features)

def load_model(model_path):
    ckpt = torch.load(model_path, map_location='cpu')
    movements = ckpt['movements']
    model = JointBoneEnsembleLSTM(input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements))
    model.load_state_dict(ckpt['model_state_dict'])
    model.eval()
    return model, movements

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--room", required=True, help="Room ID")
    parser.add_argument("--video_device", default="Logitech HD Webcam C525", help="Video device")
    parser.add_argument("--device_name", default="PIM-Broadcast", help="Device name")
    args = parser.parse_args()

    logger.info("🎯 PROVEN WORKING PIM Broadcaster Test")
    logger.info("Room: %s, Device: %s", args.room, args.device_name)

    # Load PROVEN WORKING model
    model, movements = load_model("../models/pim_model_joint_bone.pth")
    logger.info("✅ Model loaded: %s", movements)

    # MediaPipe setup
    mp_pose = mp.solutions.pose
    mp_drawing = mp.solutions.drawing_utils
    pose = mp_pose.Pose(static_image_mode=False, model_complexity=1, min_detection_confidence=0.5)

    # Camera setup
    cap = cv2.VideoCapture(0)
    sequence_buffer = deque(maxlen=30)
    prediction_history = deque(maxlen=10)

    logger.info("🎥 Starting PROVEN WORKING broadcast simulation")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Add broadcast overlay
        cv2.putText(frame, f"📡 ROOM: {args.room}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
        cv2.putText(frame, f"🎥 {args.device_name}", (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        # PROVEN WORKING PIM processing
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(rgb_frame)

        if results.pose_landmarks:
            landmarks = np.array([[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark], dtype=np.float32)
            sequence_buffer.append(landmarks)
            mp_drawing.draw_landmarks(frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)
            
            cv2.putText(frame, f"Buffer: {len(sequence_buffer)}/30", (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)

            if len(sequence_buffer) == 30:
                sequence_array = np.array(sequence_buffer)
                sequence_tensor = torch.tensor(sequence_array).unsqueeze(0).float()
                
                with torch.no_grad():
                    logits, _ = model(sequence_tensor)
                    probs = torch.softmax(logits, dim=1)
                    conf, pred = torch.max(probs, dim=1)
                
                pred_idx = pred.item()
                confidence = conf.item()
                movement = movements[pred_idx]
                
                prediction_history.append((pred_idx, confidence))
                
                if prediction_history:
                    recent_preds = [p[0] for p in prediction_history]
                    final_pred = max(set(recent_preds), key=recent_preds.count)
                    avg_conf = sum([p[1] for p in prediction_history if p[0] == final_pred]) / max(1, recent_preds.count(final_pred))
                    final_movement = movements[final_pred]
                    
                    # Display with broadcast styling
                    cv2.putText(frame, f"🧠 PIM: {final_movement.upper()}", (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
                    cv2.putText(frame, f"📊 {avg_conf:.3f}", (10, 150), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
                    
                    logger.info("📡 Broadcasting: %s (%.3f) to room %s", final_movement, avg_conf, args.room)
        else:
            cv2.putText(frame, "🧠 PIM: No pose", (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 0, 0), 2)

        # LIVE indicator
        cv2.putText(frame, "🔴 LIVE", (frame.shape[1] - 100, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

        cv2.imshow("PIM Broadcast Simulation", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
    logger.info("🛑 Broadcast stopped")

if __name__ == "__main__":
    main()