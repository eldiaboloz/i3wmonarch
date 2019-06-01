#!/bin/bash
# where is project cloned
reporoot=${1:-"/work/dev/personal/i3wmonarch"}
dirs=(\
    "$HOME/dev" \
    "$HOME/.config/xfce4/terminal" \
    "$HOME/.config/htop" \
    "$HOME/.config/Code/User" \
    "$HOME/.config/i3" \
    "$HOME/.config/parcellite" \
    "$HOME/.config/gsimplecal" \
    "$HOME/.ncmpcpp" \
    "$HOME/.vim/bundle" \
    "$HOME/.local/share/rofi" \
)

links=(\
    "/" "$HOME/dev/i3wmonarch" \
    "/.Xmodmap" "$HOME/.Xmodmap" \
    "/.XmodmapFnEscape" "$HOME/.XmodmapFnEscape" \
    "/.vimrc" "$HOME/.vimrc" \
    "/.xinitrc" "$HOME/.xinitrc" \
    "/.xfce4_terminalrc" "$HOME/.config/xfce4/terminal/terminalrc" \
    "/.parcelliterc" "$HOME/.config/parcellite/parcelliterc" \
    "/.gsimplecal_config" "$HOME/.config/gsimplecal/config" \
    "/.xbindkeysrc" "$HOME/.xbindkeysrc" \
    "/.htoprc" "$HOME/.config/htop/htoprc" \
    "/.vscode.settings.json" "$HOME/.config/Code/User/settings.json" \
    "/.vscode.keybindings.json" "$HOME/.config/Code/User/keybindings.json" \
    "/.tmux.conf" "$HOME/.tmux.conf" \
    "/.zlogin" "$HOME/.zlogin" \
    "/.zlogout" "$HOME/.zlogout" \
    "/.Xresources" "$HOME/.Xresources" \
    "/.common_zshrc" "$HOME/.zshrc" \
    "/.common_profile" "$HOME/.profile" \
    "/.ncmpcpp_config" "$HOME/.ncmpcpp/config" \
    "/github.com/VundleVim/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim" \
    "/github.com/robbyrussell/oh-my-zsh" "$HOME/.oh-my-zsh" \
    "/rofi/config/" "$HOME/.config/rofi" \
    "/rofi/themes/" "$HOME/.local/share/rofi/themes" \
)

dcnt="${#dirs[@]}"
for (( i=0; i<$dcnt; i+=1 )); do
	target="${dirs[$i]}"
	mkdir -v -p "$target"
done

lcnt="${#links[@]}"
for (( i=0; i<$lcnt; i+=2 )); do
	source="$reporoot${links[$i]}"
	target="${links[$i+1]}"
	if [ -e "$source" ]; then
		if [ ! -e "$target" ]; then
			ln -v -s "$source" "$target"
		fi
	else
		echo "$source does not exist"
	fi
done
