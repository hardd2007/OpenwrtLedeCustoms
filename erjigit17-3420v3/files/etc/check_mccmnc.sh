#!/bin/sh
goodcode="25099"
goodcode="43705"
IPTABLES="iptables"
ROUTERIP="192.168.17.254"
LOGF=/tmp/block.log

if [ -s /tmp/block.lock ]; then
echo "Block active" >>$LOGF
exit
fi
#uhttpd -p 0.0.0.0:81 -h /www2 -E /index.html -I index.html


defip=$(route -e | grep default | awk '{print $2}')
mccmnc=""
mccmnc=$(/etc/hilink.sh "$defip" | grep "MCCMNC:" |  awk -F ":" '{print $2}')

if [ "x$mccmnc" = "x" ]; then
echo "No MCCMNC" >>$LOGF
exit
fi
echo "$mccmnc" >>$LOGF
echo "$goodcode" >>$LOGF
if [ "$mccmnc" = "$goodcode" ]; then
echo "All OK" >>$LOGF
exit
fi
#Блокировка
echo "Block" >/tmp/block.lock
echo "Block"  >>$LOGF
echo "address=/#/$ROUTERIP" >>  /etc/dnsmasq.conf
$IPTABLES -t mangle -F
$IPTABLES -F


$IPTABLES -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $ROUTERIP:81
#$IPTABLES -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination $ROUTERIP:81
$IPTABLES -t filter -A FORWARD -p tcp --dport 80  -j  ACCEPT
$IPTABLES -t filter -A FORWARD -p icmp -j  ACCEPT #Убрать
#$IPTABLES -t filter -A FORWARD -p tcp --dport 443 -j  ACCEPT
$IPTABLES -t filter -A FORWARD -p tcp --dport 67:68 -j ACCEPT
$IPTABLES -t filter -A FORWARD -p udp --dport 67:68 -j ACCEPT
$IPTABLES -t filter -A FORWARD -j DROP

$IPTABLES -t filter -A INPUT -p tcp --dport 80 -j  ACCEPT
$IPTABLES -t filter -A INPUT -p tcp --dport 81 -j  ACCEPT
#$IPTABLES -t filter -A INPUT -p tcp --dport 443 -j  ACCEPT
$IPTABLES -t filter -A INPUT -p tcp --dport 53 -j  ACCEPT
$IPTABLES -t filter -A INPUT -p udp --dport 53 -j  ACCEPT
$IPTABLES -t filter -A INPUT -j DROP
$IPTABLES -t filter -A FORWARD -p tcp ! -d  192.168.0.0/16  -j  DROP
exit





