import pytest


@pytest.mark.asyncio
async def test_get_all_recordings_format(repo_root, fake_core_modules, monkeypatch):
    from Back_End.services.tests.conftest import (
        _make_mock_supabase,
        load_service_module,
    )

    data_map = {
        "ambulance_session_recordings": [
            {
                "id": "r1",
                "session_id": "s1",
                "storage_url": "https://cdn/example.mp4",
                "duration": 120,
                "file_size": 1024,
                "created_at": "2025-01-01T12:00:00Z",
                "session_start": "2025-01-01T11:00:00Z",
                "session_end": "2025-01-01T11:02:00Z",
                "ambulance_streaming_sessions": {
                    "session_name": "Test Session",
                    "ambulance_id": "a1",
                    "ambulances": {"ambulance_number": "AMB-1"},
                },
            }
        ]
    }
    fake_core_modules.supabase = _make_mock_supabase(data_map)
    video_mod = load_service_module(repo_root, "video_service.py", "video_service")
    recordings = await video_mod.VideoService.get_all_recordings()
    assert isinstance(recordings, list)
    assert recordings[0]["id"] == "r1"
    assert recordings[0]["public_video_url"] == "https://cdn/example.mp4"
