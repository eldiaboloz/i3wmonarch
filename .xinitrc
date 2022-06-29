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

# load setup script when starting X server based on hostname
if [ -f "$HOME/dev/i3wmonarch/.hosts/$(hostname)/xinit" ]; then
    source "$HOME/dev/i3wmonarch/.hosts/$(hostname)/xinit"
fi

# disable beep
xset -b

# extra bindings
xbindkeys &> /dev/null &

# fix for .zlogin/.zlogout
ssh-agent -k &> /dev/null &

# start clipboard manager
parcellite  &> /dev/null &

# bluetooth applet
blueman-applet &> /dev/null &

# start ssh-agent on login
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

$HOME/dev/i3wmonarch/scripts/i3wm/gen_i3config.sh

exec i3 --config $HOME/.config/i3/config
