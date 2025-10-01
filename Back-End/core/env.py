from pydantic_settings import BaseSettings
from typing import Optional

class Env(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_STORAGE_URL: str
    SUPABASE_KEY: str
    SUPABASE_ADMIN_KEY: str
    SUPABASE_PATIENT_VIDEO_BUCKET: str
    JWT_SECRET: str
    REDIRECT_PASSWORD_URL: str
    NEXT_PUBLIC_API_URL: str
    SB_ADMIN_ACCOUNT: str
    SB_ADMIN_PASSWORD: str
    
    # Email Configuration
    MAIL_USERNAME: Optional[str] = None
    MAIL_PASSWORD: Optional[str] = None
    MAIL_FROM: Optional[str] = None
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_PORT: int = 587
    MAIL_FROM_NAME: str = "STEMSight"
    FRONTEND_URL: str = "http://localhost:3000"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        extra = "ignore"  # Ignore extra fields in .env file


ENVIRONMENT = Env()