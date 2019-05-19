#!/bin/sh
while true
do
_uptime=$(cat /proc/uptime | awk '{print $1}' | sed 's/.$//' | sed 's/.$//' | sed 's/.$//')
if [ "$_uptime" -ge "7200" ]
then
poweroff
fi
sleep 30
done
exit 0
