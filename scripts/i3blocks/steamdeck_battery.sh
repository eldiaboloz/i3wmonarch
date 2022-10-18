#!/usr/bin/env bash

set -euf -o pipefail

status=0

curPercent="$(ssh "deck@$1" cat /sys/class/power_supply/BAT1/capacity)"
curStatus="$(ssh "deck@$1" cat /sys/class/power_supply/BAT1/status)"

if [ "${curStatus}" == "Charging" ]; then
  extra=" "
  color="#00FF00"
elif [ "${curStatus}" == "Discharging" ]; then
  if [ "${curPercent}" -le 25 ]; then
    extra=" "
    color="#FF0000"
  else
    extra=" "
    color="#FFFF00"
  fi
else
  color="#FF0000"
  status=33
fi

echo "${BLOCK_INSTANCE}: ${curPercent}% ${extra}"
echo "${BLOCK_INSTANCE}: ${curPercent}% ${extra}"
echo "${color}"

exit "${status}"
