#!/bin/bash

# setup workspaces
i3-msg "workspace 3; append_layout $HOME/dev/i3wmonarch/.i3layouts/iliyan-arch-work/3.json" > /dev/null 2>&1

nohup phpstorm_eap > /dev/null 2>&1 &
nohup code > /dev/null 2>&1 &
nohup skypeforlinux > /dev/null 2>&1 &
nohup viber >/dev/null 2>&1 &
#nohup navicat >/dev/null 2>&1 &
nohup start_audioplayer >/dev/null 2>&1 &
#nohup google-chrome-unstable >/dev/null 2>&1 &
nohup thunderbird >/dev/null 2>&1 &
nohup chromium >/dev/null 2>&1 &
nohup jetbrains-toolbox >/dev/null 2>&1 &
sleep 2 
nohup audioplayer_control play >/dev/null 2>&1 &

