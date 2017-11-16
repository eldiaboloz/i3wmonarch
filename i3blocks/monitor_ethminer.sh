#!/usr/bin/env bash

printme=""

while read -r line; do
    rign=$(echo "$line" | cut -d ';' -f1)
    rigu=$(echo "$line" | cut -d ';' -f2)
    if [ -z "$rigu" ]; then
        continue
    fi
    righ=$(($(echo "$line" | cut -d ';' -f3)/1000))
    rigs=$(echo "$line" | cut -d ';' -f4)
    rigr=$(echo "$line" | cut -d ';' -f5)
    printme="$printme $rign: $righ MH/s A-${rigs}"
    if [ "$rigr" -ne "0" ]; then
        printme="${printme};R-${rigr}"
    fi
    printme="$printme $rigu min |"
done < <(ssh pi-entry /root/monitor_ethminer.sh)

printme="${printme::-2}"
echo "$printme"
echo "#FFFFFF"
echo "#FFFFFF"

