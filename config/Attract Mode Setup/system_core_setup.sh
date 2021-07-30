#!/bin/bash

PATH_RELATIVE=`dirname "$0"`
cd $PATH_RELATIVE
PATH_SCRIPTS=`pwd -P`

# joy2key 프로세스 죽이기
function func_KillJoy2Key()
{
        JOY2KEY_PID=$(pgrep -f joy2key.py)
        sudo killall joy2key.py > /dev/null 2>&1
}

# joy2key enable - up down A-button
setterm -cursor on
"$PATH_SCRIPTS/joy2key.py" "/dev/input/js0" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09 &

"$PATH_SCRIPTS/systemsetup" > /dev/tty1

killall joy2key.py
