#!/bin/bash

sudo graphics 1
export SDL_MALI_ORIENTATION=1

export SDL_GAMECONTROLLERCONFIG="$(cat /home/odroid/emulator/ppsspp/assets/gamecontrollerdb.txt)"

#sudo mount -t exfat /dev/sda1 /mnt

#DinguxCommander.sh
cd /home/odroid/utils/dinguxcommander
./DinguxCommander
