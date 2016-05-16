#!/bin/bash
# arrange monitors based on current machine
cur=`hostname`
case $cur in
	'iliyan-arch-work')
		xrandr --output DisplayPort-0 --left-of HDMI-2
	;;
	'iliyan-arch')
		xrandr --output eDP1 --off
		xrandr --output HDMI1 --off
	;;
esac
