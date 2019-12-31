#!/bin/bash
# get the highest temp from it87 sensor
cputemp=$(($(cat /sys/devices/platform/it87.*/hwmon/hwmon*/temp*_input | sort -r | sed -n 1p)/1000))

echo "CPU: $cputemp °C"
echo "CPU: $cputemp °C"

if [ $cputemp -gt 70 ]; then
	echo "#FF0000"
elif [ $cputemp -gt 60 ]; then
       echo "#FFFF00"
else
	echo "#00FF00"
fi

exit 0
