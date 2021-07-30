#!/bin/bash

ROMS_PATH=/roms
EMULATOR=$1
ROMFILE=$2
SAVEFILE=`basename "$3" .png`

sudo rm -f "$ROMS_PATH/$EMULATOR/$ROMFILE".state.auto
cp "$ROMS_PATH/$EMULATOR/$SAVEFILE" "$ROMS_PATH/$EMULATOR/$ROMFILE".state.auto
