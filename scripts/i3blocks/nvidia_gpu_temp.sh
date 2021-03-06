#!/bin/bash

cmd=nvidia-smi

[[ "$(basename "$0")" == "optimus_temp.sh" ]] && cmd="optirun $cmd"

gputemp=$($cmd --query-gpu=temperature.gpu --format=csv,noheader)

echo "GPU: $gputemp °C"
echo "GPU: $gputemp °C"

if [ $gputemp -gt 70 ]; then
	echo "#FF0000"
elif [ $gputemp -gt 60 ]; then
	echo "#FFFF00"
else
	echo "#00FF00"
fi

exit 0
