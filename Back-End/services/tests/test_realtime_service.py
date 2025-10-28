import pytest


@pytest.mark.asyncio
async def test_realtime_service_smoke(repo_root, fake_core_modules):
    from Back_End.services.tests.conftest import load_service_module

    realtime_mod = load_service_module(
        repo_root, "realtime/realtime_service.py", "realtime_service"
    )
    # basic smoke: module loads and exports RealtimeService
    assert hasattr(realtime_mod, "RealtimeService")
