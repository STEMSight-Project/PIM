import argparse
import asyncio
import inspect
import logging
import platform
import subprocess
import re
import json
import time
import sys
from pathlib import Path
from collections import deque, Counter
from typing import Optional, List, Tuple
from datetime import datetime

import aiohttp
from aiortc import RTCPeerConnection, RTCSessionDescription
import aiortc
from aiortc.contrib.media import MediaPlayer
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
    import os
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
spec = importlib.util.spec_from_file_location("pose_tcn_single_view", parent_dir / "pose-tcn_single_view.py")
pose_tcn_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pose_tcn_module)
PoseTCNSingleView = pose_tcn_module.PoseTCNSingleView
normalize_single_view = pose_tcn_module.normalize_single_view
NUM_POSE_LANDMARKS = pose_tcn_module.NUM_POSE_LANDMARKS

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger("publisher")


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
                'frame_timestamp': datetime.now().isoformat(),
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
                'frame_timestamp': datetime.now().isoformat(),
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
            # Use dshow to list Windows devices
            result = subprocess.run(
                ["ffmpeg", "-list_devices", "true", "-f", "dshow", "-i", "dummy"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            output = result.stderr  # FFmpeg outputs device list to stderr

            # Parse video devices (format: "Device Name" (video))
            video_pattern = r'"([^"]+)"\s+\(video\)'
            matches = re.finditer(video_pattern, output)
            for match in matches:
                device_name = match.group(1)
                devices.append((device_name, f"video={device_name}"))

        elif os_name == "Darwin":  # macOS
            # Use avfoundation to list macOS devices
            result = subprocess.run(
                ["ffmpeg", "-f", "avfoundation", "-list_devices", "true", "-i", ""],
                capture_output=True,
                text=True,
                timeout=10,
            )
            output = result.stderr

            # Parse video devices (format: [AVFoundation indev @ 0x...] [0] Device Name)
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
            # List /dev/video* devices
            result = subprocess.run(
                ["ls", "/dev/video*"], capture_output=True, text=True, shell=True
            )
            if result.returncode == 0:
                for device_path in result.stdout.strip().split("\n"):
                    device_name = device_path.split("/")[-1]  # Get video0, video1, etc.
                    devices.append((f"Video Device ({device_name})", device_path))

    except subprocess.TimeoutExpired:
        LOGGER.error("⏱️  Device detection timed out")
    except FileNotFoundError:
        LOGGER.error("❌ FFmpeg not found. Please install FFmpeg to detect devices.")
    except Exception as e:
        LOGGER.error(f"❌ Error detecting devices: {e}")

    return devices


def select_video_device() -> Optional[str]:
    """
    Display available video devices and let user select one.
    Returns the device identifier string for FFmpeg.
    """
    print("\n📹 Detecting available video devices...")
    devices = detect_video_devices()

    if not devices:
        print("❌ No video devices found!")
        print("💡 Make sure cameras are connected and FFmpeg is installed")
        return None

    print(f"\n{'='*60}")
    print("📷 Available Video Devices:")
    print(f"{'='*60}")

    for idx, (name, identifier) in enumerate(devices, 1):
        print(f"  {idx}. {name}")

    print(f"{'='*60}\n")

    while True:
        try:
            choice = input(
                f"Select device number (1-{len(devices)}) or press Enter for default: "
            ).strip()

            if not choice:  # User pressed Enter - use default
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
        except KeyboardInterrupt:
            print("\n🛑 Device selection cancelled")
            return None


def default_device() -> str:
    os_name = platform.system()
    print(f"Detected OS: {os_name}")
    if os_name == "Windows":
        # Try multiple camera options with preference for lower buffer cameras
        return "video=Logitech BRIO"  # Remove audio to reduce buffer load
    elif os_name == "Darwin":  # macOS
        return "0:none"  # First camera, no audio
    else:  # Linux / *BSD
        return "/dev/video0"


def get_media_player(media_src: str) -> MediaPlayer:
    os_name = platform.system()
    format: str = None
    options: dict = None
    if os_name == "Windows":
        format = "dshow"
        options = {
            "framerate": "30",
            "video_size": "640x480",
            # Removed rtbufsize - let FFmpeg use default small buffer for real-time streaming
        }
    elif os_name == "Darwin":
        format = "avfoundation"
        options = {
            "video_size": "640x480",  # Increased from 320x240
            "framerate": "30",  # Increased from 10
            "pixel_format": "yuyv422",
        }
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
    """Prompt user for ambulance number and room number."""
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


async def get_ambulance_by_number(
    base_url: str, ambulance_number: str
) -> Optional[dict]:
    """Get ambulance details by searching for ambulance number."""
    try:
        async with aiohttp.ClientSession() as session:
            # Get all ambulances from the backend
            ambulances_url = f"{base_url}/ambulances/"
            LOGGER.info("Fetching ambulances from: %s", ambulances_url)

            async with session.get(ambulances_url) as resp:
                if resp.status == 200:
                    result = await resp.json()
                    ambulances = result.get("data", [])
                    LOGGER.info("Found %d ambulances in database", len(ambulances))

                    # Search for ambulance by ambulance_number
                    for ambulance in ambulances:
                        if ambulance.get("ambulance_number") == ambulance_number:
                            LOGGER.info(
                                "✅ Found ambulance: %s (ID: %s)",
                                ambulance.get("ambulance_number"),
                                ambulance.get("id"),
                            )
                            return ambulance

                    LOGGER.warning(
                        "❌ Ambulance %s not found in database", ambulance_number
                    )
                    return None
                else:
                    error_text = await resp.text()
                    LOGGER.error(
                        "Failed to fetch ambulances (%d): %s", resp.status, error_text
                    )
                    return None

    except Exception as e:
        LOGGER.error("Error fetching ambulances: %s", e)
        return None


async def check_room_status(base_url: str, room_id: str) -> None:
    """Check the status of rooms for debugging"""
    async with aiohttp.ClientSession() as session:
        try:
            status_url = f"{base_url}/ambulance-streaming/ambulances/status"
            async with session.get(status_url) as resp:
                if resp.status == 200:
                    status_json = await resp.json()
                    print(f"📊 Ambulance Status for {room_id}:")
                    ambulances = status_json if isinstance(status_json, list) else []
                    found_ambulance = None
                    for amb in ambulances:
                        if (
                            amb.get("ambulance_id") == room_id
                            or amb.get("ambulance_number") == room_id
                        ):
                            found_ambulance = amb
                            break

                    if found_ambulance:
                        print(f"   ✅ Ambulance found")
                        print(
                            f"   � Status: {found_ambulance.get('status', 'unknown')}"
                        )
                        print(
                            f"   📹 Total Camera Rooms: {found_ambulance.get('total_camera_rooms', 0)}"
                        )
                        print(
                            f"   � Connected Cameras: {found_ambulance.get('connected_camera_rooms', 0)}"
                        )
                        print(
                            f"   🆔 Session ID: {found_ambulance.get('session_id', 'Unknown')}"
                        )
                        if found_ambulance.get("camera_rooms"):
                            print(f"   📷 Camera Rooms:")
                            for room in found_ambulance["camera_rooms"]:
                                print(
                                    f"      - {room.get('camera_name', 'Unknown')}: {room.get('room_name', 'No Name')} (UUID: {room.get('id', 'No ID')})"
                                )
                    else:
                        print(f"   ❌ Ambulance {room_id} not found")
                else:
                    print(f"❌ Failed to get room status: {resp.status}")
        except Exception as e:
            print(f"❌ Error checking room status: {e}")


class MediaPipePoseProcessor:
    """
    Process video frames with MediaPipe Pose and extract landmarks.
    Includes PoseTCN classifier for real-time movement detection.
    Processes every Nth frame to reduce CPU load.
    """
    
    def __init__(self, process_every_n_frames: int = 2, enable_classifier: bool = True,
                 session_id: Optional[str] = None, camera_id: Optional[str] = None,
                 room_id: Optional[str] = None, enable_db_storage: bool = True):
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=2,  # Best accuracy
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7
        )
        self.frame_count = 0
        self.process_every_n_frames = process_every_n_frames
        self.last_landmarks = None
        LOGGER.info("📊 MediaPipe Pose initialized (model_complexity=2)")
        
        # Initialize PoseTCN classifier using existing training code
        self.model = None
        self.classes = None
        self.temperature = 1.0
        self.window_size = 120
        self.buffer = deque(maxlen=120)
        self.last_prediction = None
        self.infer_every_n_frames = 30  # Run inference every 30 frames (~1 per second at 30fps)
        
        # Database storage for predictions
        self.storage = None
        self.detection_counts = Counter()
        self.all_confidences = []
        self.stream_start_time = time.time()
        
        if enable_classifier:
            try:
                checkpoint_path = Path(__file__).parent.parent / "ai_models" / "best_single_view_f1_bn_t120_gamma175.pt"
                self._load_checkpoint(str(checkpoint_path))
                LOGGER.info("🤖 PoseTCN classifier initialized (T=%d frames)", self.window_size)
                
                # Initialize database storage if context provided
                if enable_db_storage and session_id and camera_id:
                    model_name = f"PoseTCN-T{self.temperature:.2f}"
                    self.storage = DetectionStorage(
                        session_id=session_id,
                        camera_id=camera_id,
                        room_id=room_id,
                        model_name=model_name
                    )
                    LOGGER.info("📊 Database storage enabled for predictions")
                elif enable_db_storage:
                    LOGGER.warning("⚠️  Database storage requested but missing session/camera IDs")
                    
            except Exception as e:
                LOGGER.error(f"❌ Failed to load PoseTCN classifier: {e}")
                LOGGER.info("⚠️  Continuing without movement classification")
    
    def _load_checkpoint(self, path: str):
        """Load checkpoint using existing training code patterns."""
        ckpt = torch.load(path, map_location="cpu")
        
        # Extract metadata
        self.classes = ckpt.get("classes", [
            "normal", "decorticate", "dystonia", "chorea", "myoclonus",
            "decerebrate", "fencer posture", "ballistic", "tremor", "versive head"
        ])
        self.temperature = float(ckpt.get("best_temperature", 1.0) or 1.0)
        if not np.isfinite(self.temperature) or self.temperature <= 0:
            self.temperature = 1.0
        
        cfg = ckpt.get("args", {}) or {}
        state = ckpt["model_state_dict"]
        
        # Build model using existing architecture
        width = int(cfg.get("width", 384))
        drop = float(cfg.get("dropout", 0.1))
        dilations = self._parse_dilations(cfg) or [1, 2, 4, 8, 16, 32]
        t_heads = int(cfg.get("t_heads", 4))
        attn_dropout = float(cfg.get("attn_dropout", 0.0))
        
        self.model = PoseTCNSingleView(
            num_classes=len(self.classes),
            width=width,
            drop=drop,
            stochastic_depth=0.0,  # No stochastic depth at inference
            dilations=dilations,
            in_features=NUM_POSE_LANDMARKS * 3,
            t_heads=t_heads,
            attn_dropout=attn_dropout
        )
        
        self.model.load_state_dict(state, strict=True)
        
        # Setup device
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device).eval()
        
        # GPU optimizations
        if self.device.type == "cuda":
            torch.backends.cuda.matmul.allow_tf32 = True
            torch.backends.cudnn.allow_tf32 = True
        
        LOGGER.info(f"Loaded checkpoint: {path}")
        LOGGER.info(f"Classes: {self.classes}")
        LOGGER.info(f"Temperature: {self.temperature:.4f}")
        LOGGER.info(f"Device: {self.device}")
    
    @staticmethod
    def _parse_dilations(cfg: dict) -> Optional[List[int]]:
        """Parse dilations from config."""
        if not isinstance(cfg, dict) or "dilations" not in cfg:
            return None
        try:
            v = cfg["dilations"]
            if isinstance(v, str):
                out = [int(x.strip()) for x in v.split(",") if x.strip()]
                return out or None
            if isinstance(v, (list, tuple)):
                return [int(x) for x in v]
        except Exception:
            return None
        return None
    
    def process_frame(self, frame: VideoFrame) -> Optional[Tuple[List[dict], Optional[dict]]]:
        """
        Process a video frame and extract pose landmarks.
        Also runs PoseTCN classifier if enabled.
        
        Returns:
            Tuple of (landmarks, prediction) where:
            - landmarks: List of landmark dicts or None if no pose detected
            - prediction: Dict with classification results or None
        """
        self.frame_count += 1
        
        # Only process every Nth frame to reduce CPU load
        if self.frame_count % self.process_every_n_frames != 0:
            return self.last_landmarks, self.last_prediction
        
        try:
            # Convert frame to numpy array in RGB format directly
            # This avoids the BGR->RGB conversion issue
            img_rgb = frame.to_ndarray(format="rgb24")
            
            # Verify image is valid
            if img_rgb is None or img_rgb.size == 0:
                LOGGER.warning("⚠️ Invalid frame received (empty or None)")
                return self.last_landmarks, self.last_prediction
            
            # Run MediaPipe (expects RGB)
            results = self.pose.process(img_rgb)
            
            # Extract landmarks if detected
            if results.pose_landmarks:
                landmarks = []
                for lm in results.pose_landmarks.landmark:
                    landmarks.append({
                        "x": float(lm.x),
                        "y": float(lm.y),
                        "z": float(lm.z),
                        "visibility": float(lm.visibility)
                    })
                self.last_landmarks = landmarks
                
                # Feed landmarks to classifier buffer
                if self.model is not None:
                    # Convert to (33, 3) array
                    frame_landmarks = np.array([
                        [lm["x"], lm["y"], lm["z"]] 
                        for lm in landmarks
                    ], dtype=np.float32)
                    self.buffer.append(frame_landmarks)
                    
                    # Run inference periodically when buffer is full
                    if len(self.buffer) >= self.window_size and self.frame_count % self.infer_every_n_frames == 0:
                        infer_start = time.time()
                        prediction = self._predict()
                        infer_time_ms = int((time.time() - infer_start) * 1000)
                        
                        if prediction:
                            self.last_prediction = prediction
                            pred_class = prediction['predicted_class']
                            confidence = prediction['confidence']
                            
                            LOGGER.info(
                                f"🤖 [PREDICTION] {pred_class} "
                                f"({confidence:.2%} confidence)"
                            )
                            
                            # Track statistics
                            self.detection_counts[pred_class] += 1
                            self.all_confidences.append(confidence)
                            
                            # Store to database if enabled and throttle allows
                            if self.storage and self.storage.should_store():
                                # Build full probability dict from top3
                                all_probs = {item['class']: item['confidence'] 
                                           for item in prediction.get('top3', [])}
                                
                                self.storage.store_detection(
                                    predicted_class=pred_class,
                                    confidence=confidence,
                                    all_probs=all_probs,
                                    temperature=self.temperature,
                                    frame_count=self.window_size,
                                    processing_time_ms=infer_time_ms,
                                    pose_landmarks=landmarks  # Include landmarks for playback skeleton overlay
                                )
                                LOGGER.info(f"💾 Stored detection #{self.storage.sequence_number} to database")
                
                return landmarks, self.last_prediction
            else:
                self.last_landmarks = None
                return None, self.last_prediction
                
        except Exception as e:
            LOGGER.error("❌ Error processing frame for pose detection: %s", e)
            # Return last known good landmarks to avoid breaking the stream
            return self.last_landmarks, self.last_prediction
    
    def _predict(self) -> Optional[dict]:
        """Run inference on buffered frames using existing training code patterns."""
        try:
            # Get buffered sequence
            seq = np.stack(list(self.buffer), axis=0)  # (T, 33, 3)
            
            # Normalize using existing function
            seq = normalize_single_view(seq)
            
            # Reshape to (T, 99) - flatten landmarks
            x_np = seq.reshape(self.window_size, -1)
            
            # Convert to tensor
            x = torch.from_numpy(x_np).unsqueeze(0).to(self.device)  # (1, T, 99)
            
            # Inference
            with torch.no_grad():
                logits = self.model(x)
                
                # Temperature scaling
                logits = logits.float()
                scaled = logits / float(self.temperature)
                
                # Get prediction
                probs = torch.softmax(scaled, dim=1)
                pred_idx = int(scaled.argmax(1).item())
                confidence = float(probs[0, pred_idx].item())
                
                # Get top 3 predictions
                top3_probs, top3_preds = torch.topk(probs[0], k=min(3, len(self.classes)))
                top3 = [
                    {
                        "class": self.classes[int(top3_preds[i])],
                        "confidence": float(top3_probs[i])
                    }
                    for i in range(len(top3_preds))
                ]
                
                return {
                    "predicted_class": self.classes[pred_idx],
                    "confidence": confidence,
                    "top3": top3,
                    "buffer_size": len(self.buffer)
                }
        except Exception as e:
            LOGGER.error(f"❌ Error during prediction: {e}")
            return None
    
    def close(self):
        """Clean up MediaPipe resources and store session summary"""
        # Store session summary if database storage enabled
        if self.storage and self.storage.enabled and len(self.detection_counts) > 0:
            duration = time.time() - self.stream_start_time
            avg_confidence = sum(self.all_confidences) / len(self.all_confidences) if self.all_confidences else 0.0
            
            self.storage.store_batch_summary(
                detection_counts=dict(self.detection_counts),
                avg_confidence=avg_confidence,
                total_frames=self.frame_count,
                duration_seconds=duration
            )
            
            # Print summary to console
            LOGGER.info("\n=== 📊 Detection Session Summary ===")
            LOGGER.info(f"Duration: {duration:.1f}s")
            LOGGER.info(f"Total frames processed: {self.frame_count}")
            LOGGER.info(f"Detections stored: {self.storage.sequence_number}")
            LOGGER.info("\nDetection distribution:")
            total_detections = sum(self.detection_counts.values())
            for cls, count in self.detection_counts.most_common():
                percentage = (count / total_detections) * 100
                LOGGER.info(f"  {cls}: {count} ({percentage:.1f}%)")
            LOGGER.info(f"\nAverage confidence: {avg_confidence:.2%}")
            LOGGER.info("✅ Session summary stored to database\n")
        
        if self.pose:
            self.pose.close()


async def publish(
    ambulance_number: str,
    room_number: str,
    base_url: str,
    video_device: Optional[str],
    audio_device: Optional[str],
    device_name: Optional[str] = None,
) -> None:
    print(f"aiortc version: {aiortc.__version__}")

    # Generate ambulance and room names
    ambulance_name = f"AMB-{ambulance_number}"  # e.g., AMB-001
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"  # e.g., AMB-001-ROOM-001

    print(f"🚑 Ambulance: {ambulance_name}")
    print(f"🏠 Room: {room_name}")

    # Step 1: Get ambulance from database by ambulance number
    LOGGER.info("🔍 Looking up ambulance %s in database...", ambulance_name)
    ambulance_data = await get_ambulance_by_number(base_url, ambulance_name)

    if not ambulance_data:
        LOGGER.error(
            "❌ Ambulance %s not found in database. Please check ambulance number.",
            ambulance_name,
        )
        return

    ambulance_id = ambulance_data.get("id")
    LOGGER.info("✅ Using Ambulance ID: %s for %s", ambulance_id, ambulance_name)

    # Step 2: Select video device
    if video_device:
        # Use specified device
        media_src = get_media_src(video_device, audio_device)
        print(f"📹 Using specified device: {video_device}")
    else:
        # Auto-detect and let user choose
        selected_device = select_video_device()
        if not selected_device:
            LOGGER.error("❌ No device selected. Exiting...")
            return

        # selected_device is already in the correct format for the platform
        media_src = selected_device

    player = get_media_player(media_src)

    # Initialize pose processor placeholder - will be configured with session context later
    pose_processor = None

    # Create peer connection with STUN servers for better connectivity
    from aiortc import RTCConfiguration, RTCIceServer

    config = RTCConfiguration(
        iceServers=[
            RTCIceServer(urls=["stun:stun.l.google.com:19302"]),
            RTCIceServer(urls=["stun:stun1.l.google.com:19302"]),
        ]
    )
    pc = RTCPeerConnection(configuration=config)

    # Create data channel for pose landmarks
    data_channel = pc.createDataChannel("pose_landmarks")
    LOGGER.info("📡 Created data channel: pose_landmarks (readyState: %s)", data_channel.readyState)
    
    @data_channel.on("open")
    def on_datachannel_open():
        LOGGER.info("📡 Data channel opened for pose landmarks (readyState: %s)", data_channel.readyState)
    
    @data_channel.on("close")
    def on_datachannel_close():
        # Log data channel closure with session statistics
        if pose_processor and pose_processor.storage:
            total_detections = sum(pose_processor.detection_counts.values()) if pose_processor.detection_counts else 0
            duration = time.time() - pose_processor.stream_start_time
            LOGGER.info(
                "📡 Data channel closed - ✅ Recording complete: %d detections saved to database "
                "(session_id: %s, camera_id: %s, duration: %.1fs)",
                total_detections,
                pose_processor.storage.session_id,
                pose_processor.storage.camera_id,
                duration
            )
        else:
            LOGGER.info("📡 Data channel closed")
    
    @data_channel.on("error")
    def on_datachannel_error(error):
        LOGGER.error("❌ Data channel error: %s", error)

    # Create video track transformer to process frames
    from aiortc.mediastreams import MediaStreamTrack
    
    class VideoTransformTrack(MediaStreamTrack):
        """
        A video stream track that transforms frames with MediaPipe.
        """
        kind = "video"
        
        def __init__(self, track, processor, data_channel):
            super().__init__()
            self.track = track
            self.processor = processor
            self.data_channel = data_channel
        
        async def recv(self):
            frame = await self.track.recv()
            
            # Process frame with MediaPipe and PoseTCN
            landmarks, prediction = self.processor.process_frame(frame)
            
            # Debug: Log landmark detection status
            if not hasattr(self, '_logged_detection'):
                if landmarks:
                    LOGGER.info("✅ MediaPipe detected pose! (%d landmarks)", len(landmarks))
                else:
                    LOGGER.warning("⚠️ No pose detected in frame (frame %d)", self.processor.frame_count)
                if self.processor.frame_count > 20:  # Only log once after some frames
                    self._logged_detection = True
            
            # Send landmarks and predictions via data channel if available
            if landmarks:
                if self.data_channel.readyState == "open":
                    try:
                        message = json.dumps({
                            "type": "pose_landmarks",
                            "landmarks": landmarks,
                            "prediction": prediction,  # Include PoseTCN prediction
                            "timestamp": time.time()
                        })
                        self.data_channel.send(message)
                        # Debug: Log first successful send
                        if not hasattr(self, '_logged_first_send'):
                            LOGGER.info("📡 Successfully sent pose landmarks (%d joints) via data channel", len(landmarks))
                            if prediction:
                                LOGGER.info("📡 Including movement prediction: %s (%.2f%%)", 
                                          prediction['predicted_class'], 
                                          prediction['confidence'] * 100)
                            self._logged_first_send = True
                    except Exception as e:
                        if not hasattr(self, '_logged_send_error'):
                            LOGGER.error("❌ Error sending landmarks: %s", e)
                            self._logged_send_error = True
                else:
                    if not hasattr(self, '_logged_channel_not_open'):
                        LOGGER.warning("⚠️ Data channel not open (readyState: %s), cannot send landmarks", self.data_channel.readyState)
                        self._logged_channel_not_open = True
            
            # Return original frame (no visual modification)
            return frame

    # Note: Video track setup will happen AFTER session/camera IDs are obtained
    # This allows pose_processor to be properly initialized with database context

    async with aiohttp.ClientSession() as session:
        # Step 1: Create/connect to ambulance session - try ambulance streaming first, fallback to regular streaming
        session_id = None

        # Try ambulance streaming endpoints first
        try:
            ambulance_payload = {
                "ambulance_id": ambulance_id,
                "session_name": f"Broadcaster Session - {ambulance_name}",
                "session_type": "emergency",
                "priority_level": 3,
            }
            create_ambulance_url = f"{base_url}/ambulance-streaming/ambulance-sessions"

            LOGGER.info(f"Trying ambulance streaming for: {ambulance_name}")
            async with session.post(
                create_ambulance_url, json=ambulance_payload
            ) as resp:
                if resp.status == 200:
                    ambulance_session = await resp.json()
                    LOGGER.info(f"✅ Ambulance session created: {ambulance_session}")
                    session_id = ambulance_session.get("id")
                    LOGGER.info(f"🔑 Extracted session_id: {session_id}")
                    if not session_id:
                        LOGGER.error(
                            f"❌ Session ID is empty! Full response: {ambulance_session}"
                        )
                        raise Exception("Session created but no ID returned")
                elif resp.status == 409:
                    # Ambulance session already exists, get existing session
                    LOGGER.info(f"🔄 Ambulance session exists, reconnecting")
                    get_session_url = (
                        f"{base_url}/ambulance-streaming/ambulance-sessions"
                    )
                    async with session.get(
                        get_session_url,
                        params={
                            "ambulance_id": ambulance_id,
                            "is_active": True,
                            "limit": 1,
                        },
                    ) as get_resp:
                        if get_resp.status == 200:
                            sessions = await get_resp.json()
                            if sessions:
                                ambulance_session = sessions[0]
                                LOGGER.info(
                                    f"✅ Retrieved existing session: {ambulance_session}"
                                )
                                session_id = ambulance_session.get("id")
                            else:
                                raise Exception("No active sessions found")
                else:
                    raise Exception(f"Ambulance endpoint failed: {resp.status}")

        except Exception as e:
            LOGGER.warning(f"Ambulance streaming not available: {e}")
            LOGGER.info("🔄 Falling back to regular streaming endpoints")

            # Fallback to regular streaming session creation
            regular_payload = {
                "patient_id": ambulance_id,  # Use ambulance ID as patient_id
                "device_name": device_name or "Ambulance Broadcaster",
                "session_name": f"Ambulance Session - {ambulance_name}",
            }
            create_session_url = f"{base_url}/streaming/sessions"

            async with session.post(create_session_url, json=regular_payload) as resp:
                if resp.status == 200:
                    session_json = await resp.json()
                    LOGGER.info(f"✅ Regular session created: {session_json}")
                    session_id = session_json.get("id")
                else:
                    error_text = await resp.text()
                    LOGGER.error(
                        f"Failed to create session ({resp.status}): {error_text}"
                    )
                    safe_close_player(player)
                    await pc.close()
                    return

        # Verify session_id was obtained
        LOGGER.info(f"📋 Session ID obtained: {session_id}")

        # Step 2: Create room and connect to streaming
        if session_id is None:
            LOGGER.error(
                "❌ No session ID available - session creation must have failed"
            )
            safe_close_player(player)
            await pc.close()
            return

        LOGGER.info(f"✅ Proceeding with session ID: {session_id}")

        # Try ambulance camera endpoints first, fallback to regular streaming room
        camera_id = None
        streaming_url = None

        try:
            # Step 2a: Get existing cameras for this ambulance
            LOGGER.info(f"Fetching existing cameras for ambulance {ambulance_id}")
            get_cameras_url = f"{base_url}/ambulances/{ambulance_id}/cameras"
            async with session.get(get_cameras_url) as get_cameras_resp:
                if get_cameras_resp.status == 200:
                    cameras_result = await get_cameras_resp.json()
                    cameras = cameras_result.get("data", [])
                    LOGGER.info(f"Found {len(cameras)} existing cameras")

                    if cameras:
                        # Select camera based on room number (cycle through available cameras)
                        camera_index = (int(room_number) - 1) % len(cameras)
                        selected_camera = cameras[camera_index]
                        camera_id = selected_camera.get("id")
                        camera_name = selected_camera.get("camera_name", "Unknown")
                        LOGGER.info(
                            f"✅ Selected camera {camera_index + 1}: {camera_name} (ID: {camera_id})"
                        )
                    else:
                        # No cameras found - create a new one
                        LOGGER.info(
                            f"📷 No cameras found, creating new camera for ambulance {ambulance_id}"
                        )

                        create_camera_payload = {
                            "camera_id": f"AMB-{ambulance_number}-CAM-{room_number.zfill(2)}",
                            "camera_name": f"Broadcaster Camera {room_number}",
                            "camera_type": "medical",
                            "position_in_ambulance": f"position-{room_number}",
                            "device_model": "Raspberry Pi Camera v3",
                            "resolution": "1920x1080",
                            "max_fps": 30,
                            "has_night_vision": False,
                            "has_audio": True,
                            "streaming_port": 8000,
                            "status": "active",
                            "ai_enabled": True,
                            "detection_types": '["pose","movement","activity"]',
                            "processing_mode": "edge",
                            "notes": f"Auto-created by broadcaster for room {room_number}",
                        }

                        create_camera_url = (
                            f"{base_url}/ambulances/{ambulance_id}/cameras"
                        )

                        async with session.post(
                            create_camera_url, json=create_camera_payload
                        ) as create_resp:
                            if create_resp.status in [200, 201]:
                                new_camera = await create_resp.json()
                                # Handle both direct response and wrapped response
                                camera_data = new_camera.get("data", new_camera)
                                camera_id = camera_data.get("id")
                                camera_name = camera_data.get("camera_name", "Unknown")
                                LOGGER.info(
                                    f"✅ Created new camera: {camera_name} (ID: {camera_id})"
                                )
                            else:
                                error_text = await create_resp.text()
                                LOGGER.error(
                                    f"Failed to create camera ({create_resp.status}): {error_text}"
                                )
                                raise Exception(
                                    f"Failed to create camera: {create_resp.status} - {error_text}"
                                )
                else:
                    error_text = await get_cameras_resp.text()
                    LOGGER.error(
                        f"Failed to fetch cameras ({get_cameras_resp.status}): {error_text}"
                    )
                    raise Exception(
                        f"Failed to fetch cameras: {get_cameras_resp.status}"
                    )

            if not camera_id:
                raise Exception("Could not select a camera")

            # Initialize MediaPipe pose processor NOW that we have session/camera IDs
            pose_processor = MediaPipePoseProcessor(
                process_every_n_frames=2,
                enable_classifier=True,
                session_id=session_id,
                camera_id=camera_id,
                room_id=room_name,  # Use room_name as room_id
                enable_db_storage=True
            )
            LOGGER.info("🦴 MediaPipe skeleton overlay enabled")
            if pose_processor.storage and pose_processor.storage.enabled:
                LOGGER.info("💾 Database storage ENABLED for AI detections")
            else:
                LOGGER.info("⚠️  Database storage DISABLED")

            # Now that pose_processor is initialized, set up video track
            if player.video:
                # Wrap video track with transformer
                video_track = VideoTransformTrack(player.video, pose_processor, data_channel)
                pc.addTrack(video_track)
                if player.audio:
                    pc.addTrack(player.audio)
            else:
                LOGGER.error("No video track found on device %s", media_src)
                safe_close_player(player)
                if pose_processor:
                    pose_processor.close()
                await pc.close()
                return

            # Create WebRTC offer
            await pc.setLocalDescription(await pc.createOffer())

            while pc.iceGatheringState != "complete":
                await asyncio.sleep(0.1)

            offer_payload = {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}
            
            # Debug: Log SDP offer to verify data channel is included
            LOGGER.info("📝 [SDP] Generated offer SDP (first 500 chars):\n%s", pc.localDescription.sdp[:500])
            if "m=application" in pc.localDescription.sdp:
                LOGGER.info("✅ [SDP] Data channel IS included in offer (found m=application)")
            else:
                LOGGER.warning("⚠️ [SDP] Data channel NOT found in offer SDP!")

            # Step 2b: Check if camera room already exists, create if not
            camera_room_payload = {
                "camera_id": camera_id,
                "room_name": room_name,
                "device_name": device_name or "Ambulance Broadcaster",
            }
            create_camera_room_url = f"{base_url}/ambulance-streaming/camera-rooms"

            # First, try to get existing camera rooms for this session
            existing_room_id = None
            get_rooms_url = f"{base_url}/ambulance-streaming/camera-rooms"
            LOGGER.info(f"🔍 Checking for existing camera room: {room_name}")

            async with session.get(
                get_rooms_url, params={"session_id": session_id, "limit": 100}
            ) as get_resp:
                if get_resp.status == 200:
                    existing_rooms = await get_resp.json()
                    for room in existing_rooms:
                        if (
                            room.get("room_name") == room_name
                            and room.get("camera_id") == camera_id
                        ):
                            existing_room_id = room.get("id")
                            LOGGER.info(
                                f"✅ Found existing camera room (UUID: {existing_room_id})"
                            )
                            LOGGER.info(f"🔄 Rejoining existing room: {room_name}")
                            break

            if existing_room_id:
                # Room exists - rejoin it
                LOGGER.info(f"♻️  Rejoining existing camera room for camera {room_name}")
                streaming_url = (
                    f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                )
            else:
                # Room doesn't exist - create new one
                LOGGER.info(
                    f"🆕 Creating new camera room for camera ID {camera_id}: {room_name}"
                )
                async with session.post(
                    create_camera_room_url,
                    json=camera_room_payload,
                    params={"session_id": session_id},
                ) as resp:
                    if resp.status == 200:
                        camera_room = await resp.json()
                        LOGGER.info(f"✅ Ambulance camera room created: {camera_room}")
                        streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                    elif resp.status == 409:
                        # Camera room already exists (race condition)
                        LOGGER.info(
                            f"🔄 Camera room already exists (409), rejoining camera ID: {camera_id}"
                        )
                        streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                    else:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"Camera room creation failed ({resp.status}): {error_text}"
                        )

                        # Check if it's a duplicate room_name error
                        if (
                            "already exists" in error_text.lower()
                            or "duplicate" in error_text.lower()
                        ):
                            LOGGER.info(
                                f"🔄 Room {room_name} already exists (duplicate key), rejoining"
                            )
                            streaming_url = f"{base_url}/ambulance-streaming/camera/{room_name}/streamer"
                        else:
                            raise Exception(
                                f"Camera endpoint failed: {resp.status} - {error_text}"
                            )

        except Exception as e:
            LOGGER.warning(f"Ambulance camera not available: {e}")
            LOGGER.info("🔄 Using regular streaming room")

            # Fallback to regular streaming room
            room_payload = {
                "session_id": session_id,
                "room_name": room_name,
                "device_name": device_name or "Ambulance Device",
            }
            create_room_url = f"{base_url}/streaming/rooms"

            async with session.post(create_room_url, json=room_payload) as resp:
                if resp.status == 200:
                    room_json = await resp.json()
                    room_name_created = (
                        room_json.get("room_name") or room_payload["room_name"]
                    )
                    LOGGER.info(f"✅ Regular room created: {room_name_created}")
                    streaming_url = (
                        f"{base_url}/streaming/room/{room_name_created}/streamer"
                    )
                else:
                    error_text = await resp.text()
                    LOGGER.error(f"Failed to create room ({resp.status}): {error_text}")
                    safe_close_player(player)
                    await pc.close()
                    return

        # Step 3: Connect to streaming endpoint
        if not streaming_url:
            LOGGER.error("No streaming URL available")
            safe_close_player(player)
            await pc.close()
            return

        LOGGER.info(f"📡 Connecting to streaming endpoint: {streaming_url}")
        answer_json = None
        max_retries = 3
        retry_count = 0

        while retry_count < max_retries:
            try:
                async with session.post(streaming_url, json=offer_payload) as resp:
                    if resp.status == 404:
                        LOGGER.error("❌ Streaming endpoint not found")
                        safe_close_player(player)
                        await pc.close()
                        return
                    elif resp.status == 409:
                        retry_count += 1
                        LOGGER.warning(
                            f"⚠️  Streamer already connected (attempt {retry_count}/{max_retries})"
                        )

                        if retry_count < max_retries:
                            LOGGER.info("🔄 Waiting 2 seconds before retry...")
                            await asyncio.sleep(2)
                            continue
                        else:
                            LOGGER.error(
                                "❌ Max retries reached. Room may have active streamer."
                            )
                            LOGGER.info(
                                "💡 Try stopping other broadcasters or wait for timeout"
                            )
                            safe_close_player(player)
                            await pc.close()
                            return
                    elif resp.status != 200:
                        error_text = await resp.text()
                        LOGGER.error(
                            f"❌ Streaming failed ({resp.status}): {error_text}"
                        )
                        safe_close_player(player)
                        await pc.close()
                        return
                    else:
                        answer_json = await resp.json()
                        LOGGER.info("✅ Successfully connected to streaming endpoint")
                        break

            except Exception as e:
                retry_count += 1
                LOGGER.error(
                    f"❌ Connection error (attempt {retry_count}/{max_retries}): {e}"
                )
                if retry_count < max_retries:
                    await asyncio.sleep(2)
                else:
                    safe_close_player(player)
                    await pc.close()
                    return

        if not answer_json:
            LOGGER.error("❌ Failed to get answer from streaming endpoint")
            safe_close_player(player)
            await pc.close()
            return

    # Filter answer to only include SDP fields
    sdp_answer = {"sdp": answer_json.get("sdp"), "type": answer_json.get("type")}
    LOGGER.info(f"📡 Received SDP answer: type={sdp_answer['type']}")
    await pc.setRemoteDescription(RTCSessionDescription(**sdp_answer))
    LOGGER.info("🎥 Ambulance streaming started successfully!")
    LOGGER.info(f"🚑 Ambulance: {ambulance_name}")
    LOGGER.info(f"🏠 Room: {room_name}")
    LOGGER.info(f"📡 Session ID: {session_id}")
    LOGGER.info(f"🆔 Camera ID: {camera_id or 'Regular Room'}")
    LOGGER.info("🔄 Reconnection: Automatic if connection exists")
    LOGGER.info("🛑 Press Ctrl+C to stop streaming...")

    try:
        # Monitor connection state
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
        LOGGER.info("💡 Session remains active - restart broadcaster to reconnect")
        LOGGER.info("💡 Use frontend to explicitly end session when done")
    finally:
        # Note: We do NOT end the session here - that's only done via frontend
        safe_close_player(player)
        if pose_processor:
            pose_processor.close()
        await pc.close()
        LOGGER.info("🧹 Broadcaster cleanup completed")
        LOGGER.info("📋 Session Status: ACTIVE (can reconnect)")


async def end_session_manually(base_url: str, session_id: str) -> None:
    """Helper function to manually end a session (for testing purposes)."""
    try:
        end_session_url = f"{base_url}/streaming/sessions/{session_id}/end"
        async with aiohttp.ClientSession() as session:
            async with session.post(end_session_url) as resp:
                if resp.status == 200:
                    LOGGER.info("✅ Session %s ended successfully", session_id)
                else:
                    LOGGER.warning("❌ Failed to end session: %s", resp.status)
    except Exception as e:
        LOGGER.error("❌ Error ending session: %s", e)


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
        default="http://localhost:8000",
        help="Base URL of signalling server (default: http://localhost:8000)",
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

    # Handle end session command
    if args.end_session:
        print(f"🛑 Ending session: {args.end_session}")
        asyncio.run(end_session_manually(args.signaling, args.end_session))
        return

    # Get ambulance and room numbers from command line or user input
    if args.ambulance_number and args.room:
        # Use command-line parameters
        ambulance_number = args.ambulance_number.zfill(3)
        room_number = args.room.zfill(3)
    else:
        # Get from user input
        ambulance_number, room_number = get_user_input()

    ambulance_name = f"AMB-{ambulance_number}"
    room_name = f"AMB-{ambulance_number}-ROOM-{room_number}"

    print(f"\n🎥 Starting Ambulance WebRTC Broadcaster")
    print(f"{'='*60}")
    print(f"🚑 Ambulance: {ambulance_name}")
    print(f"🏠 Room: {room_name}")
    print(f"🌐 Server: {args.signaling}")
    print(
        f"📹 Video Device: {args.video_device or 'Auto-detect (interactive selection)'}"
    )
    print(f"🎤 Audio Device: {args.audio_device or 'Disabled'}")
    print(f"🏷️  Device Name: {args.device_name}")
    print(f"\n🔧 Connection Strategy:")
    print(f"   1️⃣  Check if ambulance exists in database")
    print(f"   2️⃣  Auto-detect video devices (if not specified)")
    print(f"   3️⃣  Create/reconnect to ambulance session")
    print(f"   4️⃣  Get existing camera or select from available")
    print(f"   5️⃣  Check if camera room exists, create/rejoin")
    print(f"   6️⃣  Connect to streaming endpoint (3 retry attempts)")
    print(f"\n🔄 Auto-reconnect: Room will be reused if it exists")
    print(f"⏱️  Stream Timeout: 30 seconds of inactivity")
    print(f"{'='*60}\n")

    try:
        asyncio.run(
            publish(
                ambulance_number,
                room_number,
                args.signaling.rstrip("/"),
                video_device=args.video_device,
                audio_device=args.audio_device,
                device_name=args.device_name,
            )
        )
    except KeyboardInterrupt:
        print("\n🛑 Broadcaster stopped by user")
    except Exception as exc:
        LOGGER.exception("Fatal error: %s", exc)


if __name__ == "__main__":
    main()
