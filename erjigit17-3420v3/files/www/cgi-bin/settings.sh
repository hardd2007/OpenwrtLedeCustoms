#!/bin/sh
echo -e "Content-type: text/html\n\n"

if [ "$REQUEST_METHOD" = POST ]; then
	read -t 3 QUERY_STRING
	eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
	WIFION=`uhttpd -d $wifion 2>/dev/null`
	WIFINAME=`uhttpd -d $wifiname 2>/dev/null`
	WIFIPASS=`uhttpd -d $wifipass 2>/dev/null`
	WIFICHAN=`uhttpd -d $wifichan 2>/dev/null`
	WIFIPW=`uhttpd -d $wifipw 2>/dev/null`
	PCONTROL18=`uhttpd -d $pcontrol18 2>/dev/null`

if [ $WIFION = "1" ]; then
uci delete wireless.default_radio0.disabled
else
uci set wireless.default_radio0.disabled='1'
fi
uci set wireless.default_radio0.ssid=$WIFINAME
uci set wireless.radio0.channel=$WIFICHAN
uci set wireless.radio0.txpower=$WIFIPW
uci set modem.@modem[0].pcontrol18=$PCONTROL18

if [ "x$WIFIPASS" = "x" ]; then
uci set wireless.default_radio0.encryption='none'
uci set wireless.default_radio0.key=$WIFIPASS
else
uci set wireless.default_radio0.key=$WIFIPASS
uci set wireless.default_radio0.encryption='psk-mixed'
fi
if [ $PCONTROL18 = "1" ]; then
uci set network.lan.dns='77.88.8.7 77.88.8.3'
else
uci set network.lan.dns='208.67.222.222 208.67.220.220'
fi

uci commit
echo "<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<meta http-equiv=\"refresh\" content=\"5; url=../index.html\">
</head>"
echo "<body bgcolor=\"#FFFFFF\">"
echo "<p align=\"center\">Применение настроек, перезагрузка сети...</p>"
echo "</body></html>"
/etc/init.d/network restart &
#sleep 10
exit 0
fi

if [ $(uci -q get wireless.default_radio0.disabled) = "1" ]; then 
WIFION=""
else
WIFION="checked=\"checked\""
fi
WIFINAME=$(uci -q get wireless.default_radio0.ssid)
WIFIPASS=$(uci -q get wireless.default_radio0.key)
WIFICHAN=$(uci -q get wireless.radio0.channel)
SELCH01=""
SELCH02=""
SELCH03=""
SELCH04=""
SELCH05=""
SELCH06=""
SELCH07=""
SELCH08=""
SELCH09=""
SELCH10=""
SELCH11=""
SELCHAUTO=""

[ "$WIFICHAN" = "1" ] && SELCH01="selected"
[ "$WIFICHAN" = "2" ] && SELCH02="selected"
[ "$WIFICHAN" = "3" ] && SELCH03="selected"
[ "$WIFICHAN" = "4" ] && SELCH04="selected"
[ "$WIFICHAN" = "5" ] && SELCH05="selected"
[ "$WIFICHAN" = "6" ] && SELCH06="selected"
[ "$WIFICHAN" = "7" ] && SELCH07="selected"
[ "$WIFICHAN" = "8" ] && SELCH08="selected"
[ "$WIFICHAN" = "9" ] && SELCH09="selected"
[ "$WIFICHAN" = "10" ] && SELCH10="selected"
[ "$WIFICHAN" = "11" ] && SELCH11="selected"
[ "$WIFICHAN" = "auto" ] && SELCHAUTO="selected"

SELPWMIN=""
SELPWMED=""
SELPWHI=""
SELPWBEST=""
WIFIPW=$(uci -q get wireless.radio0.txpower)
[ "$WIFIPW" -eq 0 ] && SELPWMIN="selected"
[ "$WIFIPW" -gt 0 ] && [ "$WIFIPW" -le 10 ] && SELPWMED="selected"
[ "$WIFIPW" -gt 10 ] && [ "$WIFIPW" -le 15 ] && SELPWHI="selected"
[ "$WIFIPW" -gt 15 ] && [ "$WIFIPW" -le 20 ] && SELPWBEST="selected"

if [ $(uci -q get modem.@modem[0].pcontrol18) = "1" ]; then
PCONTROL18="checked=\"checked\""
else
PCONTROL18=""
fi
DEVICE=$(uci -q get modem.@modem[0].device)
MODEMSTATUS=""
if [ -e $DEVICE ]; then
MODEMSTATUS="4g-index.html"
else
MODEMSTATUS="http://"$(route -e | grep default | awk '{print $2}')
fi
if [ "x$MODEMSTATUS" = "xhttp://" ]; then
MODEM_SHOW="none"
MSG_SHOW="block"
else
MODEM_SHOW="block"
MSG_SHOW="none"
fi
TEMPLATE="myindex.html"
if [ -e $TEMPLATE ]; then
	sed -e "s!{WIFION}!$WIFION!g; \
	s!{WIFINAME}!$WIFINAME!g; \
	s!{WIFIPASS}!$WIFIPASS!g; \
	s!{WIFICHAN}!$WIFICHAN!g; \
	s!{WIFIPW}!$WIFIPW!g; \
	s!{MODEMSTATUS}!$MODEMSTATUS!g; \
	s!{MODEM_SHOW}!$MODEM_SHOW!g; \
	s!{MSG_SHOW}!$MSG_SHOW!g; \
	s!{SELCH01}!$SELCH01!g; \
	s!{SELCH02}!$SELCH02!g; \
	s!{SELCH03}!$SELCH03!g; \
	s!{SELCH04}!$SELCH04!g; \
	s!{SELCH05}!$SELCH05!g; \
	s!{SELCH06}!$SELCH06!g; \
	s!{SELCH07}!$SELCH07!g; \
	s!{SELCH08}!$SELCH08!g; \
	s!{SELCH09}!$SELCH09!g; \
	s!{SELCH10}!$SELCH10!g; \
	s!{SELCH11}!$SELCH11!g; \
	s!{SELCHAUTO}!$SELCHAUTO!g; \
	s!{SELPWMIN}!$SELPWMIN!g; \
	s!{SELPWMED}!$SELPWMED!g; \
	s!{SELPWHI}!$SELPWHI!g; \
	s!{SELPWBEST}!$SELPWBEST!g; \
	s!{PCONTROL18}!$PCONTROL18!g" $TEMPLATE
else
	echo "Template $TEMPLATE missing!"
fi

exit 0
