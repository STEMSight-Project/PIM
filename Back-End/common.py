import logging
from supabase_settings.create_client import SUPABASE

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
