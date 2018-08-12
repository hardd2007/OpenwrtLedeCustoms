
local fs = require "nixio.fs"
local uci = luci.model.uci.cursor_state()
local net = require "luci.model.network"
local m
local s
local dev, pin, port, lang
local device_suggestions = { }
nixio.util.consume((fs.glob("/dev/ttyUSB*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/ttyACM*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/ttyHS*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/tts/*")), device_suggestions)
nixio.util.consume((fs.glob("/dev/cdc-wdm*")), device_suggestions)



m = Map("modem", translate("Модем 3G/4G"),
        "На этой вкладке настройки модема для служб индикации уровня сигнала, SMS и USSD запросов.")

function m.on_commit(self)
luci.sys.call('echo "APPLY" >>/tmp/test.txt')
end
		
net = net.init(m.uci)
s = m:section(TypedSection, "modem", "Настройки модема")
s.anonymous = true
s:tab("general",  "Общие настройки")
dev = s:taboption("general", Value, "device", "Порт управления модема / Modem port")
if device_suggestions then
	local node
	for i,node in ipairs(device_suggestions) do
		dev:value(node)
	end
end


pin = s:taboption("general", Value, "pincode", "Pin")
pin.default = ""
lang = s:taboption("general",Value, "language", "Язык / Lang")
lang:value("ru", "Русский")
lang:value("en", "English")
lang.default = "ru"
lang.rmempty = false
return m