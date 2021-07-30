#!/bin/bash

cat /sys/class/thermal/thermal_zone0/temp | awk '{printf "%.1f ℃", $1 / 1000 }'