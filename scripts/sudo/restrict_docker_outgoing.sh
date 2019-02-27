#!/usr/bin/bash

set -e

chain=DOCKER-USER
setup(){
    /sbin/iptables -I "$chain" -d 10.0.0.0/24 -j DROP
    /sbin/iptables -I "$chain" -d 10.0.1.0/24 -j DROP
}
cleanup(){
    # clear current ips
    for y in $(seq "$(/sbin/iptables -L "$chain" -n --line-num | grep 'DROP' | wc -l)" -1 1); do
	    /sbin/iptables -D "$chain" $y
    done
}
case "$1" in 
    *)
        # by default cleanup and setup
        cleanup
        setup
    ;;
esac
