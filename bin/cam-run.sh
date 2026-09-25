#!/bin/bash

gst-launch-1.0 libcamerasrc ! videoconvert ! glupload ! glcolorbalance brightness=0 contrast=1.9 saturation=2 ! glvideoflip method=rotate-180 ! glcolorscale ! gldownload ! videoconvert ! video/x-raw,format=YUY2,width=1920,height=1080 ! v4l2sink device=/dev/video42 sync=false qos=false
