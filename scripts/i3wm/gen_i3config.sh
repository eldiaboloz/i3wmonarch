#!/usr/bin/env bash

set -e

[ -f "$HOME/dev/i3wmonarch/.hosts/$HOSTNAME/i3config" ] && source "$HOME/dev/i3wmonarch/.hosts/$HOSTNAME/i3config"

[ -z "$I3WM_CONFIGS" ] && \
    I3WM_CONFIGS=00_header 40_windows 50_workspaces 60_hotkeys 60_hotkeys_audio 60_hotkeys_windows 60_hotkeys_workspaces 97_single_top_bar

[ -z "$I3WM_I3BLOCKS_SINGLE" ] && \
    I3WM_I3BLOCKS_SINGLE=$HOME/dev/i3wmonarch/i3blocks/single.conf

[ -z "$I3WM_LEFT_OUT" ] && \
    I3WM_LEFT_OUT=$(xrandr --query | grep connected | grep -v disconnected | cut -d ' ' -f1)

[ -z "$I3WM_RIGHT_OUT" ] && \
    I3WM_LEFT_OUT=$(xrandr --query | grep connected | grep -v disconnected | cut -d ' ' -f1)

mkdir -pv "$HOME/.config/i3"

echo "" > "$HOME/.config/i3/config"

for x in $(echo "$I3WM_CONFIGS"|tr ' ' '\n'); do
    cat "$HOME/dev/i3wmonarch/templates/i3config/$x" >> "$HOME/.config/i3/config"
done

sed -i "s#{{%leftout%}}#${I3WM_LEFT_OUT}#g" "$HOME/.config/i3/config"
sed -i "s#{{%rightout%}}#${I3WM_RIGHT_OUT}#g" "$HOME/.config/i3/config"
sed -i "s#{{%single_top_bar%}}#${I3WM_I3BLOCKS_SINGLE}#g" "$HOME/.config/i3/config"

