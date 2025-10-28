import importlib.util
import sys
from pathlib import Path
from types import ModuleType
from unittest.mock import Mock

import pytest


class FakeResult:
    def __init__(self, data=None):
        self.data = data

    def __repr__(self):
        return f"<FakeResult data={self.data!r}>"


class MockQuery:
    def __init__(self, table_name=None, data_map=None):
        self.table_name = table_name
        self._data_map = data_map or {}
        self._return_single = False

    def select(self, *args, **kwargs):
        return self

    def eq(self, *args, **kwargs):
        return self

    def order(self, *args, **kwargs):
        return self

    def insert(self, payload):
        created = payload.copy()
        if "id" not in created:
            created["id"] = "created-id-1"
        return MockQueryResult([created])

    def update(self, payload):
        return MockQueryResult([payload.copy()])

    def delete(self):
        return MockQueryResult([{"deleted": True}])

    def single(self):
        self._return_single = True
        return self

    def not_(self):
        return self

    def is_(self, *args, **kwargs):
        return self

    def execute(self):
        data = self._data_map.get(self.table_name)
        if data is None:
            return FakeResult([])
        return FakeResult(data)


class MockQueryResult:
    def __init__(self, data):
        self.data = data

    def execute(self):
        return FakeResult(self.data)


@pytest.fixture
def repo_root():
    """
    Returns the top of the services folder.
    Assumes pytest is run from inside the services/ folder.
    """
    return Path(__file__).resolve().parent.parent


def _make_mock_supabase(data_map=None):
    data_map = data_map or {}

    def table_side_effect(table_name):
        return MockQuery(table_name=table_name, data_map=data_map)

    mock = Mock()
    mock.table.side_effect = table_side_effect
    mock.auth = Mock()
    return mock


@pytest.fixture(autouse=True)
def fake_core_modules(monkeypatch, repo_root):
    """
    Insert fake core.* modules so internal imports succeed.
    Tests can modify attributes like supabase, admin_supabase, logger if needed.
    """
    core = ModuleType("core")
    core_common = ModuleType("core.common")
    core_env = ModuleType("core.env")

    core_common.supabase = _make_mock_supabase()
    core_common.admin_supabase = _make_mock_supabase()
    core_common.logger = Mock()
    core_env.ENVIRONMENT = type(
        "ENV",
        (),
        {"NEXT_PUBLIC_API_URL": "http://api", "FRONTEND_URL": "http://frontend"},
    )()

    sys_modules_backup = {}
    for name, module in (
        ("core", core),
        ("core.common", core_common),
        ("core.env", core_env),
    ):
        sys_modules_backup[name] = sys.modules.get(name)
        sys.modules[name] = module

    yield core_common  # <-- just yield the module itself, do NOT call it

    # Restore previous sys.modules state
    for name, prev in sys_modules_backup.items():
        if prev is None:
            del sys.modules[name]
        else:
            sys.modules[name] = prev


def load_service_module(repo_root: Path, rel_path: str, module_name: str):
    """
    Load a module from the local services directory.
    rel_path examples:
        'ai/ai_detection_service.py'
        'streaming/video_stream_service.py'
    """
    file_path = repo_root / rel_path  # Do not prepend "services" again
    spec = importlib.util.spec_from_file_location(module_name, str(file_path))
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module
