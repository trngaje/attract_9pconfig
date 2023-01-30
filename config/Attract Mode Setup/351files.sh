#!/usr/bin/bash
export SDL_MALI_ORIENTATION=1
sudo graphics 1

export SDL_GAMECONTROLLERCONFIG="$(cat /home/odroid/emulator/ppsspp/assets/gamecontrollerdb.txt)"

cd ~/utils/351files
./351Files
