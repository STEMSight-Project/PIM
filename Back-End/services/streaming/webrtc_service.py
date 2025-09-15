"""
WebRTC service for handling peer connections and media relay.
"""

from typing import Optional
from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.contrib.media import MediaRelay
from core.common import logger
from services.streaming.room_service import room_manager
from services.streaming.models import SDPBody


class WebRTCService:
    """Service for managing WebRTC peer connections and media streaming."""

    def __init__(self):
        self.relay = MediaRelay()

    async def create_streamer_connection(self, room_id: str, sdp_body: SDPBody) -> dict:
        """Create a WebRTC connection for a streamer (publisher)."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                raise ValueError(f"Room {room_id} not found")

            # Create peer connection
            pc = RTCPeerConnection()
            room.add_peer_connection(pc)

            # Set up event handlers
            @pc.on("connectionstatechange")
            async def on_connectionstatechange():
                logger.info(
                    "Streamer connection state for room %s: %s",
                    room_id,
                    pc.connectionState,
                )
                if pc.connectionState == "closed":
                    room.remove_peer_connection(pc)
                elif pc.connectionState == "failed":
                    await room.handle_disconnection()

            @pc.on("track")
            def on_track(track: MediaStreamTrack):
                logger.info("Received %s track in room %s", track.kind, room_id)

                # Relay track to all other connections in the room
                relayed_track = self.relay.subscribe(track)

                # Add track to all other peer connections in the room
                for other_pc in room.pcs:
                    if other_pc != pc:
                        other_pc.addTrack(relayed_track)

                @track.on("ended")
                async def on_ended():
                    logger.info("Track ended in room %s", room_id)

            # Set remote description
            await pc.setRemoteDescription(
                RTCSessionDescription(sdp=sdp_body.sdp, type=sdp_body.type)
            )

            # Create answer
            answer = await pc.createAnswer()
            await pc.setLocalDescription(answer)

            return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

        except Exception as e:
            logger.error(
                "Error creating streamer connection for room %s: %s", room_id, e
            )
            raise

    async def create_viewer_connection(self, room_id: str, sdp_body: SDPBody) -> dict:
        """Create a WebRTC connection for a viewer (subscriber)."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                raise ValueError(f"Room {room_id} not found")

            # Create peer connection
            pc = RTCPeerConnection()
            room.add_peer_connection(pc)

            # Set up event handlers
            @pc.on("connectionstatechange")
            async def on_connectionstatechange():
                logger.info(
                    "Viewer connection state for room %s: %s",
                    room_id,
                    pc.connectionState,
                )
                if pc.connectionState == "closed":
                    room.remove_peer_connection(pc)

            # Add existing tracks from other connections
            for other_pc in room.pcs:
                if other_pc != pc:
                    for transceiver in other_pc.getTransceivers():
                        if transceiver.receiver.track:
                            track = transceiver.receiver.track
                            relayed_track = self.relay.subscribe(track)
                            pc.addTrack(relayed_track)

            # Set remote description
            await pc.setRemoteDescription(
                RTCSessionDescription(sdp=sdp_body.sdp, type=sdp_body.type)
            )

            # Create answer
            answer = await pc.createAnswer()
            await pc.setLocalDescription(answer)

            return {"sdp": pc.localDescription.sdp, "type": pc.localDescription.type}

        except Exception as e:
            logger.error("Error creating viewer connection for room %s: %s", room_id, e)
            raise

    async def handle_ice_candidate(self, room_id: str, candidate_data: dict) -> bool:
        """Handle ICE candidate for a room."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                logger.warning("ICE candidate for non-existent room %s", room_id)
                return False

            # In a production environment, you would route this to the specific
            # peer connection that needs it. For now, we'll log it.
            logger.info(
                "Received ICE candidate for room %s: %s", room_id, candidate_data
            )
            return True

        except Exception as e:
            logger.error("Error handling ICE candidate for room %s: %s", room_id, e)
            return False

    def get_connection_stats(self, room_id: str) -> dict:
        """Get connection statistics for a room."""
        try:
            room = room_manager.get_room(room_id)
            if not room:
                return {"error": f"Room {room_id} not found"}

            stats = {
                "room_id": room_id,
                "active_connections": len(room.pcs),
                "room_active": room.is_active,
                "connections": [],
            }

            for i, pc in enumerate(room.pcs):
                stats["connections"].append(
                    {
                        "connection_id": i,
                        "state": pc.connectionState,
                        "ice_connection_state": pc.iceConnectionState,
                        "ice_gathering_state": pc.iceGatheringState,
                    }
                )

            return stats

        except Exception as e:
            logger.error("Error getting stats for room %s: %s", room_id, e)
            return {"error": str(e)}


# Global WebRTC service instance
webrtc_service = WebRTCService()
