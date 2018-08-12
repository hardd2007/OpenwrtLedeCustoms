
require("nixio.fs")
local uci = luci.model.uci.cursor_state()
local net = require "luci.model.network"
local m, s, a
local action, ucom, portrtime, hosta, hostb, hostc, checktime, algcheck, enables, inittime

m = Map("netmon", translate("NetMon"),
        "Сторож сетевого соединения. Пытается восстановить связь в случае её обрыва. \
		Internet network monitor aka watchcat.")

function m.on_commit(self)
luci.sys.call('echo "APPLY" >>/tmp/test.txt')
end
		
net = net.init(m.uci)
s = m:section(TypedSection, "netmon", "Общие настройки")
s.anonymous = true
s:tab("general", "General settins")

-- a = m:section(TypedSection, "netmon", "Настройки действий / Actions")
-- a.anonymous = true
-- a:tab("gen", "Действия / Actions")


hosta = s:taboption("general", Value, "res_1", "Host 1")
hosta.placeholder = "8.8.8.8"
hosta.defualt = "8.8.8.8"
hosta.datatype="host"
hosta.rmempty = false

hostb = s:taboption("general", Value, "res_2", "Host 2")
hostb.placeholder = "77.88.8.1"
hostb.datatype="host"
hostb.rmempty = true

hostc = s:taboption("general", Value, "res_3", "Host 3")
hostc.placeholder = "2.ru.pool.ntp.org"
hostc.datatype="host"
hostc.rmempty = true

checktime = s:taboption("general",Value, "checktime", "Интервал проверки/Delay", "Задать частоту проверки сек/sec (120-9200)")
checktime.placeholder = "700"
checktime.datatype	= "range(120, 9200)"
checktime.default = "303"
checktime.rmempty = false

algcheck = s:taboption("general",ListValue, "algcheck", "Алгоритм проверки/Alg")
algcheck.widget="radio"
algcheck:value("All", "Все не ответили/All")
algcheck:value("Any", "Один не ответил/Any")
algcheck.default = "All"
function algcheck.write(self, section, value)
    return Flag.write(self, section, value)
end

action = s:taboption("general", ListValue, "action", "Действие/Action", "Выберите действие в случае отстутсвия связи")
action:value("rport", "Перезагрузить порт/Reset port")
action:value("rmodem", "Перезагрузить модем/Reset modem")
action:value("userscript", "Своя команда/User script")
action:value("resetrouter", "Перезагрузить роутер/Reboot router")
action.rmempty = false

ucom = s:taboption("general", Value, "usercommand", "Команда/script", "Для гибкости можно наваять свой скрипт и указать тут путь к нему")
ucom:depends( {action="userscript"} ) 
ucom.placeholder = "/path/to/script"
ucom.rmempty = true

portrtime=s:taboption("general", Value, "portdelay", "Port delay", "Время отключения порта сек/sec")
portrtime.datatype="uinteger"
portrtime.placeholder = "5"
portrtime:depends( {action="rport"} )
portrtime.datatype	= "max(700)"
portrtime.rmempty = true

inittime=s:taboption("general", Value, "inittime", "Init time", "Время установки соединения (30-700 сек/sec)")
inittime.datatype="uinteger"
inittime.placeholder = "70"
inittime.datatype	= "range(30, 700)"
inittime.default = "40"
inittime.rmempty = true

enables = s:taboption("general", Flag, "enable", "Включить сторожа", "Enable NetMon")
enables.enabled = "1"
enables.disabled = "0"
enables.default = "0"

return m