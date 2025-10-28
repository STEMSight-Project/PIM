import asyncio
from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.contrib.media import MediaBlackhole
import json

from mediapipe_processor import MediaPipeVideoProcessor


class VideoTransformTrack(MediaStreamTrack):
    kind = "video"

    def __init__(self, track, processor: MediaPipeVideoProcessor):
        super().__init__()
        self.track = track
        self.processor = processor

    async def recv(self):
        frame = await self.track.recv()
        processed = self.processor.process_frame(frame)
        return processed


async def process_offer(offer_sdp: str) -> str:
    """Handles incoming WebRTC offer and returns processed answer SDP."""
    offer = json.loads(offer_sdp)
    pc = RTCPeerConnection()
    media_blackhole = MediaBlackhole()

    # Create MediaPipe processor instance
    processor = MediaPipeVideoProcessor()

    @pc.on("track")
    async def on_track(track):
        if track.kind == "video":
            transformed_track = VideoTransformTrack(track, processor)
            pc.addTrack(transformed_track)
        else:
            # ignore audio for now
            pc.addTrack(track)

        @track.on("ended")
        async def on_ended():
            print("Track ended")

    # Apply the offer
    await pc.setRemoteDescription(
        RTCSessionDescription(offer["sdp"], offer["type"])
    )
    answer =
