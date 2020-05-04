#!/bin/bash
rm /tmp/screen.png 
scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
 
PX=0
PY=0
# lockscreen image info
R=$(file $HOME/.images/lock.png | grep -o '[0-9]* x [0-9]*')
RX=$(echo $R | cut -d' ' -f 1)
RY=$(echo $R | cut -d' ' -f 3)

SR=$(xrandr --query | grep ' connected' | awk '/connected/{print ($3 == "primary" ? $4 : $3)}')
for RES in $SR
do
    # monitor position/offset
    SRX=$(echo $RES | cut -d'x' -f 1)                   # x pos
    SRY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 1)  # y pos
    SROX=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 2) # x offset
    SROY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 3) # y offset
    PX=$(($SROX + $SRX/2 - $RX/2))
    PY=$(($SROY + $SRY/2 - $RY/2))

    convert /tmp/screen.png $HOME/.images/lock.png -geometry +$PX+$PY -composite -matte  /tmp/screen.png
done
i3lock -e -n -i /tmp/screen.png
