#!/bin/bash
LANG=bg_BG.UTF-8
thestr=" `date '+ %a %d %b %Y %H:%M:%S'`"
full="$thestr"
short="$thestr"
color="#FFFFFF"

case $BLOCK_BUTTON in
  1)
    if ! pgrep gsimplecal 1>/dev/null 2>/dev/null; then
      nohup gsimplecal 1>/dev/null 2>/dev/null &
    fi
  ;;
  3)
    killall gsimplecal 1>/dev/null 2>/dev/null
  ;;
  4)
    if pgrep gsimplecal 1>/dev/null 2>/dev/null; then
      gsimplecal next_month
    fi
  ;;
  5)
    if pgrep gsimplecal 1>/dev/null 2>/dev/null; then
      gsimplecal prev_month
    fi
  ;;
esac
echo $full
echo $short
echo $color
