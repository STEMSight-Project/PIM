import cv2
import mediapipe as mp
import numpy as np
import time
import csv
from datetime import datetime
import os

class PostureMovementDetector:
    def __init__(self, camera_index=0, landmark_visibility_threshold=0.5):
        # MediaPipe setup
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        
        # Initialize pose detection with higher min_detection_confidence for stability
        self.pose = self.mp_pose.Pose(
            min_detection_confidence=0.7,
            min_tracking_confidence=0.7,
            model_complexity=2  # Use the most accurate model
        )
        
        # Camera setup
        self.camera_index = camera_index
        self.cap = None
        
        # Tracking variables
        self.landmark_visibility_threshold = landmark_visibility_threshold
        self.frame_count = 0
        self.start_time = None
        self.prev_time = 0
        
        # Key landmarks for posture analysis (indices in MediaPipe Pose)
        self.key_landmarks = {
            "LEFT_SHOULDER": 11,
            "RIGHT_SHOULDER": 12,
            "LEFT_HIP": 23,
            "RIGHT_HIP": 24,
            "LEFT_KNEE": 25,
            "RIGHT_KNEE": 26,
            "LEFT_ANKLE": 27,
            "RIGHT_ANKLE": 28,
            "NOSE": 0,
            "LEFT_EAR": 7,
            "RIGHT_EAR": 8,
            "LEFT_WRIST": 15,
            "RIGHT_WRIST": 16
        }
        
        # Movement tracking
        self.landmark_history = {name: [] for name in self.key_landmarks}
        self.movement_threshold = 0.01  # Threshold for detecting significant movement
        self.max_history_length = 30  # Number of frames to keep for movement analysis
        
        # Data logging
        self.output_dir = "patient_data"
        os.makedirs(self.output_dir, exist_ok=True)
        self.csv_file = None
        self.csv_writer = None
        
    def _setup_logging(self, patient_id):
        """Set up CSV logging for a specific patient"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.output_dir}/patient_{patient_id}_{timestamp}.csv"
        
        self.csv_file = open(filename, 'w', newline='')
        fieldnames = ['timestamp', 'frame', 'landmark_name', 'landmark_id', 
                      'x', 'y', 'z', 'visibility', 
                      'movement_score', 'posture_status']
        self.csv_writer = csv.DictWriter(self.csv_file, fieldnames=fieldnames)
        self.csv_writer.writeheader()
        return filename
        
    def start_camera(self):
        """Initialize the camera"""
        self.cap = cv2.VideoCapture(self.camera_index)
        if not self.cap.isOpened():
            print(f"Error: Could not open camera at index {self.camera_index}")
            print("Trying default camera (index 0)...")
            self.camera_index = 0
            self.cap = cv2.VideoCapture(self.camera_index)
            if not self.cap.isOpened():
                raise ValueError("Error: Could not open any camera")
        
        # Set higher resolution if supported
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        
        print(f"Camera initialized: {int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))}x{int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))}")
        return self.cap
    
    def calculate_movement_score(self, landmark_name, current_position):
        """Calculate a movement score based on landmark history"""
        history = self.landmark_history[landmark_name]
        
        if len(history) < 2:
            return 0.0
        
        # Calculate average movement over recent frames
        movements = []
        for i in range(1, min(10, len(history))):
            dx = history[-i][0] - history[-i-1][0]
            dy = history[-i][1] - history[-i-1][1]
            dz = history[-i][2] - history[-i-1][2]
            distance = np.sqrt(dx*dx + dy*dy + dz*dz)
            movements.append(distance)
        
        avg_movement = np.mean(movements) if movements else 0
        
        # Update history
        self.landmark_history[landmark_name].append(current_position)
        # Maintain fixed history length
        if len(self.landmark_history[landmark_name]) > self.max_history_length:
            self.landmark_history[landmark_name].pop(0)
            
        return avg_movement
    
    def assess_posture(self, landmarks):
        """
        Basic posture assessment based on shoulder and hip alignment
        Returns a dictionary with posture issues
        """
        posture_status = {"overall": "normal"}
        
        # Check if we have the necessary landmarks with good visibility
        required_landmarks = ["LEFT_SHOULDER", "RIGHT_SHOULDER", 
                              "LEFT_HIP", "RIGHT_HIP", "NOSE", 
                              "LEFT_EAR", "RIGHT_EAR"]
        
        landmark_coords = {}
        for name in required_landmarks:
            idx = self.key_landmarks[name]
            if idx < len(landmarks) and landmarks[idx].visibility > self.landmark_visibility_threshold:
                landmark_coords[name] = (landmarks[idx].x, landmarks[idx].y, landmarks[idx].z)
            else:
                # Not enough data for reliable posture assessment
                return {"overall": "insufficient_data"}
        
        # Shoulder alignment (check if shoulders are level)
        if abs(landmark_coords["LEFT_SHOULDER"][1] - landmark_coords["RIGHT_SHOULDER"][1]) > 0.05:
            posture_status["shoulders"] = "uneven"
            posture_status["overall"] = "issues_detected"
        
        # Hip alignment (check if hips are level)
        if abs(landmark_coords["LEFT_HIP"][1] - landmark_coords["RIGHT_HIP"][1]) > 0.05:
            posture_status["hips"] = "uneven"
            posture_status["overall"] = "issues_detected"
        
        # Head position (forward head posture check)
        if "NOSE" in landmark_coords and "LEFT_SHOULDER" in landmark_coords and "RIGHT_SHOULDER" in landmark_coords:
            # Average shoulder position
            avg_shoulder_x = (landmark_coords["LEFT_SHOULDER"][0] + landmark_coords["RIGHT_SHOULDER"][0]) / 2
            # Check if head is significantly forward of shoulders
            if landmark_coords["NOSE"][0] - avg_shoulder_x > 0.1:
                posture_status["head"] = "forward_posture"
                posture_status["overall"] = "issues_detected"
        
        return posture_status
    
    def detect_involuntary_movements(self, movement_scores):
        """
        Detect involuntary movements based on movement scores
        Returns a dictionary with movement assessments
        """
        movement_status = {"overall": "normal"}
        
        # Check for tremors or involuntary movements in hands
        for side in ["LEFT", "RIGHT"]:
            wrist = f"{side}_WRIST"
            if wrist in movement_scores and movement_scores[wrist] > self.movement_threshold:
                movement_status[wrist] = "significant_movement"
                movement_status["overall"] = "movements_detected"
        
        # Check for other significant body movements
        for landmark, score in movement_scores.items():
            if score > self.movement_threshold * 2 and landmark not in movement_status:
                movement_status[landmark] = "significant_movement"
                movement_status["overall"] = "movements_detected"
        
        return movement_status
    
    def run_detection(self, patient_id, max_frames=None, display=True):
        """Run the detection process"""
        if self.cap is None:
            self.start_camera()
        
        if self.csv_file is None:
            log_file = self._setup_logging(patient_id)
            print(f"Logging data to {log_file}")
        
        self.start_time = time.time()
        self.frame_count = 0
        
        try:
            while True:
                # Check if we've reached the maximum number of frames
                if max_frames is not None and self.frame_count >= max_frames:
                    break
                
                # Capture frame
                ret, frame = self.cap.read()
                if not ret:
                    print("Error: Couldn't read frame.")
                    break
                
                # Process the frame
                self.frame_count += 1
                current_time = time.time()
                elapsed = current_time - self.start_time
                
                # Convert to RGB for MediaPipe
                frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                
                # Process with MediaPipe
                results = self.pose.process(frame_rgb)
                
                # Prepare overlay frame for visualization if displaying
                if display:
                    overlay = frame.copy()
                
                # Process landmarks if detected
                movement_scores = {}
                posture_status = {"overall": "no_detection"}
                
                if results.pose_landmarks:
                    landmarks = results.pose_landmarks.landmark
                    
                    # Analyze posture
                    posture_status = self.assess_posture(landmarks)
                    
                    # Process each key landmark
                    for name, idx in self.key_landmarks.items():
                        if idx < len(landmarks) and landmarks[idx].visibility > self.landmark_visibility_threshold:
                            lm = landmarks[idx]
                            current_pos = (lm.x, lm.y, lm.z)
                            
                            # Calculate movement score
                            movement_score = self.calculate_movement_score(name, current_pos)
                            movement_scores[name] = movement_score
                            
                            # Log to CSV
                            if self.csv_writer:
                                self.csv_writer.writerow({
                                    'timestamp': elapsed,
                                    'frame': self.frame_count,
                                    'landmark_name': name,
                                    'landmark_id': idx,
                                    'x': lm.x,
                                    'y': lm.y,
                                    'z': lm.z,
                                    'visibility': lm.visibility,
                                    'movement_score': movement_score,
                                    'posture_status': posture_status.get("overall", "unknown")
                                })
                    
                    # Draw landmarks on frame if displaying
                    if display:
                        self.mp_drawing.draw_landmarks(
                            overlay, 
                            results.pose_landmarks,
                            self.mp_pose.POSE_CONNECTIONS,
                            landmark_drawing_spec=self.mp_drawing_styles.get_default_pose_landmarks_style()
                        )
                
                # Detect involuntary movements
                movement_status = self.detect_involuntary_movements(movement_scores)
                
                # Display information on frame if showing display
                if display:
                    # Calculate FPS
                    fps = 1 / (current_time - self.prev_time) if self.prev_time else 0
                    self.prev_time = current_time
                    
                    # Add text overlays
                    cv2.putText(overlay, f'FPS: {int(fps)}', (10, 30), 
                                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2, cv2.LINE_AA)
                    
                    cv2.putText(overlay, f'Patient ID: {patient_id}', (10, 70), 
                                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2, cv2.LINE_AA)
                    
                    cv2.putText(overlay, f'Time: {elapsed:.1f}s', (10, 110), 
                                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2, cv2.LINE_AA)
                    
                    # Show posture status
                    posture_text = f'Posture: {posture_status["overall"]}'
                    color = (0, 255, 0) if posture_status["overall"] == "normal" else (0, 0, 255)
                    cv2.putText(overlay, posture_text, (10, 150), 
                                cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2, cv2.LINE_AA)
                    
                    # Show movement status
                    movement_text = f'Movement: {movement_status["overall"]}'
                    color = (0, 255, 0) if movement_status["overall"] == "normal" else (0, 165, 255)
                    cv2.putText(overlay, movement_text, (10, 190), 
                                cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2, cv2.LINE_AA)
                    
                    # Display the annotated frame
                    cv2.imshow('Posture and Movement Analysis', overlay)
                    
                    # Exit on 'q' press
                    if cv2.waitKey(1) & 0xFF == ord('q'):
                        break
        
        finally:
            # Clean up
            if self.csv_file:
                self.csv_file.close()
                self.csv_file = None
                self.csv_writer = None
            
            print(f"Processed {self.frame_count} frames in {time.time() - self.start_time:.2f} seconds")
    
    def cleanup(self):
        """Release resources"""
        if self.cap is not None:
            self.cap.release()
        cv2.destroyAllWindows()
        if self.csv_file is not None:
            self.csv_file.close()


# Usage example
if __name__ == "__main__":
    detector = PostureMovementDetector(camera_index=1)  # Default is 0
    
    try:
        # Get patient ID from user
        patient_id = input("Enter patient ID: ")
        if not patient_id:
            patient_id = "unknown"
            
        print("Starting posture and movement detection...")
        print("Press 'q' to quit")
        detector.run_detection(patient_id=patient_id)
    
    except KeyboardInterrupt:
        print("Detection stopped by user")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        detector.cleanup()