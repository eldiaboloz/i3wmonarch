#!/usr/bin/env bash

set -e

sensors_temp=(
  /sys/devices/platform/nct6775.656/hwmon/hwmon*/temp2_input
  /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input
  /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp2_input
)
sensors_fans=(
  /sys/devices/platform/nct6775.656/hwmon/hwmon*/fan2_input
  /sys/devices/platform/sch5636/fan1_input 
)
tempval=""
fanval=""
shopt -s extglob
for x in "${sensors_temp[@]}"; do 
  if [ -f "${x}" ]; then
    tempval="$(($(cat "${x}")/1000))"
    break
  fi
done
for y in "${sensors_fans[@]}"; do 
  if [ -f "${y}" ]; then
    fanval="$(cat "${y}")"
    break
  fi
done
shopt -s extglob

echo "CPU: $tempval °C ${fanval}rpm"
echo "CPU: $tempval °C"

if [ $tempval -gt 70 ]; then
	echo "#FF0000"
elif [ $tempval -gt 60 ]; then
       echo "#FFFF00"
else
	echo "#00FF00"
fi

exit 0

