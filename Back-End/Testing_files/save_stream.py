import cv2
import numpy as np
import asyncio
import websockets
import argparse

async def receive_video():
    uri = "ws://127.0.0.1:8000/video-streaming/watch/test_patient"
    async with websockets.connect(uri) as websocket:
        print("Connected to video stream.")
        while True:
            try:
                # Receive a frame (as JPEG bytes)
                frame_bytes = await websocket.recv()
                # Convert the bytes into a NumPy array
                np_arr = np.frombuffer(frame_bytes, np.uint8)
                # Decode the image (JPEG) into a frame
                frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
                if frame is None:
                    continue

                cv2.imshow("Video Stream", frame)
                # Exit on 'q' key press
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
                    
                # Add configurable delay between frames
            except websockets.ConnectionClosed:
                print("Connection closed.")
                break
            except Exception as e:
                print("Error receiving frame:", e)
                break

    cv2.destroyAllWindows()

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(receive_video())
