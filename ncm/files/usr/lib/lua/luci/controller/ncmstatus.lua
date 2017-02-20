module("luci.controller.ncmstatus", package.seeall)

function index()
	local page

	page = entry({"admin", "status", "ncm"}, template("ncm/status"), _("Ncm status"))
	page.dependent = true
end
