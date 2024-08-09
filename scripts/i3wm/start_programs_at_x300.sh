#!/bin/bash

set -e

xinput disable 'Microsoft Microsoft® Nano Transceiver v2.0 Mouse' &> /dev/null || true

# setup workspaces
i3-msg 'workspace 12; append_layout ~/dev/i3wmonarch/.i3layouts/H/12.json'
i3-msg 'workspace 11; append_layout ~/dev/i3wmonarch/.i3layouts/H/11.json'
i3-msg "workspace 7; append_layout $HOME/dev/i3wmonarch/.i3layouts/H/7.json"
i3-msg "workspace \"5 🦊\"; append_layout $HOME/dev/i3wmonarch/.i3layouts/H/5.json";
i3-msg "workspace \"4🦊\"; append_layout $HOME/dev/i3wmonarch/.i3layouts/firefox-alt.json";
i3-msg "workspace \"3\"; append_layout $HOME/dev/i3wmonarch/.i3layouts/H/3.json"
i3-msg "workspace \"2\"; append_layout $HOME/dev/i3wmonarch/.i3layouts/H/2.json"
i3-msg "workspace \"1\"; append_layout $HOME/dev/i3wmonarch/.i3layouts/H/1.json"

nohup xfce4-terminal -e 'htop' -T 'htop' --role 'the_htop' --disable-server &> /dev/null &
nohup xfce4-terminal -e 'ctop' -T 'ctop' --role 'the_ctop' --disable-server &> /dev/null &

solaar -w hide &> /dev/null &
# code crashes as a service ...
code &> /dev/null &
nohup xfce4-terminal --role code-term &> /dev/null &

# chromium profiles
nohup /work/dev/bin/xdebug &> /dev/null &
nohup /work/dev/bin/iliyan87.ivanov@gmail.com &> /dev/null &


systemctl --user start gui@ides-phpstorm
systemctl --user start gui@ides-datagrip
systemctl --user start gui@links-viber
systemctl --user start gui@links-skype
systemctl --user start gui@guis-firefox-alt

systemctl --user start gui@guis-mailclient
systemctl --user start gui@links-chromium
systemctl --user start gui@guis-firefox-main

# start mpd and pause just in case it was playing on shutdown
systemctl --user start mpd.service; sleep 0.1; mpc pause
