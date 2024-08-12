# copy pasted from default file ...
# vim: ft=sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
# merge in defaults and keymaps
# setting layout here, before setting custom xmodmaps 
setxkbmap -layout "us,bg" -model "pc104" -variant "euro,phonetic" -option "grp:shifts_toggle,grp_led:scroll"
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi
# end of copy-pasted

# init all displays
xrandr --auto

# apply xinit commands
cat ~/dev/i3wmonarch/hosts.yaml | yq '.hosts.'$(hostname)'.xinit' | jq --raw-output0 '.[]' | xargs -0 -I{} sh -c '{}'

# disable beep
xset -b

# fix for .zlogin/.zlogout
ssh-agent -k &> /dev/null &

# start gnome-keyring-daemon on login
which /usr/bin/gnome-keyring-daemon &> /dev/null && /usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets
# set SSH_AUTH_SOCK
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

if [[ -x "$HOME/dev/i3wmonarch/.hosts/$(hostname)/startx" ]]; then
  exec "$HOME/dev/i3wmonarch/.hosts/$(hostname)/startx"
else
  $HOME/dev/i3wmonarch/scripts/i3wm/gen_i3config.php
  exec i3 --config $HOME/.config/i3/config
fi

