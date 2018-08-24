#!/usr/bin/env bash
set -e
data="$(kasa_tplink_cli power "Rig ${1}")"
max=${2:-"850"}
min=${3:-"700"}
if [ -z "$data" ]; then
    exit 1 
fi
echo "rig${1}: $data W"
echo "$data "
if [ "$data" -ge "$max" ]; then
    echo "#FF0000"
elif [ "$data" -le "$min" ]; then
    echo "#FFFF00"
else
    echo "#00FF00"
fi

