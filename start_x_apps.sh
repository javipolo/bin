#!/bin/bash

pgrep -i slack || slack &
google-chrome &
pgrep -i spotify || spotify &

rearrange_windows.sh
