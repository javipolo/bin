#!/bin/bash

# Move focus back to current window when opening URLs
preserve_focus=true
# default_filter="-ignore"
default_filter=$(grep -E '^report.ls.filter=' ~/.taskrc | cut -d = -f 2-)

usage(){
  cat << EOF
TaskWarrior scripts

If command is not existing, just call task with the same arguments
Usage:
  t command args
  t taskwarriorarguments

  commands:
  w TASKS         Tag as Waiting
  q TASKS         Tag as Queued
  d TASKS         Tag as Doing
  o TASK          Open task URL
  h               This help

  you can use a tag filter as args, example:
  t o +u          Open all the tasks that are tagged +u (updated)

Examples:
  t w 20
  t w "/text that matches task/"
  t d 15 30
  t next

My tags:
  w   Waiting       - waiting for feedback or other external events
  q   Queued        - ready to pick up and start working
  d   Doing         - in progress

  n   New           - New imported task. To be revised and moved in one of the previous states
  u   Updated       - Updated imported task. To be revised and moved in one of the previous states

EOF
  exit 1
}

# Save current window_id
if [ "$preserve_focus" == "true" ]; then
    if command -v xdotool > /dev/null; then
        window=$(xdotool getwindowfocus)
    else
        preserve_focus=false
    fi
fi

# Open URLs in browser preserving focus on current window
open_url(){
    task info "$1" |awk '/^[A-Z][a-z]+ URL/{print $3}' | xargs -r xdg-open > /dev/null 2>&1

    if [ "$preserve_focus" == "true" ]; then
        declare -i n=0
        # Wait until focus jumps to another window or until timeout of 3 seconds
        until xdotool getwindowfocus | grep -qvx "$window"; do
            sleep 0.1
            n=$((n+1))
            [ $n -gt 30 ] && break
        done
        # Set window focus back
        xdotool windowfocus "$window"
    fi
}

get_ids(){
    if echo "$1" | grep -qE '^[\+-]'; then
        task _uuid $1 $default_filter
    else
        echo $@
    fi
}

case $1 in
  w) shift; for id in $(get_ids "$@"); do echo all | task "$id" mod -n -u +w -q -d -next; done ;;
  q) shift; for id in $(get_ids "$@"); do echo all | task "$id" mod -n -u -w +q -d -next; done ;;
  d) shift; for id in $(get_ids "$@"); do echo all | task "$id" mod -n -u -w -q +d -next; done ;;
  o) shift; for id in $(get_ids "$@"); do open_url "$id"; done ;;
  h|help) usage ;;
  *) task "$@" ;;
esac
