import json
from sendToChatbot import send_to_chatbot # The function from sendToChatbot is imported.

# The initilization from the data gathered from patient is compiled here as an instance
class DiagnosisReport:
    def __init__(self, patient_id, postures, movements, eye_movements, demographics):
        self.patient_id = patient_id
        self.postures = postures
        self.movements = movements
        self.eye_movements = eye_movements
        self.demographics = demographics

    # The text report is being compiled here in text and returned back
    def compile_report(self):
        report = {
            "patient_id": self.patient_id,
            "postures": self.postures,
            "movements": self.movements,
            "eye_movements": self.eye_movements,
            "demographics": self.demographics
        }
        return report

    # A method is created here to retrieve the compiled data and send it to the chatbot textbox when implemented
    # The response is returned, the function inside sendToChatbox is called inside.
    def create_and_send_report(self, chatbot_url):
        report_data = self.compile_report()
        response = send_to_chatbot(report_data, chatbot_url)
        return response
