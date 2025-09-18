"""
Complete PIM (Patient Involuntary Movement) Detection System
Integrated with multi-view video processing capabilities.
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
from mediapipe_processor import MultiViewPIMProcessor, PIMDetectorLSTM, JointBoneEnsembleLSTM, prepare_sequences, PIM_MOVEMENTS

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def process_multi_view_video_file(video_path, movement_name, output_dir="pose_data", num_views=3):
    """Process a multi-view video file to extract pose landmarks and save to CSV."""
    processor = MultiViewPIMProcessor(
        pose_detection=True,
        hand_detection=False,
        face_detection=False,
        num_views=num_views
    )
    
    return processor.process_multi_view_video_for_pim(video_path, movement_name, output_dir)

def process_video_file(video_path, movement_name, output_dir="pose_data"):
    """Process a single-view video file to extract pose landmarks and save to CSV."""
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(static_image_mode=False, model_complexity=1, min_detection_confidence=0.5)
    
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: Could not open video file: {video_path}")
        return False

    os.makedirs(output_dir, exist_ok=True)
    video_id = os.path.basename(video_path).replace('.mkv', '').replace('.mp4', '').replace(' ', '_')
    timestamp = int(time.time())
    output_file = os.path.join(output_dir, f"{movement_name}_{video_id}_{timestamp}_data.csv")

    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, ['timestamp', 'landmark_id', 'x', 'y', 'z'])
        writer.writeheader()
        
        frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = cap.get(cv2.CAP_PROP_FPS)
        print(f"Processing video: {video_path} ({frame_count} frames @ {fps} FPS)")
        
        for frame_idx in tqdm(range(frame_count), desc=f"Processing {movement_name}"):
            ret, frame = cap.read()
            if not ret:
                break

            # Calculate timestamp from frame index and fps
            timestamp = frame_idx / fps
            
            # Process frame with MediaPipe
            results = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if results.pose_landmarks:
                # Round to 3 decimals to match sequence prep
                ts = round(timestamp, 3)
                for landmark_id, landmark in enumerate(results.pose_landmarks.landmark):
                    writer.writerow({
                        'timestamp': ts, 
                        'landmark_id': landmark_id,
                        'x': landmark.x, 
                        'y': landmark.y, 
                        'z': landmark.z
                    })

    cap.release()
    print(f"Processing complete. Data saved to {output_file}")
    return True

def process_video_directory(input_dir, movement_name, output_dir="pose_data", multi_view=False):
    """Process all video files in a directory for a specific movement."""
    video_extensions = ["*.mkv", "*.mp4", "*.avi", "*.mov"]
    video_files = []
    for ext in video_extensions:
        video_files.extend(glob.glob(os.path.join(input_dir, ext)))
    
    if not video_files:
        print(f"No video files found in directory: {input_dir}")
        return False
    
    print(f"Found {len(video_files)} video files for movement: {movement_name}")
    success_count = 0
    
    for video_file in video_files:
        if multi_view:
            if process_multi_view_video_file(video_file, movement_name, output_dir):
                success_count += 1
        else:
            if process_video_file(video_file, movement_name, output_dir):
                success_count += 1
    
    print(f"Successfully processed {success_count}/{len(video_files)} videos for {movement_name}")
    return success_count > 0

def train_model(data_dir="pose_data", movements=None, epochs=50, model_type="normal"):
    """Train PIM detection model on processed landmark data."""
    # Infer movement names from files if not provided
    if not movements:
        movements = set()
        for filename in os.listdir(data_dir):
            if filename.endswith('_data.csv'):
                parts = filename.split('_')
                if parts[-1] == "data.csv":
                    if len(parts) == 2: 
                        movements.add(parts[0])
                    else: 
                        movements.add('_'.join(parts[:-3]))
        movements = list(movements)

    print(f"Training model on movements: {movements}\nModel type: {model_type}")

    # Process data
    X, y = [], []
    for idx, movement in enumerate(movements):
        movement_files = [f for f in os.listdir(data_dir) if f.startswith(f"{movement}_") and f.endswith('_data.csv')]
        if not movement_files:
            print(f"Warning: No files found for movement: {movement}")
            continue

        print(f"Found {len(movement_files)} files for movement: {movement}")
        for file in movement_files:
            sequences = prepare_sequences(os.path.join(data_dir, file))
            if len(sequences) > 0:
                X.append(sequences)
                y.extend([idx] * len(sequences))
                print(f"  - {file}: {len(sequences)} sequences")
            else:
                print(f"  - {file}: No valid sequences extracted")

    if not X:
        print("Error: No valid training data found")
        return None

    X = np.vstack(X).astype(np.float32)
    y = np.asarray(y, dtype=np.int64)
    print(f"Total sequences: {len(X)}, Shape: {X.shape}")

    # Convert to tensors
    X = torch.from_numpy(X).float()
    y = torch.from_numpy(y).long()

    # Device
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Using device: {device}")

    # Stratified split on indices to keep dtype controlled
    idx = np.arange(len(X))
    try:
        train_idx, test_idx = train_test_split(
            idx, test_size=0.2, random_state=42, stratify=y.numpy()
        )
    except Exception:
        # Fallback if classes are too small for stratify
        train_idx, test_idx = train_test_split(idx, test_size=0.2, random_state=42)

    X_train, X_test = X[train_idx], X[test_idx]
    y_train, y_test = y[train_idx], y[test_idx]

    # Initialize model
    model = JointBoneEnsembleLSTM(input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements)) \
            if model_type == "joint_bone" else \
            PIMDetectorLSTM(input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements))
    model.to(device)

    # Handle tiny datasets gracefully
    if len(X_train) == 0 or len(X_test) == 0:
        print("Error: Not enough data to split train/test. Record more samples.")
        return None

    batch_size = max(1, min(16, len(X_train)))
    print(f"Model has {sum(p.numel() for p in model.parameters()):,} parameters")

    # Train
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    start_time = time.time()

    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        total_seen = 0

        for i in range(0, len(X_train), batch_size):
            xb = X_train[i:i+batch_size].to(device, non_blocking=True)
            yb = y_train[i:i+batch_size].to(device, non_blocking=True)

            optimizer.zero_grad()
            logits, _ = model(xb)
            loss = criterion(logits, yb)
            loss.backward()
            optimizer.step()

            bs = xb.size(0)
            running_loss += loss.item() * bs
            total_seen += bs

        epoch_loss = running_loss / max(1, total_seen)
        print(f'Epoch {epoch+1}/{epochs}, Loss: {epoch_loss:.4f}, Time: {time.time()-start_time:.1f}s')

    # Evaluate
    model.eval()
    with torch.no_grad():
        correct, total = 0, 0
        for i in range(0, len(X_test), batch_size):
            xb = X_test[i:i+batch_size].to(device, non_blocking=True)
            yb = y_test[i:i+batch_size].to(device, non_blocking=True)
            logits, _ = model(xb)
            preds = torch.argmax(logits, dim=1)
            correct += (preds == yb).sum().item()
            total += yb.size(0)
        accuracy = correct / max(1, total)
        print(f'Test Accuracy: {accuracy:.4f}')

    # Save
    os.makedirs('models', exist_ok=True)
    model_path = os.path.join('models', f'pim_model_{model_type}.pth')
    torch.save({'model_state_dict': model.state_dict(), 'movements': movements, 'model_type': model_type}, model_path)
    print(f"Model saved to {model_path}")
    return model, movements

def load_trained_model(model_path):
    """Load a trained PIM detection model."""
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found: {model_path}")
    ckpt = torch.load(model_path, map_location='cpu')
    movements, model_type = ckpt['movements'], ckpt.get('model_type', 'normal')

    model = JointBoneEnsembleLSTM(input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements)) \
            if model_type == 'joint_bone' else \
            PIMDetectorLSTM(input_dim=3, hidden_dim=128, num_layers=3, num_classes=len(movements))

    model.load_state_dict(ckpt['model_state_dict'])
    model.eval()
    return model, movements, model_type

def predict_sequence(model, model_type, sequence_tensor):
    """Return (predicted_class_index, confidence, probability_vector)."""
    with torch.no_grad():
        logits, _ = model(sequence_tensor)
        probs = torch.softmax(logits, dim=1)
        conf, pred = torch.max(probs, dim=1)
    return int(pred.item()), float(conf.item()), probs.squeeze(0).cpu().numpy()

# Color coding for movement severity
COLOR_RULES = {
    'critical': (0, 0, 255), 'concerning': (0, 165, 255),
    'minor': (0, 255, 255), 'normal': (0, 255, 0)
}

def movement_color(name):
    """Get color for movement based on severity."""
    if name in ['seizure', 'myoclonus']: return COLOR_RULES['critical']
    if name in ['tremor', 'dystonia', 'chorea']: return COLOR_RULES['concerning']
    if name == 'tics': return COLOR_RULES['minor']
    return COLOR_RULES['normal']

def detection_loop(model_path, patient_id=None, debug=False):
    """Main real-time detection loop."""
    try:
        model, movements, model_type = load_trained_model(model_path)
    except Exception as e:
        print(f"❌ {e}")
        return False

    # Move to best available device for inference
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)

    pose = mp.solutions.pose.Pose()
    frame_buffer = collections.deque(maxlen=30)
    pred_q, conf_q = collections.deque(maxlen=10), collections.deque(maxlen=10)
    raw_preds = collections.deque(maxlen=50)

    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print('Error: Could not open camera.')
        return False

    prev_time, detection_count = 0, 0
    mode_label = 'DEBUG MODE' if debug else 'DETECTION'
    print(f"🏥 PIM System {mode_label} | Movements: {movements}\nKeys: q=quit d=stats (debug only)")

    while True:
        ret, frame = cap.read()
        if not ret: break

        results = pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        if results.pose_landmarks:
            landmarks = np.array([[lm.x, lm.y, lm.z] for lm in results.pose_landmarks.landmark], dtype=np.float32)
            frame_buffer.append(landmarks)
            mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp.solutions.pose.POSE_CONNECTIONS)

            cv2.putText(frame, f"Buffer: {len(frame_buffer)}/30", (10,150), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255,255,0), 2)

            if len(frame_buffer) == 30:  # Full buffer
                seq = np.array(frame_buffer, dtype=np.float32)
                seq_tensor = torch.from_numpy(seq).unsqueeze(0).to(device, non_blocking=True)
                pred, conf, probs = predict_sequence(model, model_type, seq_tensor)

                pred_q.append(pred); conf_q.append(conf)
                final_pred = max(set(pred_q), key=pred_q.count)
                avg_conf = sum(conf_q)/len(conf_q)
                movement = movements[final_pred]

                # Display the detected movement
                cv2.putText(frame, f"{movement.upper()} {avg_conf:.2f}", (10,70),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.9, movement_color(movement), 2)

                if debug:
                    raw_preds.append({'pred': final_pred, 'conf': avg_conf, 'scores': probs, 'ts': time.time()})
                    top_idx = np.argsort(probs)[-3:][::-1]
                    for i, idx in enumerate(top_idx):
                        cv2.putText(frame, f"{i+1}.{movements[idx]}:{probs[idx]:.2f}",
                                    (10,250+i*22), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255,255,255), 1)
                detection_count += 1

        # HUD
        current = time.time()
        fps = 1/(current-prev_time) if prev_time else 0
        prev_time = current
        cv2.putText(frame, f'FPS:{int(fps)}', (10,30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)
        cv2.putText(frame, f'Patient:{patient_id or "Unknown"}', (10,190), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255,255,255), 2)
        cv2.putText(frame, f'Detections:{detection_count}', (10,215), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255,255,255), 2)

        cv2.imshow(f'PIM {mode_label}', frame)
        k = cv2.waitKey(1) & 0xFF
        if k == ord('q'): break
        elif debug and k == ord('d'):
            print('\n🔍 Stats:')
            counts = collections.Counter([movements[p['pred']] for p in raw_preds])
            for m, c in counts.most_common(): print(f"  {m}: {c}")

    cap.release(); cv2.destroyAllWindows()
    print(f"\n🏥 Session Complete | detections={detection_count}")
    return True

def real_time_pim_detection(model_path='models/pim_model_normal.pth', patient_id=None):
    """Run real-time PIM detection."""
    return detection_loop(model_path, patient_id, debug=False)

def debug_real_time_detection(model_path='models/pim_model_normal.pth', patient_id=None):
    """Run real-time PIM detection with debug information."""
    return detection_loop(model_path, patient_id, debug=True)

def main():
    """Main function with command line interface."""
    parser = argparse.ArgumentParser(description='Multi-View PIM Detection System')
    parser.add_argument('--mode', type=str, default='help',
                        choices=['process_video', 'process_directory', 'train', 'detect', 'debug', 'help'],
                        help='Operation mode')
    parser.add_argument('--movement', type=str, help='Movement name for processing')
    parser.add_argument('--patient_id', type=str, help='Patient ID for detection mode')
    parser.add_argument('--epochs', type=int, default=50, help='Number of training epochs')
    parser.add_argument('--model_type', type=str, default='normal',
                        choices=['normal', 'joint_bone'],
                        help='Model type: normal or joint_bone (ensemble)')
    parser.add_argument('--model_path', type=str, help='Path to model file for detection')
    parser.add_argument('--video_path', type=str, help='Path to video file for processing')
    parser.add_argument('--video_dir', type=str, help='Directory containing video files')
    parser.add_argument('--multi_view', action='store_true', help='Enable multi-view processing (4-view to 3-view)')
    
    args = parser.parse_args()
    
    # Create necessary directories
    for dir_name in ['pose_data', 'models', 'output']: 
        os.makedirs(dir_name, exist_ok=True)

    if args.mode == 'help' or len(os.sys.argv) == 1:
        print("🏥 Multi-View PIM Detection System")
        print("=" * 55)
        print("\nQuick Start Guide:")
        print("1. Process multi-view videos: python pim_detection_system.py --mode process_directory --movement normal --video_dir /videos/normal/ --multi_view")
        print("2. Train PIM model:          python pim_detection_system.py --mode train --model_type joint_bone")
        print("3. Start detection:          python pim_detection_system.py --mode detect --patient_id John_Doe")
        print("\nAvailable modes:")
        print("  • process_video     - Process a single video file")
        print("  • process_directory - Process all videos in a directory")  
        print("  • train             - Train the PIM detection model")
        print("  • debug             - Run detection with detailed debugging info")
        print("  • detect            - Run normal PIM detection")
        print("\nModel types:")
        print("  • normal     - PIMDetectorLSTM (default)")
        print("  • joint_bone - Ensemble of joint + bone features (recommended)")
        print("\nAvailable PIM movements:", list(PIM_MOVEMENTS.keys()))
        print("\nMulti-view processing:")
        print("  Use --multi_view flag to process 4-view videos (crops rightmost view)")
        print("  Without flag: processes standard single-view videos")
        return

    if args.mode == 'process_video':
        if not args.movement or not args.video_path:
            print("Error: Must specify --movement name and --video_path")
            print("Available PIM movements:", list(PIM_MOVEMENTS.keys()))
            return
        
        if args.multi_view:
            process_multi_view_video_file(args.video_path, args.movement)
        else:
            process_video_file(args.video_path, args.movement)
        
    elif args.mode == 'process_directory':
        if not args.movement or not args.video_dir:
            print("Error: Must specify --movement name and --video_dir")
            print("Available PIM movements:", list(PIM_MOVEMENTS.keys()))
            return
        
        process_video_directory(args.video_dir, args.movement, multi_view=args.multi_view)

    elif args.mode == 'train':
        # Check which movements have data
        available_movements = []
        for movement in PIM_MOVEMENTS:
            movement_files = [f for f in os.listdir('pose_data')
                              if f.startswith(f"{movement}_") and f.endswith('_data.csv')]
            if movement_files: 
                available_movements.append(movement)

        if not available_movements:
            print("❌ No PIM movement data files found in pose_data directory")
            print("Please process video files first using:")
            print("  python pim_detection_system.py --mode process_video --movement normal --video_path /path/to/video.mp4 --multi_view")
            return

        print(f"✅ Found data for PIM movements: {available_movements}")
        train_model(movements=available_movements, epochs=args.epochs, model_type=args.model_type)

    elif args.mode in ['detect', 'debug']:
        model_path = args.model_path or os.path.join('models', f'pim_model_{args.model_type}.pth')
        if not os.path.exists(model_path):
            print(f"❌ No trained model found at {model_path}")
            print(f"Please train a {args.model_type} model first using --mode train --model_type {args.model_type}")
            return

        patient_id = args.patient_id or f"Patient_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        print(f"{'🔍' if args.mode=='debug' else '🏥'} Starting {'DEBUG ' if args.mode=='debug' else ''}PIM Detection for Patient: {patient_id}")

        if args.mode == 'debug':
            debug_real_time_detection(model_path, patient_id=patient_id)
        else:
            real_time_pim_detection(model_path, patient_id=patient_id)

if __name__ == "__main__":
    main()