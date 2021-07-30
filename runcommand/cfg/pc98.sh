#!/bin/bash
ROM=$1
ROM_TINY="${ROM##*/}"
ROM_FILENAME="${ROM_TINY%.*}"
cp "/roms/pc98/$ROM_FILENAME.bmp" "/roms/bios/np2kai/font.bmp"
#/home/odroid/emulator/retroarch/retroarch -L "/home/odroid/.config/retroarch/cores/np2kai_libretro.so" "$1"
/home/odroid/emulator/retroarch_rg351v/retroarch -L "/home/odroid/.config/retroarch/cores/np2kai_libretro.so" "$1"
