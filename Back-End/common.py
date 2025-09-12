import logging
from supabase_settings.create_client import SUPABASE, SUPABASE_AUTH
from supabase_settings.create_admin import admin_supabase

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
supabase_auth = SUPABASE_AUTH
admin_supabase = admin_supabase
