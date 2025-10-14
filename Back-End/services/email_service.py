# services/email_service.py
from core.common import logger
from core.env import ENVIRONMENT
from supabase import Client
from typing import Optional

# Use the admin client for sending system emails
from core.common import admin_supabase

class EmailService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def send_confirmation_email(self, email: str, token: str) -> bool:
        # Compose the confirmation email
        confirm_url = f"{ENVIRONMENT.NEXT_PUBLIC_API_URL}/verify-email?token={token}"
        subject = "Confirm your STEMSight account"
        content = f"""
        Welcome to STEMSight!\n\nPlease confirm your email by clicking the link below:\n{confirm_url}\n\nIf you did not sign up, please ignore this email.
        """
        try:
            # Supabase built-in email (if available) or use SMTP integration here
            # This is a placeholder for actual email sending logic
            # You may need to integrate with a 3rd party (SendGrid, Mailgun, etc.)
            logger.info(f"Sending confirmation email to {email}")
            # Example: self.supabase.auth.api.send_email(email, subject, content)
            # For now, just log and return True
            return True
        except Exception as e:
            logger.error(f"Failed to send confirmation email to {email}: %s", e)
            return False

email_service = EmailService(admin_supabase)
