#!/bin/bash
for i in $(seq 1 1727)
do
	if [ ! -f "/work/tmp/xkcd/$i" ];	then
		wget "https://xkcd.com/$i/" --output-document=/work/tmp/xkcd/$i
	else
		echo "$i already exists"
	fi
done
