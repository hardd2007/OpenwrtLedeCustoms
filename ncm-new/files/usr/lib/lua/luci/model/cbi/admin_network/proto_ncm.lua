local map, section, net = ...

local util = require "nixio.util"
local fs = require "nixio.fs"


local device, apn, mode, pincode, authtype, username, password, startdhcp, delayc, pdptype, ipv6, intline
local delay, bcast, defaultroute, peerdns, dns, metric, clientid, vendorclass

local device_suggestions = { }
nixio.util.consume((fs.glob("/dev/ttyUSB*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/ttyACM*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/ttyHS*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/tts/*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/cdc-wdm*")), device_suggestions)

device = section:taboption("general", Value, "device", "Устройство")
device.rmempty = false

if device_suggestions then
	local node
	for i,node in ipairs(device_suggestions) do
		device:value(node)
	end
end

pdptype = section:taboption("general", ListValue, "pdptype", "Режим носителя", "")
pdptype:value("IP", "IP")
pdptype:value("IPV4V6", "IPV4V6")
pdptype:value("IPV6", "IPV6")
pdptype.rmempty = false
pdptype.default = "IP"

ipv6 = section:taboption("general", Flag, "ipv6", "Использовать IPv6", "")
ipv6.default = ipv6.disabled
ipv6.enabled = "1"
ipv6.disabled = "0"

mode = section:taboption("general", ListValue, "mode", "Режим сети", "Применяется перед началом подключения")
mode:value("all", "Автоматически")
mode:value("not", "Не изменять")
mode:value("4g", "4G lte ")
mode:value("prefer4g", "4G lte/3G")
mode:value("3g", "3G" )
mode:value("prefer3g", "3G/2G")
mode:value("2g", "2G")
mode:value("4g_B1", "4G B1 FDD2100")
mode:value("4g_B3", "4G B3 FDD1800")
mode:value("4g_B7", "4G B7 FDD2600")
mode:value("4g_B8", "4G B8 FDD900")
mode:value("4g_B20", "4G B20 FDD800")
mode:value("3g_2100", "3G 2100" )
mode:value("3g_900", "3G 900")
mode:value("2g_850", "2G 850")
mode:value("2g_900", "2G 900")
mode:value("2g_1800", "2G 1800")
mode:value("2g_1900", "2G 1900")
mode:value("userat", "Другая  AT команда")
mode.default = "not"
mode.rmempty = true

intline = section:taboption("general", Value, "intline", "Своя AT команда", "Если команды выше не работают, можно использовать это поле для отправки нужной команды выбора режима сети")
intline:depends( {mode="userat"} ) 
intline.rmempty = true


apn = section:taboption("general", Value, "apn", "Точка доступа APN")

pincode = section:taboption("general", Value, "pincode", "PIN код")

auth = section:taboption("general", ListValue, "auth", "Тип авторизации")
auth:value("", "Нет")
auth:value("both", "PAP+CHAP")
auth:value("pap", "PAP")
auth:value("chap", "CHAP")
auth.default = ""

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
delay.default	  = "4"
delay.placeholder = "секунд"
delay.datatype	  = "uinteger"

delayc = section:taboption("advanced", Value, "delayc", "Время регистрации в сети")
delayc.default	  = "10"
delayc.placeholder = "секунд"
delayc.datatype	  = "uinteger"


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
