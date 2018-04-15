net="$1"
. /lib/functions.sh
. $dir/functions.sh
ipaddr=$(uci -q get meshwizard.netconfig.$net\_ip4addr)
ip6addr=$(uci -q get meshwizard.netconfig.$net\_ip6addr)
[ -z "$ipaddr" ] && msg_missing_value meshwizard $net\_ip4addr
netmask=$(uci -q get meshwizard.netconfig.$net\_netmask)
[ -z "$netmask" ] && netmask="$interface_netmask"
[ -z "$netmask" ] && netmask="255.255.0.0"
uci set network.$netrenamed="interface"
set_defaults "interface_" network.$netrenamed
uci batch << EOF
set network.$netrenamed.proto="static"
set network.$netrenamed.ipaddr="$ipaddr"
set network.$netrenamed.netmask="$netmask"
EOF
if [ "$netrenamed" = "lan" ]; then
uci -q delete network.lan.type
fi
if [ "$ipv6_enabled" = 1 ]; then
if [ "$ipv6_config" = "auto-ipv6-dhcpv6" ]; then
ip6addr="$($dir/helpers/gen_auto-ipv6-dhcpv6-ip.sh $netrenamed)"
uci set network.$netrenamed.ip6addr="${ip6addr}/112"
fi
if [ "$ipv6_config" = "static" ] && [ -n "$ip6addr" ]; then
uci set network.$netrenamed.ip6addr="$ip6addr"
fi
fi
uci_commitverbose "Setup interface $netrenamed" network
net_dhcp=$(uci -q get meshwizard.netconfig.${net}_dhcp)
if [ "$net_dhcp" == 1 ]; then
dhcprange="$(uci -q get meshwizard.netconfig.${net}_dhcprange)"
interface_ip="$(uci -q get meshwizard.netconfig.${net}_ip4addr)"
vap=$(uci -q get meshwizard.netconfig.${net}_vap)
handle_dhcpalias() {
config_get interface "$1" interface
if [ "$interface" == "$netrenamed" ]; then
if [ -z "${1/cfg[0-9a-fA-F]*/}" ]; then
section_rename network $1 ${netrenamed}dhcp
fi
fi
}
config_load network
config_foreach handle_dhcpalias interface
if [ -z "$dhcprange" ]; then
dhcprange="$($dir/helpers/gen_dhcp_ip.sh $interface_ip)/24"
uci set meshwizard.netconfig.${net}_dhcprange="$dhcprange"
fi
ahdhcp_when_vap="$(uci get profile_$community.profile.adhoc_dhcp_when_vap)"
if [ "$supports_vap" = 1 -a "$vap" = 1 -a "$ahdhcp_when_vap" = 1 ]; then
network=${dhcprange%%/*}
mask=${dhcprange##*/}
mask=$(($mask + 1))
eval $(sh $dir/helpers/ipcalc-cidr.sh ${network}/${mask} 1 0)
STARTADHOC=$START
NETMASKADHOC=$NETMASK
eval $(sh $dir/helpers/ipcalc-cidr.sh ${NEXTNET}/${mask} 1 0)
STARTVAP=$START
NETMASKVAP=$NETMASK
uci batch <<- EOF
set network.${netrenamed}dhcp=interface
set network.${netrenamed}dhcp.proto=static
set network.${netrenamed}dhcp.ipaddr="$STARTVAP"
set network.${netrenamed}dhcp.netmask="$NETMASKVAP"
EOF
uci_commitverbose  "Setup interface for ${netrenamed}dhcp" network
else
eval $(sh $dir/helpers/ipcalc-cidr.sh $dhcprange 1 0)
STARTADHOC=$START
NETMASKADHOC=$NETMASK
fi
if [ "$supports_vap" = 1 -a "$vap" = 1 -a "$ahdhcp_when_vap" != 1 ]; then
uci batch <<- EOF
set network.${netrenamed}dhcp=interface
set network.${netrenamed}dhcp.proto=static
set network.${netrenamed}dhcp.ipaddr="$STARTADHOC"
set network.${netrenamed}dhcp.netmask="$NETMASKADHOC"
EOF
uci_commitverbose  "Setup interface for ${netrenamed}dhcp" network
fi
if  [ "$supports_vap" = 0 ] || \
[ "$vap" = 0 ] || \
[ "$supports_vap" = 1 -a "$vap" = 1 -a "$ahdhcp_when_vap" = 1 ] || \
[ "$lan_is_olsr" = "1" ]; then
uci batch <<- EOF
set network.${netrenamed}ahdhcp=interface
set network.${netrenamed}ahdhcp.ifname="@${netrenamed}"
set network.${netrenamed}ahdhcp.proto=static
set network.${netrenamed}ahdhcp.ipaddr="$STARTADHOC"
set network.${netrenamed}ahdhcp.netmask="$NETMASKADHOC"
EOF
uci_commitverbose  "Setup interface for ${netrenamed}ahdhcp" network
fi
fi