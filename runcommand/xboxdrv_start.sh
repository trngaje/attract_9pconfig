#!/bin/bash

corename=`basename $2`
#echo "$1"
#echo "$corename"
#echo "$3"

PADNAME=`cat /sys/class/input/js0/device/name`
PADVENDOR=`cat /sys/class/input/js0/device/id/vendor`
PADPRODUCT=`cat /sys/class/input/js0/device/id/product`
PADVERSION=`cat /sys/class/input/js0/device/id/version`

#touch /home/odroid/output.txt
#echo "$1 $2 $3\n" >> /home/odroid/output.txt

### This no longer has dpad as button, use $dpad to add it as needed.
### Basic Configuraions - Standard controller mappings 
basicRK2020="sudo /home/odroid/util/xboxdrv/xboxdrv \
    --evdev /dev/input/event2 \
    --evdev-no-grab \
    --quiet \
    --detach-kernel-driver \
    --force-feedback \
    --deadzone-trigger 15% \
    --deadzone 4000 \
    --mimic-xpad \
    --evdev-keymap BTN_SOUTH=b,BTN_EAST=a,BTN_NORTH=x,BTN_WEST=y,BTN_TL=lb,BTN_TR=rb,BTN_TL2=tl,BTN_TR2=tr,BTN_TRIGGER_HAPPY3=back,BTN_TRIGGER_HAPPY4=start"

basicOGS="sudo /home/odroid/util/xboxdrv/xboxdrv \
    --evdev /dev/input/event2 \
    --force-feedback \
    --evdev-no-grab \
    --quiet \
    --detach-kernel-driver \
    --deadzone-trigger 15% \
    --deadzone 4000 \
    --mimic-xpad \
    --evdev-keymap BTN_SOUTH=b,BTN_EAST=a,BTN_NORTH=x,BTN_WEST=y,BTN_TL=lb,BTN_TR=rb,BTN_TL2=tl,BTN_TR2=tr,BTN_TRIGGER_HAPPY3=back,BTN_TRIGGER_HAPPY4=start \
    --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2"

basicRG351V="sudo /home/odroid/util/xboxdrv/xboxdrv \
    --evdev /dev/input/event2 \
    --force-feedback \
    --evdev-no-grab \
    --quiet \
    --detach-kernel-driver \
    --deadzone-trigger 15% \
    --deadzone 4000 \
    --mimic-xpad \
    --evdev-keymap BTN_EAST=b,BTN_SOUTH=a,BTN_C=x,BTN_NORTH=y,BTN_WEST=lb,BTN_Z=rb,BTN_SELECT=tl,BTN_START=tr,BTN_TR=back,BTN_TL=start,BTN_TR2=white,BTN_TL2=guide  \
    --evdev-absmap ABS_Z=x1,ABS_RX=y1"

#drastic="--ui-buttonmap back+x=KEY_M,back+a=KEY_D,back+y=KEY_S,back+b=KEY_A,back+start=KEY_ESC"
drastic="--ui-buttonmap back+lb=KEY_F7,back+rb=KEY_F5,back+x=KEY_M,back+y=KEY_D,back+b=KEY_A,back+start=KEY_ESC"
drasticv="--ui-buttonmap back+lb=KEY_F7,back+rb=KEY_F5,back+x=KEY_M,back+y=KEY_D,back+b=KEY_A,back+start=KEY_ESC,tr=KEY_LEFTSHIFT --ui-axismap x2=KEY_UP:KEY_DOWN,y2=KEY_LEFT:KEY_RIGHT"
drasticv_rg351v="--ui-buttonmap back+lb=KEY_F7,back+rb=KEY_F5,back+x=KEY_M,back+y=KEY_D,back+b=KEY_A,back+start=KEY_ESC,tr=KEY_LEFTSHIFT --ui-axismap x1=KEY_UP:KEY_DOWN,y1=KEY_LEFT:KEY_RIGHT"

openmsx="--ui-buttonmap back+tl=KEY_PRINT,back+y=KEY_PAUSE,back+x=KEY_MENU,back+start=KEY_LEFTALT+KEY_F4,back+lb=KEY_LEFTALT+KEY_F7,back+rb=KEY_LEFTALT+KEY_F8 "
retroarch="--ui-buttonmap back+start=KEY_ESC,back+x=KEY_F1"

### Kill Command
xboxkill="sudo killall xboxdrv > /dev/null 2>&1"

if [[ "$2" == *".so"* ]]; then
    if [ "$PADNAME" = "GO-Super Gamepad" ]; then
	:;

        $xboxkill

        /bin/sh -c "sleep 5; sudo /home/odroid/util/xboxdrv/xboxdrv  \
    --evdev /dev/input/event2 \
    --ui-clear \
    --device-names keyboard.0="trngaje" \
    --device-usbids keyboard.0=100:100:1 \
    --evdev-no-grab \
    --quiet \
    --deadzone-trigger 15% \
    --deadzone 4000 \
    --evdev-keymap BTN_SOUTH=b,BTN_EAST=a,BTN_NORTH=x,BTN_WEST=y,BTN_TL=lb,BTN_TR=rb,BTN_TL2=tl,BTN_TR2=tr,BTN_TRIGGER_HAPPY3=back,BTN_TRIGGER_HAPPY4=start,BTN_TRIGGER_HAPPY5=white,BTN_TRIGGER_HAPPY6=guide  \
    --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2 \
    --ui-buttonmap guide+start=KEY_ESC,guide+x=KEY_F1,guide+rb=KEY_F2,guide+lb=KEY_F4,guide+white=KEY_P,guide+b=KEY_H" &

    fi
else


    case $corename in
	    drastic_v.sh)
		    $xboxkill
            if [ "$PADNAME" = "GO-Super Gamepad" ]; then
		    joycommand="$basicOGS $drasticv &"
		    eval $joycommand
			fi
	        ;;
        openmsx)
				if [ "$PADNAME" = "GO-Super Gamepad" ]; then
                $xboxkill
                joycommand="$basicOGS $openmsx &"
                eval $joycommand
				fi
        ;;
		pc98.sh)

		;;
    esac

fi

