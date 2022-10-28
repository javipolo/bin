#!/bin/bash
# Set windows to standard position/desktop

# Requires
# - xdotool (used to search window ids)
# - wmctrl  (used to move and resize windows)
# - xrandr  (used to find out if we are using multiple screens and to get
#            current resolution)

apps_left=""
apps_center="terminal"
apps_right="telegram slack skype spotify chrome"
screens=${*:-left center right}

get_wids(){
    xdotool search --maxdepth 2 --onlyvisible --name "$1" || echo NULL
}

move_to_desktop(){
    for winid in $(get_wids "$1"); do
        wmctrl -i -r $winid -t $2
    done
}

rearrange(){
    local app screen laptop_lid n num_displays resolution width resize_width tmp_w tmp_h
    declare -i num_displays

    app="$1"
    screen=$2
    laptop_lid=$(awk '{print $NF}' /proc/acpi/button/lid/LID/state)

    if [ "$laptop_lid" == "closed" ]; then
        case $screen in
            center) n=0;;
            right) n=1;;
            # If lid is closed, left screen stuff goes to right screen
            left) n=1;;
        esac
    else
        case $screen in
            left) n=0;;
            center) n=1;;
            right) n=2;;
        esac
    fi

    num_displays=$(xrandr | grep -c '*')
    resolution=$(xdpyinfo | awk '/dimensions/{print $2}')
    width=$(echo $resolution | cut -d x -f 1)
    resize_width=$(( n * ( width/num_displays) + 100))
    tmp_w=10
    tmp_h=10

    for winid in $(get_wids "$app"); do
        if [ "$winid" != "NULL" ]; then
            wmctrl -i -r $winid -b remove,maximized_vert,maximized_horz
            wmctrl -i -r $winid -e 0,$resize_width,0,$tmp_w,$tmp_h
            wmctrl -i -r $winid -b add,maximized_vert,maximized_horz
            wmctrl -i -r $winid -b add,sticky
        fi
    done
}

declare -i num_displays
num_displays=$(xrandr | grep -c '*')

# Only do things if we are using more than 1 display
if [ $num_displays -gt 1 ]; then
    for screen in $screens; do
        apps=apps_${screen}
        for name in ${!apps}; do
            rearrange $name $screen
        done
    done
fi

