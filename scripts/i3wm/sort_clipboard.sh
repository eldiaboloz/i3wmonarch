#!/usr/bin/env bash

[ -z "$DISPLAY" ] && exit 1

if [ -z "$1" ]; then
    xclip -out -selection clipboard | sort -h | head -c -1 | xclip -in -selection clipboard
else
    # return unique lines
    xclip -out -selection clipboard | sort -h | uniq | head -c -1 | xclip -in -selection clipboard
fi
