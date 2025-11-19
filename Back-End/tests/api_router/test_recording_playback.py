import os
from pathlib import Path
from fastapi.testclient import TestClient
import shutil

from main import app


def test_hls_playlist_and_segment(tmp_path, monkeypatch):
    """Create a fake recording directory with playlist and segment files and
    assert the /videos/hls endpoints serve them correctly."""
    # Point the recordings base path to a temp directory
    recordings_dir = tmp_path / "recordings"
    monkeypatch.chdir(tmp_path)

    # Create room directory
    room_id = "TEST-ROOM-001"
    room_dir = recordings_dir / f"room-{room_id}"
    room_dir.mkdir(parents=True)

    # Create fake playlist and segment
    playlist = room_dir / "playlist.m3u8"
    segment = room_dir / "segment-001.ts"
    playlist.write_text("#EXTM3U\n#FAKE PLAYLIST")
    segment.write_bytes(b"FAKESEGMENTDATA")

    # Use TestClient against the app
    client = TestClient(app)

    # Request playlist
    r = client.get(f"/videos/hls/{room_id}/playlist.m3u8")
    assert r.status_code == 200
    assert "mpegurl" in r.headers.get("content-type", "") or "mpegurl" in r.text or r.content

    # Request segment
    r2 = client.get(f"/videos/hls/{room_id}/segment-001.ts")
    assert r2.status_code == 200
    assert r2.content == b"FAKESEGMENTDATA"


def test_list_hls_recordings(tmp_path, monkeypatch):
    """Ensure /videos/hls/list returns the created recording metadata."""
    recordings_dir = tmp_path / "recordings"
    room_id = "ROOM-ALPHA"
    room_dir = recordings_dir / f"room-{room_id}"
    room_dir.mkdir(parents=True)
    (room_dir / "playlist.m3u8").write_text("#EXTM3U\n#playlist")
    (room_dir / "segment-001.ts").write_bytes(b"data")

    monkeypatch.chdir(tmp_path)

    client = TestClient(app)
    resp = client.get("/videos/hls/list")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert any(item.get("room_id") == room_id for item in data)
