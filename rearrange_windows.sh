#!/bin/bash
# Set windows to standard position/desktop

# Requires
# - xdotool (used to search window ids)
# - wmctrl  (used to move and resize windows)
# - xrandr  (used to find out if we are using multiple screens and to get
#            current resolution)

names="Telegram chrome slack skype"

get_wids(){
    xdotool search --maxdepth 2 --onlyvisible --name "$1" || echo NULL
}

rearrange_terminal(){
    resize_width=15
    tmp_w=18
    tmp_h=9
    name_terminal="terminal"
    for winid in $(get_wids "$name_terminal"); do
        if [ "$winid" != "NULL" ]; then
            # Minimize window
            wmctrl -i -r $winid -b remove,maximized_vert,maximized_horz
            # Move window to display
            wmctrl -i -r $winid -e 0,$resize_width,0,$tmp_w,$tmp_h
            # Maximize window
            wmctrl -i -r $winid -b add,maximized_vert,maximized_horz
            # And set sticky
            wmctrl -i -r $winid -b remove,sticky
        fi
    done
}

move_to_desktop(){
    for winid in $(get_wids "$1"); do
        wmctrl -i -r $winid -t $2
    done
}

rearrange(){
    for winid in $(get_wids "$1"); do
        if [ "$winid" != "NULL" ]; then
            # Minimize window
            wmctrl -i -r $winid -b remove,maximized_vert,maximized_horz
            # Move window to display
            wmctrl -i -r $winid -e 0,$resize_width,0,$tmp_w,$tmp_h
            # Maximize window
            wmctrl -i -r $winid -b add,maximized_vert,maximized_horz
            # And set sticky
            wmctrl -i -r $winid -b add,sticky
        fi
    done
}

# Iterate on $names, unless we supplied some as parameter
do_names=${@:-$names}

declare -i num_displays
num_displays=$(xrandr | grep \* | wc -l)

# Only do things if we are using more than 1 display
if [ $num_displays -gt 1 ]; then
    # Calculate more than half the visible screen
    resolution=$(xdpyinfo | awk '/dimensions/{print $2}')
    width=$(echo $resolution | cut -d x -f 1)
    resize_width=15

    rearrange_terminal
    resize_width=$(( ( width/num_displays) + 100))
    tmp_w=1800
    tmp_h=900
    for name in $do_names; do
        # Second screen
        rearrange $name
    done
    # Move spotify to desktop 11 (11-1)
    move_to_desktop spotify 3
fi

