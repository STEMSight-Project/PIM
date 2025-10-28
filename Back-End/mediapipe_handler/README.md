# MediaPipe Video Recording and Playback

mediapipe_handler/
│
├── app/
│   ├── main.py                     # FastAPI entry point
│   ├── routes/
│   │   ├── stream_routes.py        # Live WebRTC stream endpoints
│   │   ├── record_routes.py        # Start/stop recording endpoints
│   │   └── playback_routes.py      # Serve recorded videos for playback
│   │
│   ├── services/
│   │   ├── camera_stream.py        # OpenCV camera capture + WebRTC bridge
│   │   ├── recorder_service.py     # Handle MediaPipe + saving video
│   │   └── playback_service.py     # Handle playback controls
│   │
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── mediapipe_utils.py      # Setup MediaPipe processing graphs
│   │   └── video_utils.py          # Timestamped filename, FPS utils, etc.
│   │
│   ├── videos/                     # Output folder (Local)
│   │   ├── output_20251013_1545.avi
│   │   └── ...
│   │
│   ├── webrtc_streamer.py          # Handles signaling + peer connection
│   └── __init__.py
│
├── requirements.txt
├── README.md
└── run.sh                          # Optional helper script to start the server

