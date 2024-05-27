#!/bin/bash
# Set windows to standard position/desktop

# Requires
# - wmctrl  (used to move and resize windows)
# - xrandr  (used to find out if we are using multiple screens and to get current resolution)
# - jc      (used to parse xrand output)

screen_nonprimary="terminal"
screen_primary="telegram slack skype spotify chrome signal"

get_wids(){
    wmctrl -l| grep -i "$1" | cut -d ' ' -f 1
}

rearrange(){
    local app screen tmp_w tmp_h screen_start_x screen_start_y

    app="$1"
    screen=$2
    tmp_w=10
    tmp_h=10
    if [[ "$screen" == "primary" ]]; then
        screen_filter="select(.is_primary)"
    else
        screen_filter="select(.is_primary==false)"
    fi
    # device_name=$(xrandr --prop|jc --xrandr|jq '.screens[].devices[] | select(.is_connected) | select(.resolution_height) | '$screen_filter' | .device_name')
    screen_start_x=$(xrandr --prop|jc --xrandr|jq '.screens[].devices[] | select(.is_connected) | select(.resolution_height) | '$screen_filter' | .offset_width')
    screen_start_y=$(xrandr --prop|jc --xrandr|jq '.screens[].devices[] | select(.is_connected) | select(.resolution_height) | '$screen_filter' | .offset_height')

    get_wids "$app" | while read -r winid; do
        wmctrl -i -r $winid -b remove,maximized_vert,maximized_horz
        wmctrl -i -r $winid -e 0,$screen_start_x,$screen_start_y,$tmp_w,$tmp_h
        wmctrl -i -r $winid -b add,maximized_vert,maximized_horz
    done
}

for screen in primary nonprimary; do
    apps=screen_${screen}
    for name in ${!apps}; do
        rearrange $name $screen
    done
done
