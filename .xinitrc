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
if [ -f "$HOME/dev/i3wmonarch/.hosts/$(hostname).once" ]; then
    source "$HOME/dev/i3wmonarch/.hosts/$(hostname).once"
fi

# disable beep
xset -b

case $VM in
    ie8|ie9|ie10|ie11)
        # dual monitor is too buggy
        xrandr --output DisplayPort-0 --off
        VirtualBox -startvm "$(tr '[:lower:]' '[:upper:]' <<<$VM) - Win7" -fullscreen
        exit
        ;;
    win7)
        VirtualBox -startvm "win7_x86_for_linux" -fullscreen
        exit
        ;;
esac    
# extra bindings
xbindkeys

# seafile client
seafile-applet &

# dropbox daemon
dropbox.py start

# fix for .zlogin/.zlogout
ssh-agent -k

# start clipboard manager
parcellite &

# bluetooth applet
blueman-applet 1>/dev/null 2>&1 &
I3CONFIGNAME=${I3CONFIGNAME:-"config"}
# start ssh-agent on login
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
exec i3 --config $HOME/.config/i3/${I3CONFIGNAME}
