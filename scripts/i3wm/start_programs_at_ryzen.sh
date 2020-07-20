#!/bin/bash

# setup workspaces
i3-msg "workspace 3; append_layout $HOME/dev/i3wmonarch/.i3layouts/iliyan-arch-work/3.json" > /dev/null 2>&1

nohup jetbrains-toolbox >/dev/null 2>&1 &
sleep 1

nohup $HOME/dev/i3wmonarch/scripts/ides/phpstorm > /dev/null 2>&1 &
nohup code > /dev/null 2>&1 &
nohup skypeforlinux > /dev/null 2>&1 &
nohup viber >/dev/null 2>&1 &
nohup $HOME/dev/i3wmonarch/scripts/guis/mail-client >/dev/null 2>&1 &
nohup chromium >/dev/null 2>&1 &
