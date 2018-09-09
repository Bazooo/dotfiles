#! /bin/sh

su bazoo -c  "DISPLAY=:0.0 /usr/bin/notify-send \"Connecting to $1 $2\" --app-name=Wicd"
