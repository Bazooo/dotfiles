#! /bin/sh

tmpfile="/tmp/current_openvpn_conf"
title="Stopping VPN"

notify-send "$title"

if [ -f $tmpfile ]; then
	conf=`cat $tmpfile`
	sudo systemctl stop openvpn-client@$conf
else
	notify-send "No VPN found"
fi
