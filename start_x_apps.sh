#!/bin/bash

PATH=$PATH:/home/javipolo/bin/local

google-chrome --profile-directory=Default &
pgrep -i slack || slack &
pgrep -i spotify || spotify &
pgrep -i Telegram || Telegram &
google-chrome --profile-directory="Profile 1" &

X.sh
sleep 10
rearrange_windows.sh
