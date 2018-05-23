#!/usr/bin/env bash

righash="${1:-0}"

# allow changin ethminer port
ethport=${2:-4000}
rigname="${BLOCK_INSTANCE:-"rig"}"
ssh pi-entry << EOF
    rigip="\$(getent hosts "$rigname" | awk '{ print \$1 }')"
    rigname="${rigname}"
    rigmhs=""
    rigacc=""
    rigrej=""
    rigupt=""
    
	out="\$(echo '{"id":0,"jsonrpc":"2.0","method":"miner_getstat1"}\n' | nc -4 -w 2 "\$rigip" $ethport | jq -r '.result[1],.result[2],.result[6]' | tr '\n' ';')"
    rigupt="\$(echo "\$out" | cut -d ';' -f1)"
    rigmhs=\$((\$(echo "\$out" | cut -d ';' -f2)/1000))
    rigacc="\$(echo "\$out" | cut -d ';' -f3)"
    rigrej="\$(echo "\$out" | cut -d ';' -f4)"
    # expected hash rate for arg1
    righash="$righash"
    if [ -z "\$rigmhs" ]; then
        echo "\$rigname 0 MH/s"
        echo "\$rigname 0 MH/s"
        echo "#FF0000"
        exit
    fi
    rigrej=\${rigrej:-"0"}
    echo -n "\$rigname: \$rigmhs MH/s A-\$rigacc R-\$rigrej"
    # long
    echo -n " \$rigupt min"
    # temps here
    while read -r line; do
        gputemp="\$(echo -n "\$line" | cut -d ';' -f1 )"
        gpufan="\$(echo -n "\$line" | cut -d ';' -f2 )"
        echo -n " \$gputemp-\$gpufan"
    done < <(echo "\$out" | cut -d ';' -f5- | tr ' ' '\n')
    # flush long output
    echo ""
    # short
    echo "\$rigname: \$rigmhs MH/s"
    rigper=\$( bc<<<"(\$rigmhs*100)/\$righash" )
    
    if [ "\$rigper" -lt "60" ]; then
        echo "#FF0000"
    elif [ "\$rigper" -lt "80" ]; then
        echo "#FFFF00"
    else
        echo "#00FF00"
    fi
EOF
