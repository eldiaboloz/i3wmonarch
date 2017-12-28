#!/bin/bash
# where is project cloned
reporoot=${1:-"/work/dev/personal/i3wmonarch"}
dirs=("$HOME/dev" "$HOME/.config/xfce4/terminal" "$HOME/.config/htop" "$HOME/.config/Code/User" "$HOME/.ncmpcpp" "$HOME/.vim/bundle")

extran=""
hwinfo --keyboard | grep -E "Model.*71M-RGB" 2>/dev/null 1>&2 && extran="Drevo71"

links=(\
"/" "$HOME/dev/i3wmonarch" \
"/bin" "$HOME/bin" \
"/.Xmodmap$extran" "$HOME/.Xmodmap" \
"/.XmodmapFnEscape$extran" "$HOME/.XmodmapFnEscape" \
"/i3blocks" "$HOME/.i3blocks" \
"/.vimrc" "$HOME/.vimrc" \
"/.xinitrc" "$HOME/.xinitrc" \
"/.xfce4_terminalrc" "$HOME/.config/xfce4/terminal/terminalrc" \
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
