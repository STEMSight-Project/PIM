import os
import sys

import playback_video

# Import your modules
import record_video

VIDEOS_DIR = "videos"


def ensure_videos_dir():
    """Make sure the videos folder exists."""
    if not os.path.exists(VIDEOS_DIR):
        os.makedirs(VIDEOS_DIR)


def main():
    ensure_videos_dir()

    print("\n=== MediaPipe Webcam Project ===")
    print("1. Record a new video")
    print("2. Play back a saved video")
    print("0. Exit")

    choice = input("Enter choice: ").strip()

    if choice == "1":
        record_video.run(VIDEOS_DIR)
    elif choice == "2":
        # List videos in the folder
        files = [f for f in os.listdir(VIDEOS_DIR) if f.endswith((".avi", ".mp4"))]
        if not files:
            print("No videos found. Record one first!")
            return
        print("\nAvailable videos:")
        for i, f in enumerate(files, 1):
            print(f"{i}. {f}")
        idx = int(input("Select video number: ").strip()) - 1
        if 0 <= idx < len(files):
            playback_video.run(os.path.join(VIDEOS_DIR, files[idx]))
        else:
            print("Invalid selection.")
    elif choice == "0":
        print("Exiting...")
        sys.exit(0)
    else:
        print("Invalid choice.")


if __name__ == "__main__":
    main()
