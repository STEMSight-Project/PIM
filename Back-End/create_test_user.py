"""
Create a test user for the STEMSight API
Run this script to create a test user account
"""

from common import supabase_auth
import sys

def create_test_user():
    """Create a test user account"""
    email = "admin@example.com"
    password = "admin123456"
    
    try:
        # Try to sign up the user
        response = supabase_auth.auth.sign_up({
            "email": email,
            "password": password
        })
        
        if response.user:
            print(f"✅ Test user created successfully!")
            print(f"Email: {email}")
            print(f"Password: {password}")
            print(f"User ID: {response.user.id}")
            print(f"\nYou can now use these credentials to login at http://127.0.0.1:8000/login")
        else:
            print("❌ Failed to create user")
            
    except Exception as e:
        if "User already registered" in str(e):
            print(f"✅ Test user already exists!")
            print(f"Email: {email}")
            print(f"Password: {password}")
            print(f"\nYou can use these credentials to login at http://127.0.0.1:8000/login")
        else:
            print(f"❌ Error creating user: {e}")

if __name__ == "__main__":
    create_test_user()