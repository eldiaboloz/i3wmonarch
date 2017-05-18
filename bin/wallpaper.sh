#!/usr/bin/env bash
wpdir=${WP_DIR:-"/wallpapers"}
DISPLAY=:0 feh --bg-scale  "$(find -L "$wpdir" -type f | shuf | sed -n 1p)"
