#!/usr/bin/env bash

set -e

export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority

# set keyboard layout
setxkbmap -layout "us,bg" -model "pc104" -variant "euro,phonetic" -option "grp:shifts_toggle,grp_led:scroll"
xmodmap $HOME/.Xmodmap

# disable some inputs
xinput disable 'Microsoft Microsoft® Nano Transceiver v2.0 Mouse' || true

