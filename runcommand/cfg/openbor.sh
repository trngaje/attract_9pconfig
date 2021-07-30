#!/bin/bash

cp "$1" /home/odroid/emulator/openbor/Paks

cd /home/odroid/emulator/openbor
DL_AUDIODRIVER=alsa ./OpenBOR

sudo rm -rf /home/odroid/emulator/openbor/Paks/*
