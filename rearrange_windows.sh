#!/bin/bash
# Set windows to standard position/desktop

# Requires
# - wmctrl  (used to move and resize windows)
# - xrandr  (used to find out if we are using multiple screens and to get current resolution)

screen_1="terminal"
screen_2="telegram slack skype spotify chrome"
laptop_screen_name=eDP-1

get_wids(){
    wmctrl -l| grep -i "$1" | cut -d ' ' -f 1
}

rearrange(){
    local app screen tmp_w tmp_h screen_start screen_start_x screen_start_y

    app="$1"
    screen=$2
    tmp_w=10
    tmp_h=10
    lid_state=$(awk '{print $NF}' /proc/acpi/button/lid/LID/state)
    if [ "$lid_state" == "closed" ]; then
      screen_start=$(xrandr| grep -v "^$laptop_screen_name" | grep ' connected' | cut -d ' ' -f 3 | cut -d + -f 2,3 | sort | head -n $screen | tail -n1)
    else
      screen_start=$(xrandr|grep ' connected' | cut -d ' ' -f 3 | cut -d + -f 2,3 | sort | head -n $screen | tail -n1)
    fi
    screen_start_x=$(cut -d + -f 1 <<< $screen_start)
    screen_start_y=$(cut -d + -f 2 <<< $screen_start)

    get_wids "$app" | while read -r winid; do
      wmctrl -i -r $winid -b remove,maximized_vert,maximized_horz
      wmctrl -i -r $winid -e 0,$screen_start_x,$screen_start_y,$tmp_w,$tmp_h
      wmctrl -i -r $winid -b add,maximized_vert,maximized_horz
    done
}

num_displays=$(xrandr | grep -c ' connected')
for screen in $(seq $num_displays); do
    apps=screen_${screen}
    for name in ${!apps}; do
        rearrange $name $screen
    done
done
