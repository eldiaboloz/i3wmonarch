#!/usr/bin/env bash

xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
xrandr --output HDMI-A-0 --auto --addmode "1920x1080_60.00" --primary --output DisplayPort-0 --auto --rotate right --right-of HDMI-A-0

