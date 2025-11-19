from fastapi.testclient import TestClient
from pathlib import Path
import os

from test_app import app


def test_get_recording_status_not_found(tmp_path, monkeypatch):
    """GET status for non-existent room should return 404."""
    # Ensure we are in a temporary directory so RECORDINGS_BASE_PATH is empty
    monkeypatch.chdir(tmp_path)
    client = TestClient(app)

    resp = client.get("/videos/hls/NO-SUCH-ROOM/status")
    assert resp.status_code == 404
    assert resp.json().get("detail") == "Recording not found"


def test_delete_nonexistent_recording(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    client = TestClient(app)

    resp = client.delete("/videos/hls/NO-SUCH-ROOM")
    assert resp.status_code == 404
    assert resp.json().get("detail") == "Recording not found"
