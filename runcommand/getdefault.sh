#!/usr/bin/bash

emulator=$1
cat /home/odroid/runcommand/cfg/$emulator.cfg | grep 'DEFAULT' | awk -F= '{print $2}'

