#!/usr/bin/env bash
#xwininfo -id $(xdotool getactivewindow) >> /tmp/log.txt
case "$1" in
    1)
        # prev tab
        xte 'keydown Control_L' 'keydown Page_Up' 'keyup Page_Up' 'keyup Control_L'
        ;;
    2)
        # next tab
        xte 'keydown Control_L' 'keydown Page_Down' 'keyup Page_Down' 'keyup Control_L'
        ;;
    3)
        # prev workspace
        i3-msg 'workspace prev'
        ;;
    4)
        # next workspace
        i3-msg 'workspace next'
        ;;
    5)
        # move to prev workspace
        i3-msg 'move workspace prev;workspace prev'
        ;;
    6)
        # move to next workspace
        i3-msg 'move workspace next;workspace next'
        ;;
esac

