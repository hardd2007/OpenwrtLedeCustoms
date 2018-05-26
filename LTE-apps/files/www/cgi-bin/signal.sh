#!/bin/sh
D=$(uci -q get modem.@modem[0].device)
echo -e "Content-type: text/html\n\n"
if [ -e $D ]; then
	gcom -d $D sig | sed -e 's/ /,/g'
fi
