#!/bin/sh
if [ "$(uci -q get netmon.@netmon[0].enable)" != "1" ]; then
logger -p user.info -t "NetMon" "Disabled"
exit
fi

hosta=$(uci -q get netmon.@netmon[0].res_1)
hostb=$(uci -q get netmon.@netmon[0].res_2)
hostc=$(uci -q get netmon.@netmon[0].res_3)
alg=$(uci -q get netmon.@netmon[0].algcheck)
checktime=$(uci -q get netmon.@netmon[0].checktime)
chp=3 #Пауза между проверками хостов
act=$(uci -q get netmon.@netmon[0].action)
portdelay=$(uci -q get netmon.@netmon[0].portdelay)
usercom=$(uci -q get netmon.@netmon[0].usercommand)
inittime=$(uci -q get netmon.@netmon[0].inittime)

if [ -z $alg ]; then
logger -p user.info -t "NetMon" "No alg select"
exit
fi

check_hosts() {
local cnp="0"
local hcn="0"
logger -p user.info -t "NetMon" "Test hosts $hosta, $hostb, $hostc"
if [ "x$hosta" != "x" ]; then
	let "hcn=hcn+1"
	if ping -c 2 -q -W4 $hosta > /dev/null 2>&1
	then 
	let "cnp=cnp+1"
	logger -p user.info -t "NetMon" "Host: $hosta OK"
	fi
fi
sleep $chp
if [ "x$hostb" != "x" ]; then
	let "hcn=hcn+1"
	if ping -c 2 -q -W4 $hostb > /dev/null 2>&1
	then 
	let "cnp=cnp+1"
	logger -p user.info -t "NetMon" "Host: $hostb OK"
	fi
fi
sleep $chp
if [ "x$hostc" != "x" ]; then
	let "hcn=hcn+1"
	if ping -c 2 -q -W4 $hostc > /dev/null 2>&1
	then 
	let "cnp=cnp+1"
	logger -p user.info -t "NetMon" "Host: $hostc OK"
	fi
fi
logger -p user.info -t "NetMon" "Result cnp:$cnp, hcn:$hcn"
if [ $alg == "All" ]; then
if [ $cnp -eq 0 ]; then # All
logger -p user.info -t "NetMon" "No Network All"
action
fi
fi
if [ $alg == "Any" ]; then
if [ $cnp -ne $hcn ] && [ $hcn -gt 0 ]; then # Any
logger -p user.info -t "NetMon" "No Network Any"
action
fi
fi
}

action() {
case $act in
	rport)
	logger -p user.info -t "NetMon" "Disable port"
	echo 0 >/sys/devices/virtual/gpio/gpio8/value
	sleep $portdelay
	logger -p user.info -t "NetMon" "Enable port"
	echo 1 >/sys/devices/virtual/gpio/gpio8/value
	sleep $inittime
	;;
	rmodem)
	logger -p user.info -t "NetMon" "Reset modem"
	device=$(uci get modem.@modem[0].device)
	eval COMMAND="AT\^RESET" gcom -d "$device" -s /etc/gcom/runcommand.gcom
	sleep $inittime
	;;
	userscript)
	logger -p user.info -t "NetMon" "Call user script"
	$usercom
	sleep $inittime
	;;
	resetrouter)
	logger -p user.info -t "NetMon" "Reboot router"
	reboot
	;;
*)
logger -p user.info -t "NetMon" "No command"
;;
esac

}
sleep $inittime
while true; do
check_hosts
sleep $checktime
done
