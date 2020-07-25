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
  ;;
dec | 5)
  COLOR_TEMP=$(validate_min_max "$((COLOR_TEMP - step))")
  redshift -P -O "${COLOR_TEMP}"
  ;;
reset | 3)
  # reset to 6000K with middle click
  redshift -P -O "6000"
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
