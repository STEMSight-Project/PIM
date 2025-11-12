Testing overview - Back-End

This folder contains pytest-based tests for the Back-End application. The aim
is to keep tests fast, hermetic, and descriptive for reviewers. The files are
organized by layer:

- tests/api_router/  -> Integration-style tests of FastAPI endpoints (use TestClient)
- tests/services/    -> Unit tests for service/business logic (mock Supabase/FFmpeg)
- tests/services/streaming/ -> Focused tests for recording/streaming logic

How to run
----------
From the project root (Windows PowerShell):

```powershell
cd Back-End
pytest -q
```

Testing features demonstrated
----------------------------
- Lightweight filesystem fixtures (tmp_path) to emulate HLS directories and
  media files without external storage.
- Mocking of external services (Supabase client, WebRTC service) so tests run
  deterministically and offline.
- Async tests using pytest-asyncio for service methods that are async.
- Small smoke tests are included to make it obvious in the PR that tests
  are present; replace smoke tests with real assertions as CI is wired up.

Reviewer notes
--------------
- The tests intentionally avoid running real FFmpeg or opening devices. They
  instead mock interfaces and verify control flow.
- When enabling end-to-end CI, consider adding an integration test job that
  runs against a staging Supabase instance or a local emulator.
