#!/bin/sh
read_defaults() {
local community="$1"
config_cb() {
local type="$1"
local name="$2"
local allowed_section_types="widget"
local allowed_section_names="
system
wifi_device
wifi_iface
interface
alias
dhcp
olsr_interface
olsr_interfacedefaults
profile
zone_freifunk
include
luci_splash
ipv6
luci_main
contact
community
wan
lan
general
ipv6
qos
"
if [ "$type" = "widget" ]; then
widgets=$(add_to_list "$widgets" "$name")
fi
if ([ -n "$name" ] && is_in_list "$allowed_section_names" $name) \
|| is_in_list "$allowed_section_types" $type ; then
option_cb() {
local option="$1"
local value="$2"
export "${CONFIG_SECTION}_${option}"="$value"
}
else
option_cb() { return; }
fi
}
config_load freifunk
config_load profile_${community}
config_load meshwizard
export widgets="$widgets"
}