#!/bin/bash

# hwmon seems to change between reboots
cputemp=$(($(cat /sys/devices/platform/nct6775.656/hwmon/hwmon*/temp2_input)/1000))
cpurpm=$(($(cat /sys/devices/platform/nct6775.656/hwmon/hwmon*/fan2_input)))
echo "CPU: $cputemp °C ${cpurpm}rpm"
echo "CPU: $cputemp °C"

if [ $cputemp -gt 70 ]; then
	echo "#FF0000"
elif [ $cputemp -gt 60 ]; then
       echo "#FFFF00"
else
	echo "#00FF00"
fi

exit 0
