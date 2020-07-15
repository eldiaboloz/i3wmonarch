#!/usr/bin/env bash

set -euf -o pipefail

get_con_id() {
  i3-msg -t get_tree\
    | jq '..|.?|select(.nodes)|select(.window_properties.class)|select(.window_properties.class=="'"${1}"'")|.id'\
    |head -n1
}

# window class
class="$1"

# set layout
layout="${2-}"

#retry
retry="${3-}"

for i in $(seq 0 ${retry:-0}); do
  conid="$(get_con_id "$class")"
  if [ -n "${conid}" ]; then
    # found window - switch to it
    i3-msg "[con_id=\"${conid}\"] focus" >/dev/null 2>&1
    # set layout
    [ -n "$layout" ] && i3-msg "layout $layout" >/dev/null 2>&1
    # stop cycle
    break
  else
    [ -z "$retry" ] && break
    # sleep
    sleep 1
  fi
done
