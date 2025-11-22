import sys
import os
import pathlib
import pytest
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, Mock

# Ensure project root is on sys.path so imports succeed when running a single test file
ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from fastapi import FastAPI
import importlib
import importlib.util
from pathlib import Path

# Try normal import first; if running a single test file, pythonpath may not be set
try:
    auth_module = importlib.import_module("api_router.auth")
    auth_router = auth_module.router
except ModuleNotFoundError:
    # Fall back to loading the module from its file location
    ROOT = Path(__file__).resolve().parents[2]
    auth_path = ROOT / "api_router" / "auth.py"
    spec = importlib.util.spec_from_file_location("test_auth", str(auth_path))
    auth_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(auth_module)
    auth_router = getattr(auth_module, "router")
import services.password_reset_service as prs
from core.common import admin_supabase

app = FastAPI()
app.include_router(auth_router, prefix="/auth")
client = TestClient(app)


def test_request_password_reset_endpoint_success(monkeypatch):
    # Patch send_password_reset_email to return True
    monkeypatch.setattr(auth_module, "send_password_reset_email", AsyncMock(return_value=True))
    # Patch admin_supabase to provide no user (should not error)
    admin_supabase.auth.admin.list_users = Mock(return_value=[])

    resp = client.post("/auth/request-password-reset", json={"email": "doc@example.com"})
    assert resp.status_code == 200
    assert "password reset link has been sent" in resp.json()["message"].lower()


def test_request_password_reset_endpoint_failure(monkeypatch):
    # Patch send_password_reset_email to return False (simulate error)
    monkeypatch.setattr(auth_module, "send_password_reset_email", AsyncMock(return_value=False))
    admin_supabase.auth.admin.list_users = Mock(return_value=[])

    resp = client.post("/auth/request-password-reset", json={"email": "doc@example.com"})
    assert resp.status_code == 200
    assert "password reset link has been sent" in resp.json()["message"].lower()


@pytest.mark.asyncio
async def test_confirm_password_reset_success(monkeypatch):
    # Prepare a sample reset record
    reset_record = {"user_id": "user-1", "token": "tok", "expires_at": "2099-01-01T00:00:00Z"}
    monkeypatch.setattr(auth_module, "verify_reset_token", AsyncMock(return_value=reset_record))
    # Mock admin_supabase update and mark token
    admin_supabase.auth.admin.update_user_by_id = Mock()
    monkeypatch.setattr(auth_module, "mark_token_used", AsyncMock(return_value=True))

    resp = client.post("/auth/confirm-password-reset", json={"token": "tok", "new_password": "Abcd1234!"})
    assert resp.status_code == 200
    assert "password reset successfully" in resp.json()["message"].lower()
    admin_supabase.auth.admin.update_user_by_id.assert_called()


@pytest.mark.asyncio
async def test_confirm_password_reset_invalid_token(monkeypatch):
    monkeypatch.setattr(auth_module, "verify_reset_token", AsyncMock(return_value=None))

    resp = client.post("/auth/confirm-password-reset", json={"token": "bad", "new_password": "Abcd1234!"})
    assert resp.status_code == 400
    assert "invalid or expired reset token" in resp.json()["detail"].lower()


def test_get_email_client_env_missing(monkeypatch):
    # Temporarily modify ENV values to simulate missing env vars
    from core import env as core_env

    original_env = core_env.ENVIRONMENT
    # Make a minimal object with None values
    class Blank:
        MAIL_USERNAME = None
        MAIL_PASSWORD = None
        MAIL_FROM = None
        MAIL_PORT = None
        MAIL_SERVER = None
        MAIL_FROM_NAME = None

    # Patch the ENV variable used by the password_reset_service module directly
    monkeypatch.setattr(prs, "ENV", Blank())

    with pytest.raises(ValueError):
        prs.get_email_client()

    # Restore environment
    # Restore environment
    monkeypatch.setattr(prs, "ENV", original_env)
