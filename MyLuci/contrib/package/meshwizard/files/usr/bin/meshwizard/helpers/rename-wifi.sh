#!/bin/sh
. $dir/functions.sh
posIB=-1
IBwifis="$(uci show meshwizard.netconfig | grep 'IB_' | sed 's/meshwizard.netconfig\.\(IB_wifi.*\)_.*/\1/' |uniq)"
[ -z "$(echo $IBwifis |grep IB_wifi)" ] && exit
for w in $IBwifis; do
posIB=$(( $posIB + 1 ))
export IB_wifi$posIB="$w"
done
pos=0
syswifis="$(uci show wireless |grep wifi-device | sed 's/wireless\.\(.*\)=.*/\1/' |uniq)"
for s in $syswifis; do
export syswifi$pos="$s"
pos=$(( $pos + 1 ))
done
for i in `seq 0 $posIB`; do
IBwifi=$(eval echo \$IB_wifi$i)
syswifi=$(eval echo \$syswifi$i)
if [ -n "$syswifi" ]; then
case $IBwifi in
IB_wifi* )
uci show meshwizard.netconfig | grep $IBwifi | while read line; do
oldline=$(echo $line | cut -d "=" -f 1)
uci set $oldline=""
newline=$(echo $line |sed -e "s/$IBwifi/$syswifi/g" -e "s/'//g")
uci set $newline
done
;;
esac
unset IBwifi
unset syswifi
fi
done
uci_commitverbose "Renaming wifi-devices in /etc/config/meshwizard" meshwizard