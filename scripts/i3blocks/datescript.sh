#!/bin/bash
LANG=bg_BG.UTF-8
thestr=" `date '+ %a %d %b %Y %H:%M:%S'`"
full="$thestr"
short="$thestr"
color="#FFFFFF"
status=0

case $BLOCK_BUTTON in
	# 1-2-3 left-middle-right mouse button
	1) gsimplecal >/dev/null ;;
esac
echo $full
echo $short
echo $color
exit $status
