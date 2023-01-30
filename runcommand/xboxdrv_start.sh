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

#     --no-extra-devices \
basicOGU="xboxdrv \
    --evdev /dev/input/event3 \
    --evdev-no-grab \
    --force-feedback \
    --detach-kernel-driver \
    --deadzone-trigger 15% \
    --deadzone 4000 \
    --mimic-xpad \
    --evdev-keymap BTN_SOUTH=b,BTN_EAST=a,BTN_NORTH=x,BTN_WEST=y,BTN_TL=lb,BTN_TR=rb,BTN_TL2=lt,BTN_TR2=rt,BTN_TRIGGER_HAPPY1=guide,BTN_TRIGGER_HAPPY2=tl,BTN_TRIGGER_HAPPY3=select,BTN_TRIGGER_HAPPY4=start,BTN_TRIGGER_HAPPY5=tr \
    --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RX=x2,ABS_RY=y2"

#drastic="--ui-buttonmap back+x=KEY_M,back+a=KEY_D,back+y=KEY_S,back+b=KEY_A,back+start=KEY_ESC"
drastic="--ui-buttonmap back+lb=KEY_F7,back+rb=KEY_F5,back+x=KEY_M,back+y=KEY_D,back+b=KEY_A,back+start=KEY_ESC"
drasticv="--ui-buttonmap back+lb=KEY_F7@keyboard,back+rb=KEY_F5@keyboard,back+x=KEY_M@keyboard,back+y=KEY_D@keyboard,back+b=KEY_A@keyboard,back+start=KEY_ESC@keyboard,tr=KEY_LEFTSHIFT@keyboard --ui-axismap x2=KEY_UP@keyboard:KEY_DOWN@keyboard,y2=KEY_LEFT@keyboard:KEY_RIGHT@keyboard"
drasticv_rg351v="--ui-buttonmap back+lb=KEY_F7,back+rb=KEY_F5,back+x=KEY_M,back+y=KEY_D,back+b=KEY_A,back+start=KEY_ESC,tr=KEY_LEFTSHIFT --ui-axismap x1=KEY_UP:KEY_DOWN,y1=KEY_LEFT:KEY_RIGHT"

openmsx="--ui-buttonmap back+tl=KEY_PRINT,back+y=KEY_PAUSE,back+x=KEY_MENU,back+start=KEY_LEFTALT+KEY_F4,back+lb=KEY_LEFTALT+KEY_F7,back+rb=KEY_LEFTALT+KEY_F8 "
retroarch="--ui-buttonmap tl+tr=KEY_ESC@keyboard,tl+x=KEY_F1@keyboard"

### Kill Command
xboxkill="killxboxdrv.sh"

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
#                    $xboxkill
#                    joycommand="$basicOGU $retroarch &"
#                    eval $joycommand

else


    case $corename in
	    drastic_v.sh)
#		    export SDL_LINUX_JOYSTICK="'Xbox Gamepad (userspace driver)' 6 1 0"
#		    export SDL_JOYSTICK_DEVICE="/dev/input/js1"
		    $xboxkill
		    joycommand="$basicOGU $drasticv &"
		    eval $joycommand
	        ;;
        openmsx)

                $xboxkill
                joycommand="$basicOGU $openmsx &"
                eval $joycommand
        ;;
		pc98.sh)

		;;
    esac

fi

