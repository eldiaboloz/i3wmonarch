#!/usr/bin/env bash
set -euf -o pipefail

[ "$#" -ge 1 ] && name="$1" || name=""

if [ -n "$name" ]; then
  coproc CHOSEN_IDE="$name" $HOME/dev/i3wmonarch/scripts/ides/jetbrains-ide.sh >/dev/null 2>&1
  exec 1>&-
  exit
fi

PRINT_ONLY=y $HOME/dev/i3wmonarch/scripts/ides/jetbrains-ide.sh

# vim:sw=2:ts=2:et:
