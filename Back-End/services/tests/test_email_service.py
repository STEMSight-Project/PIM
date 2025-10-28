from unittest.mock import Mock


def test_email_service_send_confirmation_returns_true(
    repo_root, fake_core_modules, monkeypatch
):
    # Load module
    from Back_End.services.services.tests.conftest import load_service_module

    email_mod = load_service_module(
        repo_root, "email_service.py", "email_service")
    # create a dummy client
    dummy_client = Mock()
    svc = email_mod.EmailService(dummy_client)
    assert svc.send_confirmation_email(
        "someone@example.com", "token123") is True


def test_email_service_singleton_export(repo_root, fake_core_modules):
    from Back_End.services.services.tests.conftest import load_service_module

    email_mod = load_service_module(
        repo_root, "email_service.py", "email_service")
    # the module exports email_service instance
    assert hasattr(email_mod, "email_service")
