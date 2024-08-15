#!/bin/bash
LANG=bg_BG.UTF-8

if [ "${BLOCK_INTERVAL:-}" == "persist" ]; then
  while :; do
    echo "$(date '+ %a %d %b %Y %H:%M:%S')"
    sleep 1
  done
  exit
fi

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
thestr="$(date '+ %a %d %b %Y %H:%M:%S')"
echo "${thestr}"
echo "${thestr}"
echo "#FFFFFF"
