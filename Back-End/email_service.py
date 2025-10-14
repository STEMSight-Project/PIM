from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
import os
import uuid
from typing import Optional
from common import supabase, logger
from datetime import datetime, timedelta

class EmailConfig:
    MAIL_USERNAME = os.getenv("MAIL_USERNAME")
    MAIL_PASSWORD = os.getenv("MAIL_PASSWORD") 
    MAIL_FROM = os.getenv("MAIL_FROM")
    MAIL_PORT = int(os.getenv("MAIL_PORT", 587))
    MAIL_SERVER = os.getenv("MAIL_SERVER")
    MAIL_FROM_NAME = os.getenv("MAIL_FROM_NAME", "STEMSight")

conf = ConnectionConfig(
    MAIL_USERNAME=EmailConfig.MAIL_USERNAME,
    MAIL_PASSWORD=EmailConfig.MAIL_PASSWORD,
    MAIL_FROM=EmailConfig.MAIL_FROM,
    MAIL_PORT=EmailConfig.MAIL_PORT,
    MAIL_SERVER=EmailConfig.MAIL_SERVER,
    MAIL_FROM_NAME=EmailConfig.MAIL_FROM_NAME,
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

fast_mail = FastMail(conf)

async def send_confirmation_email(email: str, confirmation_token: str, user_name: str = "User"):
    """Send confirmation email to new user"""
    try:
        frontend_url = os.getenv("FRONTEND_URL", "http://localhost:3000")
        confirmation_url = f"{frontend_url}/confirm-email?token={confirmation_token}"
        
        html_template = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Confirm your STEMSight account</title>
        </head>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="text-align: center; margin-bottom: 30px;">
                <h1 style="color: #333;">Welcome to STEMSight!</h1>
            </div>
            
            <div style="background-color: #f9f9f9; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                <p>Hello {user_name},</p>
                <p>Thank you for signing up with STEMSight! To complete your registration, please confirm your email address by clicking the button below:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{confirmation_url}" 
                       style="background-color: #007bff; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold;">
                        Confirm Email Address
                    </a>
                </div>
                
                <p>If the button doesn't work, you can also copy and paste this link into your browser:</p>
                <p style="word-break: break-all; color: #666;">{confirmation_url}</p>
                
                <p style="margin-top: 30px; font-size: 12px; color: #666;">
                    This link will expire in 24 hours for security reasons.
                </p>
            </div>
            
            <div style="text-align: center; font-size: 12px; color: #666; border-top: 1px solid #eee; padding-top: 20px;">
                                <p>If you didn't create an account with STEMSight, please ignore this email.</p>
                <p>&copy; 2024 STEMSight. All rights reserved.</p>
            </div>
        </body>
        </html>
        """
        
        message = MessageSchema(
            subject="Please confirm your STEMSight account",
            recipients=[email],
            body=html_template,
            subtype=MessageType.html
        )
        
        await fast_mail.send_message(message)
        logger.info(f"Confirmation email sent to {email}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send confirmation email to {email}: {str(e)}")
        return False

def generate_confirmation_token() -> str:
    """Generate a unique confirmation token"""
    return str(uuid.uuid4())

async def store_confirmation_token(user_id: str, email: str, token: str) -> bool:
    """Store confirmation token in Supabase"""
    try:
        # You'll need to create this table in Supabase
        result = supabase.table("email_confirmations").insert({
            "user_id": user_id,
            "email": email,
            "token": token,
            "expires_at": (datetime.utcnow() + timedelta(hours=24)).isoformat(),
            "confirmed": False
        }).execute()
        
        return True
    except Exception as e:
        logger.error(f"Failed to store confirmation token: {str(e)}")
        return False

async def verify_confirmation_token(token: str) -> Optional[dict]:
    """Verify confirmation token"""
    try:
        result = supabase.table("email_confirmations").select("*").eq("token", token).eq("confirmed", False).execute()
        
        if not result.data:
            return None
            
        confirmation = result.data[0]
        
        # Check if token is expired
        expires_at = datetime.fromisoformat(confirmation['expires_at'].replace('Z', '+00:00'))
        if datetime.utcnow() > expires_at.replace(tzinfo=None):
            return None
            
        return confirmation
        
    except Exception as e:
        logger.error(f"Failed to verify confirmation token: {str(e)}")
        return None

async def mark_email_confirmed(token: str, user_id: str) -> bool:
    """Mark email as confirmed and activate user"""
    try:
        # Mark confirmation as completed
        supabase.table("email_confirmations").update({
            "confirmed": True,
            "confirmed_at": datetime.utcnow().isoformat()
        }).eq("token", token).execute()
        
        # Update user as email confirmed in Supabase Auth
        # Note: This requires admin privileges
        from common import admin_supabase
        admin_supabase.auth.admin.update_user_by_id(
            user_id, 
            {"email_confirmed_at": datetime.utcnow().isoformat()}
        )
        
        return True
    except Exception as e:
        logger.error(f"Failed to mark email as confirmed: {str(e)}")
        return False
