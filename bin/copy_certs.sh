#!/usr/bin/env bash

set -e

# target host
th=$1
[ -z "$th" ] && { echo "No target host (arg 1 )" ; exit 1; }

# target domain - by default equals target host
td=${2:-"$th"}

ssh "$th" mkdir -pv /etc/certs_from_le/
source_dir="root@localhost:/etc/letsencrypt/live/${td}/"
target_dir="root@${th}:/etc/certs_from_le/"

scp -4 -3 "${source_dir}"'*' "${target_dir}"

ssh -- "$th" 'chmod -v 0700 /etc/certs_from_le/; chmod -v 0600 /etc/certs_from_le/*'

ssh -- "$th" "[ -f /root/install_le_certs.sh ] && /root/install_le_certs.sh $td"
