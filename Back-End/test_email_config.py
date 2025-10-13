"""
Email Configuration Test Script
Run this to verify your email settings before using password reset
"""
import asyncio
import os
from dotenv import load_dotenv
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType

# Load environment variables
load_dotenv()

def test_email_config():
    """Test email configuration"""
    print("Testing Email Configuration...")
    print("-" * 50)
    
    # Check environment variables
    required_vars = [
        "MAIL_USERNAME",
        "MAIL_PASSWORD",
        "MAIL_FROM",
        "MAIL_SERVER",
        "MAIL_PORT"
    ]
    
    missing_vars = []
    for var in required_vars:
        value = os.getenv(var)
        if not value:
            missing_vars.append(var)
            print(f"❌ {var}: NOT SET")
        else:
            # Mask password
            if "PASSWORD" in var:
                masked = value[:4] + "*" * (len(value) - 4)
                print(f"✅ {var}: {masked}")
            else:
                print(f"✅ {var}: {value}")
    
    if missing_vars:
        print("\n⚠️  Missing environment variables:")
        for var in missing_vars:
            print(f"   - {var}")
        print("\nPlease add these to your .env file")
        return False
    
    return True

async def send_test_email():
    """Send a test email"""
    try:
        print("\n" + "=" * 50)
        print("Sending Test Email...")
        print("=" * 50)
        
        # Get email config
        conf = ConnectionConfig(
            MAIL_USERNAME=os.getenv("MAIL_USERNAME"),
            MAIL_PASSWORD=os.getenv("MAIL_PASSWORD"),
            MAIL_FROM=os.getenv("MAIL_FROM"),
            MAIL_PORT=int(os.getenv("MAIL_PORT", 587)),
            MAIL_SERVER=os.getenv("MAIL_SERVER", "smtp.gmail.com"),
            MAIL_FROM_NAME=os.getenv("MAIL_FROM_NAME", "STEMSight Test"),
            MAIL_STARTTLS=True,
            MAIL_SSL_TLS=False,
            USE_CREDENTIALS=True,
            VALIDATE_CERTS=True
        )
        
        # Get recipient
        recipient = input("\nEnter test email address to send to: ").strip()
        if not recipient or "@" not in recipient:
            print("❌ Invalid email address")
            return False
        
        # Create test message
        html = """
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <h2 style="color: #007bff;">✅ Email Configuration Test</h2>
            <p>Congratulations! Your email configuration is working correctly.</p>
            <p>This test was sent from the STEMSight password reset service.</p>
            <hr>
            <p style="color: #666; font-size: 12px;">
                This is an automated test email. You can safely delete it.
            </p>
        </body>
        </html>
        """
        
        message = MessageSchema(
            subject="STEMSight Email Configuration Test",
            recipients=[recipient],
            body=html,
            subtype=MessageType.html
        )
        
        # Send email
        fm = FastMail(conf)
        await fm.send_message(message)
        
        print(f"\n✅ Test email sent successfully to {recipient}")
        print("   Check your inbox (and spam folder)")
        return True
        
    except Exception as e:
        print(f"\n❌ Failed to send test email: {str(e)}")
        print("\nCommon issues:")
        print("  1. Gmail App Password incorrect")
        print("  2. 2FA not enabled on Gmail account")
        print("  3. Firewall blocking SMTP port")
        print("  4. Wrong SMTP server or port")
        return False

async def main():
    """Main test function"""
    print("\n" + "=" * 50)
    print("STEMSight Email Configuration Test")
    print("=" * 50)
    
    # Test configuration
    config_ok = test_email_config()
    
    if not config_ok:
        print("\n❌ Configuration test failed")
        print("   Please fix the issues above and try again")
        return
    
    print("\n✅ Configuration looks good!")
    
    # Ask to send test email
    send_test = input("\nDo you want to send a test email? (y/n): ").strip().lower()
    
    if send_test == 'y':
        await send_test_email()
    else:
        print("\nTest skipped. You can run this script again anytime.")
    
    print("\n" + "=" * 50)
    print("Test Complete!")
    print("=" * 50)
    print("\nNext steps:")
    print("  1. If test email sent successfully, your setup is ready!")
    print("  2. Try the password reset flow at http://localhost:3000")
    print("  3. Check PASSWORD_RESET_SETUP.md for detailed instructions")
    print()

if __name__ == "__main__":
    asyncio.run(main())
