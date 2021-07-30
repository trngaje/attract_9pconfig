#!/usr/bin/env bash

#PATH_RELATIVE=`dirname "$0"`
#SCRIPT_PATH=$(dirname "$(realpath "$0")")
#cd $PATH_RELATIVE
#cd SCRIPT_PATH
#cd ..
#PATH_SCRIPTS=`pwd -P`

AM_PATH=/usr/games
AM_CFG_PATH=$HOME/.attract

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
