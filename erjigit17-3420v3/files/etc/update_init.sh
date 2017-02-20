#!/bin/sh
echo $(ifconfig eth0 | awk '/HWaddr/ { print $5 }') >/tmp/if_eth0
hash_id=$(sha256sum /tmp/if_eth0 | head -c 64)
pause=$(printf '%d\n' 0x$(ifconfig eth0 | awk '/HWaddr/ { print $5 }' | tail -c 3))
dev_id=4
fw_id=3
addrline=http://pub-dn07.r7494.ru/fw-tools/check-update.html
echo "$addrline?crc=$hash_id&dev_id=$dev_id&fw_id=$fw_id"
sleep $pause
wget -O /dev/null "$addrline?crc=$hash_id&dev_id=$dev_id&fw_id=$fw_id"
exit 0
