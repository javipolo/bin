#!/bin/bash

# Locks prefix
LOCKS=/tmp/.xscreensaver.lock

case $1 in
    # Things when screen gets locked
    lock)
        # Save spotify state and pause it
        SPOTIFY_STATE=$(sp status)
        if [ "$SPOTIFY_STATE" == "Playing" ]; then
            # Set lockfile to know about it
            touch ${LOCKS}.spotify
            sp pause
        fi
        ;;
    # Things when screen gets unlocked
    unlock)
        # Restore spotify state
        if [ -e ${LOCKS}.spotify ]; then
            rm ${LOCKS}.spotify
            sp play
        fi
        # Set up dualhead and rearrange windows
        ~/bin/X.sh
        ;;
esac
