#!/usr/bin/env bash

righash="${1:-0}"
rigip="192.168.1.201"
rigname="${BLOCK_INSTANCE:-"rig"}"

ssh pi-entry << EOF
    rigip="\$(getent hosts "$rigname" | awk '{ print \$1 }')"
    rigname="${rigname}"
    rigmhs=""
    rigacc=""
    rigrej=""
    rigupt=""
    
    ccmout=\$(echo -ne 'summary\n' | nc -4 -w 2 "\$rigip" 4001)
    # ccminer is on port 4001 / ethminer on port 4000
    if [ "\$?" -ne "0" ]; then
	    ccmout="\$(echo '{"id":0,"jsonrpc":"2.0","method":"miner_getstat1"}\n' | nc -4 -w 2 "\$rigip" 4000 | jq -r '.result[1],.result[2]' | tr '\n' ';')"
        rigupt="\$(echo "\$ccmout" | cut -d ';' -f1)"
        rigmhs=\$((\$(echo "\$ccmout" | cut -d ';' -f2)/1000))
        rigacc="\$(echo "\$ccmout" | cut -d ';' -f3)"
        rigrej="\$(echo "\$ccmout" | cut -d ';' -f4)"
    elif [ ! -z "\$ccmout" ]; then
	    eval "\$(echo "\$ccmout" | tr -d '|')"
        rigmhs="\$(echo "$\KHS" | cut d '.' -f1)"
        rigupt="\$((UPTIME/60))"
        rigacc="\$ACC"
        rigrej="\$REJ"
    fi
    if [ -z "\$rigmhs" ]; then
        echo "\$rigname 0 MH/s"
        echo "\$rigname 0 MH/s"
        echo "#FF0000"
        exit
    fi
    rigrej=\${rigrej:-"0"}
    echo -n "\$rigname: \$rigmhs MH/s A-\$rigacc R-\$rigrej"
    # long
    echo " \$rigupt min"
    # short
    echo "\$rigname: \$rigmhs MH/s"
    rigper=\$( bc<<<"(\$rigmhs*100)/$righash" )
    if [ "\$rigper" -lt "60" ]; then
        echo "#FF0000"
    elif [ "\$rigper" -lt "80" ]; then
        echo "#FFFF00"
    else
        echo "#00FF00"
    fi
EOF