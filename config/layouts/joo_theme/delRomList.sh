#!/bin/bash

AM_ROMSLIST_PATH=/home/odroid/.attract/romlists
ROMS_PATH=/roms
EMULATOR=$1
ROMFILE=$2

#echo "$ROMS_PATH/$EMULATOR/$ROMFILE.*"
sudo rm -rf "$ROMS_PATH/$EMULATOR/$ROMFILE".*
sudo rm -rf "$ROMS_PATH/$EMULATOR/snap/$ROMFILE".*
sudo sed -i "/^$ROMFILE;/d" $AM_ROMSLIST_PATH/$EMULATOR.txt

