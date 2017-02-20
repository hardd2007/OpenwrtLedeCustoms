--[[
LuCI - Network model - 3G, PPP, PPtP, PPPoE and PPPoA protocol extension

Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

]]--

local netmod = luci.model.network

local _, p
for _, p in ipairs({"ncm"}) do

	local proto = netmod:register_protocol(p)

	function proto.get_i18n(self)
		return luci.i18n.translate("NCM")
	end

	function proto.ifname(self)
		return p .. "-" .. self.sid
	end

	function proto.opkg_package(self)
		return "kmod-usb-net-cdc-ncm"
	end

	function proto.is_installed(self)
		return nixio.fs.access("/lib/netifd/proto/ncm.sh")
	end

	function proto.is_floating(self)
		return false
	end

	function proto.is_virtual(self)
		return false
	end

	function proto.get_interfaces(self)
		return netmod.protocol.get_interfaces(self)
	end

	function proto.contains_interface(self, ifc)
		return netmod.protocol.contains_interface(self, ifc)
	end

	netmod:register_pattern_virtual("^%s-%%w" % p)
end
