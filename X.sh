#!/bin/bash

boost_brightness(){
    # Boost brightness
    SCREENS="$(xrandr -q|awk '/ connected/{print $1}')"
    for i in $SCREENS; do xrandr --output $i --brightness 1; done
}
if [ -n "${DISPLAY}" ]; then
    ~/bin/xrandr.sh
    boost_brightness
    # Disable tapping
    pgrep syndaemon || syndaemon -i 1.5 -K -m 50 -t -d
    # Rearrange windows
    ~/bin/rearrange_windows.sh
fi
