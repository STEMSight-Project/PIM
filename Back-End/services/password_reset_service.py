"""
Password Reset Email Service
Handles sending password reset emails with custom templates
"""
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from typing import Optional
from datetime import datetime, timedelta
import uuid
import os

from core.common import supabase, logger
from core.env import ENVIRONMENT as ENV


def get_email_client() -> FastMail:
    """
    Get FastMail client instance.
    Lazy initialization to avoid errors when email config is not set.
    """
    if not ENV.MAIL_USERNAME or not ENV.MAIL_PASSWORD or not ENV.MAIL_FROM:
        raise ValueError(
            "Email configuration is incomplete. Please set MAIL_USERNAME, MAIL_PASSWORD, and MAIL_FROM in your .env file. "
            "See PASSWORD_RESET_SETUP.md for configuration instructions."
        )
    
    conf = ConnectionConfig(
        MAIL_USERNAME=ENV.MAIL_USERNAME,
        MAIL_PASSWORD=ENV.MAIL_PASSWORD,
        MAIL_FROM=ENV.MAIL_FROM,
        MAIL_PORT=ENV.MAIL_PORT,
        MAIL_SERVER=ENV.MAIL_SERVER,
        MAIL_FROM_NAME=ENV.MAIL_FROM_NAME,
        MAIL_STARTTLS=True,
        MAIL_SSL_TLS=False,
        USE_CREDENTIALS=True,
        VALIDATE_CERTS=True
    )
    
    return FastMail(conf)


async def send_password_reset_email(email: str, user_name: str = "User") -> bool:
    """
    Send password reset email with a link to reset password
    
    Args:
        email: User's email address
        user_name: User's display name
        
    Returns:
        bool: True if email sent successfully, False otherwise
    """
    try:
        # Generate password reset token
        reset_token = str(uuid.uuid4())
        
        # Store reset token in database
        stored = await store_reset_token(email, reset_token)
        if not stored:
            logger.error(f"Failed to store reset token for {email}")
            return False
        
        # Create reset URL
        reset_url = f"{ENV.FRONTEND_URL}/reset-password?token={reset_token}"
        
        # HTML email template
        html_template = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Reset Your STEMSight Password</title>
        </head>
        <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
            <div style="background-color: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                <!-- Header -->
                <div style="text-align: center; margin-bottom: 30px; border-bottom: 3px solid #007bff; padding-bottom: 20px;">
                    <h1 style="color: #333; margin: 0; font-size: 28px;">STEMSight</h1>
                    <p style="color: #666; margin: 10px 0 0 0; font-size: 16px;">Password Reset Request</p>
                </div>
                
                <!-- Content -->
                <div style="margin-bottom: 30px;">
                    <p style="color: #333; font-size: 16px; line-height: 1.6;">Hello {user_name},</p>
                    
                    <p style="color: #333; font-size: 16px; line-height: 1.6;">
                        We received a request to reset your password for your STEMSight account. 
                        Click the button below to create a new password:
                    </p>
                    
                    <!-- Reset Button -->
                    <div style="text-align: center; margin: 35px 0;">
                        <a href="{reset_url}" 
                           style="background-color: #007bff; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; display: inline-block; font-weight: bold; font-size: 16px; box-shadow: 0 2px 4px rgba(0,123,255,0.3);">
                            Reset Password
                        </a>
                    </div>
                    
                    <!-- Alternative Link -->
                    <div style="background-color: #f9f9f9; border-left: 4px solid #007bff; padding: 15px; margin: 25px 0; border-radius: 4px;">
                        <p style="color: #666; font-size: 14px; margin: 0 0 10px 0;">
                            If the button above doesn't work, copy and paste this link into your browser:
                        </p>
                        <p style="color: #007bff; font-size: 14px; word-break: break-all; margin: 0;">
                            {reset_url}
                        </p>
                    </div>
                    
                    <!-- Security Info -->
                    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 25px 0; border-radius: 4px;">
                        <p style="color: #856404; font-size: 14px; margin: 0; font-weight: bold;">
                            ⚠️ Important Security Information
                        </p>
                        <ul style="color: #856404; font-size: 13px; margin: 10px 0 0 0; padding-left: 20px;">
                            <li>This link will expire in 1 hour for security reasons</li>
                            <li>If you didn't request this reset, please ignore this email</li>
                            <li>Never share this link with anyone</li>
                        </ul>
                    </div>
                    
                    <p style="color: #666; font-size: 14px; line-height: 1.6; margin-top: 25px;">
                        If you didn't request a password reset, you can safely ignore this email. 
                        Your password will remain unchanged.
                    </p>
                </div>
                
                <!-- Footer -->
                <div style="text-align: center; font-size: 12px; color: #999; border-top: 1px solid #eee; padding-top: 20px; margin-top: 30px;">
                    <p style="margin: 5px 0;">This is an automated message, please do not reply.</p>
                    <p style="margin: 5px 0;">&copy; {datetime.now().year} STEMSight. All rights reserved.</p>
                    <p style="margin: 5px 0;">
                        <a href="{ENV.FRONTEND_URL}" style="color: #007bff; text-decoration: none;">Visit STEMSight</a>
                    </p>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Create email message
        message = MessageSchema(
            subject="Reset Your STEMSight Password",
            recipients=[email],
            body=html_template,
            subtype=MessageType.html
        )
        
        # Send email
        fast_mail = get_email_client()
        await fast_mail.send_message(message)
        logger.info(f"Password reset email sent to {email}")
        return True
        
    except Exception as e:
        logger.error(f"Failed to send password reset email to {email}: {str(e)}")
        return False


async def store_reset_token(email: str, token: str) -> bool:
    """
    Store password reset token in database
    
    Args:
        email: User's email address
        token: Reset token to store
        
    Returns:
        bool: True if stored successfully, False otherwise
    """
    try:
        # Check if user exists in Supabase Auth
        # Note: This requires admin privileges
        try:
            from core.common import admin_supabase
            user_response = admin_supabase.auth.admin.list_users()
            user = next((u for u in user_response if u.email == email), None)
            
            if not user:
                logger.warning(f"No user found with email {email}")
                # Still return True to prevent email enumeration attacks
                return True
                
            user_id = user.id
        except Exception as e:
            logger.error(f"Failed to lookup user: {str(e)}")
            # Still return True to prevent email enumeration attacks
            return True
        
        # Store token in password_resets table
        expires_at = datetime.utcnow() + timedelta(hours=1)
        
        result = supabase.table("password_resets").insert({
            "user_id": user_id,
            "email": email,
            "token": token,
            "expires_at": expires_at.isoformat(),
            "used": False
        }).execute()
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to store reset token: {str(e)}")
        return False


async def verify_reset_token(token: str) -> Optional[dict]:
    """
    Verify password reset token
    
    Args:
        token: Reset token to verify
        
    Returns:
        dict: Token data if valid, None otherwise
    """
    try:
        # Look up token in database
        result = supabase.table("password_resets")\
            .select("*")\
            .eq("token", token)\
            .eq("used", False)\
            .execute()
        
        if not result.data:
            logger.warning(f"Token not found or already used")
            return None
        
        reset_record = result.data[0]
        
        # Check if token has expired
        expires_at = datetime.fromisoformat(reset_record['expires_at'].replace('Z', '+00:00'))
        if datetime.utcnow() > expires_at.replace(tzinfo=None):
            logger.warning(f"Token expired for user {reset_record['user_id']}")
            return None
        
        return reset_record
        
    except Exception as e:
        logger.error(f"Failed to verify reset token: {str(e)}")
        return None


async def mark_token_used(token: str) -> bool:
    """
    Mark password reset token as used
    
    Args:
        token: Reset token to mark as used
        
    Returns:
        bool: True if marked successfully, False otherwise
    """
    try:
        supabase.table("password_resets").update({
            "used": True,
            "used_at": datetime.utcnow().isoformat()
        }).eq("token", token).execute()
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to mark token as used: {str(e)}")
        return False
