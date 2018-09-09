#! /bin/sh

# Get random canadian server
conf=`ls /etc/openvpn/ovpn_udp | grep ca | sort -R | tail -1`

# Save to cache
echo $conf > /tmp/current_openvpn_conf

# Notify
title="Starting VPN"
msg="$conf"

notify-send "$title" "$msg"

# Start vpn
sudo systemctl reload openvpn-client@$conf

