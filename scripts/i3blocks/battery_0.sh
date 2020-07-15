#!/usr/bin/env bash
# copy paste of https://github.com/acleverpun/i3-blocks-contrib/blob/master/battery for now
full=""
short=""
status=0

acpidata="$(acpi | sed -n 1p)"

# Exit if no battery was found
if [ "${acpidata}" == "" ]; then exit 0; fi

state=$(echo -ne "${acpidata}" | sed -n 's/Battery [0-9]: \([A-Z]\).*, .*/\1/p')
chg=$(echo -ne "${acpidata}" | sed -n 's/Battery [0-9]:.*, \([0-9]\{1,3\}\)%.*/\1/p')

# Charging or Unknown
if [ $state = "C" ] || [ $state = "U" ]; then
  icon=""
else
  if [ $chg -le 10 ]; then
    icon=""
    status=33
  else
    icon=""
  fi
fi

full="$icon $chg%"
short="$chg%"

echo $full
echo $short
exit $status
