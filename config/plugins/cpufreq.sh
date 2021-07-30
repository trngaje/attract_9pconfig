#!/bin/bash

gov=`sudo cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor`

#sudo cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq | awk '{printf "['$aa' 모드] %.2f GHz", $1 / 1000000 }'

if [ "${gov}" == "interactive" ]; then
	sudo cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq | awk '{printf "[노멀 모드] %.2f GHz", $1 / 1000000 }'
else
	sudo cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq | awk '{printf "[오버 모드] %.2f GHz", $1 / 1000000 }'
fi

