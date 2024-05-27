#!/bin/bash

PATH=$PATH:/home/javipolo/bin/local

wmctrl -l | grep Chrome || ~/bin/run_chrome --profile-directory=Default &
pgrep -i slack || slack &
pgrep -i spotify || flatpak run com.spotify.Client &
# pgrep -i signal || flatpak run org.signal.Signal &
pgrep -i Telegram || Telegram &
wmctrl -l | grep -c Chrome | grep -x 2 || ~/bin/run_chrome --profile-directory="Profile 1" &

X.sh
sleep 10
rearrange_windows.sh
