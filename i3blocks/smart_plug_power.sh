#!/usr/bin/env bash
set -e
cd ~/bin
exec /usr/bin/php kasa_tplink_cli_local.php "rig${1}-plug" "rig${1}" i3blockPrint
