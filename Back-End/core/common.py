import logging
from supabase_settings.create_client import (
    SUPABASE,
    SUPABASE_AUTH,
    create_supabase_async_client,
)
from supabase_settings.create_admin import (
    SUPABASE_ADMIN,
)  # Used by patient.py and auth.py

logger = logging.getLogger("uvicorn.error")
supabase = SUPABASE
supabase_auth = SUPABASE_AUTH
supabase_async = create_supabase_async_client  # Function reference, not call
admin_supabase = SUPABASE_ADMIN

# Suppress excessive Supabase Realtime logging (heartbeat spam)
logging.getLogger("realtime._async.client").setLevel(logging.WARNING)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("hpack.hpack").setLevel(logging.WARNING)
logging.getLogger("websockets").setLevel(logging.WARNING)
