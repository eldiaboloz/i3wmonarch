#!/bin/bash

set -e

# mount encrypted folder
#mountpoint -q /encIliyan || sudo mount /encIliyan

xinput disable 'Microsoft Microsoft® Nano Transceiver v2.0 Mouse' &> /dev/null || true

# setup workspaces
i3-msg "workspace 3; append_layout $HOME/dev/i3wmonarch/.i3layouts/iliyan-arch-work/3.json" &> /dev/null
#i3-msg "workspace 1; append_layout $HOME/dev/i3wmonarch/.i3layouts/1_wide.json" &> /dev/null
#i3-msg "workspace 4🦊; append_layout $HOME/dev/i3wmonarch/.i3layouts/4_wide.json" &> /dev/null
#i3-msg "workspace 5 🦊; append_layout $HOME/dev/i3wmonarch/.i3layouts/5_wide.json" &> /dev/null

nohup solaar -w hide &> /dev/null &
nohup skypeforlinux &> /dev/null &
nohup code &> /dev/null &

systemctl --user start gui@ides-phpstorm
#systemctl --user start gui@ides-datagrip
#systemctl --user start gui@links-viber

systemctl --user start gui@guis-mailclient
systemctl --user start gui@links-chromium
systemctl --user start gui@guis-firefox-alt
#systemctl --user start gui@guis-firefox-dev

# start mpd and pause just in case it was playing on shutdown
systemctl --user start mpd.service; sleep 0.010; mpc pause
