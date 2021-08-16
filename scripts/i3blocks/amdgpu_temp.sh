#!/bin/bash

hasRedAlert=""
hasYellowAlert=""

output="GPU:"
while read -r sensorpath; do
  if [ "$(cat "${sensorpath}/name")" = "amdgpu" ]; then
    gputemp=($(($(cat "${sensorpath}/temp1_input") / 1000)))
    if [ $gputemp -gt 70 ]; then
      hasRedAlert="yes"
    elif [ $gputemp -gt 60 ]; then
      hasYellowAlert="yes"
    fi
    output+=" ${gputemp}"
  fi
done < <(find /sys/class/hwmon -type l)
output+=" °C"

echo "${output}"
echo "${output}"

if [ -n "${hasRedAlert}" ]; then
  echo "#FF0000"
elif [ -n "${hasYellowAlert}" ]; then
  echo "#FFFF00"
else
  echo "#00FF00"
fi
exit 0
