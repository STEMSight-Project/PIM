# Import required libraries

import cv2
import mediapipe as mp
import time
import csv
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import uvicorn
import numpy as np
import json

## Import associated files and variables

import pose_model_capture
import api_router.patient
import PostureMovementDetector

## Namely patient ID and name

# Try to locate patient history using ID and/or name
## If patient history exists
### Open and be ready to write
## Else create patient history using ID and/or name //.json
### Open and be ready to write

# Declare variables needed for this
# Tracked positions of nodes as XY coordinate arrays //Going back about 300 frames for each node?
# Booleans for specific symptoms

# While online
## Don't start searching for symptoms until about 15 seconds in //Partially to fill the arrays, partially to get a baseline
## After 15 seconds pass // if time.time() == start_time + 15:
### If one eye is lower && same side of face is lower
#### Identify as droop
#### Increase odds of stroke
##
### If all signs of fencer posture //One leg bent in, same arm overhead, other arm outstretched, unable to move
#### Identify as fencer posture
#### Increase odds of stroke
##
### If one side of body moves around a lot
#### Identify as hemiballism
#### Increase odds of stroke
##
### If all signs of decerebriate //Legs stretched and turned in, arms stretched at sides, wrists flexed
#### Identify as decerebriate
#### Increase odds of stroke
##
### If all signs of decorticate //Legs stretched and turned in, arms towards chest, 
#### Identify as decorticate
#### Increase odds of stroke
##
### If all signs of chorea //Hands and feet moving rapidly and involuntarily 
#### Identify as chorea
#### Increase odds of stroke
##
## After conducting all checks && 15 seconds at least have passed
## Clear out oldest frame's data
## Push all frames down 1 to clear new frame
# Once closed // if cv2.waitkey(1) & 0xFF = ord('q'):
# Close file writer