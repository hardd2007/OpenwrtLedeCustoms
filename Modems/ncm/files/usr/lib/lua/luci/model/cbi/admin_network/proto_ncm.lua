--[[
LuCI - Lua Configuration Interface

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
]]--

local map, section, net = ...

local device, apn, mode, pincode, authtype, username, password
local delay, bcast, defaultroute, peerdns, dns, metric, clientid, vendorclass


device = section:taboption("general", Value, "device", translate("Modem device"))
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/tty[A-Z]*")
	or nixio.fs.glob("/dev/tts/*")

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end

mode = section:taboption("general", ListValue, "mode", translate("Service mode"))
mode:value("2g", translate("2G only"))
mode:value("3g", translate("3G only"))
mode:value("lte", translate("LTE only"))
mode:value("prefer3g", translate("Prefer 3G"))
mode:value("preferlte", translate("Prefer LTE"))
mode:value("auto", translate("Automatic / Any"))
mode.rmempty = false
mode.default = "auto"


apn = section:taboption("general", Value, "apn", translate("APN"))


pincode = section:taboption("general", Value, "pincode", translate("PIN"))


authtype = section:taboption("general", ListValue, "authtype", translate("Authentication type"))
authtype:value("none", translate("None"))
authtype:value("cleartext", translate("Clear text"))
authtype:value("pap", translate("PAP"))
authtype:value("chap", translate("CHAP"))
authtype.rmempty = false
authtype.default = "none"


username = section:taboption("general", Value, "username", translate("PAP/CHAP username"))


password = section:taboption("general", Value, "password", translate("PAP/CHAP password"))
password.password = true


bcast = section:taboption("advanced", Flag, "broadcast",
	translate("Use broadcast flag"),
	translate("Required for certain ISPs, e.g. Charter with DOCSIS 3"))

bcast.default = bcast.disabled


defaultroute = section:taboption("advanced", Flag, "defaultroute",
	translate("Use default gateway"),
	translate("If unchecked, no default route is configured"))

defaultroute.default = defaultroute.enabled


peerdns = section:taboption("advanced", Flag, "peerdns",
	translate("Use DNS servers advertised by peer"),
	translate("If unchecked, the advertised DNS server addresses are ignored"))

peerdns.default = peerdns.enabled


dns = section:taboption("advanced", DynamicList, "dns",
	translate("Use custom DNS servers"))

dns:depends("peerdns", "")
dns.datatype = "ipaddr"
dns.cast     = "string"


delay = section:taboption("advanced", Value, "delay",
	translate("Dongle connection delay"))
delay.default	  = "20"
delay.placeholder = translate("seconds")
delay.datatype	  = "uinteger"


metric = section:taboption("advanced", Value, "metric",
	translate("Use gateway metric"))

metric.placeholder = "0"
metric.datatype	   = "uinteger"

clientid = section:taboption("advanced", Value, "clientid",
	translate("Client ID to send when requesting DHCP"))


vendorclass = section:taboption("advanced", Value, "vendorid",
	translate("Vendor Class to send when requesting DHCP"))


luci.tools.proto.opt_macaddr(section, ifc, translate("Override MAC address"))


mtu = section:taboption("advanced", Value, "mtu", translate("Override MTU"))
mtu.placeholder = "1492"
mtu.datatype	= "max(9200)"
