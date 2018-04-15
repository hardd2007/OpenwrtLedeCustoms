#!/bin/sh
[ ! "$(uci -q get network.wan)" == "interface" ] && exit
. /lib/functions.sh
. $dir/functions.sh
if [ "$ipv6_enabled" = "1" ]; then
uci set network.wan.accept_ra='0'
uci_commitverbose "Do not accept ra on wan interface" network
fi
uci delete meshwizard.wan && uci commit meshwizard