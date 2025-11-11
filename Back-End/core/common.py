import logging
from supabase_settings.create_client import SUPABASE, SUPABASE_AUTH
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
# admin_supabase is available for import
