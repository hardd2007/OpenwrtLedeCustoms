module("luci.controller.netmon", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/netmon") then
		return
	end

	entry({"admin", "services", "netmon"}, cbi("netmon"), _("NetMon"), 90)
end