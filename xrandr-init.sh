LAPTOP=eDP-1
MONITOR=DP-1
MODE=1920x1080

# Run xrandr if we are not in desired mode
#if [ "$(xrandr|grep \*|grep ${MODE}|wc -l)" != "2" ]; then
#    xrandr --output $LAPTOP --mode ${MODE} --output $MONITOR --left-of $LAPTOP --mode ${MODE}
#else
    xrandr --output $LAPTOP --mode ${MODE}
    xrandr --output $MONITOR --mode ${MODE}
    xrandr --output $MONITOR --left-of $LAPTOP
#fi
