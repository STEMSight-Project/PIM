import pytest


@pytest.mark.asyncio
async def test_get_email_client_raises_when_env_missing(
    repo_root, fake_core_modules, monkeypatch
):
    # set env to missing values
    sys_mod = __import__("sys")
    core_env = sys.modules.get("core.env")
    setattr(
        core_env,
        "ENVIRONMENT",
        type(
            "ENV", (), {"MAIL_USERNAME": None, "MAIL_PASSWORD": None, "MAIL_FROM": None}
        )(),
    )

    from Back_End.services.tests.conftest import load_service_module

    pw_mod = load_service_module(
        repo_root, "password_reset_service.py", "password_reset_service"
    )
    with pytest.raises(ValueError):
        pw_mod.get_email_client()


@pytest.mark.asyncio
async def test_send_password_reset_email_flow(
    repo_root, fake_core_modules, monkeypatch
):
    # monkeypatch store_reset_token to avoid DB calls and get_email_client to a Fake FastMail
    from Back_End.services.tests.conftest import load_service_module

    pw_mod = load_service_module(
        repo_root, "password_reset_service.py", "password_reset_service"
    )

    async def fake_store(email, token):
        return True

    class FakeFastMail:
        def __init__(self, conf=None):
            pass

        async def send_message(self, message):
            return True

    monkeypatch.setattr(pw_mod, "store_reset_token", fake_store)
    monkeypatch.setattr(pw_mod, "get_email_client", lambda: FakeFastMail())

    ok = await pw_mod.send_password_reset_email("u@example.com", "User")
    assert ok is True
