#!/usr/bin/env python3
"""
Clean PIM Broadcaster - Ambulance Camera Streaming with AI Processing
Integrates with ambulance streaming API endpoints and processes MediaPipe landmarks
Provides real-time posture/movement detection using PIM AI models
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
    def __init__(self, video_track, model, movements):
        super().__init__()
        self.video_track = video_track  # MediaPlayer video track
        self.model = model
        self.movements = movements

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

        LOGGER.info("✅ PIM Video Stream initialized with MediaPlayer track")

    async def recv(self):
        # Get frame from the underlying video track
        frame = await self.video_track.recv()
        if not frame:
            LOGGER.warning("Failed to receive frame from video track")
            return frame

        # Convert video frame to numpy array for processing
        img = frame.to_ndarray(format="bgr24")

        # Flip horizontally for mirror effect
        img = cv2.flip(img, 1)
        rgb_frame = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

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

        new_frame = VideoFrame.from_ndarray(bgr_frame, format="bgr24")
        new_frame.pts = frame.pts
        new_frame.time_base = frame.time_base

        return new_frame

    def __del__(self):
        # MediaPlayer tracks are handled by aiortc
        pass


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
    ambulance_id: str,
    camera_id: str,
    base_url: str,
    video_device: Optional[str],
    device_name: Optional[str] = None,
) -> None:
    LOGGER.info("aiortc version: %s", aiortc.__version__)

    # Load PIM model
    import os

    model_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)), "models", "pim_model_joint_bone.pth"
    )
    model, movements = load_pim_model(model_path)

    # Use provided device or default
    device = video_device or "0"

    # For Windows, use DirectShow format like broadcaster.py
    import platform
    from aiortc.contrib.media import MediaPlayer

    def get_media_src(video_dev):
        os_name = platform.system()
        if os_name == "Windows":
            if video_dev.isdigit():
                # If numeric, use default Logitech BRIO
                return "video=Logitech BRIO"
            else:
                return f"video={video_dev}"
        else:
            return video_dev

    def get_media_player(media_src):
        os_name = platform.system()
        if os_name == "Windows":
            return MediaPlayer(
                media_src,
                format="dshow",
                options={
                    "framerate": "30",
                    "video_size": "640x480",
                },
            )
        else:
            return MediaPlayer(media_src)

    # Create media player for video source
    media_src = get_media_src(device)
    LOGGER.info("🎥 Using media source: %s", media_src)

    try:
        player = get_media_player(media_src)
        LOGGER.info("✅ MediaPlayer created: %s", type(player))
        LOGGER.info("Player video track: %s", player.video if player else "None")
        LOGGER.info("Player audio track: %s", player.audio if player else "None")
    except Exception as e:
        LOGGER.error("Failed to create MediaPlayer: %s", e)
        return

    if not player:
        LOGGER.error("MediaPlayer is None")
        return

    # Create peer connection
    pc = RTCPeerConnection()

    # Add video track from MediaPlayer and wrap with PIM processing
    if player.video:
        # Create PIM wrapper around the media player track
        pim_track = PIMVideoStreamTrack(player.video, model, movements)
        pc.addTrack(pim_track)
        LOGGER.info("✅ PIM video track added with media player")
    else:
        LOGGER.error("No video track found from media player")
        # Clean up
        if hasattr(player, "audio") and player.audio:
            player.audio.stop()
        return

    try:
        LOGGER.info("🔄 Creating WebRTC offer...")
        offer = await asyncio.wait_for(pc.createOffer(), timeout=30.0)
        await pc.setLocalDescription(offer)
        LOGGER.info("✅ WebRTC offer created")

        LOGGER.info("🔄 Gathering ICE candidates...")
        ice_timeout = 0
        while (
            pc.iceGatheringState != "complete" and ice_timeout < 100
        ):  # 10 second timeout
            await asyncio.sleep(0.1)
            ice_timeout += 1

        if pc.iceGatheringState == "complete":
            LOGGER.info("✅ ICE gathering complete")
        else:
            LOGGER.warning("⚠️ ICE gathering timeout, proceeding anyway")

        offer_payload = {
            "sdp": pc.localDescription.sdp,
            "type": pc.localDescription.type,
        }
        LOGGER.info("✅ Offer payload prepared")
    except asyncio.TimeoutError:
        LOGGER.error("WebRTC offer creation timed out")
        return
    except Exception as e:
        LOGGER.error("Failed during WebRTC setup: %s", e)
        return

    # Use ambulance_id as room_id for the streaming API
    room_id = ambulance_id

    async with aiohttp.ClientSession() as session:
        try:
            # Step 1: Create room using the standard streaming API
            device_param = f"?device_name={device_name or 'PIM-Broadcaster'}"
            create_room_url = (
                f"{base_url}/streaming/create_room/{room_id}{device_param}"
            )

            LOGGER.info("🎥 Creating streaming room for: %s", room_id)
            async with session.post(create_room_url) as resp:
                if resp.status != 200:
                    error_text = await resp.text()
                    LOGGER.error("Create room failed (%s): %s", resp.status, error_text)

                    # Check if it's because of existing non-ended session
                    if "non-ended session" in error_text.lower():
                        LOGGER.warning(
                            "Ambulance has an existing active session. Please end it first via frontend."
                        )
                        return
                    else:
                        return

                room_json = await resp.json()
                LOGGER.info("Room created/connected: %s", room_json)

                # Extract session info and updated room_id
                session_id = room_json.get("session_id")
                returned_room_id = room_json.get("room_id")
                if session_id:
                    LOGGER.info("Streaming session ID: %s", session_id)

                # Use the returned room_id for subsequent calls (includes device name suffix)
                if returned_room_id:
                    room_id = returned_room_id
                    LOGGER.info("Using returned room ID: %s", room_id)

                if room_json.get("reconnected"):
                    LOGGER.info("✅ Reconnected to existing room")
                elif room_json.get("already_exists"):
                    LOGGER.info("✅ Room already exists and is active")
                elif room_json.get("created"):
                    LOGGER.info("✅ New room and session created")

            # Step 2: Connect streamer to room
            streaming_url = f"{base_url}/streaming/streamer/{room_id}"
            LOGGER.info("🔗 Connecting PIM streamer to room: %s", room_id)

            async with session.post(streaming_url, json=offer_payload) as resp:
                if resp.status == 404:
                    LOGGER.error("Room not found. Please create room first.")
                    return
                elif resp.status == 409:
                    LOGGER.warning("Streamer already exists. Retrying...")
                    await asyncio.sleep(1)
                    # Retry once
                    async with session.post(
                        streaming_url, json=offer_payload
                    ) as retry_resp:
                        if retry_resp.status != 200:
                            LOGGER.error(
                                "Publish retry failed (%s): %s",
                                retry_resp.status,
                                await retry_resp.text(),
                            )
                            return
                        answer_json = await retry_resp.json()
                elif resp.status != 200:
                    LOGGER.error(
                        "Publish failed (%s): %s", resp.status, await resp.text()
                    )
                    return
                else:
                    answer_json = await resp.json()

            await pc.setRemoteDescription(RTCSessionDescription(**answer_json))
            LOGGER.info("🎥 PIM Streaming started successfully!")
            LOGGER.info("📡 Session ID: %s", session_id or "Unknown")
            LOGGER.info(
                "⚠️  NOTE: Session will remain active until explicitly ended via frontend"
            )
            LOGGER.info(
                "🛑 Press Ctrl+C to stop streaming (session stays active for reconnection)..."
            )

            # Keep alive and monitor connection
            try:
                while True:
                    await asyncio.sleep(5)
                    if pc.connectionState in ["failed", "closed", "disconnected"]:
                        LOGGER.warning(
                            "Connection state: %s. Room will wait for reconnection...",
                            pc.connectionState,
                        )
                        LOGGER.info(
                            "💡 Session remains active - you can restart broadcaster to reconnect"
                        )
                        break
            except KeyboardInterrupt:
                LOGGER.info("🛑 Stopping stream...")
                LOGGER.info(
                    "💡 Session remains active - restart broadcaster to reconnect"
                )
                LOGGER.info("💡 Use frontend to explicitly end session when done")

        except Exception as e:
            LOGGER.error("Streaming error: %s", e)
        finally:
            # Note: We do NOT end the session here - that's only done via frontend
            # Cleanup media player
            if hasattr(player, "audio") and player.audio:
                player.audio.stop()
            if hasattr(player, "video") and player.video:
                player.video.stop()

            await pc.close()
            LOGGER.info("🧹 Broadcaster cleanup completed")
            LOGGER.info("📋 Session Status: ACTIVE (can reconnect)")


def main() -> None:
    parser = argparse.ArgumentParser(description="Clean PIM WebRTC Broadcaster")
    parser.add_argument(
        "--ambulance_id", required=True, help="Ambulance ID for session"
    )
    parser.add_argument("--camera_id", required=True, help="Camera ID for streaming")
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
    LOGGER.info("Ambulance ID: %s", args.ambulance_id)
    LOGGER.info("Camera ID: %s", args.camera_id)
    LOGGER.info("Server: %s", args.signaling)
    LOGGER.info("Video Device: %s", args.video_device or "Default")
    LOGGER.info("Device Name: %s", args.device_name)

    try:
        asyncio.run(
            publish(
                args.ambulance_id,
                args.camera_id,
                args.signaling,
                args.video_device,
                args.device_name,
            )
        )
    except KeyboardInterrupt:
        LOGGER.info("🛑 Clean PIM Broadcaster stopped")


if __name__ == "__main__":
    main()
