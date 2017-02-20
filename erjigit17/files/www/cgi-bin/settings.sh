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
uci delete wireless.@wifi-iface[0].disabled
else
uci set wireless.@wifi-iface[0].disabled='1'
fi
uci set wireless.@wifi-iface[0].ssid=$WIFINAME
uci set wireless.radio0.channel=$WIFICHAN
uci set wireless.radio0.txpower=$WIFIPW
uci set modem.@modem[0].pcontrol18=$PCONTROL18

if [ "x$WIFIPASS" = "x" ]; then
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-iface[0].key=$WIFIPASS
else
uci set wireless.@wifi-iface[0].key=$WIFIPASS
uci set wireless.@wifi-iface[0].encryption='psk-mixed'
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

if [ $(uci -q get wireless.@wifi-iface[0].disabled) = "1" ]; then 
WIFION=""
else
WIFION="checked=\"checked\""
fi
WIFINAME=$(uci -q get wireless.@wifi-iface[0].ssid)
WIFIPASS=$(uci -q get wireless.@wifi-iface[0].key)
WIFICHAN=$(uci -q get wireless.radio0.channel)
WIFIPW=$(uci -q get wireless.radio0.txpower)
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
	s!{PCONTROL18}!$PCONTROL18!g" $TEMPLATE
else
	echo "Template $TEMPLATE missing!"
fi

exit 0
