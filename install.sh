#!/bin/bash

PATH_ATTRACT_CONFIG=$HOME/.attract
PATH_RUNCOMMAND=$HOME/runcommand

mkdir -p $PATH_ATTRACT_CONFIG
cp -rv ./config/* $PATH_ATTRACT_CONFIG/

bash "$PATH_ATTRACT_CONFIG/emulators/update_all_config.sh"

# need dependency to run below runcommand
mkdir -p $PATH_RUNCOMMAND
cp -rv ./runcommand/* $PATH_RUNCOMMAND/

sudo cp ./scripts/* /usr/local/bin/


