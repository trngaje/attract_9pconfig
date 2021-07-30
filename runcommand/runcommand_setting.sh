#!/bin/bash

RUNCOMMAND_PATH="/home/odroid/runcommand"

# joy2key 프로세스 죽이기
function func_KillJoy2Key()
{
	JOY2KEY_PID=$(pgrep -f joy2key.py)
	#sudo kill -INT "$JOY2KEY_PID"
	sudo killall joy2key.py > /dev/null 2>&1
}


# 런커맨드 설정 변경
function func_RuncommandSetting()
{
	echo "=== func_RuncommandSetting=="

	TIME=(`sed -n "/TIME=/p" $RUNCOMMAND_PATH/runcommand.cfg`)

	OPTIONS=()
	for (( i = 0 ; i <= 5 ; i++ )) ; do
 		OPTIONS+=("$i"  "$i sec")
		TIMES[$i]=$i
	done
	OPTIONS+=("EXIT" "EXIT")

	######################################## dialog menu ###########################################################
	dialog --clear --no-cancel   \
	--title "[ R U N N C O M A N D - S E T T I N G ]" \
	--menu "\nRUNCOMMAND DELAY $TIME\n\
	" 15 60 10 \
	"${OPTIONS[@]}" 2>$RUNCOMMAND_PATH/timeItem


	############################################ select menu #######################################################
	timeItem=`cat $RUNCOMMAND_PATH/timeItem` 

	if [ "$timeItem" != "EXIT" ]; then
		sed -i "3s/.*/TIME=${TIMES[$timeItem]}/g" $RUNCOMMAND_PATH/runcommand.cfg
	else
		func_KillJoy2Key
		exit 0
	fi
}




##### Main Function ##################################################################

clear
# joy2key enable - up down A-button
"$RUNCOMMAND_PATH/joy2key.py" "/dev/input/js0" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09 & 

while [ 1 ]; do
	func_RuncommandSetting
done

clear
#######################################################################################
