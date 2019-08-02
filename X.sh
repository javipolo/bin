#!/bin/bash

remap_capslock(){
    # Remap CAPSLOCK to ^ if its not already done
    if [ "$(xmodmap -pk |awk '{ if ($1 == "66") print $3}'|tr -d '()')" != 'asciicircum' ]; then
        xmodmap -e 'clear Lock'
        xmodmap -e 'keycode 66 = asciicircum'
    fi
}

boost_brightness(){
    # Boost brightness
    SCREENS="$(xrandr -q|awk '/ connected/{print $1}')"
    for i in $SCREENS; do xrandr --output $i --brightness 1; done
}
if [ -n "${DISPLAY}" ]; then
    ~/bin/xrandr.sh
    remap_capslock
    boost_brightness
    # Disable tapping
    pgrep syndaemon || syndaemon -i 1.5 -K -m 50 -t -d
    # Rearrange windows
    ~/bin/rearrange_windows.sh
fi
