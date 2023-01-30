#!/usr/bin/bash

emulator=$1
cat /home/odroid/runcommand/cfg/$emulator.cfg | grep 'CORES' | awk -F= '{print $2}'

