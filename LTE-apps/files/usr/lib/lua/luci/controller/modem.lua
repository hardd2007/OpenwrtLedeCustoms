module("luci.controller.modem", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/modem") then
		return
	end

	local page

	page = entry({"admin", "services", "modem"}, cbi("modem"), _("Modem 3G/4G"), 60)
	page.dependent = true
end