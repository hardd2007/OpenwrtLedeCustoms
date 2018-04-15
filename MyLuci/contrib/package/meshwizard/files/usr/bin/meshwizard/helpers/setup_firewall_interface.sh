#!/bin/sh
net=$1
. /lib/functions.sh
. $dir/functions.sh
config_load firewall
type="$(uci -q get wireless.$net.type)"
vap="$(uci -q get meshwizard.netconfig.$net\_vap)"
wan_is_olsr=$(uci -q get meshwizard.netconfig.wan_config)
handle_fwzone() {
config_get name "$1" name
config_get network "$1" network
if [ "$2" == "zoneconf" ]; then
if [ "$name" == "freifunk" ]; then
if [ -z "${1/cfg[0-9a-fA-F]*/}" ]; then
section_rename firewall $1 zone_freifunk
fi
else
if [ ! "$name" == "freifunk" ] && [ -n "$netrenamed" -a -n "$(echo $network | grep $netrenamed)" ]; then
echo "    Removed $netrenamed from firewall zone $name."
network_new=$(echo $network | sed -e 's/'$netrenamed'//' -e 's/^ //' -e 's/  / /' -e 's/ $//')
uci set firewall.$1.network="$network_new"
fi
fi
fi
}
config_foreach handle_fwzone zone zoneconf
config_get network zone_freifunk network
[ -n "$network" -a -n "$net" ] && network="${network/${netrenamed}dhcp/}"
network=$(echo $network)
[ -n "$netrenamed" ] && [ -z "$(echo $network | grep $netrenamed)" ] && network="$network $netrenamed"
if [ "$supports_vap" == "1" -a "$vap" == 1 ]; then
[ -n "$netrenamed" ] && [ "$network" == "${network/${netrenamed}dhcp/}" ] && network="$network ${netrenamed}dhcp"
fi
uci set firewall.zone_freifunk.network="$network"
uci_commitverbose "Add '$netrenamed' to freifunk firewall zone" firewall
currms=$(uci -q get firewall.zone_freifunk.masq_src)
if [ "$vap" == 1 ]; then
if_ip="$(uci -q get network.${netrenamed}dhcp.ipaddr)"
if_mask="$(uci -q get network.${netrenamed}dhcp.netmask)"
[ -n "$if_ip" -a "$if_mask" ] && export $(ipcalc.sh $if_ip $if_mask)
[ -n "$NETWORK" -a "$PREFIX" ] && dhcprange="$NETWORK/$PREFIX"
if [ -n "$dhcprange" ]; then
meshnet="$(uci get profile_$community.profile.mesh_network)"
dhcpinmesh="$($dir/helpers/check-range-in-range.sh $dhcprange $meshnet)"
if [ "$dhcpinmesh" == 1 ]; then
if [ "$has_luci_splash" == TRUE ]; then
uci set firewall.zone_freifunk.contrack="1"
fi
else
uci set firewall.zone_freifunk.masq=1
[ -z "$(echo $currms |grep ${netrenamed}dhcp)" ] && uci add_list firewall.zone_freifunk.masq_src="${netrenamed}dhcp"
fi
fi
fi
if_ip="$(uci -q get network.${netrenamed}ahdhcp.ipaddr)"
if_mask="$(uci -q get network.${netrenamed}ahdhcp.netmask)"
[ -n "$if_ip" -a "$if_mask" ] && export $(ipcalc.sh $if_ip $if_mask)
[ -n "$NETWORK" -a "$PREFIX" ] && dhcprangeah="$NETWORK/$PREFIX"
if [ -n "$dhcprangeah" ]; then
meshnet="$(uci get profile_$community.profile.mesh_network)"
dhcpinmesh="$($dir/helpers/check-range-in-range.sh $dhcprangeah $meshnet)"
if [ "$dhcpinmesh" == 1 ]; then
if [ "$has_luci_splash" == TRUE ]; then
uci set firewall.zone_freifunk.contrack="1"
fi
else
uci set firewall.zone_freifunk.masq=1
[ -z "$(echo $currms |grep ${netrenamed}ahdhcp)" ] && uci add_list firewall.zone_freifunk.masq_src="${netrenamed}ahdhcp"
fi
fi
for i in IP NETMASK BROADCAST NETWORK PREFIX; do
unset $i
done
uci_commitverbose "Setup masquerading rules for '$netrenamed'" firewall