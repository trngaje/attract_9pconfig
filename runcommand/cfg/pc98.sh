#!/bin/bash
ROM=$1
ROM_TINY="${ROM##*/}"
ROM_FILENAME="${ROM_TINY%.*}"
cp "/mnt/sdcard/roms/pc98/$ROM_FILENAME.bmp" "/home/odroid/.config/retroarch/system/np2kai/font.bmp"
#/home/odroid/emulator/retroarch/retroarch -L "/home/odroid/.config/retroarch/cores/np2kai_libretro.so" "$1"
retroarch -L "/home/odroid/.config/retroarch/cores/np2kai_libretro.so" "$1"
