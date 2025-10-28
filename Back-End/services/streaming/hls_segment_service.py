"""
HLS Segment Monitoring Service with SSE Broadcasting

This service monitors HLS segment creation in real-time and broadcasts
events to connected frontend clients via Server-Sent Events (SSE).
"""

import asyncio
import json
from datetime import datetime
from pathlib import Path
from typing import AsyncIterator, Dict, Optional, Set
from fastapi import Request
from core.common import logger


class HLSSegmentMonitor:
    """
    Monitors HLS segments for a specific recording session
    and broadcasts new segment events via SSE
    """

    def __init__(self, room_id: str, recording_path: Path):
        self.room_id = room_id
        self.recording_path = recording_path
        self.is_monitoring = False
        self._monitor_task: Optional[asyncio.Task] = None
        self._event_queues: Dict[str, asyncio.Queue] = {}  # client_id -> queue
        self._known_segments: Set[str] = set()
        self._segment_count = 0

        logger.info(f"📹 HLSSegmentMonitor created for room {room_id}")

    async def start_monitoring(self):
        """Start monitoring for new HLS segments"""
        if self.is_monitoring:
            logger.warning(f"Monitoring already active for room {self.room_id}")
            return

        self.is_monitoring = True
        self._monitor_task = asyncio.create_task(self._monitor_loop())
        logger.info(f"🎬 Started HLS segment monitoring for room {self.room_id}")

    async def stop_monitoring(self):
        """Stop monitoring and cleanup"""
        if not self.is_monitoring:
            return

        self.is_monitoring = False

        if self._monitor_task:
            self._monitor_task.cancel()
            try:
                await self._monitor_task
            except asyncio.CancelledError:
                pass

        # Clear all queues
        self._event_queues.clear()
        self._known_segments.clear()

        logger.info(f"🛑 Stopped HLS segment monitoring for room {self.room_id}")

    async def _monitor_loop(self):
        """Main monitoring loop - checks for new segments every second"""
        try:
            while self.is_monitoring:
                await self._check_for_new_segments()
                await asyncio.sleep(1.0)  # Check every second
        except asyncio.CancelledError:
            logger.info(f"Monitor loop cancelled for room {self.room_id}")
        except Exception as e:
            logger.error(f"Error in monitor loop for room {self.room_id}: {e}")

    async def _check_for_new_segments(self):
        """Check recording directory for new .ts segments"""
        try:
            if not self.recording_path.exists():
                return

            # Find all .ts segment files
            segment_files = sorted(self.recording_path.glob("segment-*.ts"))

            # Check for new segments
            for segment_file in segment_files:
                segment_name = segment_file.name

                if segment_name not in self._known_segments:
                    # New segment detected!
                    self._known_segments.add(segment_name)
                    self._segment_count += 1

                    # Get segment metadata
                    segment_info = {
                        "type": "new_segment",
                        "room_id": self.room_id,
                        "segment_name": segment_name,
                        "segment_number": self._segment_count,
                        "segment_path": str(
                            segment_file.relative_to(self.recording_path.parent)
                        ),
                        "file_size": segment_file.stat().st_size,
                        "timestamp": datetime.utcnow().isoformat(),
                    }

                    # Broadcast to all connected clients
                    await self._broadcast_event(segment_info)

                    logger.info(
                        f"🎞️ New segment detected: {segment_name} "
                        f"(#{self._segment_count}) for room {self.room_id}"
                    )

        except Exception as e:
            logger.error(f"Error checking segments for room {self.room_id}: {e}")

    async def _broadcast_event(self, event_data: dict):
        """Broadcast event to all connected SSE clients"""
        event_json = f"data: {json.dumps(event_data)}\n\n"

        # Send to all active queues
        for client_id, queue in list(self._event_queues.items()):
            try:
                if not queue.full():
                    queue.put_nowait(event_json)
                else:
                    logger.warning(
                        f"Event queue full for client {client_id[:8]}... in room {self.room_id}"
                    )
            except Exception as e:
                logger.error(f"Error broadcasting to client {client_id[:8]}...: {e}")

    async def create_sse_stream(
        self, request: Request, client_id: str
    ) -> AsyncIterator[str]:
        """
        Create SSE stream for a client to receive segment events

        Args:
            request: FastAPI request object
            client_id: Unique identifier for the client

        Yields:
            SSE formatted strings
        """
        # Create event queue for this client
        queue = asyncio.Queue(maxsize=100)
        self._event_queues[client_id] = queue

        logger.info(
            f"🔌 SSE client connected: {client_id[:8]}... for room {self.room_id} "
            f"(total clients: {len(self._event_queues)})"
        )

        try:
            # Send initial connection confirmation
            initial_event = {
                "type": "connected",
                "room_id": self.room_id,
                "client_id": client_id,
                "segment_count": self._segment_count,
                "timestamp": datetime.utcnow().isoformat(),
            }
            yield f"data: {json.dumps(initial_event)}\n\n"

            # Event loop - yield messages from queue
            while True:
                # Check if client disconnected
                if await request.is_disconnected():
                    logger.info(
                        f"🔌 SSE client disconnected: {client_id[:8]}... from room {self.room_id}"
                    )
                    break

                try:
                    # Wait for event with 30-second timeout for heartbeat
                    msg = await asyncio.wait_for(queue.get(), timeout=30.0)
                    yield msg

                except asyncio.TimeoutError:
                    # Send heartbeat to keep connection alive
                    heartbeat = {
                        "type": "heartbeat",
                        "room_id": self.room_id,
                        "timestamp": datetime.utcnow().isoformat(),
                    }
                    yield f"data: {json.dumps(heartbeat)}\n\n"

                except Exception as e:
                    logger.error(
                        f"Error in SSE stream for client {client_id[:8]}...: {e}"
                    )
                    error_event = {
                        "type": "error",
                        "room_id": self.room_id,
                        "error": str(e),
                        "timestamp": datetime.utcnow().isoformat(),
                    }
                    yield f"data: {json.dumps(error_event)}\n\n"
                    break

        except asyncio.CancelledError:
            logger.info(f"SSE stream cancelled for client {client_id[:8]}...")
        except Exception as e:
            logger.error(f"Error in SSE stream for client {client_id[:8]}...: {e}")
        finally:
            # Cleanup client queue
            if client_id in self._event_queues:
                del self._event_queues[client_id]
                logger.info(
                    f"🧹 Cleaned up SSE client: {client_id[:8]}... from room {self.room_id} "
                    f"(remaining clients: {len(self._event_queues)})"
                )

    def get_active_client_count(self) -> int:
        """Get number of active SSE clients"""
        return len(self._event_queues)

    def get_segment_count(self) -> int:
        """Get current number of segments"""
        return self._segment_count


class HLSSegmentService:
    """
    Global service managing HLS segment monitors for all active recordings
    """

    def __init__(self):
        self._monitors: Dict[str, HLSSegmentMonitor] = {}  # room_id -> monitor
        logger.info("📺 HLSSegmentService initialized")

    async def start_monitoring_room(
        self, room_id: str, recording_path: Path
    ) -> HLSSegmentMonitor:
        """
        Start monitoring HLS segments for a room

        Args:
            room_id: Camera room ID
            recording_path: Path to recording directory containing segments

        Returns:
            HLSSegmentMonitor instance
        """
        if room_id in self._monitors:
            logger.warning(f"Monitor already exists for room {room_id}")
            return self._monitors[room_id]

        monitor = HLSSegmentMonitor(room_id, recording_path)
        await monitor.start_monitoring()
        self._monitors[room_id] = monitor

        logger.info(
            f"✅ Started segment monitoring for room {room_id} "
            f"(total monitors: {len(self._monitors)})"
        )

        return monitor

    async def stop_monitoring_room(self, room_id: str):
        """Stop monitoring HLS segments for a room"""
        monitor = self._monitors.get(room_id)
        if not monitor:
            logger.warning(f"No monitor found for room {room_id}")
            return

        await monitor.stop_monitoring()
        del self._monitors[room_id]

        logger.info(
            f"✅ Stopped segment monitoring for room {room_id} "
            f"(remaining monitors: {len(self._monitors)})"
        )

    def get_monitor(self, room_id: str) -> Optional[HLSSegmentMonitor]:
        """Get monitor for a specific room"""
        return self._monitors.get(room_id)

    async def stop_all_monitors(self):
        """Stop all active monitors (cleanup on shutdown)"""
        for room_id in list(self._monitors.keys()):
            await self.stop_monitoring_room(room_id)

    def get_active_monitor_count(self) -> int:
        """Get number of active monitors"""
        return len(self._monitors)

    def get_stats(self) -> dict:
        """Get service statistics"""
        total_clients = sum(
            monitor.get_active_client_count() for monitor in self._monitors.values()
        )
        total_segments = sum(
            monitor.get_segment_count() for monitor in self._monitors.values()
        )

        return {
            "active_monitors": len(self._monitors),
            "total_sse_clients": total_clients,
            "total_segments_tracked": total_segments,
            "rooms": [
                {
                    "room_id": room_id,
                    "clients": monitor.get_active_client_count(),
                    "segments": monitor.get_segment_count(),
                }
                for room_id, monitor in self._monitors.items()
            ],
        }


# Global service instance
hls_segment_service = HLSSegmentService()
