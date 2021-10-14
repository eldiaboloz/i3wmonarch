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

COLOR_TEMP="$(cat /tmp/redshift_last_color_temp | tr -dc '0-9')"
[ -z "${COLOR_TEMP}" ] && COLOR_TEMP=6000

case ${1:-$BLOCK_BUTTON} in
inc | 4)
  COLOR_TEMP=$(validate_min_max "$((COLOR_TEMP + step))")
  redshift -P -O "${COLOR_TEMP}"
  pkill -RTMIN+10 i3blocks
  ;;
dec | 5)
  COLOR_TEMP=$(validate_min_max "$((COLOR_TEMP - step))")
  redshift -P -O "${COLOR_TEMP}"
  pkill -RTMIN+10 i3blocks
  ;;
max | 3)
  # set to 6000K with right click
  redshift -P -O "6000"
  pkill -RTMIN+10 i3blocks
  ;;
min | 1)
  # set to min 1200K with left click
  redshift -P -O "1200"
  pkill -RTMIN+10 i3blocks
  ;;
toggle | 2)
  # toggle between 1200 and 6000 with middle click
  if (("${COLOR_TEMP}" <= "3000")); then
    redshift -P -O "6000"
  else
    redshift -P -O "1200"
  fi
  pkill -RTMIN+10 i3blocks
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
