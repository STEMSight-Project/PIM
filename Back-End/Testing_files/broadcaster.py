import argparse
import asyncio
import inspect
import logging
import os
import platform
import subprocess
import re
import json
import time
import sys
from pathlib import Path
from collections import deque, Counter
from typing import Optional, List, Tuple
from datetime import datetime, timezone

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer
from aiortc.mediastreams import MediaStreamTrack
import cv2
import numpy as np
import mediapipe as mp
import torch
from av import VideoFrame

# Database imports (optional - graceful fallback)
try:
    # Add parent directory to Python path for core imports
    parent_dir_str = str(Path(__file__).parent.parent)
    if parent_dir_str not in sys.path:
        sys.path.insert(0, parent_dir_str)
    
    # Change working directory to Back-End so .env file is found
    original_cwd = os.getcwd()
    backend_dir = Path(__file__).parent.parent
    os.chdir(backend_dir)
    
    from core.common import supabase, logger as db_logger
    
    # Restore original working directory
    os.chdir(original_cwd)
    
    DATABASE_AVAILABLE = True
    print("✅ Database imports successful - predictions will be stored")
except Exception as e:
    DATABASE_AVAILABLE = False
    db_logger = None
    print(f"⚠️  Database not available: {e}")
    print("   Predictions will NOT be stored to database")
    print("   (This is normal if running from Testing_files/ without .env file)")

# Add parent directory to path to import pose-tcn_single_view
parent_dir = Path(__file__).parent.parent
if str(parent_dir) not in sys.path:
    sys.path.insert(0, str(parent_dir))

# Import model architecture and normalization from existing training code
# Note: Python can't import files with hyphens directly, so we use importlib
import importlib.util
try:
    # Try standard import first (if renamed)
    from pose_tcn_single_view import PoseTCNSingleView, normalize_single_view, NUM_POSE_LANDMARKS
except ImportError:
    # Fallback to dynamic import for hyphenated filename
    spec = importlib.util.spec_from_file_location("pose_tcn_single_view", parent_dir / "pose-tcn_single_view.py")
    if spec and spec.loader:
        pose_tcn_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(pose_tcn_module)
        PoseTCNSingleView = pose_tcn_module.PoseTCNSingleView
        normalize_single_view = pose_tcn_module.normalize_single_view
        NUM_POSE_LANDMARKS = pose_tcn_module.NUM_POSE_LANDMARKS
    else:
        print("❌ Could not import PoseTCN architecture. Make sure pose-tcn_single_view.py exists.")
        sys.exit(1)

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger("publisher")

# Hosted backend default (override via PIM_SIGNALING_URL env var or --signaling flag)
DEFAULT_SIGNALING_URL = os.getenv(
    "PIM_SIGNALING_URL",
    "https://fastapibackend-amfucydqayg9h8gb.westus3-01.azurewebsites.net",
).rstrip("/")


class DetectionStorage:
    """
    Handles storing AI detection predictions to the database.
    Throttles storage to avoid database overload (default: every 2 seconds).
    """
    
    def __init__(self, session_id: str, camera_id: str, room_id: Optional[str],
                 model_name: str, store_interval: float = 2.0):
        self.enabled = DATABASE_AVAILABLE
        if not self.enabled:
            LOGGER.warning("📊 Database not available - predictions will not be stored")
            return
        
        self.session_id = session_id
        self.camera_id = camera_id
        self.room_id = room_id
        self.model_name = model_name
        self.store_interval = store_interval
        self.last_store_time = 0
        self.sequence_number = 0
        
        LOGGER.info(f"📊 Database storage initialized (interval={store_interval}s)")
    
    def should_store(self) -> bool:
        """Check if enough time has elapsed since last storage."""
        if not self.enabled:
            return False
        
        current_time = time.time()
        if current_time - self.last_store_time >= self.store_interval:
            self.last_store_time = current_time
            return True
        return False
    
    def store_detection(self, predicted_class: str, confidence: float,
                       all_probs: dict, temperature: float = 1.0,
                       frame_count: int = 120, processing_time_ms: int = 0,
                       pose_landmarks: list = None):
        """Store a single detection to the database with optional pose landmarks."""
        if not self.enabled:
            return
        
        try:
            self.sequence_number += 1
            
            detection_data = {
                'all_probabilities': all_probs,
                'temperature': temperature,
                'frame_count': frame_count,
                'model_architecture': 'PoseTCN-SingleView'
            }
            
            # Add pose landmarks if provided (for skeleton replay during playback)
            if pose_landmarks:
                detection_data['pose_landmarks'] = pose_landmarks
            
            supabase.table('ai_detections').insert({
                'session_id': self.session_id,
                'camera_id': self.camera_id,
                'room_id': self.room_id,
                'detection_type': predicted_class,
                'confidence_score': confidence,
                'detection_data': detection_data,
                'frame_timestamp': datetime.now(timezone.utc).isoformat(),  # FIX: Use UTC aware time
                'sequence_number': self.sequence_number,
                'model_used': self.model_name,
                'processing_time_ms': processing_time_ms,
                'processed_on': 'edge'
            }).execute()
            
            if db_logger:
                db_logger.info(f"✅ Stored detection #{self.sequence_number}: {predicted_class} ({confidence:.2%})")
            
        except Exception as e:
            if db_logger:
                db_logger.error(f"Failed to store detection: {e}")
            else:
                LOGGER.error(f"❌ Failed to store detection: {e}")
    
    def store_batch_summary(self, detection_counts: dict, avg_confidence: float,
                            total_frames: int, duration_seconds: float):
        """Store a summary of detection session."""
        if not self.enabled:
            return
        
        try:
            summary_data = {
                'detection_counts': detection_counts,
                'avg_confidence': avg_confidence,
                'total_frames': total_frames,
                'duration_seconds': duration_seconds,
                'detections_per_second': self.sequence_number / duration_seconds if duration_seconds > 0 else 0
            }
            
            supabase.table('ai_detections').insert({
                'session_id': self.session_id,
                'camera_id': self.camera_id,
                'room_id': self.room_id,
                'detection_type': 'session_summary',
                'confidence_score': avg_confidence,
                'detection_data': summary_data,
                'frame_timestamp': datetime.now(timezone.utc).isoformat(), # FIX: Use UTC aware time
                'sequence_number': self.sequence_number,
                'model_used': self.model_name,
                'processed_on': 'edge'
            }).execute()
            
            if db_logger:
                db_logger.info(f"✅ Stored session summary: {len(detection_counts)} unique detections")
            
        except Exception as e:
            if db_logger:
                db_logger.error(f"Failed to store session summary: {e}")
            else:
                LOGGER.error(f"❌ Failed to store summary: {e}")


def detect_video_devices() -> List[Tuple[str, str]]:
    """
    Detect available video devices on the system.
    Returns list of tuples: (device_name, device_identifier)
    """
    os_name = platform.system()
    devices = []

    try:
        if os_name == "Windows":
            result = subprocess.run(
                ["ffmpeg", "-list_devices", "true", "-f", "dshow", "-i", "dummy"],
                capture_output=True, text=True, timeout=10
            )
            output = result.stderr
            video_pattern = r'"([^"]+)"\s+\(video\)'
            matches = re.finditer(video_pattern, output)
            for match in matches:
                device_name = match.group(1)
                devices.append((device_name, f"video={device_name}"))

        elif os_name == "Darwin":  # macOS
            result = subprocess.run(
                ["ffmpeg", "-f", "avfoundation", "-list_devices", "true", "-i", ""],
                capture_output=True, text=True, timeout=10
            )
            output = result.stderr
            video_pattern = r"\[(\d+)\]\s+(.+?)(?:\n|$)"
            in_video_section = False
            for line in output.split("\n"):
                if "AVFoundation video devices:" in line:
                    in_video_section = True
                    continue
                elif "AVFoundation audio devices:" in line:
                    in_video_section = False
                    break

                if in_video_section:
                    match = re.search(video_pattern, line)
                    if match:
                        device_index = match.group(1)
                        device_name = match.group(2).strip()
                        devices.append((device_name, f"{device_index}:none"))

        else:  # Linux / *BSD
            result = subprocess.run(
                ["ls", "/dev/video*"], capture_output=True, text=True, shell=True
            )
            if result.returncode == 0:
                for device_path in result.stdout.strip().split("\n"):
                    device_name = device_path.split("/")[-1]
                    devices.append((f"Video Device ({device_name})", device_path))

    except Exception as e:
        LOGGER.error(f"❌ Error detecting devices: {e}")

    return devices


def select_video_device() -> Optional[str]:
    print("\n📹 Detecting available video devices...")
    devices = detect_video_devices()

    if not devices:
        print("❌ No video devices found!")
        return None

    print(f"\n{'='*60}")
    print("📷 Available Video Devices:")
    print(f"{'='*60}")

    for idx, (name, identifier) in enumerate(devices, 1):
        print(f"  {idx}. {name}")

    print(f"{'='*60}\n")

    while True:
        try:
            choice = input(f"Select device number (1-{len(devices)}) or press Enter for default: ").strip()
            if not choice:
                print(f"✅ Using default device: {devices[0][0]}")
                return devices[0][1]

            choice_num = int(choice)
            if 1 <= choice_num <= len(devices):
                selected_name, selected_identifier = devices[choice_num - 1]
                print(f"✅ Selected: {selected_name}")
                return selected_identifier
            else:
                print(f"❌ Please enter a number between 1 and {len(devices)}")
        except ValueError:
            print("❌ Please enter a valid number")


def get_media_player(media_src: str) -> MediaPlayer:
    os_name = platform.system()
    format: str = None
    options: dict = None
    if os_name == "Windows":
        format = "dshow"
        options = {"framerate": "30", "video_size": "640x480"}
    elif os_name == "Darwin":
        format = "avfoundation"
        options = {"video_size": "640x480", "framerate": "30", "pixel_format": "yuyv422"}
    return MediaPlayer(media_src, format=format, options=options)


def safe_close_player(player: MediaPlayer):
    if hasattr(player, "stop") and inspect.iscoroutinefunction(player.stop):
        return player.stop()
    else:
        for track in (player.audio, player.video):
            if track:
                track.stop()
        return None


def get_media_src(video_dev: Optional[str], audio_dev: Optional[str]) -> str:
    os_name = platform.system()
    if os_name == "Windows":
        if video_dev and audio_dev:
            return f"video={video_dev}:audio={audio_dev}"
        elif video_dev:
            return f"video={video_dev}"
        else:
            return f"video=default"
    if os_name == "Darwin":
        if video_dev and audio_dev:
            return f"{video_dev}:{audio_dev}"
        elif video_dev:
            return f"{video_dev}:none"
        else:
            return "0:none"
    else:
        return "/dev/video0"


def get_user_input() -> tuple[str, str]:
    print("🚑 Ambulance WebRTC Broadcaster Setup")
    print("=" * 50)
    while True:
        ambulance_num = input("Enter Ambulance Number (e.g., 001, 002): ").strip()
        if ambulance_num.isdigit() and len(ambulance_num) <= 3:
            break
        print("❌ Please enter a valid number (up to 3 digits)")
    while True:
        room_num = input("Enter Room Number (e.g., 001, 002): ").strip()
        if room_num.isdigit() and len(room_num) <= 3:
            break
        print("❌ Please enter a valid number (up to 3 digits)")
    return ambulance_num.zfill(3), room_num.zfill(3)


async def get_ambulance_by_number(base_url: str, ambulance_number: str) -> Optional[dict]:
    try:
        async with aiohttp.ClientSession() as session:
            ambulances_url = f"{base_url}/ambulances/"
            async with session.get(ambulances_url) as resp:
                if resp.status == 200:
                    result = await resp.json()
                    ambulances = result.get("data", [])
                    for ambulance in ambulances:
                        if ambulance.get("ambulance_number") == ambulance_number:
                            return ambulance
                    return None
                else:
                    return None
    except Exception as e:
        LOGGER.error("Error fetching ambulances: %s", e)
        return None


class MediaPipePoseProcessor:
    """
    Process video frames with MediaPipe Pose and extract landmarks.
    Includes PoseTCN classifier for real-time movement detection.
    """
    
    def __init__(self, process_every_n_frames: int = 2, enable_classifier: bool = True,
                 session_id: Optional[str] = None, camera_id: Optional[str] = None,
                 room_id: Optional[str] = None, enable_db_storage: bool = True):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1, # Reduced from 2 to 1 for speed
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7
        )
        self.frame_count = 0
        self.process_every_n_frames = process_every_n_frames
        self.last_landmarks = None
        
        self.model = None
        self.classes = None
        self.temperature = 1.0
        self.window_size = 120
        self.buffer = deque(maxlen=120)
        self.last_prediction = None
        self.infer_every_n_frames = 30
        
        self.storage = None
        self.detection_counts = Counter()
        self.all_confidences = []
        self.stream_start_time = time.time()
        
        if enable_classifier:
            try:
                checkpoint_path = Path(__file__).parent.parent / "ai_models" / "best_single_view_f1_bn_t120_gamma175.pt"
                self._load_checkpoint(str(checkpoint_path))
                LOGGER.info("🤖 PoseTCN classifier initialized")
                
                if enable_db_storage and session_id and camera_id:
                    model_name = f"PoseTCN-T{self.temperature:.2f}"
                    self.storage = DetectionStorage(
                        session_id=session_id, camera_id=camera_id,
                        room_id=room_id, model_name=model_name
                    )
                    LOGGER.info("📊 Database storage enabled")
            except Exception as e:
                LOGGER.error(f"❌ Failed to load PoseTCN classifier: {e}")
                LOGGER.info("⚠️  Continuing without movement classification")
    
    def _load_checkpoint(self, path: str):
        ckpt = torch.load(path, map_location="cpu")
        self.classes = ckpt.get("classes", ["normal", "decorticate", "dystonia", "chorea", "myoclonus", "decerebrate", "fencer posture", "ballistic", "tremor", "versive head"])
        self.temperature = float(ckpt.get("best_temperature", 1.0) or 1.0)
        
        cfg = ckpt.get("args", {}) or {}
        state = ckpt["model_state_dict"]
        
        width = int(cfg.get("width", 384))
        drop = float(cfg.get("dropout", 0.1))
        
        # Helper to parse dilations safely
        dilations = [1, 2, 4, 8, 16, 32]
        if "dilations" in cfg:
            v = cfg["dilations"]
            if isinstance(v, str):
                dilations = [int(x.strip()) for x in v.split(",") if x.strip()]
            elif isinstance(v, (list, tuple)):
                dilations = [int(x) for x in v]
        
        t_heads = int(cfg.get("t_heads", 4))
        attn_dropout = float(cfg.get("attn_dropout", 0.0))
        
        self.model = PoseTCNSingleView(
            num_classes=len(self.classes), width=width, drop=drop,
            stochastic_depth=0.0, dilations=dilations,
            in_features=NUM_POSE_LANDMARKS * 3, t_heads=t_heads, attn_dropout=attn_dropout
        )
        self.model.load_state_dict(state, strict=True)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device).eval()
    
    def process_frame(self, frame: VideoFrame) -> Optional[Tuple[List[dict], Optional[dict]]]:
        self.frame_count += 1
        
        if self.frame_count % self.process_every_n_frames != 0:
            return self.last_landmarks, self.last_prediction
        
        try:
            # This conversion is CPU bound
            img_rgb = frame.to_ndarray(format="rgb24")
            
            if img_rgb is None or img_rgb.size == 0:
                return self.last_landmarks, self.last_prediction
            
            # MediaPipe is CPU bound
            results = self.pose.process(img_rgb)
            
            if results.pose_landmarks:
                landmarks = []
                for lm in results.pose_landmarks.landmark:
                    landmarks.append({"x": float(lm.x), "y": float(lm.y), "z": float(lm.z), "visibility": float(lm.visibility)})
                self.last_landmarks = landmarks
                
                if self.model is not None:
                    frame_landmarks = np.array([[lm["x"], lm["y"], lm["z"]] for lm in landmarks], dtype=np.float32)
                    self.buffer.append(frame_landmarks)
                    
                    if len(self.buffer) >= self.window_size and self.frame_count % self.infer_every_n_frames == 0:
                        prediction = self._predict()
                        if prediction:
                            self.last_prediction = prediction
                            pred_class = prediction['predicted_class']
                            confidence = prediction['confidence']
                            
                            LOGGER.info(f"🤖 [PREDICTION] {pred_class} ({confidence:.2%})")
                            self.detection_counts[pred_class] += 1
                            self.all_confidences.append(confidence)
                            
                            if self.storage and self.storage.should_store():
                                all_probs = {item['class']: item['confidence'] for item in prediction.get('top3', [])}
                                self.storage.store_detection(
                                    predicted_class=pred_class, confidence=confidence,
                                    all_probs=all_probs, temperature=self.temperature,
                                    frame_count=self.window_size, pose_landmarks=landmarks
                                )
                
                return landmarks, self.last_prediction
            else:
                self.last_landmarks = None
                return None, self.last_prediction
                
        except Exception as e:
            LOGGER.error("❌ Error processing frame: %s", e)
            return self.last_landmarks, self.last_prediction
    
    def _predict(self) -> Optional[dict]:
        try:
            seq = np.stack(list(self.buffer), axis=0)
            seq = normalize_single_view(seq)
            x_np = seq.reshape(self.window_size, -1)
            x = torch.from_numpy(x_np).unsqueeze(0).to(self.device)
            
            with torch.no_grad():
                logits = self.model(x)
                scaled = logits.float() / float(self.temperature)
                probs = torch.softmax(scaled, dim=1)
                pred_idx = int(scaled.argmax(1).item())
                confidence = float(probs[0, pred_idx].item())
                
                top3_probs, top3_preds = torch.topk(probs[0], k=min(3, len(self.classes)))
                top3 = [{"class": self.classes[int(top3_preds[i])], "confidence": float(top3_probs[i])} for i in range(len(top3_preds))]
                
                return {
                    "predicted_class": self.classes[pred_idx],
                    "confidence": confidence,
                    "top3": top3
                }
        except Exception as e:
            LOGGER.error(f"❌ Prediction error: {e}")
            return None
    
    def close(self):
        if self.storage and self.storage.enabled and len(self.detection_counts) > 0:
            duration = time.time() - self.stream_start_time
            avg_confidence = sum(self.all_confidences) / len(self.all_confidences) if self.all_confidences else 0.0
            self.storage.store_batch_summary(
                detection_counts=dict(self.detection_counts), avg_confidence=avg_confidence,
                total_frames=self.frame_count, duration_seconds=duration
            )
            LOGGER.info(f"✅ Session summary stored. Duration: {duration:.1f}s")
        if self.pose:
            self.pose.close()


class VideoTransformTrack(MediaStreamTrack):
    """
    A video stream track that transforms frames with MediaPipe.
    Uses threading to offload heavy processing and prevent blocking the event loop.
    """
    kind = "video"
    
    def __init__(self, track, processor, data_channel):
        super().__init__()
        self.track = track
        self.processor = processor
        self.data_channel = data_channel
    
    async def recv(self):
        frame = await self.track.recv()
        
        # ⚡ CRITICAL FIX: Offload heavy inference to a separate thread
        # This prevents the network heartbeat from freezing
        loop = asyncio.get_running_loop()
        landmarks, prediction = await loop.run_in_executor(
            None, # Use default ThreadPoolExecutor
            self.processor.process_frame,
            frame
        )
        
        # Send data via data channel (must happen on main loop)
        if landmarks and self.data_channel.readyState == "open":
            try:
                message = json.dumps({
                    "type": "pose_landmarks",
                    "landmarks": landmarks,
                    "prediction": prediction,
                    "timestamp": time.time()
                })
                self.data_channel.send(message)
            except Exception as e:
                pass # Suppress send errors to avoid log spam
        
        return frame


async def publish(ambulance_number: str, room_number: str, base_url: str,
                  video_device: Optional[str], audio_device: Optional[str],
                  device_name: Optional[str] = None) -> None:
    
    ambulance_name = f"AMB-{ambulance_number}"
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"
    
    LOGGER.info(f"🔍 Looking up ambulance {ambulance_name}...")
    ambulance_data = await get_ambulance_by_number(base_url, ambulance_name)
    if not ambulance_data:
        LOGGER.error(f"❌ Ambulance {ambulance_name} not found.")
        return

    ambulance_id = ambulance_data.get("id")
    
    if video_device:
        media_src = get_media_src(video_device, audio_device)
    else:
        selected_device = select_video_device()
        if not selected_device: return
        media_src = selected_device

    player = get_media_player(media_src)
    pose_processor = None

    # WebRTC Setup
    from aiortc import RTCConfiguration, RTCIceServer
    config = RTCConfiguration(iceServers=[RTCIceServer(urls=["stun:stun.l.google.com:19302"])])
    pc = RTCPeerConnection(configuration=config)
    
    data_channel = pc.createDataChannel("pose_landmarks")
    
    @data_channel.on("open")
    def on_datachannel_open():
        LOGGER.info("📡 Data channel opened")
        
    async with aiohttp.ClientSession() as session:
        # 1. Create Ambulance Session
        session_payload = {"ambulance_id": ambulance_id, "session_name": f"Broadcaster - {ambulance_name}", "session_type": "emergency", "priority_level": 3}
        create_url = f"{base_url}/ambulance-streaming/ambulance-sessions"
        
        session_id = None
        try:
            async with session.post(create_url, json=session_payload) as resp:
                if resp.status in [200, 409]:
                    # If 409 (exists), fetch it
                    if resp.status == 409:
                        async with session.get(create_url, params={"ambulance_id": ambulance_id, "is_active": True}) as get_resp:
                            if get_resp.status == 200:
                                sessions = await get_resp.json()
                                if sessions: session_id = sessions[0].get("id")
                    else:
                        sess = await resp.json()
                        session_id = sess.get("id")
        except Exception as e:
            LOGGER.error(f"Session creation failed: {e}")
            return

        if not session_id:
            LOGGER.error("❌ Could not obtain session ID")
            return

        # 2. Get/Create Camera
        camera_id = None
        get_cams_url = f"{base_url}/ambulances/{ambulance_id}/cameras"
        async with session.get(get_cams_url) as resp:
            if resp.status == 200:
                data = await resp.json()
                cameras = data.get("data", [])
                if cameras:
                    # Simple selection logic
                    cam_idx = (int(room_number) - 1) % len(cameras)
                    camera_id = cameras[cam_idx].get("id")
        
        if not camera_id:
            # Create camera
            create_cam_payload = {
                "camera_id": f"AMB-{ambulance_number}-CAM-{room_number}",
                "camera_name": f"Cam {room_number}",
                "camera_type": "medical",
                "position_in_ambulance": f"pos-{room_number}",
                "status": "active"
            }
            async with session.post(get_cams_url, json=create_cam_payload) as resp:
                if resp.status in [200, 201]:
                    new_cam = await resp.json()
                    camera_id = new_cam.get("data", new_cam).get("id")
        
        if not camera_id:
            LOGGER.error("❌ Could not obtain Camera ID")
            return

        # 3. Initialize Processor & Tracks
        pose_processor = MediaPipePoseProcessor(
            process_every_n_frames=2, session_id=session_id,
            camera_id=camera_id, room_id=room_name, enable_db_storage=True
        )
        
        if player.video:
            video_track = VideoTransformTrack(player.video, pose_processor, data_channel)
            pc.addTrack(video_track)
            if player.audio: pc.addTrack(player.audio)
        
        await pc.setLocalDescription(await pc.createOffer())
        
        # 4. Create/Join Room
        room_payload = {"camera_id": camera_id, "room_name": room_name, "device_name": device_name or "Broadcaster"}
        create_room_url = f"{base_url}/ambulance-streaming/camera-rooms"
        
        async with session.post(create_room_url, json=room_payload, params={"session_id": session_id}) as resp:
            # Whether created (200) or exists (409), we use the same streamer URL
            streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
        
        # 5. Connect
        while pc.iceGatheringState != "complete": await asyncio.sleep(0.1)
        offer = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}
        
        async with session.post(streaming_url, json=offer) as resp:
            if resp.status == 200:
                answer = await resp.json()
                await pc.setRemoteDescription(RTCSessionDescription(**answer))
                LOGGER.info(f"✅ Broadcasting to {room_name}")
            else:
                LOGGER.error(f"❌ Connection failed: {resp.status}")
                return

        try:
            while True:
                await asyncio.sleep(5)
                if pc.connectionState in ["failed", "closed"]: break
        finally:
            safe_close_player(player)
            if pose_processor: pose_processor.close()
            await pc.close()

async def end_session_manually(base_url: str, session_id: str) -> None:
    url = f"{base_url}/streaming/sessions/{session_id}/end"
    async with aiohttp.ClientSession() as session:
        await session.post(url)

def main() -> None:
    parser = argparse.ArgumentParser(
        description="WebRTC camera publisher with smart session management and auto device detection",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Interactive mode (will prompt for ambulance, room, and device selection)
  python broadcaster.py

  # Specify ambulance and room, but choose device interactively
  python broadcaster.py --ambulance_number 001 --room 001

  # Fully automated with specific device (Windows)
  python broadcaster.py --ambulance_number 001 --room 001 --video_device "Logitech BRIO"

  # Fully automated with specific device (macOS)
  python broadcaster.py --ambulance_number 001 --room 001 --video_device "0"

  # End a session manually
  python broadcaster.py --end_session SESSION_ID_HERE
        """,
    )
    parser.add_argument(
        "--signaling",
        default=DEFAULT_SIGNALING_URL,
        help=f"Base URL of signalling server (default: {DEFAULT_SIGNALING_URL})",
    )
    parser.add_argument(
        "--video_device",
        required=False,
        help="Specify video device directly (skips auto-detection). "
        "If not provided, will show available devices for selection.",
    )
    parser.add_argument(
        "--audio_device",
        required=False,
        help="Specify audio device (optional). "
        "If not provided, audio will be disabled for better performance.",
    )
    parser.add_argument(
        "--device_name",
        required=False,
        default="TestDevice-Broadcaster",
        help="Name of the streaming device (default: TestDevice-Broadcaster)",
    )
    parser.add_argument(
        "--end_session",
        required=False,
        help="End a specific session ID (for testing purposes)",
    )
    parser.add_argument(
        "--ambulance_number",
        required=False,
        help="Ambulance number (e.g., 001, 003). If not provided, will prompt for input.",
    )
    parser.add_argument(
        "--room",
        required=False,
        help="Room number (e.g., 001, 002). If not provided, will prompt for input.",
    )
    args = parser.parse_args()

    if args.end_session:
        asyncio.run(end_session_manually(args.signaling, args.end_session))
        return

    amb, room = (args.ambulance_number, args.room) if args.ambulance_number else get_user_input()
    
    try:
        asyncio.run(publish(
            amb.zfill(3), room.zfill(3), args.signaling.rstrip("/"),
            args.video_device, args.audio_device, args.device_name
        ))
    except KeyboardInterrupt:
        pass
    except Exception as e:
        LOGGER.exception(f"Fatal error: {e}")

if __name__ == "__main__":
    main()