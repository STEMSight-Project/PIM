import logging
from supabase_settings.create_client import SUPABASE, SUPABASE_AUTH

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
supabase_auth = SUPABASE_AUTH
# admin_supabase is available for import
