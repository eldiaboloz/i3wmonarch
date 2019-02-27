#!/usr/bin/env bash
pgrep '^i3lock$' > /dev/null && { echo "screen locked!"; exit 1; }
wpdir=${WP_DIR:-"$HOME/Pictures/wallpapers"}
DISPLAY=:0 feh --bg-scale  "$(find -L "$wpdir" -type f | shuf | sed -n 1p)"
