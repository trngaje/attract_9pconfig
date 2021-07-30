#!/bin/bash
ROM=$1
ROM_TINY="${ROM##*/}"
ROM_FILENAME="${ROM_TINY%.*}"
cp "/home/odroid/roms/pc98/$ROM_FILENAME.bmp" "/home/odroid/roms/bios/np2kai/font.bmp"
retroarch -L "/usr/lib/aarch64-linux-gnu/libretro/np2kai_libretro.so" "$1"
