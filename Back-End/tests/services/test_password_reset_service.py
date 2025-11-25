import pytest
import asyncio
from datetime import datetime, timedelta
from unittest.mock import patch, AsyncMock, Mock

import services.password_reset_service as prs


@pytest.mark.asyncio
async def test_store_reset_token_no_user_found(monkeypatch):
    # admin list users returns empty -> should return True to avoid enumeration
    admin_mock = Mock()
    admin_mock.auth.admin.list_users.return_value = []

    monkeypatch.setattr(prs, "supabase", Mock())
    monkeypatch.setattr("core.common.admin_supabase", admin_mock)

    res = await prs.store_reset_token("missing@example.com", "token123")
    assert res is True


@pytest.mark.asyncio
async def test_store_reset_token_with_user(monkeypatch):
    # admin returns a user and supabase insert is called
    fake_user = Mock()
    fake_user.email = "found@example.com"
    fake_user.id = "user-123"
    admin_mock = Mock()
    admin_mock.auth.admin.list_users.return_value = [fake_user]

    mock_supabase = Mock()
    mock_supabase.table.return_value.insert.return_value.execute.return_value = {"data": [{"id": "pr-1"}]}

    monkeypatch.setattr("core.common.admin_supabase", admin_mock)
    monkeypatch.setattr(prs, "supabase", mock_supabase)

    res = await prs.store_reset_token("found@example.com", "token123")
    assert res is True
    mock_supabase.table.assert_called_with("password_resets")
    mock_supabase.table.return_value.insert.assert_called()


@pytest.mark.asyncio
async def test_verify_reset_token_valid(monkeypatch):
    now = datetime.utcnow()
    expires_at = (now + timedelta(hours=1)).isoformat()
    mock_result = Mock()
    mock_result.data = [{"token": "tok", "expires_at": expires_at, "user_id": "u1"}]
    monkeypatch.setattr(prs, "supabase", Mock())
    prs.supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_result

    record = await prs.verify_reset_token("tok")
    assert record is not None
    assert record["token"] == "tok"


@pytest.mark.asyncio
async def test_verify_reset_token_expired(monkeypatch):
    now = datetime.utcnow()
    expires_at = (now - timedelta(hours=1)).isoformat()
    mock_result = Mock()
    mock_result.data = [{"token": "tok", "expires_at": expires_at, "user_id": "u1"}]
    monkeypatch.setattr(prs, "supabase", Mock())
    prs.supabase.table.return_value.select.return_value.eq.return_value.eq.return_value.execute.return_value = mock_result

    record = await prs.verify_reset_token("tok")
    assert record is None


@pytest.mark.asyncio
async def test_mark_token_used_success(monkeypatch):
    mock_supabase = Mock()
    mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value = {"data": [{"id": "pr-1"}]}
    monkeypatch.setattr(prs, "supabase", mock_supabase)

    res = await prs.mark_token_used("tok")
    assert res is True
    mock_supabase.table.assert_called_with("password_resets")


@pytest.mark.asyncio
async def test_send_password_reset_email_success(monkeypatch):
    # Mock store reset token to succeed
    monkeypatch.setattr(prs, "store_reset_token", AsyncMock(return_value=True))

    # Mock get_email_client to return a dummy client that can send message
    fake_client = Mock()
    fake_client.send_message = AsyncMock(return_value=None)
    monkeypatch.setattr(prs, "get_email_client", Mock(return_value=fake_client))

    res = await prs.send_password_reset_email("test@example.com", "Tester")
    assert res is True


@pytest.mark.asyncio
async def test_send_password_reset_email_send_fail(monkeypatch):
    monkeypatch.setattr(prs, "store_reset_token", AsyncMock(return_value=True))
    fake_client = Mock()
    fake_client.send_message = AsyncMock(side_effect=Exception("SMTP fail"))
    monkeypatch.setattr(prs, "get_email_client", Mock(return_value=fake_client))

    res = await prs.send_password_reset_email("test@example.com", "Tester")
    assert res is False
