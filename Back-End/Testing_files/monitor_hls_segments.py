"""
Monitor HLS Segment Creation in Real-Time
==========================================

This script monitors HLS segment creation during live streaming
to verify that segments are being created while recording is active.

Usage:
    python monitor_hls_segments.py <session_id>

Example:
    python monitor_hls_segments.py 12345678-1234-1234-1234-123456789abc
"""

import sys
import time
import requests
from pathlib import Path
from datetime import datetime

# API endpoint
API_URL = "http://localhost:8000/videos/hls"


def monitor_session(session_id: str, interval: int = 2):
    """
    Monitor HLS segment creation for a session

    Args:
        session_id: The session ID to monitor
        interval: Seconds between checks (default: 2)
    """
    print(f"🎬 Monitoring HLS segments for session: {session_id}")
    print(f"⏱️  Update interval: {interval} seconds")
    print(f"🔗 API endpoint: {API_URL}/{session_id}/status")
    print("=" * 80)
    print()

    last_segment_count = 0
    start_time = time.time()
    check_count = 0

    try:
        while True:
            check_count += 1
            elapsed = int(time.time() - start_time)

            try:
                # Query status endpoint
                response = requests.get(f"{API_URL}/{session_id}/status", timeout=5)

                if response.status_code == 200:
                    data = response.json()

                    # Extract info
                    status = data.get("status", "unknown")
                    is_active = data.get("is_active", False)
                    duration = data.get("duration", 0)
                    segment_count = data.get("segment_count", 0)
                    hls_ready = data.get("hls_ready", False)
                    recording_path = data.get("recording_path", "N/A")

                    # Calculate segment growth
                    new_segments = segment_count - last_segment_count
                    last_segment_count = segment_count

                    # Print status
                    timestamp = datetime.now().strftime("%H:%M:%S")
                    status_icon = "🔴" if is_active else "⚫"
                    ready_icon = "✅" if hls_ready else "⏳"
                    growth_icon = "📈" if new_segments > 0 else "⏸️"

                    print(f"[{timestamp}] Check #{check_count} (T+{elapsed}s)")
                    print(f"  {status_icon} Status: {status.upper()}")
                    print(f"  {ready_icon} HLS Ready: {hls_ready}")
                    print(f"  📹 Duration: {duration}s")
                    print(
                        f"  🎞️  Segments: {segment_count} {growth_icon} (+{new_segments})"
                    )
                    print(f"  📁 Path: {recording_path}")

                    if new_segments > 0:
                        print(f"  ✨ NEW: {new_segments} segment(s) created!")

                    print()

                    # Check for completion
                    if not is_active:
                        print(f"🏁 Recording completed!")
                        print(f"   Total segments: {segment_count}")
                        print(f"   Total duration: {duration}s")
                        break

                elif response.status_code == 404:
                    print(f"❌ Session not found: {session_id}")
                    print(f"   Make sure the recording has started")
                    break

                else:
                    print(f"⚠️  HTTP {response.status_code}: {response.text}")

            except requests.exceptions.ConnectionError:
                print(f"❌ Cannot connect to {API_URL}")
                print(f"   Is the backend server running?")
                break

            except requests.exceptions.Timeout:
                print(f"⏱️  Request timeout")

            except Exception as e:
                print(f"❌ Error: {e}")

            # Wait before next check
            time.sleep(interval)

    except KeyboardInterrupt:
        print()
        print("⏹️  Monitoring stopped by user")
        print(f"   Total checks: {check_count}")
        print(f"   Total time: {elapsed}s")
        print(f"   Final segment count: {last_segment_count}")


def check_local_path(session_id: str):
    """
    Check if recording directory exists locally

    Args:
        session_id: The session ID to check
    """
    recording_path = (
        Path(__file__).parent.parent / "recordings" / f"session-{session_id}"
    )

    print(f"🔍 Local path check:")
    print(f"   Path: {recording_path}")

    if recording_path.exists():
        print(f"   ✅ Directory exists")

        # Count segments
        segments = list(recording_path.glob("segment-*.ts"))
        playlist = recording_path / "playlist.m3u8"
        video = recording_path / "output.mp4"

        print(f"   📹 output.mp4: {'✅' if video.exists() else '❌'}")
        print(f"   📝 playlist.m3u8: {'✅' if playlist.exists() else '❌'}")
        print(f"   🎞️  Segments: {len(segments)}")

        if segments:
            total_size = sum(seg.stat().st_size for seg in segments)
            print(f"   💾 Total size: {total_size / 1024 / 1024:.2f} MB")
    else:
        print(f"   ❌ Directory does not exist")

    print()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("❌ Usage: python monitor_hls_segments.py <session_id>")
        print()
        print("Example:")
        print("  python monitor_hls_segments.py 12345678-1234-1234-1234-123456789abc")
        sys.exit(1)

    session_id = sys.argv[1]

    # Check local path first
    check_local_path(session_id)

    # Start monitoring
    monitor_session(session_id)
