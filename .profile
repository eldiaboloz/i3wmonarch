# PATH setup
PATH="/work/dev/bin:$PATH"

# load host specific init script
if [ -f "$HOME/dev/i3wmonarch/.hosts/$HOST/init" ]; then
  source "$HOME/dev/i3wmonarch/.hosts/$HOST/init"
fi

# current terminal to use
export TERMINAL=xfce4-terminal

# setup go ...
GOCACHE="$HOME/.cache/go-build"
GOPATH="$HOME/go"
PATH="$GOPATH/bin:$PATH"
export EDITOR=vim

export MPD_HOST=172.16.0.1
export MPD_PORT=8600


