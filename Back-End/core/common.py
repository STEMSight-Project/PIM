import logging
from supabase_settings.create_client import SUPABASE, SUPABASE_AUTH
from supabase_settings.create_admin import (
    SUPABASE_ADMIN,
)  # Used by patient.py and auth.py

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
supabase_auth = SUPABASE_AUTH
admin_supabase = SUPABASE_ADMIN 
# admin_supabase is available for import
