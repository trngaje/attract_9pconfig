#!/usr/bin/env bash

cp /home/odroid/.start_am /home/odroid/autostart.sh
sudo chmod 755 /home/odroid/autostart.sh

sudo killall attract
sudo reboot