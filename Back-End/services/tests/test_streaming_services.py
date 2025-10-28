import pytest


@pytest.mark.asyncio
async def test_streaming_recording_service_imports(repo_root, fake_core_modules):
    from Back_End.services.tests.conftest import load_service_module

    recording_mod = load_service_module(
        repo_root, "streaming/recording_service.py", "recording_service"
    )
    # spot check that expected symbols exist
    assert hasattr(recording_mod, "RecordingService") or hasattr(
        recording_mod, "get_recordings_by_session"
    )


@pytest.mark.asyncio
async def test_streaming_room_service_imports(repo_root, fake_core_modules):
    from Back_End.services.tests.conftest import load_service_module

    room_mod = load_service_module(
        repo_root, "streaming/room_service.py", "room_service"
    )
    assert hasattr(room_mod, "RoomService") or hasattr(room_mod, "create_room")
