#!/usr/bin/env bash

set -e

[ -f ~/.fixkbd.lock ] && exit

touch ~/.fixkbd.lock

sleep 3

~/dev/i3wmonarch/scripts/i3wm/fix_keyboard.sh
