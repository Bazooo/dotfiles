#! /bin/sh

# $1 = brightness up/down/set
# $2 = brightness level

if [ $1 == "up" ]; then
  arg='inc'
elif [ $1 == "down" ]; then
  arg='dec'
elif [ $1 == "set" ]; then
  arg='set'
fi

xbacklight -$arg $2 -fps 60

level=`xbacklight -get`

notify-send "Brightness: $level%" --app-name=xbacklight
