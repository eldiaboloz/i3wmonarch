#!/usr/bin/env bash

set -euf -o pipefail

[ ! -d "$HOME/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv" ] && {
  python -m venv ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv &&
    ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv/bin/python -m pip install -e 'git+https://github.com/eldiaboloz/TapoP100.git@dev#egg=PyP100'
}

# init connection params ( handshake() and login() )
[ ! -f "/tmp/tapo-p110.${1}.json" ] && ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv/bin/python ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/init.py "${1}"

# read current power consumption. delete connection json on error and hope next call will be ok
~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv/bin/python ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/run.py "${@}" || rm "/tmp/tapo-p110.${1}.json"
