# copy pasted from default file ...
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
if [ -f "$HOME/dev/i3wmonarch/.hosts/$(hostname).once" ]; then
	source "$HOME/dev/i3wmonarch/.hosts/$(hostname).once"
fi

# disable beep
xset -b

case $WM in
ie6-xp)
	# dual monitor is too buggy
	xrandr --output DisplayPort-0 --off
	VirtualBox -startvm "IE6 - WinXP" -fullscreen
	exit
;;
ie11-win7)
	# dual monitor is too buggy
	xrandr --output DisplayPort-0 --off
	VirtualBox -startvm "IE11 - Win7" -fullscreen
	exit
;;
win7)
	VirtualBox -startvm "win7_x86_for_linux" -fullscreen
	exit
;;
*)
	# extra bindings
	xbindkeys

	# seafile client
	seafile-applet &

	# dropbox daemon
	dropbox.py start

	# start ssh-agent on login
	eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
	export SSH_AUTH_SOCK
	exec i3
;;
esac
