"""
Simple SSE test endpoint to verify streaming works
"""

from fastapi import APIRouter, Request
from fastapi.responses import StreamingResponse
import asyncio
import json
import logging

logger = logging.getLogger(__name__)
router = APIRouter()


@router.get("/test-sse")
async def test_sse(request: Request):
    """Simple SSE test without Supabase"""

    async def event_generator():
        try:
            # Send initial message
            yield f"data: {json.dumps({'type': 'connected', 'message': 'SSE test connected'})}\n\n"
            logger.info("SSE test: Initial message sent")

            counter = 0
            while True:
                # Check if client disconnected
                if await request.is_disconnected():
                    logger.info("SSE test: Client disconnected")
                    break

                # Send a test message every 5 seconds
                counter += 1
                yield f"data: {json.dumps({'type': 'test', 'count': counter, 'message': f'Test message #{counter}'})}\n\n"
                logger.info(f"SSE test: Sent message #{counter}")

                # Wait 5 seconds
                await asyncio.sleep(5)

        except Exception as e:
            logger.error(f"SSE test error: {e}", exc_info=True)
            yield f"data: {json.dumps({'type': 'error', 'error': str(e)})}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
