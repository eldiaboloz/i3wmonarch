source ~/.profile
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi
[ -z "$SSH_AUTH_SOCK" ] && eval $(ssh-agent)
