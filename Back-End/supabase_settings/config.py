from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_STORAGE_URL: str
    SUPABASE_KEY: str
    SUPABASE_PATIENT_VIDEO_BUCKET: str

    class Config:
        env_file = ".env"

settings = Settings()
