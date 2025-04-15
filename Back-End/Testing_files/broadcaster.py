import cv2
import asyncio
import websockets

async def video_stream():
    # Open the default camera (change the index if necessary)
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FPS, 60)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1928)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 1080)

    if not cap.isOpened():
        print("Error: Could not open camera.")
        return

    ws_url = "ws://127.0.0.1:8000/video-streaming/live/test_patient"
    # Establish a persistent WebSocket connection.
    async with websockets.connect(ws_url) as ws:
        print("WebSocket connection opened.")
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Error: Frame not read properly.")
                break

            # Display the frame in a window named "Camera"
            cv2.imshow("Camera", frame)
            # Calling waitKey is essential for the window to refresh and process input.
            if cv2.waitKey(1) & 0xFF == ord("q"):
                print("User pressed 'q', stopping.")
                break

            # Encode the frame as JPEG.
            ret, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 100])
            if not ret:
                print("Error: Could not encode frame.")
                continue

            # Convert encoded frame to bytes and send over the WebSocket.
            await ws.send(buffer.tobytes())

    cap.release()
    cv2.destroyAllWindows()

async def main():
    await video_stream()

if __name__ == "__main__":
    asyncio.run(main())