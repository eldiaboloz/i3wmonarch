#!/bin/bash
case $1 in
inc)
pactl set-sink-volume "alsa_output.usb-Creative_Technology_Ltd._SB_Tactic3D_Rage_Wireless-00.analog-stereo" +5%
;;
dec)
pactl set-sink-volume "alsa_output.usb-Creative_Technology_Ltd._SB_Tactic3D_Rage_Wireless-00.analog-stereo" -5%
;;
mute)
pactl set-sink-mute "alsa_output.usb-Creative_Technology_Ltd._SB_Tactic3D_Rage_Wireless-00.analog-stereo" toggle
;;
esac
sleep 0.1
pkill -RTMIN+1 i3blocks
