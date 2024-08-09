# PATH setup

binPaths=(
  "/work/dev/bin"
  "$HOME/dev/i3wmonarch/scripts/ides"
  "$HOME/dev/i3wmonarch/scripts/guis"
  "$HOME/dev/i3wmonarch/bin"
)
PATH="$(printf "%s:" "${binPaths[@]}")${PATH}"
unset binPaths

# load host specific init script
if [ -f "$HOME/dev/i3wmonarch/.hosts/$HOST/init" ]; then
  source "$HOME/dev/i3wmonarch/.hosts/$HOST/init"
fi

# current terminal to use
export TERMINAL=xfce4-terminal
export MPD_HOST=172.16.0.1
export MPD_PORT=8600
