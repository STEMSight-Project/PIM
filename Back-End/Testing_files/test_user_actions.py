import asyncio
from datetime import datetime
import pytest
from unittest.mock import patch, MagicMock

from user_actions import log_patient_action, is_admin


class DummyResult:
    def __init__(self, data):
        self.data = data


@pytest.mark.asyncio
async def test_log_patient_action_success(monkeypatch):
    mock_table = MagicMock()
    mock_table.insert.return_value.execute.return_value = DummyResult(data=[{"id": "1"}])

    with patch("user_actions.supabase") as mock_supabase:
        mock_supabase.table.return_value = mock_table
        ok = await log_patient_action("user1", "patient1", "view", metadata={"k": "v"})
        assert ok is True
        mock_table.insert.assert_called_once()


@pytest.mark.asyncio
async def test_log_patient_action_failure(monkeypatch):
    mock_table = MagicMock()
    mock_table.insert.return_value.execute.return_value = DummyResult(data=None)

    with patch("user_actions.supabase") as mock_supabase:
        mock_supabase.table.return_value = mock_table
        ok = await log_patient_action("user1", "patient1", "view")
        assert ok is False


def test_is_admin_true():
    user = {"user_metadata": {"role": "admin"}}
    assert is_admin(user) is True


def test_is_admin_false():
    user = {"user_metadata": {"role": "user"}}
    assert is_admin(user) is False


def test_audit_logs_endpoint_access_control(monkeypatch):
    from fastapi import FastAPI
    from fastapi.testclient import TestClient
    from unittest.mock import patch, MagicMock

    import user_actions

    app = FastAPI()

    app.dependency_overrides[user_actions.router_auth_dependency] = lambda: {"id": "user1", "user_metadata": {"role": "user"}}

    app.include_router(user_actions.router, prefix="/user-actions")

    client = TestClient(app)

    mock_query = MagicMock()
    mock_query.eq.return_value = mock_query
    mock_query.gte.return_value = mock_query
    mock_query.lte.return_value = mock_query
    mock_query.order.return_value = mock_query
    mock_query.execute.return_value = MagicMock(data=[])

    mock_table = MagicMock()
    mock_table.select.return_value = mock_query

    with patch("user_actions.supabase") as mock_supabase:
        mock_supabase.table.return_value = mock_table

        # Test non-admin user is forbidden (admin-only endpoint)
        response = client.get("/user-actions/audit-logs")
        assert response.status_code == 403

        # Now override as admin and expect success
        app.dependency_overrides[user_actions.router_auth_dependency] = lambda: {
            "id": "admin1",
            "user_metadata": {"role": "admin"},
        }
        response = client.get("/user-actions/audit-logs")
        assert response.status_code == 200
        assert response.json() == []
