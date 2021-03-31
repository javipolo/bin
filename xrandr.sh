LAPTOP=$(xrandr|grep ' primary'| grep ' connected'|cut -d ' ' -f 1)
MONITOR=$(xrandr|grep -v ' primary'| grep ' connected'|cut -d ' ' -f 1)
MMODE=1920x1080
LMODE=1920x1200

if [ "$MONITOR" ]; then
    extra="--output $MONITOR --left-of $LAPTOP --mode ${MMODE}"
fi

xrandr --output $LAPTOP --mode ${LMODE} $extra
