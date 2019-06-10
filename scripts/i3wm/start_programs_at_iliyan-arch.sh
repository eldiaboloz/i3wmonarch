#!/bin/bash
$HOME/dev/i3wmonarch/scripts/multimedia/start_audioplayer >/dev/null 2>&1 &
google-chrome-unstable >/dev/null 2>&1 &
pcmanfm >/dev/null 2>&1 &
smplayer >/dev/null 2>&1 &
firefox >/dev/null 2>&1 &
sleep 60
transmission-qt >/dev/null 2>&1 &
