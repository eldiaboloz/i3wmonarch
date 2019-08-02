#!/usr/bin/env bash

set -e
batval="$(cat /tmp/datafromphone.txt | tr -d '[:space:]')"
[ -z "$batval" ] && exit
if [ "$batval" -ge 90 ]; then
  battery=''
elif [ "$batval" -ge 75 ]; then
  battery=''
elif [ "$batval" -ge 50 ]; then
  battery=''
elif [ "$batval" -ge 25 ]; then
  battery=''
else
  battery=''
fi

echo " $battery $batval %"
echo " $battery $batval %"
