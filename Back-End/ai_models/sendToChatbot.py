import json
import requests

# This is the method used to contact the database
def send_to_chatbot(report_data, chatbot_url):

    headers = {"Content-Type": "application/json"}
    
    try:
        # This part will send the data to the Chatbot
        response = requests.post(chatbot_url, data=json.dumps(report_data), headers=headers)
        response.raise_for_status()  # Raise an error if an HTTP issue is encountered
        
        print("Report successfully sent to chatbot.")
        return response.json()  # Return the response in json text format from the successful transfer to chatbot
    
    #This will handle the exception if any error were to occur during the HTTP request.
    except requests.exceptions.RequestException as e:
        print(f"Error sending report to chatbot: {e}")
        return None
