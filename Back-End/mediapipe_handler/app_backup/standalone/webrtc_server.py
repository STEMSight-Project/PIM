#!/usr/bin/env python3
"""
Simple WebRTC server that streams MediaPipe-processed OpenCV frames
to a browser. Uses aiohttp for HTTP endpoints and aiortc for WebRTC.

Endpoint:
  POST /offer
    Body: JSON { "sdp": "<offer-sdp>", "type": "offer" }
    Response: JSON { "sdp": "<answer-sdp>", "type": "answer" }

Static files are served from ./static (index.html client).
"""

import asyncio
import logging
import os
import sys
import time
from fractions import Fraction

import av
import cv2
import mediapipe as mp
from aiohttp import web
from aiortc import (
    MediaStreamTrack,
    RTCPeerConnection,
    RTCSessionDescription,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("webrtc_server")

ROOT = os.path.dirname(__file__)
STATIC_DIR = os.path.join(ROOT, "static")

PCS = set()


class MediaPipeVideoTrack(MediaStreamTrack):
    """
    A VideoStreamTrack that captures from OpenCV (webcam or file),
    runs MediaPipe hands detection, draws landmarks, and yields frames.

    Note: MediaPipe + OpenCV can be CPU heavy; you may need to tune fps,
    max_num_hands, or run this on a machine with sufficient CPU.
    """

    kind = "video"

    def __init__(self, source=0, fps=20):
        super().__init__()  # don't forget this!
        self._source = source
        self._fps = fps
        self._frame_time = 1.0 / fps
        self._last_frame_time = None

        # OpenCV capture
        self._cap = cv2.VideoCapture(source)
        if not self._cap.isOpened():
            raise RuntimeError(f"Could not open video source: {source}")

        # MediaPipe setup (re-use logic from record_video.py)
        self._mp_hands = mp.solutions.hands
        self._mp_drawing = mp.solutions.drawing_utils
        self._hands = self._mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )
        self._pts = 0
        # common value used by aiortc examples
        self._time_base = Fraction(1, 90000)

        # ensure we have a consistent width/height
        self._width = int(self._cap.get(cv2.CAP_PROP_FRAME_WIDTH) or 640)
        self._height = int(self._cap.get(cv2.CAP_PROP_FRAME_HEIGHT) or 480)

        logger.info(
            "MediaPipeVideoTrack initialized (source=%s, fps=%s)", source, fps)

    async def recv(self):
        """
        Receives the next frame. We call blocking cv2.read in a threadpool
        to avoid blocking the event loop.
        """
        # pacing
        if self._last_frame_time is not None:
            elapsed = time.time() - self._last_frame_time
            wait = self._frame_time - elapsed
            if wait > 0:
                await asyncio.sleep(wait)

        loop = asyncio.get_running_loop()
        ret, frame = await loop.run_in_executor(None, self._cap.read)
        if not ret or frame is None:
            # End of stream or failed read: raise EOF
            logger.info("Frame capture failed/ended; stopping track")
            raise MediaStreamTrack.EndOfStreamError

        # Process with MediaPipe (convert BGR->RGB for processing)
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self._hands.process(image_rgb)

        # Draw landmarks onto the BGR 'frame' (so we show them)
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                self._mp_drawing.draw_landmarks(
                    frame, hand_landmarks, self._mp_hands.HAND_CONNECTIONS
                )

        # Convert to av.VideoFrame (aiortc expects VideoFrame)
        # aiortc expects frames in RGB or YUV formats; use RGB24
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        video_frame = av.VideoFrame.from_ndarray(frame_rgb, format="rgb24")

        # set pts/time_base for proper synchronization
        # increment pts by an appropriate amount (using 90kHz clock)
        self._pts += int(90000 * self._frame_time)
        video_frame.pts = self._pts
        video_frame.time_base = self._time_base

        self._last_frame_time = time.time()
        return video_frame

    def stop(self):
        try:
            self._hands.close()
        except Exception:
            pass
        try:
            if self._cap is not None:
                self._cap.release()
        except Exception:
            pass
        super().stop()
        logger.info("MediaPipeVideoTrack stopped and resources released")


async def offer(request):
    """
    Accept a JSON POST with keys {sdp, type} (the offer) and return the answer.
    """
    params = await request.json()
    offer_sdp = params["sdp"]
    offer_type = params.get("type", "offer")

    pc = RTCPeerConnection(
        # If you need STUN/TURN servers, put them here:
        # RTCConfiguration([RTCIceServer(urls=["stun:stun.l.google.com:19302"])])
    )
    PCS.add(pc)
    logger.info("Created PeerConnection %s", pc)

    # add the MediaPipe track which will be sent to the browser
    local_video = MediaPipeVideoTrack(source=0, fps=20)
    pc.addTrack(local_video)

    @pc.on("connectionstatechange")
    async def on_connectionstatechange():
        logger.info("Connection state is %s", pc.connectionState)
        if pc.connectionState in ("failed", "closed", "disconnected"):
            await pc.close()
            PCS.discard(pc)

    # set remote description
    offer_desc = RTCSessionDescription(sdp=offer_sdp, type=offer_type)
    await pc.setRemoteDescription(offer_desc)

    # create answer
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    logger.info("Returning answer to client")
    return web.json_response(
        {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}
    )


async def on_shutdown(app):
    # close all peer connections
    coros = [pc.close() for pc in list(PCS)]
    await asyncio.gather(*coros)
    PCS.clear()


def main(argv):
    app = web.Application()
    app.router.add_post("/offer", offer)
    app.router.add_static("/", STATIC_DIR, show_index=True)
    app.on_shutdown.append(on_shutdown)

    # run aiohttp app
    host = "0.0.0.0"
    port = int(os.environ.get("PORT", 8080))
    logger.info("Starting server at http://%s:%s", host, port)
    web.run_app(app, host=host, port=port)


if __name__ == "__main__":
    main(sys.argv)
