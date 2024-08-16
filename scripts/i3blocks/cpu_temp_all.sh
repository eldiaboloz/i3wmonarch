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
  /sys/devices/platform/thinkpad_hwmon/hwmon/*/fan1_input
)

tempPath=""
fanPath=""

shopt -s extglob
for x in "${sensors_temp[@]}"; do
  if [ -f "${x}" ]; then
    tempPath="${x}"
    break
  fi
done
for y in "${sensors_fans[@]}"; do
  if [ -f "${y}" ]; then
    fanPath="${y}"
    break
  fi
done
shopt -s extglob

tempval=""
fanval=""

while :; do
  [ -n "${tempPath}" ] && tempval="$(($(cat "${x}") / 1000))"
  [ -n "${fanPath}" ] && fanval="$(cat "${y}")"

  if [ "$tempval" -gt 70 ]; then
    color="#FF0000"
  elif [ "$tempval" -gt 60 ]; then
    color="#FFFF00"
  else
    color="#00FF00"
  fi
  echo "{\"full_text\":\"CPU: ${tempval} °C ${fanval}rpm\",\"short_text\":\"CPU: ${tempval} °C\",\"color\":\"${color}\"}"
  sleep 5
done
