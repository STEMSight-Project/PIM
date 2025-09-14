import cv2
import mediapipe as mp
import time
import csv

mp_pose = mp.solutions.pose
pose = mp_pose.Pose()  

cap = cv2.VideoCapture(1) # Find and use the index for your webcam (0, 1, 2...)
                          # mine is at 1 but the default is usually 0

# Check webcam
if not cap.isOpened():
    print("Error: Could not open camera.")
    exit()

# Open a CSV file to store the landmarks
with open('landmarks_data.csv', 'w', newline='') as csvfile:
    fieldnames = ['timestamp', 'landmark_id', 'x', 'y', 'z']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    start_time = time.time()
    prev_time = 0

    writer.writeheader()
    
    while True:
        # Capture frame-by-frame
        ret, frame = cap.read()

        if not ret:
            print("Error: Couldn't read frame.")
            break

        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB) # Converting to rgb for MediaPipe Compatibility
       
        results = pose.process(frame_rgb)

        if results.pose_landmarks:
            timestamp = time.time() - start_time  # Get the current timestamp

            for landmark_id, landmark in enumerate(results.pose_landmarks.landmark):
                # Write the landmark data to a CSV
                writer.writerow({
                    'timestamp': timestamp,
                    'landmark_id': landmark_id,
                    'x': landmark.x,
                    'y': landmark.y,
                    'z': landmark.z
                })

            # Draw the landmarks on the frame
            mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

        # calculte and displaying the fps on the frame
        current_time = time.time()
        fps = 1 / (current_time - prev_time) if prev_time else 0
        prev_time = current_time  
        cv2.putText(frame, f'FPS: {int(fps)}', (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
        1, (0, 255, 0), 2, cv2.LINE_AA)

        cv2.imshow('Webcam Feed with MediaPipe Pose', frame) # display the frame

        # Quit when 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

cap.release()
cv2.destroyAllWindows()
