# copy pasted from default file ...
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
# merge in defaults and keymaps

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
if [ -f "$HOME/dev/i3wmonarch/.hosts/$(hostname).once" ]; then
	source "$HOME/dev/i3wmonarch/.hosts/$(hostname).once"
fi

# disable beep
xset -b

# extra bindings
xbindkeys

# seafile client
seafile-applet &

# start ssh-agent on login
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
exec i3
