from pydantic_settings import BaseSettings

class Env(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_STORAGE_URL: str
    SUPABASE_KEY: str
    SUPABASE_PATIENT_VIDEO_BUCKET: str
    REDIRECT_PASSWORD_URL: str
    NEXT_PUBLIC_API_URL: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


ENVIRONMENT = Env()