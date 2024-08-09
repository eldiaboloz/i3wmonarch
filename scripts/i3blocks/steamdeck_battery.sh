#!/usr/bin/env bash

set -euf -o pipefail

status=0

stInfo="$(ssh -o ConnectTimeout=1 "deck@$1" "cat /sys/class/power_supply/BAT1/capacity; cat /sys/class/power_supply/BAT1/status" || true)"

curPercent="$(echo "${stInfo}" | sed '1q;d')"
curStatus="$(echo "${stInfo}" | sed '2q;d')"

if [ "${curStatus}" == "Charging" ] || [ "${curStatus}" == "Full" ]; then
  extra=""
  color="#00FF00"
elif [ "${curStatus}" == "Discharging" ]; then
  if [ "${curPercent}" -le 25 ]; then
    extra=""
    color="#FF0000"
  else
    extra=""
    color="#FFFF00"
  fi
else
  curPercent="  X"
  extra="❌"
  color="#FFFF00"
  status=0
fi

echo "${BLOCK_INSTANCE}: ${curPercent}% ${extra}"
echo "${BLOCK_INSTANCE}: ${curPercent}% ${extra}"
echo "${color}"

exit "${status}"
