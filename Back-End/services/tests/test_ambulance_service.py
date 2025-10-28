import pytest


@pytest.mark.asyncio
async def test_get_all_ambulances(repo_root, fake_core_modules, monkeypatch):
    # prepare fake data
    data_map = {
        "ambulances": [
            {"id": "a1", "ambulance_number": "AMB-001"},
            {"id": "a2", "ambulance_number": "AMB-002"},
        ]
    }
    fake_core_modules.supabase = fake_core_modules.supabase = __import__(
        "types"
    ).SimpleNamespace()
    # Use the helper to create a mock supabase consistent with conftest
    from Back_End.services.tests.conftest import (
        _make_mock_supabase,  # local import for the helper
    )

    fake_core_modules.supabase = _make_mock_supabase(data_map)

    ambulance_mod = load_and_get_module(
        repo_root, "ambulance_service.py", "ambulance_service"
    )
    AmbulanceService = ambulance_mod.AmbulanceService

    results = await AmbulanceService.get_all_ambulances()
    assert isinstance(results, list)
    assert len(results) == 2
    assert results[0]["id"] == "a1"


@pytest.mark.asyncio
async def test_get_ambulance_by_id_and_create(
    repo_root, fake_core_modules, monkeypatch
):
    from Back_End.services.tests.conftest import _make_mock_supabase

    data_map = {
        "ambulances": [{"id": "a1", "ambulance_number": "AMB-001"}],
        "cameras": [{"id": "c1", "ambulance_id": "a1", "name": "cam1"}],
        "ambulance_streaming_sessions": [],
    }
    fake_core_modules.supabase = _make_mock_supabase(data_map)

    ambulance_mod = load_and_get_module(
        repo_root, "ambulance_service.py", "ambulance_service"
    )
    AmbulanceService = ambulance_mod.AmbulanceService

    ambulance = await AmbulanceService.get_ambulance_by_id("a1")
    assert ambulance["id"] == "a1"

    new_data = {"ambulance_number": "NEW-001"}
    created = await AmbulanceService.create_ambulance(new_data)
    assert created["id"].startswith("created-id")


@pytest.mark.asyncio
async def test_delete_ambulance_with_active_sessions_raises(
    repo_root, fake_core_modules
):
    from Back_End.services.tests.conftest import _make_mock_supabase

    data_map = {
        "ambulance_streaming_sessions": [
            {"id": "s1", "ambulance_id": "del-1", "is_active": True}
        ],
    }
    fake_core_modules.supabase = _make_mock_supabase(data_map)

    ambulance_mod = load_and_get_module(
        repo_root, "ambulance_service.py", "ambulance_service"
    )
    AmbulanceService = ambulance_mod.AmbulanceService

    with pytest.raises(Exception):
        await AmbulanceService.delete_ambulance("del-1")


# Helper used inside this test module
def load_and_get_module(repo_root, rel_path, name):
    # import the loader from conftest to respect the repo layout
    from Back_End.services.tests.conftest import load_service_module

    return load_service_module(repo_root, rel_path, name)
