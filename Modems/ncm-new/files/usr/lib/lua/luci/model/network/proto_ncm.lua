local netmod = luci.model.network

local _, p
for _, p in ipairs({"ncm"}) do

	local proto = netmod:register_protocol(p)

	function proto.get_i18n(self)
		return luci.i18n.translate("4G/3G modem - NCM")
	end

	function proto.ifname(self)
		return p .. "-" .. self.sid
	end

	function proto.opkg_package(self)
		return "ncm"
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
