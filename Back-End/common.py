import logging
from supabase_settings.create_client import SUPABASE
from supabase_settings.create_admin import admin_supabase

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
admin_supabase = admin_supabase
