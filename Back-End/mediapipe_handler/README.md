# MediaPipe Video Recording and Playback

## Project Structure:
mediapipe_handler/
│
├── main.py                 # Entry point (menu to record or playback)
├── record_video.py         # Handles webcam + MediaPipe + recording
├── playback_video.py       # Handles playback with pause/rewind/scrub
│
├── videos/                 # Saved recordings go here
│   ├── output_20250929_1930.avi
│   └── ...
│
├── utils/                  # Helper functions or common code
│   ├── __init__.py
│   ├── mediapipe_utils.py  # e.g., setup MediaPipe pipelines
│   └── video_utils.py      # e.g., timestamped filename generator
│
├── requirements.txt        # Dependencies (mediapipe, opencv-python)
└── README.md               # Instructions on running the project
    
