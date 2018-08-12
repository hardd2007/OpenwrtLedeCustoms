local map, section, net = ...

local device, apn, modes, pincode, authtype, username, password, startdhcp
local delay, bcast, defaultroute, peerdns, dns, metric, clientid, vendorclass


device = section:taboption("general", Value, "device", "Устройство")
device.rmempty = false

local device_suggestions = nixio.fs.glob("/dev/cdc*")
	

if device_suggestions then
	local node
	for node in device_suggestions do
		device:value(node)
	end
end

modes = section:taboption("general", ListValue, "modes", "Режим сети", "Применяется перед началом подключения")
modes:value("", "Не изменять")
modes:value("all", "All")
modes:value("umts,gsm", "UMTS/GPRS")
modes:value("umts", "UMTS" )
modes:value("gsm", "GPRS")
modes:value("lte,umts", "LTE/UMTS")
modes:value("lte", "LTE")
modes.default = "all"


apn = section:taboption("general", Value, "apn", "Точка доступа APN")


pincode = section:taboption("general", Value, "pincode", "PIN код")


auth = section:taboption("general", ListValue, "auth", "Тип авторизации")
auth:value("none", "Нет")
auth:value("both", "PAP+CHAP")
auth:value("pap", "PAP")
auth:value("chap", "CHAP")
auth.default = "none"


username = section:taboption("general", Value, "username", "PAP/CHAP username")


password = section:taboption("general", Value, "password", "PAP/CHAP password")
password.password = true

stdhcp = section:taboption("general", Flag, "startdhcp", "Запускать DHCP-клиент",
	"Выключите, если создаёте мост между устройствами, и адрес будет получать другое устройство")

stdhcp.default = stdhcp.enabled
stdhcp.enabled = "1"
stdhcp.disabled = "0"


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


delay = section:taboption("advanced", Value, "delay", "Время инициализации модема")
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
mtu.placeholder = "1472"
mtu.datatype	= "max(9200)"
