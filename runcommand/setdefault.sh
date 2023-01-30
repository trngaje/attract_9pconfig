#!/usr/bin/bash
DEFAULT=$1
CORE_CONF_FILE="/home/odroid/runcommand/cfg/"$2".cfg"

#echo $DEFAULT
#echo $CORE_CONF_FILE

sed -i '/DEFAULT=/c\DEFAULT=\"'"${DEFAULT}"'\"' ${CORE_CONF_FILE}
