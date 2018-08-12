#!/bin/sh
RES="/www"

LANG=$(uci -q get modem.@modem[0].language)
[ "x$LANG" = "x" ] && LANG="en"

getpath() {
	DEV=$1
	O=$(ls -al /sys/class/tty/$DEV 2>/dev/null)
	O1=$(echo "$O" | awk -F">" '/'$DEV'/ {print $2}' | sed -e 's/\/'$DEV'\/tty\/'$DEV'//g')
	P=${O1%%[0-9]}
}

if [ "`basename $0`" = "4gmodem" ]; then
	TOTXT=1
else
	TOTXT=0
	echo -e "Content-type: text/html\n\n"
fi

if [ ! -e $RES/msg.dat.$LANG ]; then
    echo "File missing: $RES/msg.dat.$LANG"
    exit 0
fi
. $RES/msg.dat.$LANG

DEVICE=$(uci -q get modem.@modem[0].device)

if [ "x$DEVICE" = "x" ]; then
	devices=$(ls /dev/ttyACM* /dev/ttyUSB* /dev/ttyHS* 2>/dev/null | sort -r);
	for d in $devices; do
		DEVICE=$d gcom -s $RES/scripts/probeport.gcom > /dev/null 2>&1
		if [ $? = 0 ]; then
			uci set modem.@modem[0].device="$d"
			uci commit modem
			break
		fi
	done
	DEVICE=$(uci -q get modem.@modem[0].device)
fi

if [ "x$DEVICE" = "x" ]; then
	if [ $TOTXT -eq 0 ]; then
		echo "<h3 style='color:red;' class=\"c\">$NOTDETECTED</h3>"
	else
		echo $NOTDETECTED
	fi
	exit 0
fi

if [ ! -e $DEVICE ]; then
	if [ $TOTXT -eq 0 ]; then
		echo "<h3 style='color:red;' class=\"c\">$NODEVICE $DEVICE!</h3>"
	else
		echo "$NODEVICE $DEVICE."
	fi
	exit 0
fi

getpath ${DEVICE##/*/}
PORIG=$P
for DEV in /sys/class/tty/${DEVICE##/*/}/device/driver/tty*; do
	getpath ${DEV##/*/}
	if [ "x$PORIG" = "x$P" ]; then
		SEC=$(uci show network | grep "/dev/"${DEV##/*/} | cut -f2 -d.)
		if [ ! -z $SEC ]; then
			break
		fi
	fi
done
if [ -z $SEC ]; then
	SEC=$(uci show network | grep ${DEVICE%%[0-9]} | cut -f2 -d.)
fi

if [ ! -f /tmp/pincode_was_given ]; then

	if [ ! -z $SEC ]; then
		PINCODE=$(uci -q get network.$SEC.pincode)
	fi
	if [ -z "$PINCODE" ]; then
		PINCODE=$(uci -q get 4gmodem.@4gmodem[0].pincode)
	fi
	if [ ! -z $PINCODE ]; then
		PINCODE="$PINCODE" gcom -d "$DEVICE" -s /etc/gcom/setpin.gcom > /dev/null || {
			if [ $TOTXT -eq 0 ]; then
				echo "<h3 style='color:red;' class=\"c\">$PINERROR</h3>"
			else
				echo $PINERROR
			fi
			exit 0
		}
	fi
	touch /tmp/pincode_was_given
fi

O=$(gcom -d $DEVICE -s $RES/scripts/4gmodem.gcom 2>/dev/null)
echo $O >/tmp/o.txt
# CSQ
CSQ=$(echo "$O" | awk -F[,\ ] '/^\+CSQ/ {print $2}')

[ "x$CSQ" = "x" ] && CSQ=-1
if [ $CSQ -ge 0 -a $CSQ -le 31 ]; then

	# for Gargoyle
	[ -e /tmp/strength.txt ] && echo "+CSQ: $CSQ,99" > /tmp/strength.txt

	CSQ_PER=$(($CSQ * 100/31))
	CSQ_COL="red"
	[ $CSQ -ge 10 ] && CSQ_COL="orange"
	[ $CSQ -ge 15 ] && CSQ_COL="yellow"
	[ $CSQ -ge 20 ] && CSQ_COL="green"
	CSQ_RSSI=$((2 * CSQ - 113))
	[ $CSQ -eq 0 ] && CSQ_RSSI="<= "$CSQ_RSSI
	[ $CSQ -eq 31 ] && CSQ_RSSI=">= "$CSQ_RSSI
else
	CSQ="-"
	CSQ_PER="0"
	CSQ_COL="black"
	CSQ_RSSI="-"
fi

# COPS
COPS_NUM=$(echo "$O" | awk -F[\"] '/^\+COPS: 0,2/ {print $2}')
if [ "x$COPS_NUM" = "x" ]; then
	COPS_NUM="-"
	COPS_MCC="-"
	COPS_MNC="-"
else
	COPS_MCC=${COPS_NUM:0:3}
	COPS_MNC=${COPS_NUM:3:2}
	COPS=$(awk -F[\;] '/'$COPS_NUM'/ {print $2}' $RES/mccmnc.dat)
	[ "x$COPS" = "x" ] && COPS="-"
fi

# dla modemow Option i ZTE
if [ "$COPS_NUM" = "-" ]; then
	COPS=$(echo "$O" | awk -F[\"] '/^\+COPS: 0,0/ {print $2}')
	[ "x$COPS" = "x" ] && COPS="---"

	COPS_TMP=$(awk -F[\;] '/'"$COPS"'/ {print $2}' $RES/mccmnc.dat)
	if [ "x$COPS_TMP" = "x" ]; then
		COPS_NUM="-"
		COPS_MCC="-"
		COPS_MNC="-"
	else
		COPS="$COPS_TMP"
		COPS_NUM=$(awk -F[\;] '/'"$COPS"'/ {print $1}' $RES/mccmnc.dat)
		COPS_MCC=${COPS_NUM:0:3}
		COPS_MNC=${COPS_NUM:3:2}
	fi
fi

# Technologia
MODE="-"

# Nowe Huawei
TECH=$(echo "$O" | awk -F[,] '/^\^SYSINFOEX/ {print $9}' | sed 's/"//g')
if [ "x$TECH" != "x" ]; then
	MODE="$TECH"
fi

# Starsze modele Huawei i inne pozostale
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,] '/^\^SYSINFO/ {print $7}')
	case $TECH in
		17*) MODE="HSPA+ (64QAM)";;
		18*) MODE="HSPA+ (MIMO)";;
		1*) MODE="GSM";;
		2*) MODE="GPRS";;
		3*) MODE="EDGE";;
		4*) MODE="UMTS";;
		5*) MODE="HSDPA";;
		6*) MODE="HSUPA";;
		7*) MODE="HSPA";;
		9*) MODE="HSPA+";;
		 *) MODE="-";;
	esac
fi

# ZTE
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,\ ] '/^\+ZPAS/ {print $2}' | sed 's/"//g')
	if [ "x$TECH" != "x" -a "x$TECH" != "xNo" ]; then
		MODE="$TECH"
	fi
fi

# OPTION
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F, '/^\+COPS: 0/ {print $4}')
	MODE="-"
	if [ "$TECH" = 0 ]; then
		TECH1=$(echo "$O" | awk '/^_OCTI/ {print $2}' | cut -f1 -d,)
		case $TECH1 in
			1*) MODE="GSM";;
			2*) MODE="GPRS";;
			3*) MODE="EDGE";;
			 *) MODE="-";;
		esac
	elif [ "$TECH" = 2 ]; then
		TECH1=$(echo "$O" | awk '/^_OWCTI/ {print $2}')
		case $TECH1 in
			1*) MODE="UMTS";;
			2*) MODE="HSDPA";;
			3*) MODE="HSUPA";;
			4*) MODE="HSPA";;
			 *) MODE="-";;
		esac
	fi
fi

# Sierra
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,\ ] '/^\*CNTI/ {print $3}' | sed 's|/|,|g')
	if [ "x$TECH" != "x" ]; then
		MODE="$TECH"
	fi
fi

# Novatel
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,\ ] '/^\$CNTI/ {print $4}' | sed 's|/|,|g')
	if [ "x$TECH" != "x" ]; then
		MODE="$TECH"
	fi
fi

# Vodafone - icera
if [ "x$MODE" = "x-" ]; then
	TECH=$(echo "$O" | awk -F[,\ ] '/^\%NWSTATE/ {print $4}' | sed 's|/|,|g')
	if [ "x$TECH" != "x" ]; then
		MODE="$TECH"
	fi
fi

# CREG
CREG="+CREG"
LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
if [ "x$LAC" = "x" ]; then
	CREG="+CGREG"
	LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
fi

if [ "x$LAC" != "x" ]; then
	LAC_NUM=$(printf %d 0x$LAC)
else
	LAC="-"
	LAC_NUM="-"
fi

BTSINFO=""
ENB="-"
ENB_NUM="-"
ENB_SHOW="none"
CID=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($4)}' | sed 's/[^A-F0-9]//g')
if [ "x$CID" != "x" ]; then
	if [ ${#CID} -le 4 ]; then
		LCID="-"
		LCID_NUM="-"
		LCID_SHOW="none"
		RNC="-"
		RNC_NUM="-"
		RNC_SHOW="none"
	else
		LCID=$CID
		LCID_NUM=$(printf %d 0x$LCID)
		LCID_SHOW="block"
		RNC=$(echo "$LCID" | awk '{print substr($1,1,length($1)-4)}')
		RNC_NUM=$(printf %d 0x$RNC)
		RNC_SHOW="block"
		CID=$(echo "$LCID" | awk '{print substr($1,length(substr($1,1,length($1)-4))+1)}')

		if [ "x$MODE" = "xLTE" ]; then
			LCIDLEN=${#LCID}
			CIDSTART=$((LCIDLEN - 2))
			ENB=$(echo $LCID | cut -c 1-$CIDSTART)
			ENB_NUM=$(printf %d 0x$ENB)
			ENB_SHOW="block"
			CIDSTART=$((LCIDLEN - 1))
			CID=$(echo $LCID | cut -c $CIDSTART-255)
			CID=$(printf %04X 0x$CID)
			RNC="-"
			RNC_NUM="-"
			RNC_SHOW="none"
		fi
	fi

	CID_NUM=$(printf %d 0x$CID)
	CLF=$(uci -q get 4gmodem.@4gmodem[0].clf)
	
else
	LCID="-"
	LCID_NUM="-"
	LCID_SHOW="none"
	RNC="-"
	RNC_NUM="-"
	RNC_SHOW="none"
	CID="-"
	CID_NUM="-"
fi

# CGEQNEG
QOS_SHOW="none"
DOWN="-"
UP="-"


# SMS
SMS_SHOW="block"
# USSD
USSD_SHOW="block"

# Status polaczenia
PROTO=$(uci -q get network.$SEC.proto)
if [ "${DEVICE%%[0-9]}" = "/dev/ttyHS" ] && [ "x$PROTO" = "xhso" ]; then
	IFACE="hso0"
else
	IFACE="3g-"$SEC
fi

if ! ifconfig -a | grep -q "$IFACE"; then
	DEV=${DEVICE##/*/}
	DEV1=$(echo /sys/devices/platform/*/*/subsystem/*/*/$DEV)
	if [ -n "$DEV1" ]; then
		DEV1=${DEV1%%/[0-9]*/$DEV}
		DEV1=$(ls "$DEV1"/*/net 2>/dev/null)
		if [ -n "$DEV1" ]; then
			if ifconfig -a | grep -q $DEV1; then
				IFACE=$DEV1
			fi
		fi
	fi
fi

CONN_TIME="-"
RX="-"
TX="-"

if [ "$IFACE" = "3g-" ]; then
	STATUS=$NOINFO
	STATUS_TRE="-"
	STATUS_SHOW="none"
else
	if ifconfig $IFACE 2>/dev/null | grep -q inet; then
		if [ $TOTXT -eq 0 ]; then
			STATUS="<font color=green>$CONNECTED</font>"
		else
			STATUS=$CONNECTED
		fi
		STATUS_TRE=$DISCONNECT

		CT=$(uci -q get -P /var/state/ network.$SEC.connect_time)
		if [ -z $CT ]; then
			CT=$(ifstatus wan | awk -F[:,] '/uptime/ {print $2}')
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
		RX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$2}')
		TX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$4}')
	else
		if [ $TOTXT -eq 0 ]; then
			STATUS="<font color=red>$DISCONNECTED</font>"
		else
			STATUS=$DISCONNECTED
		fi
		STATUS_TRE=$CONNECT
	fi
	STATUS_SHOW="none" #Исправить в будущем
fi

# Informacja o urzadzeniu
DEVICE=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
if [ "x$DEVICE" = "x" ]; then
	DEVICE="-"
fi

# podmiana w szablonie
if [ $TOTXT -eq 0 ]; then
	EXT="html"
else
	EXT="txt"
fi

TEMPLATE="$RES/status.$EXT.$LANG"

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
	s!{LCID}!$LCID!g; \
	s!{LCID_NUM}!$LCID_NUM!g; \
	s!{LCID_SHOW}!$LCID_SHOW!g; \
	s!{RNC}!$RNC!g; \
	s!{RNC_NUM}!$RNC_NUM!g; \
	s!{RNC_SHOW}!$RNC_SHOW!g; \
	s!{ENB}!$ENB!g; \
	s!{ENB_NUM}!$ENB_NUM!g; \
	s!{ENB_SHOW}!$ENB_SHOW!g; \
	s!{CID}!$CID!g; \
	s!{CID_NUM}!$CID_NUM!g; \
	s!{BTSINFO}!$BTSINFO!g; \
	s!{DOWN}!$DOWN!g; \
	s!{UP}!$UP!g; \
	s!{QOS_SHOW}!$QOS_SHOW!g; \
	s!{SMS_SHOW}!$SMS_SHOW!g; \
	s!{USSD_SHOW}!$USSD_SHOW!g; \
	s!{LIMIT_SHOW}!$LIMIT_SHOW!g; \
	s!{STATUS}!$STATUS!g; \
	s!{CONN_TIME}!$CONN_TIME!g; \
	s!{RX}!$RX!g; \
	s!{TX}!$TX!g; \
	s!{STATUS_TRE}!$STATUS_TRE!g; \
	s!{STATUS_SHOW}!$STATUS_SHOW!g; \
	s!{DEVICE}!$DEVICE!g; \
	s!{MODE}!$MODE!g" $TEMPLATE
else
	echo "Template $TEMPLATE missing!"
fi

exit 0
