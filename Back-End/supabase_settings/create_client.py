from supabase import create_client, Client
from supabase.lib.client_options import ClientOptions
from core.env import ENVIRONMENT

# Client for auth operations - needs session management
SUPABASE_AUTH: Client = create_client(
    supabase_url=ENVIRONMENT.SUPABASE_URL,
    supabase_key=ENVIRONMENT.SUPABASE_KEY,
    options=ClientOptions(auto_refresh_token=True, persist_session=True),
)

# Client for data operations - stateless
SUPABASE: Client = create_client(
    supabase_url=ENVIRONMENT.SUPABASE_URL,
    supabase_key=ENVIRONMENT.SUPABASE_KEY,
    options=ClientOptions(auto_refresh_token=False, persist_session=False),
)
