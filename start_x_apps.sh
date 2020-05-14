#!/bin/bash

PATH=$PATH:/home/javipolo/bin/local

pgrep -i slack || slack &
google-chrome &
pgrep -i spotify || spotify &
pgrep -i Telegram || Telegram &

rearrange_windows.sh
