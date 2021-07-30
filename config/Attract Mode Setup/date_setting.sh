#!/bin/bash

PATH_RELATIVE=`dirname "$0"`
cd $PATH_RELATIVE
SCRIPT_PATH=`pwd -P`

YEAR=2020
MONTH=07
DAY=26
HOUR=12
MIN=30

MODE="YEAR"


# joy2key 프로세스 죽이기
function func_KillJoy2Key()
{
	JOY2KEY_PID=$(pgrep -f joy2key.py)
	sudo killall joy2key.py > /dev/null 2>&1
}


function func_Date()
{
	S = 0;
	E = 1;
	if [ "$MODE" == "YEAR" ]; then
		S=2020
		E=2030
	fi

	if [ "$MODE" == "MONTH" ]; then
		S=1
		E=12
	fi

	if [ "$MODE" == "DAY" ]; then
		S=1
		E=31
	fi

	if [ "$MODE" == "HOUR" ]; then
		S=1
		E=24
	fi

	if [ "$MODE" == "MIN" ]; then
		S=0
		E=59
	fi

	OPTIONS=()	
	for (( i = $S ; i <= $E ; i++ )) ; do
 		OPTIONS+=("$i"  "$i")
	done
	OPTIONS+=("EXIT" "EXIT")

	dialog --clear --no-cancel   \
	--title "[ $MODE ]" \
	--menu "UP/DOWN A-BUTTON!" 15 60 10 \
	"${OPTIONS[@]}" 2>"$SCRIPT_PATH"/value

	GET_VALUE=`cat "$SCRIPT_PATH"/value` 

	if [ "$GET_VALUE" != "EXIT" ]; then
		if [ "$MODE" == "YEAR" ]; then
			YEAR=$GET_VALUE
		fi
		if [ "$MODE" == "MONTH" ]; then
			MONTH=$GET_VALUE
		fi
		if [ "$MODE" == "DAY" ]; then
			DAY=$GET_VALUE
		fi
		if [ "$MODE" == "HOUR" ]; then
			HOUR=$GET_VALUE
		fi
		if [ "$MODE" == "MIN" ]; then
			MIN=$GET_VALUE
		fi
	fi
}


function func_Save()
{
	sudo date -s "$YEAR-$MONTH-$DAY $HOUR:$MIN:00"
}




# joy2key enable - up down A-button
"$SCRIPT_PATH/joy2key.py" "/dev/input/js0" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09 & 

CURRENT_DATE=`date '+%F  %r'`

while [ 1 ]; do	
	dialog --clear \
	--title "[ SETTING - DATE ]" \
	--menu "CURRENT_DATE : $CURRENT_DATE" 15 60 10 \
	0 "YEAR  : $YEAR" \
	1 "MONTH : $MONTH" \
	2 "DAY   : $DAY" \
	3 "HOUR  : $HOUR" \
	4 "MIN   : $MIN" \
	5 "SAVE ( $YEAR-$MONTH-$DAY $HOUR:$MIN )" \
	EXIT "EXIT" 2>"$SCRIPT_PATH"/menuitem 

	menuitem=`cat "$SCRIPT_PATH"/menuitem` 

	# make decsion 
	case $menuitem in
		0) MODE="YEAR";func_Date;;
		1) MODE="MONTH";func_Date;;
		2) MODE="DAY";func_Date;;
		3) MODE="HOUR";func_Date;;
		4) MODE="MIN";func_Date;;
		5) func_KillJoy2Key;func_Save; exit 0;;
		EXIT) func_KillJoy2Key;exit 0;;
	esac		
done


