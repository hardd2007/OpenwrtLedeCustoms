#!/bin/sh
RES="/www/res"

LANG=$(uci -q get modem.@modem[0].language)
[ "x$LANG" = "x" ] && LANG="en"

getpath() {
	devname="$(basename "$1")"
	case "$devname" in
	'tty'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		P=${devpath%/*/*}
		;;
	*)
		devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
		P=${devpath%/*}
		;;
	esac
}


echo -e "Content-type: text/html\n\n"


# odpytanie urzadzenia
DEVICE=$(uci -q get modem.@modem[0].device)

if echo "x$DEVICE" | grep -q "192.168."; then
	if grep -q "Vendor=1bbb" /sys/kernel/debug/usb/devices; then
		O=$($RES/scripts/alcatel_hilink.sh $DEVICE)
	fi
	if grep -q "Vendor=12d1" /sys/kernel/debug/usb/devices; then
		O=$($RES/scripts/huawei_hilink.sh $DEVICE)
	fi
	SEC=$(uci -q get modem.@modem[0].network)
	SEC=${SEC:-wan}
else

if [ "x$DEVICE" = "x" ]; then
echo "<h3 style='color:red;' class=\"c\">Not Connected</h3>"
exit 0
fi

if [ ! -e $DEVICE ]; then
echo "<h3 style='color:red;' class=\"c\">No signal to $DEVICE!</h3>"
exit 0
fi

SEC=$(uci -q get modem.@modem[0].network)
	if [ -z "$SEC" ]; then
		getpath $DEVICE
		PORIG=$P
		for DEV in /sys/class/tty/* /sys/class/usbmisc/*; do
			getpath "/dev/"${DEV##/*/}
			if [ "x$PORIG" = "x$P" ]; then
				SEC=$(uci show network | grep "/dev/"${DEV##/*/} | cut -f2 -d.)
				[ -n "$SEC" ] && break
			fi
		done
	fi


	if [ ! -f /tmp/pincode_was_given ]; then

		if [ ! -z $SEC ]; then
			PINCODE=$(uci -q get network.$SEC.pincode)
		fi
		if [ -z "$PINCODE" ]; then
			PINCODE=$(uci -q get modem.@modem[0].pincode)
		fi
		if [ ! -z $PINCODE ]; then
PINCODE="$PINCODE" gcom -d "$DEVICE" -s /etc/gcom/setpin.gcom > /dev/null || {
echo "<h3 style='color:red;' class=\"c\">PINERROR</h3>"
exit 0
}
fi
touch /tmp/pincode_was_given
fi

	O=$(gcom -d $DEVICE -s $RES/modem.gcom 2>/dev/null)
fi

if [ "x$1" = "xtest" ]; then
	echo "$O"
	echo "---------------------------------------------------------------"
	ls /dev/tty*
	echo "---------------------------------------------------------------"
	cat /sys/kernel/debug/usb/devices
	echo "---------------------------------------------------------------"
	uci show modem
	exit 0
fi
echo $O >/tmp/modem_o.log
# CSQ
CSQ=$(echo "$O" | awk -F[,\ ] '/^\+CSQ/ {print $2}')

[ "x$CSQ" = "x" ] && CSQ=-1
if [ $CSQ -ge 0 -a $CSQ -le 31 ]; then
	CSQ_PER=$(($CSQ * 100/31))
	CSQ_COL="red"
	[ $CSQ -ge 10 ] && CSQ_COL="orange"
	[ $CSQ -ge 15 ] && CSQ_COL="yellow"
	[ $CSQ -ge 20 ] && CSQ_COL="green"
	CSQ_RSSI=$((2 * CSQ - 113))
else
if [ $CSQ -ge 100 ]; then
let "CSQ=CSQ-101"
if [ $CSQ -ge 0 -a $CSQ -le 91 ]; then
	CSQ_PER=$(($CSQ * 100/91))
	CSQ_COL="red"
	[ $CSQ -ge 10 ] && CSQ_COL="orange"
	[ $CSQ -ge 15 ] && CSQ_COL="yellow"
	[ $CSQ -ge 20 ] && CSQ_COL="green"
	CSQ_RSSI=$((2 * CSQ - 115))
fi 
else
CSQ="-"
CSQ_PER="0"
CSQ_COL="black"
CSQ_RSSI="-"
fi	
fi








# COPS
COPS_NUM=$(echo "$O" | awk -F[\"] '/^\+COPS: .,2/ {print $2}')
if [ "x$COPS_NUM" = "x" ]; then
	COPS_NUM="-"
	COPS_MCC="-"
	COPS_MNC="-"
else
	COPS_MCC=${COPS_NUM:0:3}
	COPS_MNC=${COPS_NUM:3:3}
	COPS=$(awk -F[\;] '/'$COPS_NUM'/ {print $2}' $RES/mccmnc.dat)
	[ "x$COPS" = "x" ] && COPS="-"
fi

# dla modemow Option i ZTE
if [ "$COPS_NUM" = "-" ]; then
	COPS=$(echo "$O" | awk -F[\"] '/^\+COPS: .,0/ {print $2}')
	[ "x$COPS" = "x" ] && COPS="---"

	COPS_TMP=$(awk -F[\;] 'BEGIN {IGNORECASE = 1} /'"$COPS"'/ {print $2}' $RES/mccmnc.dat)
	if [ "x$COPS_TMP" = "x" ]; then
		COPS_NUM="-"
		COPS_MCC="-"
		COPS_MNC="-"
	else
		COPS="$COPS_TMP"
		COPS_NUM=$(awk -F[\;] 'BEGIN {IGNORECASE = 1} /'"$COPS"'/ {print $1}' $RES/mccmnc.dat)
		COPS_MCC=${COPS_NUM:0:3}
		COPS_MNC=${COPS_NUM:3:3}
	fi
fi

# Technologia
MODE="-"
TECH=$(echo "$O" | awk -F[,] '/^\^SYSINFO/ {print $9}')
	case $TECH in
		17*) MODE="LTE";;
		15*) MODE="TD-SCDMA";;
		5*) MODE="WCDMA";;
		3*) MODE="GSM/GPRS";;
		0*) MODE="no service";;
		 *) MODE="-";;
	esac


# generic 3GPP TS 27.007 V10.4.0
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,] '/^\+COPS/ {print $4}')
	case "$TECH" in
		2*) MODE="WCDMA";;
		3*) MODE="EDGE";;
		4*) MODE="HSDPA";;
		5*) MODE="HSUPA";;
		6*) MODE="HSPA";;
		7*) MODE="LTE";;
		 *) MODE="-";;
	esac
fi

# CREG
CREG="+CGREG"
LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
if [ "x$LAC" = "x" ]; then
	CREG="+CREG"
	LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
fi

if [ "x$LAC" != "x" ]; then
	LAC_NUM=$(printf %d 0x$LAC)
else
	LAC="-"
	LAC_NUM="-"
fi

# TAC
TAC=$(echo "$O" | awk -F[,] '/^\+CEREG/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
if [ "x$TAC" != "x" ]; then
	TAC_NUM=$(printf %d 0x$TAC)
else
	TAC="-"
	TAC_NUM="-"
fi


# ECIO / RSCP
ECIO="-"
RSCP="-"

ECIx=$(echo "$O" | awk -F[,\ ] '/^\+ZRSSI:/ {print $3}')
if [ "x$ECIx" != "x" ]; then
	ECIO=`expr $ECIx / 2`
	ECIO="-"$ECIO
fi

RSCx=$(echo "$O" | awk -F[,\ ] '/^\+ZRSSI:/ {print $4}')
	if [ "x$RSCx" != "x" ]; then
		RSCP=`expr $RSCx / 2`
		RSCP="-"$RSCP
fi

RSCx=$(echo "$O" | awk -F[,\ ] '/^\^CSNR:/ {print $2}')
if [ "x$RSCx" != "x" ]; then
	RSCP=$RSCx
fi

ECIx=$(echo "$O" | awk -F[,\ ] '/^\^CSNR:/ {print $3}')
if [ "x$ECIx" != "x" ]; then
	ECIO=$ECIx
fi

# RSRP / RSRQ
RSRP="-"
RSRQ="-"
SINR="-"
RSRx=$(echo "$O" | awk -F[,:] '/^\^LTERSRP:/ {print $2}')
if [ "x$RSRx" != "x" ]; then
	RSRP=$RSRx
	RSRQ=$(echo "$O" | awk -F[,:] '/^\^LTERSRP:/ {print $3}')
fi

TECH=$(echo "$O" | awk -F[,:] '/^\^HCSQ:/ {print $2}' | sed 's/[" ]//g')
if [ "x$TECH" != "x" ]; then
	PARAM2=$(echo "$O" | awk -F[,:] '/^\^HCSQ:/ {print $4}')
	PARAM3=$(echo "$O" | awk -F[,:] '/^\^HCSQ:/ {print $5}')
	PARAM4=$(echo "$O" | awk -F[,:] '/^\^HCSQ:/ {print $6}')

	case "$TECH" in
		WCDMA*)
			RSCP=$(awk 'BEGIN {print -121 + '$PARAM2'}')
			ECIO=$(awk 'BEGIN {print -32.5 + '$PARAM3'/2}')
			;;
		LTE*)
			RSRP=$(awk 'BEGIN {print -141 + '$PARAM2'}')
			SINR=$(awk 'BEGIN {print -20.2 + '$PARAM3'/5}')
			RSRQ=$(awk 'BEGIN {print -20 + '$PARAM4'/2}')
			;;
	esac
fi

if [ -n "$SEC" ]; then
	if [ "x$(uci -q get network.$SEC.proto)" = "xqmi" ]; then
		. /usr/share/libubox/jshn.sh
		json_init
		json_load "$(uqmi -d "$(uci -q get network.$SEC.device)" --get-signal-info)" >/dev/null 2>&1
		json_get_var T type
		if [ "x$T" = "xlte" ]; then
			json_get_var RSRP rsrp
			json_get_var RSRQ rsrq
		fi
		if [ "x$T" = "xwcdma" ]; then
			json_get_var ECIO ecio
			json_get_var RSSI rssi
			json_get_var RSCP rscp
			if [ -z "$RSCP" ]; then
				RSCP=$((RSSI+ECIO))
			fi
		fi
	fi
fi

CID=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($4)}' | sed 's/[^A-F0-9]//g')
if [ "x$CID" != "x" ]; then
	CID_NUM=$(printf %d 0x$CID)

	if [ ${#CID} -gt 4 ]; then
		T=$(echo "$CID" | awk '{print substr($1,length(substr($1,1,length($1)-4))+1)}')
	else
		T=$CID
	fi

	CLF=$(uci -q get modem.@modem[0].clf)
else
	CID="-"
	CID_NUM="-"
fi

SMS_SHOW="block"
#SMS_SHOW="none"


# USSD
which ussd159 >/dev/null 2>&1
if [ $? -eq 0 ]; then
	USSD_SHOW="block"
else
	USSD_SHOW="none"
fi

# Status polaczenia

CONN_TIME="-"
RX="-"
TX="-"

if [ -z "$SEC" ]; then
	STATUS=$NOINFO
	[ $FORMAT -eq 2 ] && STATUS="NOINFO"

	STATUS_TRE="-"
	STATUS_SHOW="none"
	STATUS_SHOW_BUTTON="none"
else
	NETUP=$(ifstatus $SEC | grep "\"up\": true")
	if [ -n "$NETUP" ]; then
		[ $FORMAT -eq 0 ] && STATUS="<font color=green>$CONNECTED</font>"
		[ $FORMAT -eq 1 ] && STATUS=$CONNECTED
		[ $FORMAT -eq 2 ] && STATUS="CONNECTED"
		STATUS_TRE=$DISCONNECT

		CT=$(uci -q -P /var/state/ get network.$SEC.connect_time)
		if [ -z $CT ]; then
			CT=$(ifstatus $SEC | awk -F[:,] '/uptime/ {print $2}' | xargs)
		else
			UPTIME=$(cut -d. -f1 /proc/uptime)
			CT=$((UPTIME-CT))
		fi
		if [ ! -z $CT ]; then
			D=$(expr $CT / 60 / 60 / 24)
			H=$(expr $CT / 60 / 60 % 24)
			M=$(expr $CT / 60 % 60)
			S=$(expr $CT % 60)
			CONN_TIME=$(printf "%dd, %02d:%02d:%02d" $D $H $M $S)
		fi
		IFACE=$(ifstatus $SEC | awk -F\" '/l3_device/ {print $4}')
		if [ -n "$IFACE" ]; then
			RX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$2}')
			TX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$4}')
		fi
	else

		[ $FORMAT -eq 0 ] && STATUS="<font color=red>$DISCONNECTED</font>"
		[ $FORMAT -eq 1 ] && STATUS=$DISCONNECTED
		[ $FORMAT -eq 2 ] && STATUS="DISCONNECTED"
		STATUS_TRE=$CONNECT
	fi
	STATUS_SHOW="block"
	STATUS_SHOW_BUTTON="block"
fi

if [ "x"$(uci -q get modem.@modem[0].connect_button) = "x0" ]; then
	STATUS_SHOW_BUTTON="none"
fi

DEVICE=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
if [ "x$DEVICE" = "x" ]; then
	DEVICE="-"
fi

TEMPLATE="$RES/status.html.$LANG"
if [ -e $TEMPLATE ]; then
	sed -e "s!{CSQ}!$CSQ!g; \
	s!{CSQ_PER}!$CSQ_PER!g; \
	s!{CSQ_RSSI}!$CSQ_RSSI!g; \
	s!{CSQ_COL}!$CSQ_COL!g; \
	s!{COPS}!$COPS!g; \
	s!{COPS_NUM}!$COPS_NUM!g; \
	s!{COPS_MCC}!$COPS_MCC!g; \
	s!{COPS_MNC}!$COPS_MNC!g; \
	s!{LAC}!$LAC!g; \
	s!{LAC_NUM}!$LAC_NUM!g; \
	s!{CID}!$CID!g; \
	s!{CID_NUM}!$CID_NUM!g; \
	s!{TAC}!$TAC!g; \
	s!{TAC_NUM}!$TAC_NUM!g; \
	s!{BTSINFO}!$BTSINFO!g; \
	s!{DOWN}!$DOWN!g; \
	s!{UP}!$UP!g; \
	s!{QOS_SHOW}!$QOS_SHOW!g; \
	s!{SMS_SHOW}!$SMS_SHOW!g; \
	s!{USSD_SHOW}!$USSD_SHOW!g; \
	s!{LIMIT_SHOW}!$LIMIT_SHOW!g; \
	s!{STATUS}!$STATUS!g; \
	s!{CONN_TIME}!$CONN_TIME!g; \
	s!{CONN_TIME_SEC}!$CT!g; \
	s!{RX}!$RX!g; \
	s!{TX}!$TX!g; \
	s!{STATUS_TRE}!$STATUS_TRE!g; \
	s!{STATUS_SHOW}!$STATUS_SHOW!g; \
	s!{STATUS_SHOW_BUTTON}!$STATUS_SHOW_BUTTON!g; \
	s!{DEVICE}!$DEVICE!g; \
	s!{ECIO}!$ECIO!g; \
	s!{RSCP}!$RSCP!g; \
	s!{RSRP}!$RSRP!g; \
	s!{RSRQ}!$RSRQ!g; \
	s!{SINR}!$SINR!g; \
	s!{MODE}!$MODE!g" $TEMPLATE
else
	echo "Template $TEMPLATE missing!"
fi

exit 0
