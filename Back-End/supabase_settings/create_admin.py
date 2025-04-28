import supabase
from supabase import create_client, Client
from supabase import ClientOptions
from env import ENVIRONMENT

admin_supabase: Client = create_client(
    ENVIRONMENT.SUPABASE_URL, 
    ENVIRONMENT.SUPABASE_ADMIN_KEY,
    options= ClientOptions(
        auto_refresh_token=False,
        persist_session=False,
    )
)
