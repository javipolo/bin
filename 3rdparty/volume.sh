#!/bin/bash

#AMIXER="/usr/bin/amixer -q -D pulse sset Master"
SPOTIFY_DBUS="dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2"

SINKS=$(pactl list|grep ^Sink| cut -d \# -f 2)

## This is a test ##
## Following lines will print the sink index of a single app:
# APP="vlc"
# pacmd list-sink-inputs  | awk -v APP=$APP '{ if ($1 == "index:") { INDEX=$NF }; if ($1 == "application.process.binary") { gsub(/\"/, "", $NF); if ($NF == APP) { print INDEX } } }'
## And mute it:
# pacmd list-sink-input-mute "$APPID" toogle

case "$1" in
    "mute")
        for sink in ${SINKS}; do
            pactl set-sink-mute "${sink}" toggle
        done
        # ${AMIXER} toggle
    ;;
    "up")
        for sink in ${SINKS}; do
            pactl set-sink-volume "${sink}" +5%
        done
        # ${AMIXER} 5%+
    ;;
    "down")
        for sink in ${SINKS}; do
            pactl set-sink-volume "${sink}" -5%
        done
        # ${AMIXER} 5%-
    ;;
    "playpause")
        ${SPOTIFY_DBUS}.Player.PlayPause
    ;;
    "next")
        ${SPOTIFY_DBUS}.Player.Next
    ;;
    "previous")
        ${SPOTIFY_DBUS}.Player.Previous
    ;;
    "raise")
        ${SPOTIFY_DBUS}.Raise
    ;;
esac

