import cv2
from app.services.camera_stream import CameraStream
from fastapi import APIRouter, Response
from fastapi.responses import StreamingResponse

router = APIRouter()
camera = CameraStream()
camera.start()


def generate_frames():
    while True:
        frame = camera.get_frame()
        if frame is None:
            continue
        # Encode frame as JPEG
        ret, buffer = cv2.imencode(".jpg", frame)
        if not ret:
            continue
        yield (
            b"--frame\r\nContent-Type: image/jpeg\r\n\r\n" + buffer.tobytes() + b"\r\n"
        )


@router.get("/stream")
def stream_video():
    """
    HTTP MJPEG stream (useful for testing in browser).
    """
    return StreamingResponse(
        generate_frames(), media_type="multipart/x-mixed-replace; boundary=frame"
    )


@router.get("/snapshot")
def snapshot():
    """
    Returns a single frame as JPEG image.
    """
    frame = camera.get_frame()
    if frame is None:
        return Response(status_code=404)
    _, buffer = cv2.imencode(".jpg", frame)
    return Response(content=buffer.tobytes(), media_type="image/jpeg")
