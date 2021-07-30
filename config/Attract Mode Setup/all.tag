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


# joy2key í”„ë¡œì„¸ìŠ¤ ì£½ì´ê¸°
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

				echo "	filter               ëŒ€ì „" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains vs" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ìŠˆíŒ…" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains shooting" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ìŠ¤í¬ì¸ " >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains sports" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ì•¡ì…˜" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains action" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ì–´ë“œë²¤ì²˜" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains adventure" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ê³ ì „" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains old" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               í¼ì¦" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains puzzle" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               3,4ì¸ìš©" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains threefour" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               í•œê¸€ê²Œì„" >> $AM_CFG_PATH/attract_new.cfg
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
# ì˜ë¬¸ -> í•œê¸€ë¦¬ìŠ¤íŠ¸ ë³€í™˜

sudo rm $AM_CFG_PATH/romlists/kr/*
$AM_CFG_PATH/romlists_kr/krRomList
cp $AM_CFG_PATH/romlists/kr/* $AM_CFG_PATH/romlists/
cd $AM_CFG_PATH/romlists
ls -I"Attract Mode Setup.txt" -I"all.*" -I*.tag -I"kr" -I*.bak | xargs -i cat {} > all.txt
ls -I"Attract Mode Setup.tag" -I"all.*" -I*.txt -I"kr" -I*.bak | xargs -i cat {} > all.tag
###########################

###########################
# ì¦ê²¨ì°¾ê¸° ë¦¬ìŠ¤íŠ¸ ë§Œë“¤ê¸°

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
# tag ì¹´í…Œê³ ë¦¬ ì œë„ˆë ˆì´í„°
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

				echo "	filter               ëŒ€ì „" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains vs" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ìŠˆíŒ…" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains shooting" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ìŠ¤í¬ì¸ " >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains sports" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ì•¡ì…˜" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains action" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ì–´ë“œë²¤ì²˜" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains adventure" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               ê³ ì „" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains old" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               í¼ì¦" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains puzzle" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               3,4ì¸ìš©" >> $AM_CFG_PATH/attract_new.cfg
				echo "		sort_by              Title" >> $AM_CFG_PATH/attract_new.cfg
				echo "		rule                 Tags contains threefour" >> $AM_CFG_PATH/attract_new.cfg
				echo "	filter               í•œê¸€ê²Œì„" >> $AM_CFG_PATH/attract_new.cfg
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
# ì˜ë¬¸ -> í•œê¸€ë¦¬ìŠ¤íŠ¸ ë³€í™˜

sudo rm $AM_CFG_PATH/romlists/kr/*
$AM_CFG_PATH/romlists_kr/krRomList
cp $AM_CFG_PATH/romlists/kr/* $AM_CFG_PATH/romlists/
cd $AM_CFG_PATH/romlists
ls -I"Attract Mode Setup.txt" -I"all.*" -I*.tag -I"kr" -I*.bak | xargs -i cat {} > all.txt
ls -I"Attract Mode Setup.tag" -I"all.*" -I*.txt -I"kr" -I*.bak | xargs -i cat {} > all.tag
###########################

###########################
# ì¦ê²¨ì°¾ê¸° ë¦¬ìŠ¤íŠ¸ ë§Œë“¤ê¸°

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
# tag ì¹´í…Œê³ ë¦¬ ì œë„ˆë ˆì´í„°
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

# joy2key í”„ë¡œì„¸ìŠ¤ ì£½ì´ê¸°
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
ELF          ·    à      @       Pn          @ 8 	 @         @       @       @       ø      ø                   8      8      8                                                         TA      TA                   xK      xK     xK     ˜      ¸˜                  ˆK      ˆK     ˆK     0      0                   T      T      T      D       D              Påtd   d<      d<      d<      ü       ü              Qåtd                                                  Råtd   xK      xK     xK     ˆ      ˆ             /lib/ld-linux-aarch64.so.1           GNU â‚Ê	“% ÒÄxgıhSqóÍ         GNU                                                                          ğ                     P             K                     c                     i                      ?                     Æ                                             ¾                      `                                          ’                     }  "                                        g                     ›                      w                     {                     ×                     ò                      o                      Y                                                                V                      Ş                      ½                      ¢                      “                     R                     æ                                                                D                     v                      ı                                          !                     -                       »                     Í                      8                     à                     2                                          Œ                                          Ô                                           ®                     Y                                           ö                     ¼                     É                     m                     <                       H                     ¬                      p                     2                     ³                      ”                     …                     o                     >                      libncurses.so.6 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable use_default_colors wbkgd noecho wattr_on can_change_color init_color wgetch mvwprintw endwin wattr_off wrefresh newwin COLORS init_pair initscr start_color derwin libtinfo.so.6 keypad stdscr curs_set cbreak libmenu.so.6 set_menu_win new_menu item_description free_item item_name set_menu_back free_menu current_item unpost_menu set_menu_format set_menu_fore set_menu_sub set_menu_mark new_item menu_driver libc.so.6 strcpy readdir sprintf fopen closedir puts __stack_chk_fail mkdir abort fgets calloc strlen memset fclose remove opendir fprintf qsort __cxa_finalize strcmp __libc_start_main ld-linux-aarch64.so.1 __stack_chk_guard GLIBC_2.17 NCURSES6_TINFO_5.0.19991023 NCURSES6_5.0.19991023                                                                            ¥         —‘–   Í        ù          MW    Ø                  S¦Ú   ô        %         S¦Ú   ô        ì         —‘–   Í      xK           è      €K                  °O           9      èO           9      ğO           ¨8      P           P     ¸O                  ÀO                  ÈO                   ĞO       '           ØO       (           àO       )           øO       9           ĞM                  ØM                  àM                  èM                  ğM                  øM       	            N       
           N                  N                  N                   N                  (N                  0N                  8N                  @N                  HN                  PN                  XN                  `N                  hN                  pN                  xN                  €N                  ˆN                  N                  ˜N                   N                  ¨N                  °N       !           ¸N       "           ÀN       #           ÈN       $           ĞN       %           ØN       &           àN       '           èN       *           ğN       +           øN       ,            O       -           O       .           O       /           O       0            O       1           (O       2           0O       3           8O       4           @O       5           HO       6           PO       7           XO       8           `O       :           hO       ;           pO       <           xO       =           €O       >           ˆO       ?           O       @           ˜O       A            O       B           ı{¿©ı ‘ ”ı{Á¨À_Ö            ğ{¿©  ğæFù"7‘ Ö Õ Õ Õ  ğêFùB7‘ Ö  ğîFùb7‘ Ö  ğòFù‚7‘ Ö  ğöFù¢7‘ Ö  ğúFùÂ7‘ Ö  ğşFùâ7‘ Ö  ğGù8‘ Ö  ğGù"8‘ Ö  ğ
GùB8‘ Ö  ğGùb8‘ Ö  ğGù‚8‘ Ö  ğGù¢8‘ Ö  ğGùÂ8‘ Ö  ğGùâ8‘ Ö  ğ"Gù9‘ Ö  ğ&Gù"9‘ Ö  ğ*GùB9‘ Ö  ğ.Gùb9‘ Ö  ğ2Gù‚9‘ Ö  ğ6Gù¢9‘ Ö  ğ:GùÂ9‘ Ö  ğ>Gùâ9‘ Ö  ğBGù:‘ Ö  ğFGù":‘ Ö  ğJGùB:‘ Ö  ğNGùb:‘ Ö  ğRGù‚:‘ Ö  ğVGù¢:‘ Ö  ğZGùÂ:‘ Ö  ğ^Gùâ:‘ Ö  ğbGù;‘ Ö  ğfGù";‘ Ö  ğjGùB;‘ Ö  ğnGùb;‘ Ö  ğrGù‚;‘ Ö  ğvGù¢;‘ Ö  ğzGùÂ;‘ Ö  ğ~Gùâ;‘ Ö  ğ‚Gù<‘ Ö  ğ†Gù"<‘ Ö  ğŠGùB<‘ Ö  ğGùb<‘ Ö  ğ’Gù‚<‘ Ö  ğ–Gù¢<‘ Ö  ğšGùÂ<‘ Ö  ğGùâ<‘ Ö  ğ¢Gù=‘ Ö  ğ¦Gù"=‘ Ö  ğªGùB=‘ Ö  ğ®Gùb=‘ Ö  ğ²Gù‚=‘ Ö  ğ¶Gù¢=‘ Ö  ğºGùÂ=‘ Ö  ğ¾Gùâ=‘ Ö  ğÂGù>‘ Ö  ğÆGù">‘ Ö  ğÊGùB>‘ Ö  ğÎGùb>‘ Ö  ğÒGù‚>‘ Ö €Ò €Òå ªá@ùâ# ‘æ ‘€  ğ øGùƒ  ğcôGù„  ğ„ØGùlÿÿ—“ÿÿ—€  ğ èGù@  ´‹ÿÿÀ_Ö Õ    @ ‘¡  !@ ‘?  ëÀ  T  ğ!ÜGùa  ´ğª ÖÀ_Ö    @ ‘¡  !@ ‘!  Ë"üÓA‹ÿë!üA“À  T‚  ğBüGùb  ´ğª ÖÀ_Öı{¾©ı ‘ó ù³  `B@9@ 5€  ğ àGù€  ´    @ùışÿ—Øÿÿ—  €R`B 9ó@ùı{Â¨À_ÖŞÿÿı{½©ı ‘à ùà@ùÍşÿ—  Qà/ ¹à/@¹  q+ Tà/€¹á@ù   ‹  @9¸ qá  Tà/€¹á@ù   ‹  9 Õ  à/@¹  Qà/ ¹îÿÿ Õı{Ã¨À_Öı{¶©ı ‘à ùá ù€  ğ ìGù @ùáO ù €Òà@ùªşÿ—  Qà/ ¹à/@¹  q+ Tà/€¹á@ù   ‹  @9¸ qá Tà/€¹  ‘á@ù   ‹ãÃ ‘â ª   ĞÀ&‘àª½şÿ—àÃ ‘á@ù.ÿÿ—  à/@¹  Qà/ ¹æÿÿ  €á *€  ğ ìGùâO@ù @ùB ë €Ò@  Tÿÿ—à*ı{Ê¨À_Öÿƒ Ñà ùÿ ¹à€¹á@ù   ‹  @9  q` Tà€¹á@ù   ‹  @9€q) Tà€¹á@ù   ‹  @9èqh Tà€¹á@ù   ‹ @9à€¹â@ù@  ‹!€ Q!   9à@¹  à ¹áÿÿà@¹ÿƒ ‘À_Öı{¼©ı ‘à ùá' ¹â ùà@ùëşÿ—ÿ? ¹á?@¹à'@¹?  kÊ Tà?€¹ ÔvÓá@ù   ‹â ªá?@¹   Ğ à&‘ÿÿ—à?@¹  à? ¹ğÿÿ Õı{Ä¨À_ÖÿÃÑı{ ©ı ‘à ùá ¹€  ğ ìGù @ùáù €Òÿ# ¹à@¹  Qá#@¹?  k
 Tÿ' ¹á@¹à#@¹   K  Qá'@¹?  kŠ Tà'€¹ ÔvÓá@ù"  ‹à'€¹  ‘ ÔvÓá@ù   ‹á ªàª¶şÿ—  qM Tà'€¹ ÔvÓá@ù!  ‹à£ ‘Êşÿ—à'€¹ ÔvÓá@ù"  ‹à'€¹  ‘ ÔvÓá@ù   ‹á ªàª¾şÿ—à'€¹  ‘ ÔvÓá@ù   ‹á£ ‘·şÿ—à'@¹  à' ¹Ïÿÿà#@¹  à# ¹Åÿÿ Õ€  ğ ìGùáBù @ù! ë €Ò@  Trşÿ—ı{@©ÿÃ‘À_Öı{¾©ı ‘à ùá ùá@ùà@ù€şÿ—ı{Â¨À_Öÿ!Ñı{ ©ı ‘€  ğ ìGù @ùáù €Ò   Ğ @'‘à ùÿ ¹`ÈˆÒà ò €Òâ‘@„©à#‘~€Òâª €R4şÿ—à@ùöıÿ—à ùà ° °‘  ¹à@ù  ñà Tà@ù=şÿ—à ùà@ù  ñàŸ    q 	 Tà@ù L ‘ãã ‘â ª   ĞÀ&‘àªÚıÿ—àã ‘1ÿÿ—à@ùL ‘   ĞÀ'‘àªFşÿ—  qÀüÿTà@ùL ‘   Ğà'‘àª>şÿ—  qÀûÿTà ° °‘  @¹ |@“ÔvÓÀ  ° ` ‘#  ‹à@ù L ‘â ª   ĞÀ&‘àª¹ıÿ—à ° °‘  @¹ |@“ÔvÓ@ ğ ` ‘#  ‹àã ‘â ª   ĞÀ&‘àª«ıÿ—à ° °‘  @¹ |@“ÔvÓ@ ğ ` ‘   ‹©şÿ—à ° °‘  @¹ à ° °‘  ¹°ÿÿà ° °‘  @¹|@“    2‘€€Ò@ ğ ` ‘œıÿ—à ° °‘  @¹|@“    2‘€€ÒÀ  ° ` ‘’ıÿ—à ° °‘  @¹ |@“ÔvÓ@ ğ ` ‘"  ‹   Ğ (‘àªzıÿ—à ° °‘  @¹ |@“ÔvÓÀ  ° ` ‘"  ‹   Ğ (‘àªnıÿ—à ° °‘  @¹ à ° °‘  ¹à@ù½ıÿ—€  ğ ìGùáDù @ù! ë €Ò@  T¹ıÿ—ı{@©ÿ!‘À_Öı{´©ı ‘à ù€  ğ ìGù @ùá_ ù €Ò   Ğ @(‘à ù   Ğ€(‘à@ùoşÿ—à/ ¹ãã ‘â/@¹   Ğ (‘àªDıÿ— €Ò@€Rà@ùıÿ—ÿ+ ¹à ° ` ‘  @¹á+@¹?  kj T   ĞÀ)‘â+@¹ €Rà@ùkıÿ—à+@¹  à+ ¹ñÿÿàã ‘ã ªB €R €Rà@ùaıÿ— €ÒA €Rà@ùÕıÿ—à@ùWıÿ— Õ€  Ğ ìGùá_@ù @ù! ë €Ò@  Tvıÿ—ı{Ì¨À_Öı{¼©ı ‘à ùá' ¹â# ¹ã ¹ä ¹å ¹ €Ò €Rà@ù\ıÿ—ÿ; ¹á;@¹à#@¹?  kj Tÿ? ¹á?@¹à'@¹?  kJ Tá@¹à?@¹$  á@¹à;@¹       °À)‘â*á*à@ù-ıÿ—à?@¹  à? ¹ìÿÿà;@¹  à; ¹ãÿÿØüÿ— €Ò €Rà@ù˜ıÿ— Õı{Ä¨À_Öı{´©ı ‘à ùá ùâ ùã ù€  Ğ ìGù @ùá_ ù €Ò% €RD€R# €Rb	€RÁ €Rà@ù¼ÿÿ— €Ò €Rà@ùıÿ—   °à)‘‚€RA €Rà@ùıÿ—ãã ‘â@ù   °@*‘àªÃüÿ—àã ‘ã ªÂ€Ra €Rà@ùõüÿ—€ €Rà3 ¹à  ` ‘  @¹á3@¹?  kj T   °À)‘â3@¹¡ €Rà@ùçüÿ—à3@¹  à3 ¹ñÿÿãã ‘â@ù   °€*‘àª¥üÿ—àã ‘ã ªÂ€R €Rà@ù×üÿ— €Ò! €Rà@ùKıÿ— €Ò`€Rà@ùçüÿ—ÿ7 ¹à  ` ‘  @¹á7@¹?  kÊ Tà  p ‘  @¹ Q   °À)‘â7@¹à@ù¿üÿ—à7@¹  à7 ¹îÿÿà  p ‘  @¹ Qà  ` ‘  @¹H Q   °à*‘à@ù¯üÿ— €Òa €Rà@ù#ıÿ—à@ù¥üÿ— Õ€  Ğ ìGùá_@ù @ù! ë €Ò@  TÄüÿ—ı{Ì¨À_Öı{µ©ı ‘à ù€  Ğ ìGù @ùáW ù €Ò €Ò €Rà@ùªüÿ—   ° +‘B €RA €Rà@ùŒüÿ—   °€+‘B €Ra €Rà@ù†üÿ—   °à+‘B €R €Rà@ù€üÿ— €Ò! €Rà@ùôüÿ— €Ò`€Rà@ùüÿ—ÿ' ¹à  ` ‘  @¹á'@¹?  kÊ Tà  p ‘  @¹ Q   °À)‘â'@¹à@ùhüÿ—à'@¹  à' ¹îÿÿà  p ‘  @¹ Qà  ` ‘  @¹H Q   °à*‘à@ùXüÿ—à  p ‘  @¹ Q   °@,‘B €Rà@ùOüÿ— €Òa €Rà@ùÃüÿ—à@ùEüÿ— Õ€  Ğ ìGùáW@ù @ù! ë €Ò@  Tdüÿ—ı{Ë¨À_Öı{¼©ı ‘à ùá' ¹â# ¹ã ¹ä ùå ¹à@ù  ñ¡  T€  Ğ äGù  @ùà ùà@ù  ñ€  Tà@ù  Ày    €à3 ¹à@ù  ñ€  Tà@ù Ày    €à7 ¹à#@¹  q`  Tà#@¹à7 ¹à'@¹  q`  Tà'@¹à3 ¹à@¹  qa  T 
€Rà ¹à@ù®ûÿ—à; ¹á@¹à;@¹   K|S    |  ' Ø!^à? ½à?@½ ¸¡^à#@¹ &  à7 ¹ €Òá@¹à@ùüÿ—ä@ù   °À&‘â7@¹á3@¹à@ùóûÿ— €Òá@¹à@ùgüÿ—¢ûÿ— Õı{Ä¨À_Öı{¼©ı ‘ó ùà ùá ùÿ? ¹ó?€¹à@ù‚ûÿ— ëâ Tà?€¹á@ù   ‹ @9à@ù  @9?  ka  Tà?@¹  à?@¹  à? ¹îÿÿ  €ó@ùı{Ä¨À_ÖÿÑı{ ©ı ‘ó ùà ù€  Ğ ìGù @ùáù €Ò   °à,‘à@ùÖÿÿ—à3 ¹à3@¹  q Tà3€¹  ‘á@ù   ‹â ª   °À&‘à@ù{ûÿ—à@ùQûÿ—  Ñá@ù   ‹  9ãã ‘â@ù   °À&‘àªoûÿ—ÿ3 ¹ÿ7 ¹ó7€¹àã ‘Bûÿ— ë Tà7€¹áã ‘ h`8pqà Tà3@¹ á3 ¹ |@“á@ù   ‹á7€¹âã ‘Aha8  9à3€¹á@ù   ‹  9à7@¹  à7 ¹åÿÿâ@ù   °À&‘à    ‘Kûÿ— Õ€  Ğ ìGùáBù @ù! ë €Ò@  Tûÿ—ó@ùı{@©ÿ‘À_ÖÿÑı{ ©ı ‘à ùá ù€  Ğ ìGù @ùá_ù €Òäã ‘ã@ùâ@ù   ° -‘àª-ûÿ—âã ‘   °à-‘àªLûÿ—à ùà@ù  ñ  T   ° .‘à    ‘ûÿ—ÿ/ ¹àã‘â@ù€€RÚûÿ—  ñàŸ    q` Tà/@¹  q Tàã‘â ª   °À&‘à    ‘ûÿ—à    ‘sÿÿ—  à/@¹  à/ ¹æÿÿà@ù!ûÿ—   Õ€  Ğ ìGùá_Bù @ù! ë €Ò@  TSûÿ—ı{@©ÿ‘À_Öı{µ©ı ‘à ù€  Ğ ìGù @ùáW ù €Òã£ ‘â@ù   ° .‘àªæúÿ—à£ ‘Á?€Rûÿ— Õ€  Ğ ìGùáW@ù @ù! ë €Ò@  T6ûÿ—ı{Ë¨À_Öı{µ©ı ‘à ùá ù€  Ğ ìGù @ùáW ù €Òä£ ‘ã@ùâ@ù   ° -‘àªÈúÿ—à£ ‘¶úÿ— Õ€  Ğ ìGùáW@ù @ù! ë €Ò@  Tûÿ—ı{Ë¨À_Öı{µ©ı ‘à ùá ù€  Ğ ìGù @ùáW ù €Òà@ù½ÿÿ—ä£ ‘ã@ùâ@ù   ° -‘àª©úÿ—â£ ‘   °à.‘àªÈúÿ—à ùà@ù  ñ@ Tà   ‘   ° /‘à@ùVûÿ—à@ù¸úÿ—   Õ€  Ğ ìGùáW@ù @ù! ë €Ò@  Têúÿ—ı{Ë¨À_ÖÿÃÑı{ ©ı ‘à ¹€  Ğ ìGù @ùáù €Òà€¹ÔvÓ€  ğ ` ‘"  ‹   °à,‘àªÈşÿ—à' ¹à'@¹  qK Tà€¹ÔvÓ€  ğ ` ‘#  ‹à'@¹  |@“à€¹ ÔvÓ!  ‹€  ğ ` ‘   ‹â ª   °À&‘àªcúÿ—à€¹ÔvÓ€  ğ ` ‘   ‹5úÿ—  Ñ  ğ"` ‘á€¹!ÔvÓA ‹   ‹  9à€¹ÔvÓ€  ğ ` ‘   ‹á ª€  Ğ ìGùâBù @ùB ë €Ò@  T£úÿ—àªı{@©ÿÃ‘À_Öı{´©ı ‘à ù€  Ğ ìGù @ùá_ ù €Òãã ‘â@ù   ° /‘àª5úÿ—âã ‘   °à.‘àªTúÿ—à ùà@ù  ñ  Tà   ‘   ° /‘à@ùâúÿ—ÿ/ ¹à   ‘  @¹á/@¹?  k
 Tà/€¹ÔvÓ€  ğ ` ‘   ‹ã ªâ/@¹   °à/‘à@ùĞúÿ—à/@¹  à/ ¹ìÿÿà@ù.úÿ—   Õ€  Ğ ìGùá_@ù @ù! ë €Ò@  T`úÿ—ı{Ì¨À_Öÿ"Ñı{ ©ı ‘ó ùà ùá ùâ ùã ù€  Ğ ìGù @ùá?ù €Òãã‘â@ù   ° /‘àªïùÿ—âã‘   °à-‘àªúÿ—à3 ùà3@ù  ña  T  €RQ ÿW ¹àã‘â3@ù€€RŸúÿ—  ñàŸ    q@ TàW@¹  qÁ Tà  € ‘  @¹ qA Tàã‘â ª   °À&‘à@ùÌùÿ—à@ù5şÿ—  à  € ‘  @¹ q Tá@ùà@ù„şÿ—à   ‘   °À&‘à@ù»ùÿ—  àW@¹  Q |@“ÔvÓ€  ğ ` ‘#  ‹àã‘â ª   °À&‘àª­ùÿ—àW@¹  àW ¹Çÿÿà3@ùÇùÿ—à  € ‘  @¹ q¡ TàW@¹  Q |@“ÔvÓ€  ğ ` ‘"  ‹   ° 0‘àª—ùÿ—àW€¹ÔvÓ€  ğ ` ‘"  ‹   ° 0‘àªùÿ—àW@¹  àS ¹à   ‘áS@¹  ¹   à  € ‘  @¹ qa TàW@¹  Q |@“ÔvÓ€  ğ ` ‘"  ‹   °À0‘àªvùÿ—àW€¹ÔvÓ€  ğ ` ‘"  ‹   ° 1‘àªmùÿ—àW@¹àS ¹à   ‘áS@¹  ¹àS@¹   |@“€Ò®ùÿ—à7 ùÿO ¹áO@¹àS@¹?  k* TàO@¹Ïşÿ—â ªàO€¹ ğ}Óá7@ù3  ‹   °@1‘àªeùÿ—` ùàO@¹  àO ¹íÿÿàS€¹ ğ}Óá7@ù   ‹  ùà7@ù)ùÿ—à; ùá@ùà;@ù­ùÿ—€€Rà;@ùÂùÿ— €Rà;@ù×ùÿ—D€Rã €RÂ€R€Rà@ùMùÿ—á ªà;@ùÆùÿ—" €R€Rà;@ù®ùÿ—   `1‘à;@ùÂùÿ—ã@ùâ@ùá@ùà@ùAüÿ—à@ùÊûÿ—ùÿ—à;@ùÔùÿ—à@ùRùÿ—ÿ[ ¹à@ù#ùÿ—à_ ¹à_@¹$qàŸ    q  Tà@ù¹ûÿ—ÿ[ ¹à_@¹q  Tà_@¹q¬ Tà_@¹q` Tà_@¹qì
 Tà_@¹$ q  Tà_@¹( q  TP  a@€Rà;@ùcùÿ—L  A@€Rà;@ù_ùÿ—H    €Rà[ ¹E  à;@ù©ùÿ—Ìøÿ—â ª   À0‘àª_ùÿ—  qàŸ    q€ T  €Rà[ ¹À ğ € ‘  @¹ q  Tà@ù›şÿ—-  À ğ € ‘  @¹ q Tá@ùà@ùşÿ—$  à;@ù‰ùÿ—¬øÿ—â ª    0‘àª?ùÿ—  qàŸ    qà  Tá@ùà@ùìıÿ—  €Rà[ ¹  à;@ùvùÿ—™øÿ—â ª   À&‘à@ù¸øÿ—à@ù!ıÿ—À ğ  ‘â@ùá@ùà@ùÌûÿ— Õà@ùáøÿ—à[@¹ q@  Tÿÿ Õà;@ùøÿ—à;@ù´øÿ—ÿO ¹áO@¹àS@¹?  kj TàO€¹ ğ}Óá7@ù   ‹  @ù!ùÿ—àO@¹  àO ¹óÿÿ  €Rá *€  ° ìGùâ?Dù @ùB ë €Ò@  Tçøÿ—à*ó@ùı{@©ÿ"‘À_Öÿƒ1Ñı{ ©ı ‘ó ùà ù€  ° ìGù @ùá/ù €ÒÀ ğ °‘  @¹àC ¹àC€¹€ÒÁøÿ—à' ùÿ; ¹àC@¹  Qá;@¹?  kê Tà;€¹ÔvÓ@ ° ` ‘"  ‹à;€¹ÔvÓ   ğ ` ‘#  ‹à;€¹ ğ}Óá'@ù3  ‹áªàªqøÿ—` ùà;@¹  à; ¹æÿÿà'@ù:øÿ—à+ ù! €Rà@ùšøÿ—á@ùà+@ù»øÿ—D €Rã €RB€R€Rà@ùaøÿ—á ªà+@ùÚøÿ—" €R€Rà+@ùÂøÿ— €Rà+@ùÃøÿ— €Rà+@ùØøÿ—   €1‘à+@ùĞøÿ—à@ùÑûÿ—à@ùÛúÿ—øÿ—à+@ùåøÿ—à@ùcøÿ—øÿ—ÿ? ¹à@ù3øÿ—àG ¹àG@¹$qàŸ    qÀ Tà?@¹ q  TàG@¹Lq  TàG@¹Lql	 TàG@¹Hqà TàG@¹Hq¬ TàG@¹q  TàG@¹qì TàG@¹q` TàG@¹q, TàG@¹$ q` TàG@¹( q@ T2  a@€Rà+@ùgøÿ—.  A@€Rà+@ùcøÿ—*  Á@€Rà+@ù_øÿ—&  á@€Rà+@ù[øÿ—"  À ğ € ‘! €R  ¹à+@ù¤øÿ—‹øÿ—á ªàc‘xøÿ—âc!‘ác‘àc‘ãªâªá ªà@ùßıÿ—À ğ p ‘  @¹  Q% €RD€R# €Rb	€Rá *à@ù¾úÿ—    €Rà? ¹ Õ¼÷ÿ—à@ùøÿ—à?@¹ q€  Tÿÿ Õ   Õà+@ù½÷ÿ—à+@ùÓ÷ÿ—ÿ; ¹á;@¹àC@¹?  kj Tà;€¹ ğ}Óá'@ù   ‹  @ù@øÿ—à;@¹  à; ¹óÿÿ Õ€  ° ìGùá/Fù @ù! ë €Ò@  Tøÿ—ó@ùı{@©ÿƒ1‘À_ÖÿÃÑı{ ©ı ‘€  ° ìGù @ùáù €ÒÎ÷ÿ—á÷ÿ—È÷ÿ—øÿ—¶÷ÿ—  €RŒ÷ÿ—€  ° äGù  @ù! €RÛ÷ÿ—º÷ÿ—    q  T€  ° ğGù  @¹< qm  T  €R    €R  qÀ  T}€R}€R}€Rà€Røÿ—€  ° ğGù  @¹< qÍ Tâ€R €R  €Ró÷ÿ—â€R! €RÀ €Rï÷ÿ—â€R €Rà €Rë÷ÿ—  â €R €R  €Ræ÷ÿ—â€R! €RÀ €Râ÷ÿ—â€R €Rà €RŞ÷ÿ—‚ €Rá €R@ €RÚ÷ÿ—" €Rá €R` €RÖ÷ÿ—B €R €R€ €RÒ÷ÿ—b €R €R  €RÎ÷ÿ—=÷ÿ—€  ° äGù  @ù  ñà  T€  ° äGù  @ù Ày      €à ¹€  ° äGù  @ù  ñà  T€  ° äGù  @ù Ày      €à ¹À ğ ` ‘á@¹  ¹À ğ p ‘á@¹  ¹ €R €Rá@¹à@¹÷ÿ—à ù! €Rà@ùn÷ÿ—à@ùËùÿ— €Rà@ù÷ÿ— €Ò €Rà@ùm÷ÿ—÷ÿ—ùÿ—à@ù”şÿ—¼÷ÿ— Õ€  ° ìGùâBù @ùB ë €Ò@  Tk÷ÿ—à*ı{@©ÿÃ‘À_ÖÿÃÑı{ ©ı ‘à ¹á ù€  ° ìGù @ùáù €ÒZÿÿ—  €Rá *€  ° ìGùâBù @ùB ë €Ò@  TR÷ÿ—à*ı{@©ÿÃ‘À_Ö Õı{¼©ı ‘óS©”  °”.‘õ[©•  °µâ-‘”Ëö *÷c©÷ªøª«öÿ—ÿ”ë` T”şC“ €Ò£zsøâªs ‘áªà*` ?ÖŸë!ÿÿTóSA©õ[B©÷cC©ı{Ä¨À_Ö ÕÀ_Öı{¿©ı ‘ı{Á¨À_Ö          %s       city[%d] ==> %s 
      /home/odroid/runcommand/cfg     .       ..      EXIT    Exit    test.cfg        cfg     :: OGS 9P FIRMWARE ::   D E F A U L T    C O R E    S E L E C T > %d            UP / DOWN A-BUTTON      EMULATOR : %s   DEFAULT CORE : %s       by SSHINBAYMAX  CURSOR MOVE : UP / DOWN SELECT : A BUTTON       BACK / EXIT : B BUTTON  EMULATOR SYSTEM DEFAULT CORE SETUP MODE "       /home/odroid/runcommand/defaultGameCore/%s/%s.cfg       r               /home/odroid/runcommand/defaultGameCore/%s      w       %s
     /home/odroid/runcommand/cfg/%s  DEFAULT="%s"
   CORES[%d]="%s"
 - Clear default core & Exit     - Exit  - Save & Exit   - Save & Exit 2 ì„¤ëª…   >>      *  ;ø      ÌÛÿÿ  üÛÿÿ$  <Üÿÿ8  „Üÿÿ\  ˆÜÿÿt  üÜÿÿ”  Ğİÿÿ´  hŞÿÿÌ  ØŞÿÿì  $àÿÿ  Hàÿÿ0  ãÿÿT  äÿÿt  Üäÿÿ”  Øæÿÿ´  XèÿÿÔ  ¤éÿÿô  êÿÿ  xëÿÿ@   ìÿÿd  íÿÿ„  „íÿÿ¤  @îÿÿÄ  dïÿÿè  hğÿÿ  Xöÿÿ0  ÔùÿÿX  Düÿÿ|  ¬üÿÿ¤  ,ıÿÿØ         zR x       ´Úÿÿ0          ,   ĞÚÿÿ@           @   üÚÿÿH    A B“NŞİÓ       d    Ûÿÿ              |   Ûÿÿt    A0[Şİ       œ   `ÛÿÿÔ    A sŞİ      ¼   Üÿÿ˜    A d     Ô   ”Üÿÿp    A@ZŞİ        ô   äÜÿÿL   A°A†…PİŞ        Şÿÿ$    A GŞİ        8  ŞÿÿÀ   AÀAˆ‡­İŞ      \  ¬àÿÿ   AÀ@Şİ     |  ”áÿÿÌ    A@qŞİ       œ  @âÿÿü   AÀ}Şİ     ¼  äÿÿ€   A°^Şİ     Ü  |åÿÿL   A@QŞİ       ü  ¨æÿÿt    A@B“YŞİÓ    $      øæÿÿ`   AÀAˆ‡B“†SİŞÓ      H  0èÿÿ(   AÀ	A˜—GİŞ      l  4éÿÿp    A°ZŞİ      Œ  „éÿÿt    A°[Şİ      ¬  Øéÿÿ¼    A°mŞİ       Ì  têÿÿ$   A°A†…FİŞ      ğ  tëÿÿ   AÀŞİ   $     Xìÿÿğ   A€AB“wİŞÓ $   8   òÿÿ|   AàAŒ‹B“ŠÚİŞÓ      `  tõÿÿp   A°A†…™İŞ   $   „  À÷ÿÿd    A°A†…VİŞ        0   ¬   øÿÿ|    A@B“”C•–E—˜SŞİ×ØÕÖÓÔ      à  Løÿÿ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               è                                  ù              %             ì             ¥             ğ             ”9             xK                          €K                   õşÿo    ˜              	             ¸      
       
                                          ¸M            ˆ                           h             0             8      	                            ûÿÿo          şÿÿo          ÿÿÿo           ğÿÿo    
      ùÿÿo                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ˆK     9                                                      9      ¨8                      P     GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0                                     8                    T                    x                    ˜                    ¸                     	                    
                                       	 0                   
 h                    ğ                                        à                    ”9                    ¨9                    d<                    `=                    xK                   €K                   ˆK                   ¸M                    P                   P                                       ñÿ                E      x              H      à              E      ¨9              K    ñÿ                H                                      H      ğ              H      ”9              ›    ñÿ                H      ü              H      œ9              Ş    ñÿ                H      0              é     0              ë     `              E      P             ş                        P            E      €K             #    €K             J    è              E      xK             V    xK             E      t=              E      P             u   ñÿ                E      P             H      ì              E      °9              E      Ø=              …   ñÿ                H      9              E      A              Ş    ñÿ                E      PA              ‘    PA                   ñÿ                Ÿ     €K             °   ñÿˆK             ¹     xK             Ì     d<              ß   ñÿ¨O             Š    ğ              H                    õ    `      Ô           |&      `          9                  t)      t       7                     J                     k                     ˆ                     ¨                     Æ    Ü'      (      Ù                      Ø      P             õ     à            ›                     û    P             	                                          B                     e  "                   €                     ”                     ¨                     Æ                     Ï    0ä             Ø    P             ß                          ,ä                                 2    )      p       G                     e    à            o    ˆ      $          ”9              ’    <#      €      °                     Î    0ä             Ú                     í    ì      t       ÿ                         è)      ¼       )                     Q                     {                     š                     º    4      ˜       Ò                     ó                                          $                     G                     k                                          ¢                     Â                     Ö     P             ã    ¼2      |      ÿ                                          1    ¤*      $      =                      L                     j                     ˆ    Ì      p       ›   P             ¨    Ì,      ğ      Ğ                     â    ¨9             ñ                                          8                     I                     \                     €    9      |                            ±                     «    0ä             Ü    à              Ø    À            ê    86      p      ö    0ä             ş    t       Ì       	    (ä            ,	    (à            :	                     _	                 l	    P             x	    à            ‚	    ¨8      d       ‡	                     ¨	    ¼$      L      Ë	                     í	                      
    @!      ü       
    P      P      .
    ¬      À      B
                     f
                     ‹
    &      t       ›
    È+            ´
                     Ù
   P             å
                      ÿ
                     '    <      L      8                     ®                     V                     h                     D                     ‰                     ­                     Á                     Ó    l             /usr/lib/gcc/aarch64-linux-gnu/9/../../../aarch64-linux-gnu/Scrt1.o $d $x /usr/lib/gcc/aarch64-linux-gnu/9/../../../aarch64-linux-gnu/crti.o call_weak_fn /usr/lib/gcc/aarch64-linux-gnu/9/../../../aarch64-linux-gnu/crtn.o crtstuff.c deregister_tm_clones __do_global_dtors_aux completed.9126 __do_global_dtors_aux_fini_array_entry frame_dummy __frame_dummy_init_array_entry systemsetup.cpp elf-init.oS __FRAME_END__ __init_array_end _DYNAMIC __init_array_start __GNU_EH_FRAME_HDR _GLOBAL_OFFSET_TABLE_ _Z6ExtCmpPcS_ _Z7setCorePc __libc_csu_fini _Z14rmdirRomConfigPcS_ strlen@@GLIBC_2.17 item_name@@NCURSES6_5.0.19991023 wbkgd@@NCURSES6_5.0.19991023 new_menu@@NCURSES6_5.0.19991023 newwin@@NCURSES6_5.0.19991023 _Z10getRomCorePcS_ _ITM_deregisterTMCloneTable _MODE __bss_start__ remove@@GLIBC_2.17 curs_set@@NCURSES6_TINFO_5.0.19991023 unpost_menu@@NCURSES6_5.0.19991023 __cxa_finalize@@GLIBC_2.17 sprintf@@GLIBC_2.17 opendir@@GLIBC_2.17 wgetch@@NCURSES6_5.0.19991023 qsort@@GLIBC_2.17 _edata free_menu@@NCURSES6_5.0.19991023 _MAX_SYSTEM_COUNT new_item@@NCURSES6_5.0.19991023 _Z14mkdirRomConfigPc derwin@@NCURSES6_5.0.19991023 _MAX_ROWS _Z24comparisonFunctionStringPKvS0_ _Z16showStatusSystemP7_win_st noecho@@NCURSES6_5.0.19991023 __bss_end__ fclose@@GLIBC_2.17 _Z11getFileNamePc fopen@@GLIBC_2.17 _Z15updateRomConfigPcS_ can_change_color@@NCURSES6_5.0.19991023 use_default_colors@@NCURSES6_5.0.19991023 initscr@@NCURSES6_5.0.19991023 wrefresh@@NCURSES6_5.0.19991023 _Z17convertSystemNamePc mvwprintw@@NCURSES6_5.0.19991023 __libc_start_main@@GLIBC_2.17 memset@@GLIBC_2.17 start_color@@NCURSES6_5.0.19991023 stdscr@@NCURSES6_TINFO_5.0.19991023 keypad@@NCURSES6_TINFO_5.0.19991023 calloc@@GLIBC_2.17 wattr_on@@NCURSES6_5.0.19991023 readdir@@GLIBC_2.17 __data_start _Z14makeSystemMenuP7_win_st closedir@@GLIBC_2.17 __stack_chk_fail@@GLIBC_2.17 _Z7getItemi __gmon_start__ __stack_chk_guard@@GLIBC_2.17 COLORS@@NCURSES6_5.0.19991023 _Z4DispPA1024_ciPc __dso_handle _Z18makeSystemCoreMenuP7_win_stPcS1_S1_ abort@@GLIBC_2.17 _IO_stdin_used menu_driver@@NCURSES6_5.0.19991023 set_menu_win@@NCURSES6_5.0.19991023 puts@@GLIBC_2.17 strcmp@@GLIBC_2.17 cbreak@@NCURSES6_TINFO_5.0.19991023 __libc_csu_init init_pair@@NCURSES6_5.0.19991023 set_menu_format@@NCURSES6_5.0.19991023 system_items_name _Z7executev __end__ _Z11clearStatusP7_win_stiiiii _MAX_CORE_COUNT _DEFAULT_CORE set_menu_fore@@NCURSES6_5.0.19991023 system_items __bss_start _MAX_COLS main free_item@@NCURSES6_5.0.19991023 _Z15print_in_middleP7_win_stiiiPcj init_color@@NCURSES6_5.0.19991023 strcpy@@GLIBC_2.17 _Z10showStatusP7_win_stPcS1_S1_ choices_items _Z14readSystemListv set_menu_sub@@NCURSES6_5.0.19991023 set_menu_mark@@NCURSES6_5.0.19991023 _Z8findTextPcS_ _Z18updateSystemConfigPc set_menu_back@@NCURSES6_5.0.19991023 __TMC_END__ _ITM_registerTMCloneTable item_description@@NCURSES6_5.0.19991023 _Z4SortPA1024_ci endwin@@NCURSES6_5.0.19991023 mkdir@@GLIBC_2.17 wattr_off@@NCURSES6_5.0.19991023 current_item@@NCURSES6_5.0.19991023 fprintf@@GLIBC_2.17 fgets@@GLIBC_2.17 _Z9showTitleP7_win_st  .symtab .strtab .shstrtab .interp .note.gnu.build-id .note.ABI-tag .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init .text .fini .rodata .eh_frame_hdr .eh_frame .init_array .fini_array .dynamic .got .data .bss .comment                                                                                   8      8                                    #             T      T      $                              6             x      x                                     D   öÿÿo       ˜      ˜                                   N             ¸      ¸      H                          V              	       	      
                             ^   ÿÿÿo       
      
      †                            k   şÿÿo                                                z             0      0      8                           „      B       h      h      ˆ                                       ğ      ğ                                    ‰                         Ğ                            ”             à      à      ´!                             š             ”9      ”9                                                  ¨9      ¨9      ¼                             ¨             d<      d<      ü                              ¶             `=      `=      ô                             À             xK     xK                                   Ì             €K     €K                                   Ø             ˆK     ˆK      0                           á             ¸M     ¸M      H                            æ              P      P                                    ì             P     P       ”                            ñ      0               P      *                                                   @P      (         F                 	                      ha      é                                                   Qm      ú                              #!/usr/bin/env bash
glutexto
2#!/bin/bash
sudo nmui

