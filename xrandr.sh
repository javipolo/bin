#LAPTOP=$(xrandr|grep ' primary'| grep ' connected'|cut -d ' ' -f 1)
#MONITOR=$(xrandr|grep -v ' primary'| grep ' connected'|cut -d ' ' -f 1)

LAPTOP=eDP1
LMODE=disabled
PRIMARY=DP-1-3
PMODE=1920x1080
SECONDARY=DP-1-1
SMODE=1920x1080

if [ "$(xrandr | grep $SECONDARY |grep ' connected')" ]; then
    extra="--output $SECONDARY --left-of $PRIMARY --mode ${SMODE} --output $LAPTOP --off"
else
    PRIMARY=$LAPTOP
fi

xrandr --output $PRIMARY --primary --mode ${PMODE} $extra
