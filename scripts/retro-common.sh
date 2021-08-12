# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

#export LD_LIBRARY_PATH="/emuelec/lib:/emuelec/lib32:$LD_LIBRARY_PATH"
#export PATH="/emuelec/scripts:/emuelec/bin:/usr/bin/batocera:$PATH"

#export SDL_GAMECONTROLLERCONFIG_FILE="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"

#EE_DIR="/storage/.config/emuelec"
#EE_CONF="${EE_DIR}/configs/emuelec.conf"
#EE_EMUCONF=/emuelec/configs/emuoptions.conf
ES_CONF="/home/odroid/.emulationstation/es_settings.cfg"
#EE_DEVICE=$(cat /ee_arch)
#EE_LOG="/emuelec/logs/emuelec.log"

get_es_setting() { 
	echo $(sed -n "s|\s*<${1} name=\"${2}\" value=\"\(.*\)\" />|\1|p" ${ES_CONF})
}

