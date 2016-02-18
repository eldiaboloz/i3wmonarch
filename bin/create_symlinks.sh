#!/bin/bash
# where is project cloned
reporoot=${1:-"/work/dev/personal/i3wmonarch"}
dirs=("$HOME/dev" "$HOME/.config/xfce4/terminal" )
links=(\
"/" "$HOME/dev/i3wmonarch" \
"/bin" "$HOME/bin" \
"/.Xmodmap" "$HOME/.Xmodmap" \
"/.XmodmapFnEscape" "$HOME/.XmodmapFnEscape" \
"/i3blocks" "$HOME/.i3blocks" \
"/.vimrc" "$HOME/.vimrc" \
"/.xinitrc" "$HOME/.xinitrc" \
"/.xfce4_terminalrc" "$HOME/.config/xfce4/terminal/terminalrc" \
"/.xbindkeysrc" "$HOME/.xbindkeysrc" \
)

dcnt="${#dirs[@]}"
for (( i=0; i<$dcnt; i+=1 )); do
	target="${dirs[$i]}"
	mkdir --verbose -p "$target"
done

lcnt="${#links[@]}"
for (( i=0; i<$lcnt; i+=2 )); do
	source="$reporoot${links[$i]}"
	target="${links[$i+1]}"
	if [ -e "$source" ]; then
		if [ ! -e "$target" ]; then
			ln --verbose -s "$source" "$target"
		fi
	else
		echo "$source does not exist"
	fi
done
