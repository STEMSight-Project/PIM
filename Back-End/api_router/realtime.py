"""
Realtime API router for Server-Sent Events (SSE) endpoints with Supabase integration
"""

import asyncio
import json
from typing import AsyncIterator, Optional, Dict, Any
from fastapi import APIRouter, Request, Depends
from fastapi.responses import StreamingResponse
from security.jwt_verify import current_user
from core.common import logger, supabase_async
from core.env import ENVIRONMENT

# Initialize router
router = APIRouter()


class SupabaseRealtimeService:
    """
    Service for handling Supabase real-time subscriptions via SSE
    """

    def __init__(self):
        self.active_subscriptions: Dict[str, Any] = {}
        self._event_queues: Dict[str, asyncio.Queue] = {}

    async def create_sse_stream(
        self,
        request: Request,
        table: str,
        schema: str = "public",
        event_filter: str = "*",
        patient_id: Optional[str] = None,
        custom_filter: Optional[str] = None,
    ) -> AsyncIterator[str]:
        """
        Create Server-Sent Events stream for real-time Supabase data

        Args:
            request: FastAPI request object
            table: Database table to subscribe to
            schema: Database schema (default: "public")
            event_filter: Event type filter ("*", "INSERT", "UPDATE", "DELETE")
            patient_id: Optional patient ID for filtering
            custom_filter: Optional custom filter string
        """
        channel_name = (
            f"realtime_{table}_{patient_id or 'all'}_{asyncio.get_event_loop().time()}"
        )
        logger.info(
            "Creating Supabase SSE stream for table %s, channel: %s",
            table,
            channel_name,
        )

        # Create event queue for this stream
        queue = asyncio.Queue()
        self._event_queues[channel_name] = queue

        try:
            # Get async Supabase client
            supabase = await supabase_async()

            # Create realtime channel
            channel = supabase.channel(channel_name)

            # Define event handler
            def event_handler(payload: Dict[str, Any]) -> None:
                """Handle incoming realtime events"""
                try:
                    # Process the event payload
                    event_data = {
                        "type": "database_change",
                        "table": table,
                        "event": payload.get("eventType", "unknown"),
                        "new": payload.get("new"),
                        "old": payload.get("old"),
                        "timestamp": asyncio.get_event_loop().time(),
                    }

                    # Add to queue (non-blocking)
                    if not queue.full():
                        queue.put_nowait(f"data: {json.dumps(event_data)}\n\n")
                        logger.info("Real-time event queued for table %s", table)
                    else:
                        logger.warning("Event queue full for channel %s", channel_name)

                except (TypeError, ValueError, KeyError) as e:
                    logger.error("Error handling real-time event: %s", e)
                    error_msg = (
                        f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"
                    )
                    if not queue.full():
                        queue.put_nowait(error_msg)

            # Configure postgres changes subscription
            subscription_filter = custom_filter
            if patient_id and not custom_filter:
                subscription_filter = f"patient_id=eq.{patient_id}"

            # Subscribe to postgres changes
            channel.on_postgres_changes(
                event=event_filter,
                schema=schema,
                table=table,
                filter=subscription_filter,
                callback=event_handler,
            )

            # Subscribe to channel
            await channel.subscribe()

            # Store subscription reference
            self.active_subscriptions[channel_name] = channel

            logger.info(
                "Started Supabase subscription for table %s with channel %s",
                table,
                channel_name,
            )

            # Send initial connection confirmation
            initial_msg = f"data: {json.dumps({'type': 'connected', 'channel': channel_name, 'table': table})}\n\n"
            yield initial_msg

            # Event loop - yield messages from queue
            while True:
                # Check if client disconnected
                if await request.is_disconnected():
                    logger.info(
                        "Client disconnected from realtime stream: %s", channel_name
                    )
                    break

                try:
                    # Wait for event with timeout for heartbeat
                    msg = await asyncio.wait_for(queue.get(), timeout=30.0)
                    yield msg

                except asyncio.TimeoutError:
                    # Send heartbeat
                    heartbeat = f"data: {json.dumps({'type': 'heartbeat', 'timestamp': asyncio.get_event_loop().time()})}\n\n"
                    yield heartbeat

                except Exception as e:
                    logger.error("Error in SSE event loop: %s", e)
                    error_msg = (
                        f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"
                    )
                    yield error_msg
                    break

        except asyncio.CancelledError:
            logger.info("Supabase SSE stream cancelled: %s", channel_name)
        except Exception as e:
            logger.error("Error in Supabase SSE stream %s: %s", channel_name, e)
            error_msg = f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"
            yield error_msg
        finally:
            # Cleanup subscription and queue
            await self._cleanup_subscription(channel_name)

    async def _cleanup_subscription(self, channel_name: str) -> None:
        """Clean up subscription and associated resources"""
        try:
            # Unsubscribe from channel
            if channel_name in self.active_subscriptions:
                channel = self.active_subscriptions[channel_name]
                await channel.unsubscribe()
                del self.active_subscriptions[channel_name]
                logger.info("Unsubscribed from channel: %s", channel_name)

            # Clean up event queue
            if channel_name in self._event_queues:
                del self._event_queues[channel_name]
                logger.info("Cleaned up event queue for: %s", channel_name)

        except Exception as e:
            logger.error("Error cleaning up subscription %s: %s", channel_name, e)

    def get_active_queue_count(self) -> int:
        """Get the number of active event queues"""
        return len(self._event_queues)


# Global service instance
realtime_service = SupabaseRealtimeService()


@router.get("/sessions")
async def realtime_sessions(request: Request, patient_id: Optional[str] = None):
    """Stream real-time updates for streaming sessions using SSE"""
    logger.info(
        "Starting real-time sessions stream for patient_id: %s", patient_id or "all"
    )

    stream = realtime_service.create_sse_stream(
        request=request,
        table="streaming_sessions",
        patient_id=patient_id,
        event_filter="*",
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/rooms")
async def realtime_rooms(request: Request):
    """Stream real-time updates for streaming rooms using SSE"""
    logger.info("Starting real-time rooms stream")

    stream = realtime_service.create_sse_stream(
        request=request, table="streaming_rooms", event_filter="*"
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


@router.get("/patient/{patient_id}/status", dependencies=[Depends(current_user)])
async def realtime_patient_status(request: Request, patient_id: str):
    """Stream real-time patient status updates using SSE"""
    logger.info("Starting real-time patient status stream for patient: %s", patient_id)

    stream = realtime_service.create_sse_stream(
        request=request,
        table="patients",
        patient_id=patient_id,
        event_filter="UPDATE",
        custom_filter=f"id=eq.{patient_id}",
    )

    return StreamingResponse(
        stream,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
