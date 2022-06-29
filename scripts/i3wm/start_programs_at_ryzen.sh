#!/bin/bash

set -e

# mount encrypted folder
mountpoint -q /encIliyan || sudo mount /encIliyan

# setup workspaces
i3-msg "workspace 3; append_layout $HOME/dev/i3wmonarch/.i3layouts/iliyan-arch-work/3.json" &> /dev/null

nohup jetbrains-toolbox &> /dev/null &
sleep 1

nohup solaar &> /dev/null &
nohup phpstorm &> /dev/null &
nohup code &> /dev/null &
nohup skypeforlinux &> /dev/null &
#nohup viber &> /dev/null &
nohup mail-client &> /dev/null &
nohup chromium &> /dev/null &
nohup firefox-alt &> /dev/null &
