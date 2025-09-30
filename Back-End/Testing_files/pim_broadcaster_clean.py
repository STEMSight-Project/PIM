#!/usr/bin/env python3
"""
Clean PIM Broadcaster - Merges proven PIM model with working broadcaster structure
Uses broadcaster.py framework with ultra_simple_pim_broadcast.py AI logic
"""
import argparse
import asyncio
import logging
import platform
from typing import Optional
import cv2
import numpy as np
import mediapipe as mp
import torch
import torch.nn as nn
from collections import deque

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription, VideoStreamTrack
import aiortc
from aiortc.contrib.media import MediaPlayer

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger("pim_broadcaster")


# PROVEN WORKING PIM Model Architecture
class JointBoneEnsembleLSTM(nn.Module):
    def __init__(self, input_dim=3, hidden_dim=128, num_layers=3, num_classes=7):
        super(JointBoneEnsembleLSTM, self).__init__()
        self.pose_connections = [
            (0, 1),
            (1, 2),
            (2, 3),
            (3, 7),
            (0, 4),
            (4, 5),
            (5, 6),
            (6, 8),
            (9, 10),
            (11, 13),
            (13, 15),
            (15, 17),
            (15, 19),
            (15, 21),
            (17, 19),
            (12, 14),
            (14, 16),
            (16, 18),
            (16, 20),
            (16, 22),
            (18, 20),
            (11, 23),
            (12, 24),
            (23, 24),
            (23, 25),
            (24, 26),
            (25, 27),
            (26, 28),
            (27, 29),
            (28, 30),
            (29, 31),
            (30, 32),
            (27, 31),
            (28, 32),
        ]
        self.num_keypoints, self.num_bones = 33, len(self.pose_connections)
        self.joint_feature_dim = input_dim * self.num_keypoints
        self.bone_feature_dim = input_dim * self.num_bones

        self.joint_lstm = nn.LSTM(
            input_size=self.joint_feature_dim,
            hidden_size=hidden_dim,
            num_layers=num_layers,
            batch_first=True,
            dropout=0.3,
        )
        self.bone_lstm = nn.LSTM(
            input_size=self.bone_feature_dim,
            hidden_size=hidden_dim,
            num_layers=num_layers,
            batch_first=True,
            dropout=0.3,
        )
        self.joint_attention = nn.MultiheadAttention(hidden_dim, 8, batch_first=True)
        self.bone_attention = nn.MultiheadAttention(hidden_dim, 8, batch_first=True)
        self.fusion_layer = nn.Sequential(
            nn.Linear(hidden_dim * 2, hidden_dim), nn.ReLU(), nn.Dropout(0.3)
        )
        self.feature_layers = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2), nn.ReLU(), nn.Dropout(0.3)
        )
        self.classifier = nn.Linear(hidden_dim // 2, num_classes)
        self.confidence_head = nn.Sequential(
            nn.Linear(hidden_dim // 2, 1), nn.Sigmoid()
        )

    def _extract_bone_features(self, joint_data):
        batch_size, seq_length = joint_data.shape[0], joint_data.shape[1]
        bone_features = torch.zeros(
            batch_size,
            seq_length,
            len(self.pose_connections),
            3,
            device=joint_data.device,
        )
        for i, (joint_a, joint_b) in enumerate(self.pose_connections):
            bone_features[:, :, i, :] = (
                joint_data[:, :, joint_b, :] - joint_data[:, :, joint_a, :]
            )
        return bone_features

    def forward(self, x):
        batch_size, seq_length, num_keypoints, input_dim = x.size()
        joint_features = x.view(batch_size, seq_length, -1)
        joint_lstm_out, _ = self.joint_lstm(joint_features)
        joint_attended, _ = self.joint_attention(
            joint_lstm_out, joint_lstm_out, joint_lstm_out
        )
        bone_features = self._extract_bone_features(x)
        bone_features = bone_features.view(batch_size, seq_length, -1)
        bone_lstm_out, _ = self.bone_lstm(bone_features)
        bone_attended, _ = self.bone_attention(
            bone_lstm_out, bone_lstm_out, bone_lstm_out
        )
        fused = self.fusion_layer(
            torch.cat([joint_attended[:, -1, :], bone_attended[:, -1, :]], dim=1)
        )
        features = self.feature_layers(fused)
        return self.classifier(features), self.confidence_head(features)


# PIM Video Track with AI Processing
class PIMVideoStreamTrack(VideoStreamTrack):
    def __init__(self, device, model, movements):
        super().__init__()
        self.device = device
        self.model = model
        self.movements = movements

        # Initialize camera
        try:
            device_index = int(device) if device.isdigit() else 0
        except:
            device_index = 0

        self.cap = cv2.VideoCapture(device_index)
        if not self.cap.isOpened():
            LOGGER.error("Failed to open camera device: %s", device)
            raise RuntimeError(f"Cannot open camera device: {device}")

        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        self.cap.set(cv2.CAP_PROP_FPS, 30)

        # MediaPipe setup
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )

        # Sequence tracking
        self.sequence_buffer = deque(maxlen=30)
        self.prediction_history = deque(maxlen=10)

        LOGGER.info("✅ PIM Video Stream initialized with device: %s", device)

    async def recv(self):
        pts, time_base = await self.next_timestamp()

        ret, frame = self.cap.read()
        if not ret:
            LOGGER.warning("Failed to read frame from camera")
            return

        # Flip horizontally for mirror effect
        frame = cv2.flip(frame, 1)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # MediaPipe pose detection
        results = self.pose.process(rgb_frame)

        # Process pose landmarks
        if results.pose_landmarks:
            # Extract landmarks
            landmarks = []
            for lm in results.pose_landmarks.landmark:
                landmarks.extend([lm.x, lm.y, lm.z])

            landmarks_array = np.array(landmarks).reshape(33, 3)
            self.sequence_buffer.append(landmarks_array)

            # Run PIM detection if we have enough frames
            if len(self.sequence_buffer) == 30:
                try:
                    # Prepare input for model
                    sequence = torch.tensor(
                        np.array(list(self.sequence_buffer)), dtype=torch.float32
                    )
                    sequence = sequence.unsqueeze(0)  # Add batch dimension

                    with torch.no_grad():
                        predictions, confidence_raw = self.model(sequence)
                        probabilities = torch.softmax(predictions, dim=1)
                        predicted_class = torch.argmax(probabilities, dim=1).item()
                        confidence = probabilities[0][predicted_class].item()

                        movement = self.movements[predicted_class]
                        self.prediction_history.append((movement, confidence))

                        # Stabilize predictions with history
                        if len(self.prediction_history) >= 5:
                            recent_predictions = list(self.prediction_history)[-5:]
                            avg_confidence = np.mean(
                                [conf for _, conf in recent_predictions]
                            )

                            if avg_confidence > 0.7:
                                most_common = max(
                                    set([pred for pred, _ in recent_predictions]),
                                    key=[pred for pred, _ in recent_predictions].count,
                                )
                                display_text = f"{most_common}: {avg_confidence:.2f}"
                                color = (0, 255, 0)  # Green for high confidence
                            else:
                                display_text = "No clear movement detected"
                                color = (255, 255, 0)  # Yellow for uncertain
                        else:
                            display_text = f"{movement}: {confidence:.2f}"
                            color = (0, 255, 255)  # Cyan for single prediction

                except Exception as e:
                    LOGGER.error("PIM model error: %s", e)
                    display_text = "Model Error"
                    color = (0, 0, 255)  # Red for error
            else:
                display_text = f"Collecting frames... {len(self.sequence_buffer)}/30"
                color = (255, 255, 255)  # White for loading

            # Draw pose landmarks on frame
            bgr_frame = cv2.cvtColor(rgb_frame, cv2.COLOR_RGB2BGR)
            self.mp_drawing.draw_landmarks(
                bgr_frame,
                results.pose_landmarks,
                self.mp_pose.POSE_CONNECTIONS,
                self.mp_drawing.DrawingSpec(
                    color=(0, 255, 0), thickness=2, circle_radius=2
                ),
                self.mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2),
            )

            # Add PIM detection text
            cv2.putText(
                bgr_frame,
                display_text,
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                color,
                2,
            )

        else:
            bgr_frame = cv2.cvtColor(rgb_frame, cv2.COLOR_RGB2BGR)
            cv2.putText(
                bgr_frame,
                "No pose detected",
                (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.7,
                (0, 0, 255),
                2,
            )

        # Convert to aiortc VideoFrame
        from av import VideoFrame

        frame = VideoFrame.from_ndarray(bgr_frame, format="bgr24")
        frame.pts = pts
        frame.time_base = time_base

        return frame

    def __del__(self):
        if hasattr(self, "cap"):
            self.cap.release()


# Broadcaster utility functions (from broadcaster.py)
def default_device() -> str:
    os_name = platform.system()
    LOGGER.info("Detected OS: %s", os_name)
    if os_name == "Windows":
        return "video=Logitech BRIO:audio=Microphone (3- AT2020USB+)"
    elif os_name == "Darwin":  # macOS
        return "0"
    else:  # Linux / *BSD
        return "/dev/video0"


def load_pim_model(model_path):
    """Load the PROVEN WORKING PIM model"""
    try:
        checkpoint = torch.load(model_path, map_location="cpu")
        movements = checkpoint["movements"]
        model = JointBoneEnsembleLSTM(
            input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements)
        )
        model.load_state_dict(checkpoint["model_state_dict"])
        model.eval()
        LOGGER.info("✅ PIM Model loaded: %s", movements)
        return model, movements
    except Exception as e:
        LOGGER.error("Failed to load PIM model: %s", e)
        raise


async def publish(
    room_id: str,
    base_url: str,
    video_device: Optional[str],
    device_name: Optional[str] = None,
) -> None:
    LOGGER.info("aiortc version: %s", aiortc.__version__)

    # Load PIM model
    model, movements = load_pim_model("../models/pim_model_joint_bone.pth")

    # Use provided device or default
    device = video_device or default_device()

    # Create peer connection
    pc = RTCPeerConnection()

    # Create PIM video track
    try:
        video_track = PIMVideoStreamTrack(device, model, movements)
        pc.addTrack(video_track)
        LOGGER.info("✅ PIM video track added")
    except Exception as e:
        LOGGER.error("Failed to create PIM video track: %s", e)
        return

    await pc.setLocalDescription(await pc.createOffer())

    while pc.iceGatheringState != "complete":
        await asyncio.sleep(0.1)

    offer_payload = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

    # Create room via API
    device_param = f"?device_name={device_name}" if device_name else ""
    create_room_url = f"{base_url}/streaming/create_room/{room_id}{device_param}"

    LOGGER.info("🔗 Creating room: %s", create_room_url)

    async with aiohttp.ClientSession() as session:
        try:
            # Create room
            async with session.post(create_room_url) as resp:
                if resp.status == 200:
                    room_info = await resp.json()
                    LOGGER.info("✅ Room created: %s", room_info)
                else:
                    LOGGER.error("Failed to create room: %s", resp.status)
                    return

            # Start streaming
            async with session.post(
                f"{base_url}/streaming/streamer/{room_id}",
                json=offer_payload,
                headers={"Content-Type": "application/json"},
            ) as resp:
                if resp.status == 200:
                    answer = await resp.json()
                    LOGGER.info("✅ Streaming started")

                    await pc.setRemoteDescription(
                        RTCSessionDescription(sdp=answer["sdp"], type=answer["type"])
                    )

                    LOGGER.info("🎥 PIM Broadcasting active - press Ctrl+C to stop")

                    # Keep alive
                    try:
                        await asyncio.sleep(3600)  # Run for 1 hour
                    except KeyboardInterrupt:
                        LOGGER.info("🛑 Broadcast stopped by user")

                else:
                    LOGGER.error("Failed to start streaming: %s", resp.status)

        except Exception as e:
            LOGGER.error("Streaming error: %s", e)
        finally:
            await pc.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Clean PIM WebRTC Broadcaster")
    parser.add_argument("--room", required=True, help="Room ID (patient ID)")
    parser.add_argument(
        "--signaling", default="http://localhost:8000", help="Signaling server URL"
    )
    parser.add_argument(
        "--video_device", required=False, help="Video device name or index"
    )
    parser.add_argument(
        "--device_name", default="PIM-Broadcaster-Clean", help="Device name"
    )

    args = parser.parse_args()

    LOGGER.info("🎯 Clean PIM Broadcaster Starting")
    LOGGER.info("Room: %s", args.room)
    LOGGER.info("Server: %s", args.signaling)
    LOGGER.info("Video Device: %s", args.video_device or "Default")
    LOGGER.info("Device Name: %s", args.device_name)

    try:
        asyncio.run(
            publish(args.room, args.signaling, args.video_device, args.device_name)
        )
    except KeyboardInterrupt:
        LOGGER.info("🛑 Clean PIM Broadcaster stopped")


if __name__ == "__main__":
    main()
