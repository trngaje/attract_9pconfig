#!/usr/bin/env bash

cp /home/odroid/.start_es /home/odroid/autostart.sh
sudo chmod 755 /home/odroid/autostart.sh

sudo killall emulationstation
sudo reboot