import logging
from supabase_settings.create_client import (
    SUPABASE,
    SUPABASE_AUTH,
    create_supabase_async_client,
)
from supabase_settings.create_admin import (
    SUPABASE_ADMIN,
)  # Used by patient.py and auth.py

# Ensure logger is configured with a handler to avoid "No handlers could be found"
# when modules import `logger` but the application hasn't configured logging yet.
logger = logging.getLogger("uvicorn.error")
if not logger.handlers:
    # Small, safe default configuration for libraries importing this module.
    logging.basicConfig(level=logging.INFO)

supabase = SUPABASE
supabase_auth = SUPABASE_AUTH
admin_supabase = SUPABASE_ADMIN 
# Async client factory (keep as a function reference rather than calling it here).
# Some parts of the codebase create an async client per-task or per-request;
# importing and calling an async client factory at module import time can
# produce event-loop issues. Provide the factory reference so callers can
# instantiate when appropriate.
supabase_async = create_supabase_async_client
# admin_supabase is available for import
