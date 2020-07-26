#!/bin/bash

RESOLUTION="2560x1440"
URL="https://source.unsplash.com/featured/${RESOLUTION}/?motivation,focus"
WALLPAPER=~/.images/wallpaper.jpeg

if test -f "$WALLPAPER"; then
    rm "$WALLPAPER"
fi
mkdir -p "~/.images/"
RES=$(curl -L "$URL" -o "$WALLPAPER")
if [ -z "$RES" ]; then
    feh --bg-scale "$WALLPAPER"
fi
