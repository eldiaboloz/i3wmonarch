#!/usr/bin/env bash
# where is project cloned
reporoot="$HOME/dev/i3wmonarch"
links=(
  "/.Xmodmap" "$HOME/.Xmodmap"
  "/.xinitrc" "$HOME/.xinitrc"
  "/.xbindkeysrc" "$HOME/.xbindkeysrc"
  "/.Xresources" "$HOME/.Xresources"
  "/.config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
  "/.config/xfce4/terminal" "$HOME/.config/xfce4/terminal"
  "/.config/parcellite" "$HOME/.config/parcellite"
  "/.config/gsimplecal" "$HOME/.config/gsimplecal"
  "/.config/ncmpcpp" "$HOME/.config/ncmpcpp"
  "/.config/systemd" "$HOME/.config/systemd"
  "/.config/Code - OSS/User/keybindings.json" "$HOME/.config/Code - OSS/User/keybindings.json"
  "/.config/Code - OSS/User/settings.json" "$HOME/.config/Code - OSS/User/settings.json"
  "/.config/rofi" "$HOME/.config/rofi"
  "/.local/share/rofi" "$HOME/.local/share/rofi"
  "/.config/pcmanfm" "$HOME/.config/pcmanfm"
  "/.config/mimeapps.list" "$HOME/.config/mimeapps.list"
  "/.config/qalculate" "$HOME/.config/qalculate"
  "/.config/mpd" "$HOME/.config/mpd"
)

lcnt="${#links[@]}"
for ((i = 0; i < $lcnt; i += 2)); do
  source="$reporoot${links[$i]}"
  target="${links[$i + 1]}"
  if [ -e "$source" ]; then
    mkdir -pv "$(dirname "${target}")"
    if [ ! -e "$target" ]; then
      ln -n -f -v -s "$source" "$target"
    else
      srcRP="$(realpath "${source}")"
      dstRP="$(realpath "${target}")"
      if [ "${srcRP}" != "${dstRP}" ]; then
        echo "src: '$(realpath "${source}")'"
        echo "dst: '$(realpath "${target}")'"
        echo ""
      fi
    fi
  else
    echo "$source does not exist"
  fi
done
