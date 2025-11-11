"""Environment configuration for the backend.

This module attempts to import BaseSettings from the newer `pydantic-settings`
package (pydantic v2 / settings management). If that's not available we fall
back to pydantic v1's `pydantic.BaseSettings` for compatibility. This is a
low-risk change to improve compatibility across environments.
"""

try:
    from pydantic_settings import BaseSettings
except Exception:
    # Fall back to pydantic v1 compatible import
    from pydantic import BaseSettings


class Env(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_STORAGE_URL: str
    SUPABASE_KEY: str
    SUPABASE_ADMIN_KEY: str
    SUPABASE_PATIENT_VIDEO_BUCKET: str
    JWT_SECRET: str
    REDIRECT_PASSWORD_URL: str
    NEXT_PUBLIC_API_URL: str
    SB_ADMIN_ACCOUNT:str
    SB_ADMIN_PASSWORD:str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Instantiate once for import by other modules. If environment variables are
# missing this will raise during application start which is the desired
# behavior for a misconfigured environment.
ENVIRONMENT = Env()