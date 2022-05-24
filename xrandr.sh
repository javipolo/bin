#LAPTOP=$(xrandr|grep ' primary'| grep ' connected'|cut -d ' ' -f 1)
#MONITOR=$(xrandr|grep -v ' primary'| grep ' connected'|cut -d ' ' -f 1)

LAPTOP=eDP-1
LENOVO=DP-3-1
SAMSUNG=DP-3-3
LEFT=$LAPTOP
CENTER=$SAMSUNG
RIGHT=$LENOVO
MODE=1920x1080
extra=""

if [ "$1" == "office" ]; then
    LEFT=DP-2
    RIGHT=$LAPTOP
fi

if [ "$(awk '{print $NF}' /proc/acpi/button/lid/LID/state)" == "open" ]; then
    # With laptop lid open
    if [ "$(xrandr | grep $LEFT |grep ' connected')" ]; then
        extra="$extra --output $LEFT --left-of $CENTER --mode ${MODE}"
    fi

    if [ "$(xrandr | grep $RIGHT |grep ' connected')" ]; then
        extra="$extra --output $RIGHT --right-of $CENTER --mode ${MODE}"
    fi

    xrandr --output $CENTER --primary --mode ${MODE} $extra
else
    # With laptop lid closed
    if [ "$(xrandr | grep $CENTER |grep ' connected')" ]; then
        extra="$extra --output $CENTER --left-of $RIGHT --mode ${MODE}"
    fi

    if [ "$(xrandr | grep $RIGHT |grep ' connected')" ]; then
        extra="$extra --output $RIGHT --primary --mode ${MODE}"
    fi

    xrandr $extra --output $LEFT --off
fi

