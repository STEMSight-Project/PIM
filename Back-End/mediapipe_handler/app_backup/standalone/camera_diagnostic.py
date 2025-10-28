#!/usr/bin/env python3
"""
Camera diagnostic (minimal, robust). Save and run:
  python mediapipe_handler/app_backup/standalone/camera_diagnostic.py
"""

import os
import subprocess
import sys

try:
    import cv2
except Exception as e:
    print("ERROR: failed to import cv2:", e)
    sys.exit(1)


def run_cmd(cmd):
    try:
        out = subprocess.check_output(
            cmd, shell=True, stderr=subprocess.STDOUT, text=True
        )
        return out.strip()
    except Exception as e:
        return "(failed) " + str(e)


print("PYTHON:", sys.executable)
print("PYTHON VERSION:", sys.version.replace("\n", " "))
print("OpenCV version:", getattr(cv2, "__version__", "unknown"))
print()

print("Listing /dev/video* nodes:")
print(run_cmd("ls -l /dev/video* || true"))
print()

print("Current user groups:")
print(run_cmd("id -nG"))
print()

print("Trying to open device indices 0..5 with OpenCV:")
for i in range(6):
    try:
        cap = cv2.VideoCapture(i)
        opened = bool(cap.isOpened())
        if opened:
            ret, frame = cap.read()
            if frame is None:
                shape = None
            else:
                try:
                    shape = tuple(frame.shape)
                except Exception:
                    shape = str(type(frame))
            print(
                "Index {0}: opened=True, read_frame={1}, frame_shape={2}".format(
                    i, bool(ret), shape
                )
            )
        else:
            print("Index {0}: opened=False".format(i))
        try:
            cap.release()
        except Exception:
            pass
    except Exception as e:
        print("Index {0}: Exception: {1}".format(i, e))

print()
print("Try opening /dev/video0 explicitly:")
for api_name, api in [("default", None), ("CAP_V4L2", getattr(cv2, "CAP_V4L2", None))]:
    try:
        if api is None:
            cap = cv2.VideoCapture("/dev/video0")
        else:
            cap = cv2.VideoCapture("/dev/video0", api)
        print(
            "open /dev/video0 api={0} opened={1}".format(api_name, bool(cap.isOpened()))
        )
        try:
            cap.release()
        except Exception:
            pass
    except Exception as e:
        print("Exception for api {0}: {1}".format(api_name, e))

print()
print("Processes using /dev/video0 (if present):")
if os.path.exists("/dev/video0"):
    print(run_cmd("lsof /dev/video0 || true"))
else:
    print("/dev/video0 does not exist")
print()

print("Quick OpenCV capture test on index 0:")
try:
    cap = cv2.VideoCapture(0)
    print("cap.isOpened() ->", cap.isOpened())
    ret, frame = cap.read()
    print(
        "read ->",
        ret,
        "frame ->",
        None if frame is None else getattr(frame, "shape", str(type(frame))),
    )
    try:
        cap.release()
    except Exception:
        pass
except Exception as e:
    print("Exception during quick test:", e)

print()
print("Diagnostic finished.")
