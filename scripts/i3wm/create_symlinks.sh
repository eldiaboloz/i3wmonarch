#!/bin/bash
# where is project cloned
reporoot=${1:-"/work/dev/personal/i3wmonarch"}
dirs=(
  "$HOME/dev" ""
  "$HOME/.config/htop" ""
  "$HOME/.config/Code - OSS/User" "y"
  "$HOME/.config/i3" "y"
  "$HOME/.config/parcellite" "y"
  "$HOME/.config/gsimplecal" "y"
  "$HOME/.ncmpcpp" ""
  "$HOME/.vim/bundle" ""
  "$HOME/.local/share/rofi" "y"
  "$HOME/.config/xfce4" "y"
)

links=(
  "/" "$HOME/dev/i3wmonarch" ""
  "/.Xmodmap" "$HOME/.Xmodmap" "y"
  "/.vimrc" "$HOME/.vimrc" ""
  "/.xinitrc" "$HOME/.xinitrc" "y"
  "/.xfce4-terminal" "$HOME/.config/xfce4/terminal" "y"
  "/.parcelliterc" "$HOME/.config/parcellite/parcelliterc" "y"
  "/.gsimplecal_config" "$HOME/.config/gsimplecal/config" "y"
  "/.xbindkeysrc" "$HOME/.xbindkeysrc" "y"
  "/.htoprc" "$HOME/.config/htop/htoprc" ""
  "/.vscode.settings.json" "$HOME/.config/Code - OSS/User/settings.json" "y"
  "/.vscode.keybindings.json" "$HOME/.config/Code - OSS/User/keybindings.json" "y"
  "/.tmux.conf" "$HOME/.tmux.conf" ""
  "/.zlogin" "$HOME/.zlogin" ""
  "/.zlogout" "$HOME/.zlogout" ""
  "/.Xresources" "$HOME/.Xresources" "y"
  "/.common_zshrc" "$HOME/.zshrc" ""
  "/.common_bashrc" "$HOME/.bashrc" ""
  "/.common_profile" "$HOME/.profile" ""
  "/.ncmpcpp_config" "$HOME/.ncmpcpp/config" ""
  "/rofi/config/" "$HOME/.config/rofi" "y"
  "/rofi/themes/" "$HOME/.local/share/rofi/themes" "y"
  "/systemd" "$HOME/.config/systemd" "y"
  "/.chromium-flags.conf" "$HOME/.config/chromium-flags.conf" "y"
)

[ -n "${2:-}" ] && dotFilesOnlyFlag="y" || dotFilesOnlyFlag=""

dcnt="${#dirs[@]}"
for ((i = 0; i < $dcnt; i += 2)); do
  target="${dirs[$i]}"
  dotFilesOnlyOpt="${dirs[$i + 1]}"
  # skip this dir
  [ -n "${dotFilesOnlyFlag}" ] && [ -n "${dotFilesOnlyOpt}" ] && continue
  mkdir -v -p "$target"
done

lcnt="${#links[@]}"
for ((i = 0; i < $lcnt; i += 3)); do
  source="$reporoot${links[$i]}"
  target="${links[$i + 1]}"
  dotFilesOnlyOpt="${links[$i + 2]}"
  # skip this dir
  [ -n "${dotFilesOnlyFlag}" ] && [ -n "${dotFilesOnlyOpt}" ] && continue
  if [ -e "$source" ]; then
    if [ ! -e "$target" ]; then
      ln -n -f -v -s "$source" "$target"
    fi
  else
    echo "$source does not exist"
  fi
done
