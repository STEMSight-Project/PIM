# Import necessary libraries

import socket
import sys
import threading
from flask import Flask, render_template, Response
import cv2
import json

""" Code stolen
app = Flask(__name__)

def gen_frames():
	camera = cv2.videoGapture(0) #Default camera = 0
	while True: #while online 
		success, frame = camera.read() #look at the camera
		if not success: #If it can't connect
			break #GGs
		else:
			ret, buffer = cv2.imencode('.jpg', frame)
			frame = buffer.tobytes()
			yield (b'--frame\r\n'
				b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/')
def index():
	return render_template('index.html')

@app.route('/video_feed')
def video_feed():
	return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ = '__main__'
	app.run(debug=True)
"""


# Reuse/Import Ping/Connect code from video recording
# This time to server/directory where the JSON files are, rather than the video files.

# Establish connection with JSON file repository for patient
# Create file name based on patient name and as well as date and time of video start
# I.E. "Valentine, Elphelt 2187-11-9 22:13:54.txt"
# Either way, after opening or creating file, create log and timestamp with date start
# I.E. {"patientName": Elphelt Valentine "date": 2187-11-9 "time" 22:13:54}

"""

"""

# When filming
# Take note of current recorded state
# Begin counting frames
# Start and save timestamp at current time, down to the frame
# If state changes AND the previous state has been held for more than five seconds (120 frames at 24 FPS)
# If state is constantly changing on one side, note as hemiballism
# Start parallel timer, save previous state's ending time
# If timer on state holds for two seconds without transferring to previous state
# Append to JSON file in new line:
# Saved starting timestamp, ending timestamp, first state, average, minimum, and peak confidence interval:
# I.E., {"starttime":00:05:07.23 "endtime": 00:05:23.07 "state": Fencer Posture "avgconfidence": 54 "minconfidence": 33 "maxconfidence": 65}"
# Then repeat the cycle for the second state
# By transferring the previous recorded state and counted frames
# Generally speaking, states recorded for less than a second should be disregarded and seen as erroneous reads on the part of the camera.
