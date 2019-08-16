#!/bin/bash
cputemp=$(($(cat /sys/class/hwmon/hwmon2/temp1_input)/1000))

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
