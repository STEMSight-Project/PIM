from supabase import create_client, Client
from supabase.lib.client_options import ClientOptions
from env import ENVIRONMENT

SUPABASE: Client = create_client(
    supabase_url=ENVIRONMENT.SUPABASE_URL,
    supabase_key=ENVIRONMENT.SUPABASE_KEY,
    # the server, not the SDK, will refresh – keep it stateless
    options=ClientOptions(auto_refresh_token=False, persist_session=False),
)