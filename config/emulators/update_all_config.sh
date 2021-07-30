#!/bin/bash

PATH_RELATIVE=`dirname "$0"`
cd $PATH_RELATIVE
PATH_SCRIPTS=`pwd -P`

echo $PATH_SCRIPTS
for cfgfile in $PATH_SCRIPTS/*.cfg; do
    echo $cfgfile
    bash update_emulator_config.sh $cfgfile
done
