#!/usr/bin/env bash

set -euf -o pipefail

[ ! -d "$HOME/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv" ] && {
  python -m venv ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv &&
    ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv/bin/python -m pip install -e 'git+https://github.com/eldiaboloz/TapoP100.git@dev#egg=PyP100'
}

~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/venv/bin/python ~/dev/i3wmonarch/scripts/i3blocks/tapo-p110/run.py "${@}"
