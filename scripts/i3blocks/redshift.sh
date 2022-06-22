#!/bin/bash

step=${BLOCK_INSTANCE:-100}

validate_min_max() {
  maxval="25000"
  minval="1000"
  newval="$1"
  (("$newval" > "$maxval")) && newval="$maxval"
  (("$newval" < "$minval")) && newval="$minval"
  echo $newval
}
set_color_temp() {
  COLOR_TEMP="$1"
  redshift -P -O "${COLOR_TEMP}"
  pkill -RTMIN+10 i3blocks
}

COLOR_TEMP="$(cat /tmp/redshift_last_color_temp | tr -dc '0-9')"
[ -z "${COLOR_TEMP}" ] && COLOR_TEMP=6000

case ${1:-$BLOCK_BUTTON} in
inc | 4)
  set_color_temp "$(validate_min_max "$((COLOR_TEMP + step))")"
  ;;
dec | 5)
  set_color_temp "$(validate_min_max "$((COLOR_TEMP - step))")"
  ;;
max | 3)
  set_color_temp "6000"
  ;;
min | 1)
  set_color_temp "1200"
  ;;
toggle | 2)
  # toggle between 1200 and 6000 with middle click
  if (("${COLOR_TEMP}" <= "3000")); then
    set_color_temp "6000"
  else
    set_color_temp "1200"
  fi
  ;;
esac

if ((${COLOR_TEMP} <= 1500)); then
  icon="🌑"
elif ((${COLOR_TEMP} <= 2000)); then
  icon="🕯"
elif ((${COLOR_TEMP} <= 3000)); then
  icon="💡"
else
  icon="🌞"
fi

echo "$icon ${COLOR_TEMP}K"
echo "${COLOR_TEMP}K"
