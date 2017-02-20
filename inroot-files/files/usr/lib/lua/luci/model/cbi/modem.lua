
require("nixio.fs")
local uci = luci.model.uci.cursor_state()
local net = require "luci.model.network"
local m
local s
local dev, pin, port, lang, infoqmi
local try_devices = nixio.fs.glob("/dev/ttyUSB*") or nixio.fs.glob("/dev2/ttyACM*")


m = Map("modem", translate("Модем 3G/4G"),
        "На этой вкладке настройки модема для служб индикации уровня сигнала, SMS и USSD запросов.")

function m.on_commit(self)
luci.sys.call('echo "APPLY" >>/tmp/test.txt')
end
		
net = net.init(m.uci)
s = m:section(TypedSection, "modem", "Настройки модема")
s:tab("general",  "Общие настройки")
s:tab("infosetting", "Настройки отображения")
dev = s:taboption("general", Value, "device", "Порт управления модема")
if try_devices then
	local node
	for node in try_devices do
		dev:value(node, node)
	end
end

pin = s:taboption("general", Value, "pincode", "Pin код если есть")
pin.default = ""
lang = s:taboption("general",Value, "language", "Язык")
lang:value("ru", "Русский")
lang:value("en", "English")
lang.default = "ru"

infoqmi = s:taboption("infosetting", Flag, "infoqmi", "Получать информацию по QMI протоколу. Не реализовано.")
infoqmi.enabled = "1"
infoqmi.disabled = "0"

return m