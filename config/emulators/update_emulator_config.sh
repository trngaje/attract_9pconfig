#!/bin/bash

if [[ -f $1 ]]
then

    #echo $1
    cfgname=`basename $1`
    echo $cfgname
    emulatorname="${cfgname%.*}"
    echo $emulatorname
    #echo $HOME
    path_roms="$HOME/roms"
    sed -i 's/executable.*/executable           runcommand.sh/g' $1
    sed -i "s/args.*/args                 $emulatorname "'"[romfilename]"/g' $1
    sed -i "s|rompath.*|rompath              $path_roms/$emulatorname|g" $1
    sed -i "s/system.*/system               $emulatorname/g" $1
    sed -i '/artwork/d' $1
    sed -i "$ a artwork    flyer     $path_roms/$emulatorname/boxart" $1
    sed -i "$ a artwork    marquee   $path_roms/$emulatorname/marquee" $1
    sed -i "$ a artwork    snap      $path_roms/$emulatorname/snap" $1
    sed -i "$ a artwork    wheel     $path_roms/$emulatorname/wheel" $1
fi
