#!/bin/bash
LOADING_PATH=/home/odroid/runcommand
ffplay $LOADING_PATH/loading.mp4 -fs -autoexit -t 3 -loglevel quiet & > /dev/null 2>&1
