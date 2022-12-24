#!/bin/bash

retroarch -L /home/odroid/.config/retroarch/cores/bsnes_libretro.so "$1" --subsystem sgb "/mnt/sdcard/roms/bios/gb/Super_Game_Boy_World_Rev_2.sfc"
