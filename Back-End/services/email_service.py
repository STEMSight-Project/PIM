# services/email_service.py
from core.common import logger
from core.env import ENVIRONMENT
from supabase import Client
from typing import Optional

import smtplib
from email.message import EmailMessage
from email.headerregistry import Address
from email.utils import make_msgid
from services import email_service

# Use the admin client for sending system emails
from core.common import admin_supabase

class EmailService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def send_confirmation_email(self, email: str, token: str) -> bool:
        # Compose the confirmation email
        confirm_url = f"{ENVIRONMENT.NEXT_PUBLIC_API_URL}/verify-email?token={token}"
        confirmMsg = EmailMessage()
        confirmMsg['Subject'] = 'Confirm your STEMSight account'
        confirmMsg['From'] = Address("STEMSight", "no-reply", "stemsight.com")
        confirmMsg['To'] = Address("Burner", "corbinwest", "csus.edu")
        confirmMsg.set_content("""\Welcome to STEMSight!\n
                       \nPlease confirm your email by clicking the link below:\n
                       \n{confirm_url}\n
                       \nIf you did not sign up, please ignore this email.""")
        confirmMsg.add_alternative("""\<html>
          <head></head>
          <body>
            <p>\Welcome to STEMSight!</p>
            <p>Please confirm your email by clicking the link below:</p>
            <p><a href="{confirm_url}">{confirm_url}</a></p>
            <p>If you did not sign up, please ignore this email.</p>
          </body>
        </html>""", subtype='html')
        try:
            # Supabase built-in email (if available) or use SMTP integration here
            # You may need to integrate with a 3rd party (SendGrid, Mailgun, etc.)
            logger.info(f"Sending confirmation email to {email}")
            print("Hello world")
            with smtplib.SMTP('localhost') as smtp:
                smtp.send_message(confirmMsg)
            # Example: self.supabase.auth.api.send_email(email, subject, content)
            # For now, just log and return True
            return True
        except Exception as e:
            logger.error(f"Failed to send confirmation email to {email}: %s", e)
            return False

email_service = EmailService(admin_supabase)