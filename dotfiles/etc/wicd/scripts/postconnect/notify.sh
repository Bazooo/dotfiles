#! /bin/sh

if [ $1 == "wireless" ]; then
	interface="wlp3s0"
else
	interface="enp2s0"
fi

conn="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
ip=`ifconfig $interface | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | tr -d 'inet '`

# Notify
title="$conn Connection Established"
msg="$2@$ip"

su bazoo -c "DISPLAY=:0.0 /usr/bin/notify-send \"$title\" \"$msg\" --app-name=Wicd"
