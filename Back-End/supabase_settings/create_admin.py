from supabase import create_client, Client
from supabase import ClientOptions
from core.env import ENVIRONMENT

SUPABASE_ADMIN: Client = create_client(
    ENVIRONMENT.SUPABASE_URL,
    ENVIRONMENT.SUPABASE_ADMIN_KEY,
    options=ClientOptions(
        auto_refresh_token=False,
        persist_session=False,
    ),
)
