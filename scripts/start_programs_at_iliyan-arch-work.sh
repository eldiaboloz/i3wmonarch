#!/bin/bash
phpstorm
LC_TIME="C" nohup skype > /dev/null  2>&1 &
LC_TIME="C" nohup skypeforlinux > /dev/null 2>&1 &
#nohup viber >/dev/null 2>&1 &
nohup navicat >/dev/null 2>&1 &
nohup start_audioplayer >/dev/null 2>&1 &
nohup google-chrome-unstable >/dev/null 2>&1 &
nohup chromium >/dev/null 2>&1 &
#nohup jetbrains-toolbox >/dev/null 2>&1 &
sleep 3
nohup audioplayer_control play >/dev/null 2>&1 &
