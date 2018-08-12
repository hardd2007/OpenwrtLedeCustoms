#!/bin/sh
dev_id=7
fw_id=3
addrline=http://pub-dn07.r7494.ru/fw-tools/check-update.html
sleep 300

echo $(ifconfig eth0 | awk '/HWaddr/ { print $5 }') >/tmp/if_eth0
hash_id=$(sha256sum /tmp/if_eth0 | head -c 64)
pause=$(printf '%d\n' 0x$(ifconfig eth0 | awk '/HWaddr/ { print $5 }' | tail -c 3))

while true
do

sleep $pause
wget -O /dev/null "$addrline?crc=$hash_id&dev_id=$dev_id&fw_id=$fw_id"
sleep 3600
done
exit 0