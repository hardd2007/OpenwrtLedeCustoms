#!/bin/sh
echo -e "Content-type: text/html\n\n"

if [ "$REQUEST_METHOD" = POST ]; then
	read -t 3 QUERY_STRING
	eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
	WIFIN=`uhttpd -d $wifin 2>/dev/null`
	WIFINAME=`uhttpd -d $wifiname 2>/dev/null`
	WIFIPASS=`uhttpd -d $wifipass 2>/dev/null`
	WIFISEC=`uhttpd -d $wifisec 2>/dev/null`
	WIFIPW=`uhttpd -d $wifipw 2>/dev/null`
	IPROUTER=`uhttpd -d $iprouter 2>/dev/null`
	IPGW=`uhttpd -d $ipgw 2>/dev/null`

if [ $WIFIN = "11b" ]; then
uci set wireless.radio0.hwmode='11b'
uci delete wireless.radio0.htmode
else
uci set wireless.radio0.hwmode='11g'
uci set wireless.radio0.htmode='HT20'
fi
uci set wireless.@wifi-iface[0].ssid=$WIFINAME
#uci set wireless.radio0.channel=$WIFICHAN
#uci set wireless.radio0.txpower=$WIFIPW


if [ "x$WIFIPASS" = "x" ]; then
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-iface[0].key=$WIFIPASS
else
uci set wireless.@wifi-iface[0].key=$WIFIPASS
uci set wireless.@wifi-iface[0].encryption=$WIFISEC
fi
uci set network.lan.ipaddr=$IPROUTER
uci set network.bridge.ipaddr=$IPROUTER
uci set network.bridge.gateway=$IPGW

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
SEL11g="";
SEL11b="";
WIFIN=$(uci -q get wireless.radio0.hwmode)
if [ "$WIFIN" = "11b" ]; then
SEL11b="selected"
else
SEL11g="selected"
fi
SELnone=""
SELwep=""
SELpsk1=""
SELpsk2=""
SELpsk3=""
UPTIMEP=""

WIFINAME=$(uci -q get wireless.@wifi-iface[0].ssid)
WIFIPASS=$(uci -q get wireless.@wifi-iface[0].key)
WIFISEC=$(uci -q get wireless.@wifi-iface[0].encryption)
WIFIPW=$(uci -q get wireless.radio0.txpower)
IPROUTER=$(uci -q get network.lan.ipaddr)
IPGW=$(uci -q get network.bridge.gateway)
[ "$WIFISEC" = "psk-mixed" ] && SELpsk3="selected"
[ "$WIFISEC" = "none" ] && SELnone="selected"
[ "$WIFISEC" = "wep" ] && SELwep="selected"
[ "$WIFISEC" = "psk" ] && SELpsk1="selected"
[ "$WIFISEC" = "psk2" ] && SELpsk2="selected"

if [ "x$(ip link | grep wlan0)" != "x" ]; then
iw wlan0 link >/tmp/wlink.info
WLINK=$(cat /tmp/wlink.info | grep "SSID")/$(cat /tmp/wlink.info | grep "freq")/$(cat /tmp/wlink.info | grep "signal")/$(cat /tmp/wlink.info | grep "tx bitrate")
else
WLINK="Wifi off"
fi
UPTIMEP=$(uptime)
VER=$(uname -a)
TEMPLATE="myindex.html"
if [ -e $TEMPLATE ]; then
	sed -e "s!{WIFIN}!$WIFIN!g; \
	s!{WIFINAME}!$WIFINAME!g; \
	s!{WIFIPASS}!$WIFIPASS!g; \
	s!{WIFISEC}!$WIFISEC!g; \
	s!{WIFIPW}!$WIFIPW!g; \
	s!{IPROUTER}!$IPROUTER!g; \
	s!{VER}!$VER!g; \
	s!{WLINK}!$WLINK!g; \
	s!{SEL11g}!$SEL11g!g; \
	s!{SEL11b}!$SEL11b!g; \
	s!{SELnone}!$SELnone!g; \
	s!{SELwep}!$SELwep!g; \
	s!{SELpsk1}!$SELpsk1!g; \
	s!{SELpsk3}!$SELpsk3!g; \
	s!{SELpsk2}!$SELpsk2!g; \
	s!{UPTIMEP}!$UPTIMEP!g; \
	s!{IPGW}!$IPGW!g" $TEMPLATE
else
	echo "Template $TEMPLATE missing!"
fi

exit 0
