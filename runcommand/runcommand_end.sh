#!/bin/bash

# Screen / Records Path
SCREENSHOT_PATH="/home/odroid/.config/retroarch/screenshots"
RECORDS_PATH="/home/odroid/.config/retroarch/records"

# roms Path
ROMS_PATH="/roms"



echo "" >> $LOG_FILE
echo "=== runcommand_end" >> $LOG_FILE



######################################################################################################
# screenshot / records 옮기기 #
######################################################################################################

echo "- screenshot / records 옮기기" >> $LOG_FILE
find $SCREENSHOT_PATH -type f | sort -n | while read entry
do
	moveEntry="${entry:0:${#entry}-18}"
	mv "$entry" "$moveEntry.png"
done

if [ ! -d "$ROMS_PATH/$EMULATOR/snap" ] ; then
	mkdir $ROMS_PATH/$EMULATOR/snap
fi

if [ "$EMULATOR" != "arcade" -a "$EMULATOR" != "mame" -a "$EMULATOR" != "fbneo" -a "$EMULATOR" != "mame-advmame" -a "$EMULATOR" != "hbmame" -a "$EMULATOR" != "fba" -a "$EMULATOR" != "fbn" ];then
	mv -vf $SCREENSHOT_PATH/* $ROMS_PATH/$EMULATOR/snap >> $LOG_FILE
else
	cp -vf $SCREENSHOT_PATH/* $ROMS_PATH/$EMULATOR/snap >> $LOG_FILE
	mv -vf $SCREENSHOT_PATH/* $ROMS_PATH/arcade/snap >> $LOG_FILE
fi

find $RECORDS_PATH -type f | sort -n | while read recordsEntry
do
	moveEntry="${recordsEntry:0:${#recordsEntry}-18}"
	mv "$recordsEntry" "$moveEntry.mkv"
done

if [ ! -d "$ROMS_PATH/$EMULATOR/snap" ] ; then
	mkdir $ROMS_PATH/$EMULATOR/snap
fi

echo "FFMPEG FILE : ffmpeg -i "$RECORDS_PATH/$ROM_FILENAME.mkv" -codec copy "$RECORDS_PATH/$ROM_FILENAME.mp4" -y" >> $LOG_FILE
ffmpeg -i "$RECORDS_PATH/$ROM_FILENAME.mkv" -codec copy "$RECORDS_PATH/$ROM_FILENAME.mp4"
rm -rf $RECORDS_PATH/*.mkv
if [ "$EMULATOR" != "arcade" -a "$EMULATOR" != "mame" -a "$EMULATOR" != "fbneo" -a "$EMULATOR" != "mame-advmame" -a "$EMULATOR" != "hbmame" -a "$EMULATOR" != "fba" -a "$EMULATOR" != "fbn" ];then
	mv -vf $RECORDS_PATH/* $ROMS_PATH/$EMULATOR/snap >> $LOG_FILE
else
	cp -vf $RECORDS_PATH/* $ROMS_PATH/$EMULATOR/snap >> $LOG_FILE
	mv -vf $RECORDS_PATH/* $ROMS_PATH/arcade/snap >> $LOG_FILE
fi
######################################################################################################




# 세이브정보 저장하기
echo "" >> $LOG_FILE
echo "- 퀵 세이브 포인트 정보 저장하기" >> $LOG_FILE

# ls -t '/roms/gba/건스타 슈퍼 히어로즈 (한글)'.state*.png | while read line
sudo rm -f "$ROMS_PATH/$EMULATOR/$ROM_FILENAME".saveInfo
sudo rm -f "$ROMS_PATH/$EMULATOR/$ROM_FILENAME".state.auto

ls -t "$ROMS_PATH/$EMULATOR/$ROM_FILENAME".state*.png | while read line
do
	SAVEFILENAME=`basename "$line"`
	SAVESTATEFILE="${SAVEFILENAME%.*}"
	#(printf "$line|" && ls -alh --time-style='+%Y-%m-%d %H:%M:%S' "$ROMS_PATH/$EMULATOR/$SAVESTATEFILE" | awk '{print $6, $7"|"$5}') >> $LOG_FILE
	(printf "$line|" && ls -alh --time-style='+%Y-%m-%d %H:%M:%S' "$ROMS_PATH/$EMULATOR/$SAVESTATEFILE" | awk '{print $6, $7"|"$5}') >> "$ROMS_PATH/$EMULATOR/$ROM_FILENAME".saveInfo
done



