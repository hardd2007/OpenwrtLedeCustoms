#!/bin/sh
[ ! "$(uci -q get network.lan)" == "interface" ] && exit
. /lib/functions.sh
. $dir/functions.sh
ip6addr=""
if [ "$ipv6_config" = "auto-ipv6-dhcpv6" ]; then
device="$(uci -p/var/state -q get network.lan.ifname)"
if [ -n "device" ]; then
ip6addr="$($dir/helpers/gen_auto-ipv6-dhcpv6-ip.sh $device)"
fi
uci set network.lan.ip6addr="${ip6addr}/112"
fi
uci_commitverbose "Setup ipv6 address for lan" network