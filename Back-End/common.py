import logging
from supabase_settings.supabase_client import get_supabase_client

logger = logging.getLogger("uvicorn.error")
supabase = get_supabase_client()