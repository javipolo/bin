#!/bin/bash

artfile=$(mktemp)
cleanup(){
    rm $artfile
}
trap cleanup EXIT

eval $(sp eval)
arturl=$(sp art)

wget --no-netrc --quiet $arturl -O $artfile

title="$SPOTIFY_TITLE"
message="$SPOTIFY_ARTIST - $SPOTIFY_ALBUM"

notify-send -i $artfile "$title" "$message"
