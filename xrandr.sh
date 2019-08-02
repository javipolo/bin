LAPTOP=eDP-1
MONITOR=DP-1
LMODE=1920x1080
MMODE=3840x2160
MODE=1920x1080

case $(iwgetid --raw) in
    "Gey Panda Crew")
        MMODE=1920x1080
        ;;
esac


# Run xrandr if we are not in desired mode
if [ "$(xrandr|grep \*|grep ${MMODE}|wc -l)" != "2" ]; then
    xrandr --output $LAPTOP --mode ${LMODE} --output $MONITOR --left-of $LAPTOP --mode ${MMODE}
else
    xrandr --output $LAPTOP --mode ${MODE}
fi
