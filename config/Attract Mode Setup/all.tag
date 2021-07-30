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


#!/bin/bash
clear

echo "======== DISK INFO =========="
echo ""

df -h

echo ""
echo " Exit after 5 seconds....."
sleep 5
clear#!/bin/bash
/home/odroid/util/splash/splash.sh

#!/bin/bash

#sudo mount -t exfat /dev/sda1 /mnt

DinguxCommander.sh

#!/usr/bin/python

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

import os, sys, struct, time, fcntl, termios, signal
import curses, errno, re
from pyudev import Context


#    struct js_event {
#        __u32 time;     /* event timestamp in milliseconds */
#        __s16 value;    /* value */
#        __u8 type;      /* event type */
#        __u8 number;    /* axis/button number */
#    };

JS_MIN = -32768
JS_MAX = 32768
JS_REP = 0.20

JS_THRESH = 0.75

JS_EVENT_BUTTON = 0x01
JS_EVENT_AXIS = 0x02
JS_EVENT_INIT = 0x80

CONFIG_DIR = '/home/odroid/.config/retroarch'
RETROARCH_CFG = CONFIG_DIR + '/retroarch.cfg'

def ini_get(key, cfg_file):
    pattern = r'[ |\t]*' + key + r'[ |\t]*=[ |\t]*'
    value_m = r'"*([^"\|\r]*)"*'
    value = ''
    with open(cfg_file, 'r') as ini_file:
        for line in ini_file:
            if re.match(pattern, line):
                value = re.sub(pattern + value_m + '.*\n', r'\1', line)
                break
    return value

def get_btn_num(btn, cfg):
    num = ini_get('input_' + btn + '_btn', cfg)
    if num: return num
    num = ini_get('input_player1_' + btn + '_btn', cfg)
    if num: return num
    return ''

def sysdev_get(key, sysdev_path):
    value = ''
    for line in open(sysdev_path + key, 'r'):
        value = line.rstrip('\n')
        break
    return value

def get_button_codes(dev_path):
    js_cfg_dir = CONFIG_DIR + '/autoconfig/'
    js_cfg = ''
    dev_name = ''
    dev_button_codes = list(default_button_codes)

    for device in Context().list_devices(DEVNAME=dev_path):
        sysdev_path = os.path.normpath('/sys' + device.get('DEVPATH')) + '/'
        if not os.path.isfile(sysdev_path + 'name'):
            sysdev_path = os.path.normpath(sysdev_path + '/../') + '/'
        # getting joystick name
        dev_name = sysdev_get('name', sysdev_path)
        # getting joystick vendor ID
        dev_vendor_id = int(sysdev_get('id/vendor', sysdev_path), 16)
        # getting joystick product ID
        dev_product_id = int(sysdev_get('id/product', sysdev_path), 16)
    if not dev_name:
        return dev_button_codes

    # getting retroarch config file for joystick
    for f in os.listdir(js_cfg_dir):
        if f.endswith('.cfg'):
            input_device = ini_get('input_device', js_cfg_dir + f)
            input_vendor_id = ini_get('input_vendor_id', js_cfg_dir + f)
            input_product_id = ini_get('input_product_id', js_cfg_dir + f)
            if (input_device == dev_name and
               (input_vendor_id  == '' or int(input_vendor_id)  == dev_vendor_id) and
               (input_product_id == '' or int(input_product_id) == dev_product_id)):
                js_cfg = js_cfg_dir + f
                break
    if not js_cfg:
        js_cfg = RETROARCH_CFG

    # getting configs for dpad, buttons A, B, X and Y
    btn_map = [ 'left', 'right', 'up', 'down', 'a', 'b', 'x', 'y' ]
    btn_num = {}
    biggest_num = 0
    i = 0
    for btn in list(btn_map):
        if i >= len(dev_button_codes):
            break
        try:
            btn_num[btn] = int(get_btn_num(btn, js_cfg))
        except ValueError:
            btn_map.pop(i)
            dev_button_codes.pop(i)
            btn_num.pop(btn, None)
            continue
        if btn_num[btn] > biggest_num:
            biggest_num = btn_num[btn]
        i += 1

    # building the button codes list
    btn_codes = [''] * (biggest_num + 1)
    i = 0
    for btn in btn_map:
        if i >= len(dev_button_codes):
            break
        btn_codes[btn_num[btn]] = dev_button_codes[i]
        i += 1
    try:
        # if button A is <enter> and menu_swap_ok_cancel_buttons is true, swap buttons A and B functions
        if (ini_get('menu_swap_ok_cancel_buttons', RETROARCH_CFG) == 'true' and
           'a' in btn_num and 'b' in btn_num and btn_codes[btn_num['a']] == '\n'):
            btn_codes[btn_num['a']] = btn_codes[btn_num['b']]
            btn_codes[btn_num['b']] = '\n'
    except (IOError, ValueError):
        pass

    return btn_codes

def signal_handler(signum, frame):
    signal.signal(signal.SIGINT, signal.SIG_IGN)
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    if (js_fds):
        close_fds(js_fds)
    if (tty_fd):
        tty_fd.close()
    sys.exit(0)

def get_hex_chars(key_str):
    if (key_str.startswith("0x")):
        return key_str[2:].decode('hex')
    else:
        return curses.tigetstr(key_str)

def get_devices():
    devs = []
    if sys.argv[1] == '/dev/input/jsX':
        for dev in os.listdir('/dev/input'):
            if dev.startswith('js'):
                devs.append('/dev/input/' + dev)
    else:
        devs.append(sys.argv[1])

    return devs

def open_devices():
    devs = get_devices()

    fds = []
    for dev in devs:
        try:
            fds.append(os.open(dev, os.O_RDONLY | os.O_NONBLOCK ))
            js_button_codes[fds[-1]] = get_button_codes(dev)
        except (OSError, ValueError):
            pass

    return devs, fds

def close_fds(fds):
    for fd in fds:
        os.close(fd)

def read_event(fd):
    while True:
        try:
            event = os.read(fd, event_size)
        except OSError, e:
            if e.errno == errno.EWOULDBLOCK:
                return None
            return False

        else:
            return event

def process_event(event):

    (js_time, js_value, js_type, js_number) = struct.unpack(event_format, event)

    # ignore init events
    if js_type & JS_EVENT_INIT:
        return False

    hex_chars = ""

    if js_type == JS_EVENT_BUTTON:
        if js_number < len(button_codes) and js_value == 1:
            hex_chars = button_codes[js_number]

    if js_type == JS_EVENT_AXIS and js_number <= 7:
        if js_number % 2 == 0:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = axis_codes[0]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = axis_codes[1]
        if js_number % 2 == 1:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = axis_codes[2]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = axis_codes[3]

    if hex_chars:
        for c in hex_chars:
            fcntl.ioctl(tty_fd, termios.TIOCSTI, c)
        return True

    return False

js_fds = []
tty_fd = []

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# daemonize when signal handlers are registered
if os.fork():
    os._exit(0)

js_button_codes = {}
button_codes = []
default_button_codes = []
axis_codes = []

curses.setupterm()

i = 0
for arg in sys.argv[2:]:
    chars = get_hex_chars(arg)
    if i < 4:
        axis_codes.append(chars)

    default_button_codes.append(chars)
    i += 1

event_format = 'IhBB'
event_size = struct.calcsize(event_format)

try:
    tty_fd = open('/dev/tty', 'a')
except IOError:
    print 'Unable to open /dev/tty'
    sys.exit(1)

rescan_time = time.time()
while True:
    do_sleep = True
    if not js_fds:
        js_devs, js_fds = open_devices()
        if js_fds:
            i = 0
            current = time.time()
            js_last = [None] * len(js_fds)
            for js in js_fds:
                js_last[i] = current
                i += 1
        else:
            time.sleep(1)
    else:
        i = 0
        for fd in js_fds:
            event = read_event(fd)
            if event:
                do_sleep = False
                if time.time() - js_last[i] > JS_REP:
                    if fd in js_button_codes:
                        button_codes = js_button_codes[fd]
                    else:
                        button_codes = default_button_codes
                    if process_event(event):
                        js_last[i] = time.time()
            elif event == False:
                close_fds(js_fds)
                js_fds = []
                break
            i += 1

    if time.time() - rescan_time > 2:
        rescan_time = time.time()
        if cmp(js_devs, get_devices()):
            close_fds(js_fds)
            js_fds = []

    if do_sleep:
        time.sleep(0.01)
#!/bin/bash

arr=($(nmcli -g uuid c s --active))

for i in "${arr[@]}"
do
	#echo uuid=$i
	str=$(echo CONNECTION)
	str+=$'\n'
	str+=$(nmcli -g connection.id c s $i)
	str+=$'\n\n'
	str+=$(nmcli -m tabular -f ip4.address,ip4.gateway,ip4.domain c s $i)

	echo $str
	msgbox "$str"
done

#!/usr/bin/env bash

PATH_RELATIVE=`dirname "$0"`
cd $PATH_RELATIVE
PATH_SCRIPTS=`pwd -P`

AM_PATH=
AM_CFG_PATH=$PATH_SCRIPTS/..

sudo killall attract

cp -rf $AM_CFG_PATH/default_cfg $AM_CFG_PATH/attract_new.cfg

cd $AM_CFG_PATH/emulators

emulator_list="ls *.cfg"
for eachfile in $emulator_list 
do
	emulator=$( echo $eachfile | sed "s/.cfg//g")

	if [ "$emulator" != "Attract Mode Setup" -a "$emulator" != "Favorites.txt" -a "$emulator" != "RetroPie" ];then
		echo $emulator
		rm -rf $AM_CFG_PATH/romlists/"$emulator".txt
		$AM_PATH/attract --build-romlist "$emulator" --output "$emulator"
		if [ -f $AM_CFG_PATH/romlists/"$emulator".txt ]; then
			sed 's/AAAAAAAAAA/'"$emulator"'/g' $AM_CFG_PATH/default_display >> $AM_CFG_PATH/attract_new.cfg

			if [ "$emulator" = "arcade" -o "$emulator" = "fbneo" -o "$emulator" = "mame" -o "$emulator" = "mame-advmame" ];then

				echo "	filter               대전" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains vs" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               슈팅" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains shooting" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               스포츠" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains sports" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               액션" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains action" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               어드벤처" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains adventure" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               고전" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains old" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               퍼즐" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains puzzle" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               3,4인용" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains threefour" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               한글게임" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains korea" >> $AM_CFG_PATH/attract_new.cfg
				if [ ! -d $AM_CFG_PATH/romlists/"$emulator" ]; then
					mkdir $AM_CFG_PATH/romlists/"$emulator"
					touch $AM_CFG_PATH/romlists/"$emulator"/vs.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/shooting.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/sports.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/action.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/adventure.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/old.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/threefour.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/korea.tag

				else
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/vs.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/vs.tag
					fi				
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/shooting.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/shooting.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/sports.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/sports.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/action.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/action.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/adventure.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/adventure.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/old.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/old.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/threefour.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/threefour.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/korea.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/korea.tag
					fi
				fi
			fi
			echo "" >> $AM_CFG_PATH/attract_new.cfg
		fi
	fi
done

cat $AM_CFG_PATH/default_input_init >> $AM_CFG_PATH/attract_new.cfg

cp -rf $AM_CFG_PATH/attract.cfg $AM_CFG_PATH/attract.cfg.backup
cp -rf $AM_CFG_PATH/attract_new.cfg $AM_CFG_PATH/attract.cfg
sudo rm -rf $AM_CFG_PATH/attract_new.cfg

###########################
# 영문 -> 한글리스트 변환

sudo rm $AM_CFG_PATH/romlists/kr/*
$AM_CFG_PATH/romlists_kr/krRomList
cp $AM_CFG_PATH/romlists/kr/* $AM_CFG_PATH/romlists/
cd $AM_CFG_PATH/romlists
ls -I"Attract Mode Setup.txt" -I"all.*" -I*.tag -I"kr" -I*.bak | xargs -i cat {} > all.txt
ls -I"Attract Mode Setup.tag" -I"all.*" -I*.txt -I"kr" -I*.bak | xargs -i cat {} > all.tag
###########################

###########################
# 즐겨찾기 리스트 만들기

cd $AM_CFG_PATH/romlists
rm Favorites.tag
rm Favorites.txt
touch $AM_CFG_PATH/romlists/Favorites.txt

#clear
echo
echo "This script will generate a new romlist called Favorites.txt."
echo
echo "Generating new Favorites.txt file ....."
sleep 1
echo

ls *.tag | grep -v all.tag | grep -v 'Attract Mode Setup.tag' > tagfiles

while read filename
do
echo "Using ${filename} ....."
echo

  while read gamename
  do
    romlist=`echo ${filename} |cut -f1 -d '.'`
    echo "     Searching ${romlist}.txt for ${gamename} ....."
    cat "${romlist}.txt"|grep "^${gamename};" >> Favorites.txt
#    cat "${romlist}.txt"|egrep "^${gamename};" >> Favorites.txt
#    cat "${romlist}.txt"|grep "[;]${gamename}[;]" >> Favorites.txt
  done < "${filename}"

sleep 1
echo
done < tagfiles

rm tagfiles

cat Favorites.txt |sort -u > tmp_favorites.txt
mv tmp_favorites.txt Favorites.txt

echo
echo "Finished creating new Favorites.txt ....."
sleep 1
echo
########################


########################
# tag 카테고리 제너레이터
#bash "$AM_CFG_PATH/Attract Mode Setup/oneClickCategory.sh"
########################

#clear
echo
echo
echo
echo "reboot after 3 seconds."
echo
sleep 3
sudo reboot
#!/usr/bin/env bash

PATH_RELATIVE=`dirname "$0"`
cd $PATH_RELATIVE
PATH_SCRIPTS=`pwd -P`

AM_PATH=/usr/bin
AM_CFG_PATH="$PATH_SCRIPTS/.."

echo $AM_CFG_PATH

sudo killall attract

cp -rf $AM_CFG_PATH/default_cfg $AM_CFG_PATH/attract_new.cfg

cd $AM_CFG_PATH/emulators

emulator_list="ls *.cfg"
for eachfile in $emulator_list 
do
	emulator=$( echo $eachfile | sed "s/.cfg//g")

	if [ "$emulator" != "Attract Mode Setup" -a "$emulator" != "Favorites.txt" -a "$emulator" != "RetroPie" ];then
		echo $emulator
		rm -rf $AM_CFG_PATH/romlists/"$emulator".txt
		$AM_PATH/attract --build-romlist "$emulator" --output "$emulator"
		if [ -f $AM_CFG_PATH/romlists/"$emulator".txt ]; then
			sed 's/AAAAAAAAAA/'"$emulator"'/g' $AM_CFG_PATH/default_display >> $AM_CFG_PATH/attract_new.cfg

			if [ "$emulator" = "arcade" -o "$emulator" = "fbneo" -o "$emulator" = "mame" -o "$emulator" = "mame-advmame" ];then

				echo "	filter               대전" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains vs" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               슈팅" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains shooting" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               스포츠" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains sports" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               액션" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains action" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               어드벤처" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains adventure" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               고전" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains old" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               퍼즐" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains puzzle" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               3,4인용" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains threefour" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               한글게임" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains korea" >> $AM_CFG_PATH/attract_new.cfg
				if [ ! -d $AM_CFG_PATH/romlists/"$emulator" ]; then
					mkdir $AM_CFG_PATH/romlists/"$emulator"
					touch $AM_CFG_PATH/romlists/"$emulator"/vs.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/shooting.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/sports.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/action.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/adventure.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/old.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/threefour.tag
					touch $AM_CFG_PATH/romlists/"$emulator"/korea.tag

				else
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/vs.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/vs.tag
					fi				
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/shooting.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/shooting.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/sports.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/sports.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/action.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/action.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/adventure.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/adventure.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/old.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/old.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/puzzle.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/threefour.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/threefour.tag
					fi
					if [ ! -f $AM_CFG_PATH/romlists/"$emulator"/korea.tag ]; then
						touch $AM_CFG_PATH/romlists/"$emulator"/korea.tag
					fi
				fi
			fi
			echo "" >> $AM_CFG_PATH/attract_new.cfg
		fi
	fi
done


sed -n "/sound/,\$p" $AM_CFG_PATH/attract.cfg > $AM_CFG_PATH/default_input

cat $AM_CFG_PATH/default_input >> $AM_CFG_PATH/attract_new.cfg


cp -rf $AM_CFG_PATH/attract.cfg $AM_CFG_PATH/attract.cfg.backup
cp -rf $AM_CFG_PATH/attract_new.cfg $AM_CFG_PATH/attract.cfg
sudo rm -rf $AM_CFG_PATH/attract_new.cfg

###########################
# 영문 -> 한글리스트 변환

sudo rm $AM_CFG_PATH/romlists/kr/*
$AM_CFG_PATH/romlists_kr/krRomList
cp $AM_CFG_PATH/romlists/kr/* $AM_CFG_PATH/romlists/
cd $AM_CFG_PATH/romlists
ls -I"Attract Mode Setup.txt" -I"all.*" -I*.tag -I"kr" -I*.bak | xargs -i cat {} > all.txt
ls -I"Attract Mode Setup.tag" -I"all.*" -I*.txt -I"kr" -I*.bak | xargs -i cat {} > all.tag
###########################

###########################
# 즐겨찾기 리스트 만들기

cd $AM_CFG_PATH/romlists
rm Favorites.tag
rm Favorites.txt
touch $AM_CFG_PATH/romlists/Favorites.txt

#clear
echo
echo "This script will generate a new romlist called Favorites.txt."
echo
echo "Generating new Favorites.txt file ....."
sleep 1
echo

ls *.tag | grep -v all.tag | grep -v 'Attract Mode Setup.tag' > tagfiles

while read filename
do
echo "Using ${filename} ....."
echo

  while read gamename
  do
    romlist=`echo ${filename} |cut -f1 -d '.'`
    echo "     Searching ${romlist}.txt for ${gamename} ....."
    cat "${romlist}.txt"|grep "^${gamename};" >> Favorites.txt
#    cat "${romlist}.txt"|egrep "^${gamename};" >> Favorites.txt
#    cat "${romlist}.txt"|grep "[;]${gamename}[;]" >> Favorites.txt
  done < "${filename}"

sleep 1
echo
done < tagfiles

rm tagfiles

cat Favorites.txt |sort -u > tmp_favorites.txt
mv tmp_favorites.txt Favorites.txt

echo
echo "Finished creating new Favorites.txt ....."
sleep 1
echo
########################


########################
# tag 카테고리 제너레이터
#bash "$AM_CFG_PATH/Attract Mode Setup/oneClickCategory.sh"
########################

#clear
echo
echo
echo
echo "reboot after 3 seconds."
echo
#!/bin/bash

/home/odroid/overclock/OC_select.sh

#!/usr/bin/env bash

retroarch32 "$@"
#!/usr/bin/env bash

retroarch "$@"
#!/bin/bash

runcommand_setting.sh
#!/usr/bin/env bash

cp /home/odroid/.start_am /home/odroid/autostart.sh
sudo chmod 755 /home/odroid/autostart.sh

sudo killall attract
sudo reboot#!/usr/bin/env bash

cp /home/odroid/.start_es /home/odroid/autostart.sh
sudo chmod 755 /home/odroid/autostart.sh

sudo killall emulationstation
sudo reboot#!/bin/bash

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
ELF          �    �      @       Pn          @ 8 	 @         @       @       @       �      �                   8      8      8                                                         TA      TA                   xK      xK     xK     �      ��                  �K      �K     �K     0      0                   T      T      T      D       D              P�td   d<      d<      d<      �       �              Q�td                                                  R�td   xK      xK     xK     �      �             /lib/ld-linux-aarch64.so.1           GNU ���	�%���xg�hSq��         GNU                                                                          �                     P             K                     c                     i                      ?                     �                                             �                      `                                          �                     }  "                                        g                     �                      w                     {                     �                     �                      o                      Y                     
           N                  N                  N       
G�B8� ֐  �G�b8� ֐  �G��8� ֐  �G��8� ֐  �G��8� ֐  �G��8� ֐  �"G�9� ֐  �&G�"9� ֐  �*G�B9� ֐  �.G�b9� ֐  �2G��9� ֐  �6G��9� ֐  �:G��9� ֐  �>G��9� ֐  �BG�:� ֐  �FG�":� ֐  �JG�B:� ֐  �NG�b:� ֐  �RG��:� ֐  �VG��:� ֐  �ZG��:� ֐  �^G��:� ֐  �bG�;� ֐  �fG�";� ֐  �jG�B;� ֐  �nG�b;� ֐  �rG��;� ֐  �vG��;� ֐  �zG��;� ֐  �~G��;� ֐  ��G�<� ֐  ��G�"<� ֐  ��G�B<� ֐  ��G�b<� ֐  ��G��<� ֐  ��G��<� ֐  ��G��<� ֐  ��G��<� ֐  ��G�=� ֐  ��G�"=� ֐  ��G�B=� ֐  ��G�b=� ֐  ��G��=� ֐  ��G��=� ֐  ��G��=� ֐  ��G��=� ֐  ��G�>� ֐  ��G�">� ֐  ��G�B>� ֐  ��G�b>� ֐  ��G��>� � �� ��� ��@��# �� ��  � �G��  �c�G��  ���G�l��������  � �G�@  �����_� ՠ  � @ ��  �!@ �?  ��  T�  �!�G�a  ��� ��_֠  � @ ��  �!@ �!  �"��A�����!�A��  T�  �B�G�b  ��� ��_��{��� �� ��  �`B@9@ 5�  � �G��  ��  � @���������  �R`B 9�@��{¨�_�����{��� �� ��@�����  Q�/ ��/@�  q+ T�/���@�   �  @9� q�  T�/���@�   �  9 �  �/@�  Q�/ ���� ��{è�_��{��� �� �� ��  � �G� @��O � ���@�����  Q�/ ��/@�  q+ T�/���@�   �  @9� q� T�/��  ��@�   ��� �� �   ��&��������� ��@�.���  �/@�  Q�/ ����  �� *�  � �G��O@� @�B � ��@  T����*�{ʨ�_��� �� �� �����@�   �  @9  q` T����@�   �  @9�q) T����@�   �  @9�qh T����@�   � @9����@�@  �!� Q!   9�@�  � �����@��� ��_��{��� �� ��' �� ��@������? ��?@��'@�?  k� T�?�� �v��@�   �� ��?@�   � �&�����?@�  �? ���� ��{Ĩ�_�����{ �� �� �� ��  � �G� @��� ���# ��@�  Q�#@�?  k
 T�' ��@��#@�   K  Q�'@�?  k� T�'�� �v��@�"  ��'��  � �v��@�   �� �������  qM T�'�� �v��@�!  �� ������'�� �v��@�"  ��'��  � �v��@�   �� ��������'��  � �v��@�   �� ������'@�  �' �����#@�  �# ���� Հ  � �G��B� @�! � ��@  Tr����{@�����_��{��� �� �� ��@��@������{¨�_��!��{ �� ��  � �G� @��� ��   � @'�� �� �`Ȉ���� ����@���#�~���� �R4����@������ �� � ��  ��@�  �� T�@�=���� ��@�  ���    q 	 T�@� L ��� �� �   ��&��������� �1����@�L �   ��'���F���  q���T�@�L �   ��'���>���  q���T� � ��  @� |@��v��  � ` �#  ��@� L �� �   ��&�������� � ��  @� |@��v�@ � ` �#  ��� �� �   ��&�������� � ��  @� |@��v�@ � ` �   ������ � ��  @� � � ��  ����� � ��  @�|@�   � 2����@ � ` ������ � ��  @�|@�   � 2�����  � ` ������ � ��  @� |@��v�@ � ` �"  �   � (���z���� � ��  @� |@��v��  � ` �"  �   � (���n���� � ��  @� � � ��  ��@������  � �G��D� @�! � ��@  T�����{@��!��_��{��� �� ��  � �G� @��_ � ��   � @(�� �   ��(��@�o����/ ��� ��/@�   ��(���D��� ��@�R�@������+ �� � ` �  @��+@�?  kj T   ��)��+@� �R�@�k����+@�  �+ ������ �� �B �R �R�@�a��� ��A �R�@������@�W��� Հ  � �G��_@� @�! � ��@  Tv����{̨�_��{��� �� ��' ��# �� �� �� � �� �R�@�\����; ��;@��#@�?  kj T�? ��?@��'@�?  kJ T�@��?@�$  �@��;@�       ��)��*�*�@�-����?@�  �? �����;@�  �; �������� �� �R�@����� ��{Ĩ�_��{��� �� �� �� �� ��  � �G� @��_ � ��% �RD�R# �Rb	�R� �R�@����� �� �R�@����   ��)���RA �R�@������ ��@�   �@*��������� �� ���Ra �R�@������ �R�3 �� � ` �  @��3@�?  kj T   ��)��3@�� �R�@������3@�  �3 ������ ��@�   ��*��������� �� ���R� �R�@����� ��! �R�@�K��� ��`�R�@������7 �� � ` �  @��7@�?  k� T� � p �  @� Q   ��)��7@��@������7@�  �7 ����� � p �  @� Q� � ` �  @�H Q   ��*��@����� ��a �R�@�#����@����� Հ  � �G��_@� @�! � ��@  T�����{̨�_��{��� �� ��  � �G� @��W � �� �� �R�@�����   � +�B �RA �R�@�����   ��+�B �Ra �R�@�����   ��+�B �R� �R�@����� ��! �R�@����� ��`�R�@������' �� � ` �  @��'@�?  k� T� � p �  @� Q   ��)��'@��@�h����'@�  �' ����� � p �  @� Q� � ` �  @�H Q   ��*��@�X���� � p �  @� Q   �@,�B �R�@�O��� ��a �R�@������@�E��� Հ  � �G��W@� @�! � ��@  Td����{˨�_��{��� �� ��' ��# �� �� �� ��@�  �  T�  � �G�  @�� ��@�  �  T�@�  �y    ��3 ��@�  �  T�@� �y    ��7 ��#@�  q`  T�#@��7 ��'@�  q`  T�'@��3 ��@�  qa  T 
�R� ��@������; ��@��;@�   K|S    |  ' �!^�? ��?@� ��^�#@� &  �7 � ���@��@�����@�   ��&��7@��3@��@����� ���@��@�g������� ��{Ĩ�_��{��� �� �� �� ��? ��?���@����� �� T�?���@�   � @9�@�  @9?  ka  T�?@�  �?@�  �? ����  ��@��{Ĩ�_����{ �� �� �� ��  � �G� @��� ��   ��,��@������3 ��3@�  q T�3��  ��@�   �� �   ��&��@�{����@�Q���  ��@�   �  9�� ��@�   ��&���o����3 ��7 ��7���� �B��� � T�7���� � h`8pq� T�3@� �3 � |@��@�   ��7���� �Aha8  9�3���@�   �  9�7@�  �7 �����@�   ��&�� � � �K��� Հ  � �G��B� @�! � ��@  T�����@��{@����_����{ �� �� �� ��  � �G� @��_� ���� ��@��@�   � -���-����� �   ��-���L���� ��@�  � T   � .�� � � �����/ �����@���R����  ���    q` T�/@�  q� T���� �   ��&�� � � ����� � � �s���  �/@�  �/ �����@�!���   Հ  � �G��_B� @�! � ��@  TS����{@����_��{��� �� ��  � �G� @��W � ��� ��@�   � .�������� ��?�R���� Հ  � �G��W@� @�! � ��@  T6����{˨�_��{��� �� �� ��  � �G� @��W � ��� ��@��@�   � -�������� ����� Հ  � �G��W@� @�! � ��@  T����{˨�_��{��� �� �� ��  � �G� @��W � ���@������ ��@��@�   � -�������� �   ��.�������� ��@�  �@ T� �� �   � /��@�V����@�����   Հ  � �G��W@� @�! � ��@  T�����{˨�_�����{ �� �� ��  � �G� @��� ������vӀ  � ` �"  �   ��,��������' ��'@�  qK T����vӀ  � ` �#  ��'@�  |@���� �v�!  ��  � ` �   �� �   ��&���c�������vӀ  � ` �   �5���  с  �"` ����!�v�A �   �  9����vӀ  � ` �   �� ��  � �G��B� @�B � ��@  T�������{@�����_��{��� �� ��  � �G� @��_ � ���� ��@�   � /���5����� �   ��.���T���� ��@�  �  T� �� �   ��/��@������/ �� � ��  @��/@�?  k
 T�/���vӀ  � ` �   �� ��/@�   ��/��@������/@�  �/ �����@�.���   Հ  � �G��_@� @�! � ��@  T`����{̨�_��"��{ �� �� �� �� �� �� ��  � �G� @��?� ������@�   � /����������   ��-�������3 ��3@�  �a  T  �RQ �W �����3@���R����  ���    q@ T�W@�  q� T� � � �  @� qA T���� �   ��&��@������@�5���  � � � �  @� q T�@��@������ �� �   ��&��@�����  �W@�  Q |@��vӀ  � ` �#  ����� �   ��&��������W@�  �W �����3@������ � � �  @� q� T�W@�  Q |@��vӀ  � ` �"  �   � 0��������W���vӀ  � ` �"  �   ��0��������W@�  �S �� � ���S@�  �   � � � �  @� qa T�W@�  Q |@��vӀ  � ` �"  �   ��0���v����W���vӀ  � ` �"  �   � 1���m����W@��S �� � ���S@�  ��S@�   |@��Ү����7 ��O ��O@��S@�?  k* T�O@������ ��O�� �}��7@�3  �   �@1���e���` ��O@�  �O �����S�� �}��7@�   �  ��7@�)����; ��@��;@�������R�;@����� �R�;@�����D�R� �R��R��R�@�M���� ��;@�����" �R��R�;@�����   �`1��;@������@��@��@��@�A����@���������;@������@�R����[ ��@�#����_ ��_@�$q��    q�
 T�_@�$ q� T�_@�( q� TP  a@�R�;@�c���L  A@�R�;@�_���H    �R�[ �E  �;@���������� �   ��0���_���  q��    q� T  �R�[ �� � � �  @� q�  T�@�����-  � � � �  @� q T�@��@����$  �;@���������� �   � 0���?���  q��    q�  T�@��@�����  �R�[ �  �;@�v�������� �   ��&��@������@�!���� �� ��@��@��@����� ��@������[@� q@  T��� ��;@������;@������O ��O@��S@�?  kj T�O�� �}��7@�   �  @�!����O@�  �O ����  �R� *�  � �G��?D� @�B � ��@  T�����*�@��{@��"��_���1��{ �� �� �� ��  � �G� @��/� ��� � ��  @��C ��C���������' ��; ��C@�  Q�;@�?  k� T�;���v�@ � ` �"  ��;���vӠ  � ` �#  ��;�� �}��'@�3  �����q���` ��;@�  �; �����'@�:����+ �! �R�@������@��+@�����D �R� �RB�R��R�@�a���� ��+@�����" �R��R�+@�������R�+@����� �R�+@�����   ��1��+@������@������@���������+@������@�c�������? ��@�3����G ��G@�$q��    q� T�?@� q  T�G@�Lq  T�G@�Lql	 T�G@�Hq� T�G@�Hq� T�G@�q� T�G@�q� T�G@�q` T�G@�q, T�G@�$ q` T�G@�( q@ T2  a@�R�+@�g���.  A@�R�+@�c���*  �@�R�+@�_���&  �@�R�+@�[���"  � � � �! �R  ��+@���������� ��c�x����c!��c��c������ ��@������ � p �  @�  Q% �RD�R# �Rb	�R� *�@�����    �R�? � ռ����@�����?@� q�  T��� �   ��+@������+@������; ��;@��C@�?  kj T�;�� �}��'@�   �  @�@����;@�  �; ���� Հ  � �G��/F� @�! � ��@  T����@��{@���1��_�����{ �� ��  � �G� @��� ���������������������  �R�����  � �G�  @�! �R��������    q  T�  � �G�  @�< qm  T  �R    �R  q�  T}�R}�R}�R��R����  � �G�  @�< q� T��R �R  �R������R! �R� �R������R� �R� �R����
      /home/odroid/runcommand/cfg     .       ..      EXIT    Exit    test.cfg        cfg     :: OGS 9P FIRMWARE ::   D E F A U L T    C O R E    S E L E C T > %d            UP / DOWN A-BUTTON      EMULATOR : %s   DEFAULT CORE : %s       by SSHINBAYMAX  CURSOR MOVE : UP / DOWN SELECT : A BUTTON       BACK / EXIT : B BUTTON  EMULATOR SYSTEM DEFAULT CORE SETUP MODE "       /home/odroid/runcommand/defaultGameCore/%s/%s.cfg       r               /home/odroid/runcommand/defaultGameCore/%s      w       %s
     /home/odroid/runcommand/cfg/%s  DEFAULT="%s"
   CORES[%d]="%s"
 - Clear default core & Exit     - Exit  - Save & Exit   - Save & Exit 2 설명   >>      *  ;�      ����  ����$  <���8  ����\  ����t  �����  �����  h����  �����  $���  H���0  ���T  ���t  �����  �����  X����  �����  ���  x���@  ����d  ����  �����  @����  d����  h���  X���0  ����X  D���|  �����  ,����         zR x       ����0          ,   ����@           @   ����H    A ��B�N���       d    ���              |   ���t    A0��[��       �   `����    A���s��      �   ����    A d     �   ����p    A@��Z��        �   ����L   A�A����P��        ���$    A ��G��        8  ����   A�A�������      \  ����   A���@��     |  �����    A@��q��       �  @����   A���}��     �  ����   A���^��     �  |���L   A@��Q��       �  ����t    A@��B�Y���    $      ����`   A�A����B��S���      H  0���(   A�	A����G��      l  4���p    A���Z��      �  ����t    A���[��      �  �����    A���m��       �  t���$   A�A����F��      �  t���   A�����   $     X����   A�A����B��w��� $   8   ���|   A�A����B������      `  t���p   A�A�������   $   �  ����d    A�A����V��        0   �   ���|    A@��B��C��E��S��������      �  L���                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               �      �                           �              %             �             �             �      
       
                                          �M            �                           h             0
      ���o                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     �K     �9                                                      9      �8                      P     GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0                                     8                    T                    x                    �                    �                     	                    
                    �                   	 0
 h                    �                                       
   
    P      P      .
   
                     f
                     �
   
   
                     �
   P             �
                      �
                     '   
                             ^   ���o       
      
      �                            k   ���o       �      �      �                            z             0
glutexto
2#!/bin/bash
sudo nmui
