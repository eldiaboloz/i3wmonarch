#!/usr/bin/env bash
arr=( $(free -m | sed -n 2p) )
#echo "RAM: ${arr[2]}/${arr[1]} MB"
#echo "RAM: ${arr[2]}/${arr[1]} MB"

usage=$(((arr[2]*100)/arr[1]))
echo "RAM: ${usage}%"
echo "RAM: ${usage}%"
if [ $usage -gt 60 ]; then
	echo "#FF0000"
elif [ $usage -gt 40 ]; then
       echo "#FFFF00"
else
	echo "#00FF00"
fi

exit 0
