#!/bin/bash
cputemp="$(
sensors -j coretemp-isa-0000 \
  | jq -r '."coretemp-isa-0000" | to_entries[]|select(.key | test("^(Package|Core)")).value|to_entries[]|select(.key | test("^temp[0-9]+_input.*")).value' \
  | sort -r | head -n 1
)"
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
