import unittest
from unittest.mock import patch
import smtplib
from email.message import EmailMessage
from email.headerregistry import Address
from email.utils import make_msgid
from services import email_service

confirmMsg = EmailMessage()
confirmMsg['Subject'] = 'Confirm your STEMSight account'
confirmMsg['From'] = Address("STEMSight", "no-reply", "stemsight.com")
confirmMsg['To'] = Address("Burner", "burner", "example.com")
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

class TestEmailService(unittest.TestCase):
    
    @patch('services.email_service.logger')
    def test_logger_info_called(self, mock_logger):
        # Call the function that should trigger logger.info
        email_service.send_confirmation_email(self, "burner@example.com", "hash")  # Replace with the actual function name
        print("Hello world")

        # Assert logger.info was called
        mock_logger.info.assert_called()
        with smtplib.SMTP('localhost') as smtp:
            smtp.send_message(confirmMsg)

if __name__ == '__main__':
    unittest.main()