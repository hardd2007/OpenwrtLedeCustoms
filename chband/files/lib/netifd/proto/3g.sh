#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	NOT_INCLUDED=1
	INCLUDE_ONLY=1

	. ../netifd-proto.sh
	. ./ppp.sh
	init_proto "$@"
}

proto_3g_init_config() {
	no_device=1
	available=1
	ppp_generic_init_config
	proto_config_add_string "device:device"
	proto_config_add_string "apn"
	proto_config_add_string "service"
	proto_config_add_string "pincode"
	proto_config_add_string "dialnumber"
}

proto_3g_setup() {
	local interface="$1"
	local chat

	json_get_var device device
	json_get_var apn apn
	json_get_var service service
	json_get_var pincode pincode
	json_get_var dialnumber dialnumber

	[ -n "$dat_device" ] && device=$dat_device
	[ -e "$device" ] || {
		proto_set_available "$interface" 0
		return 1
	}

	case "$service" in
		cdma|evdo)
			chat="/etc/chatscripts/evdo.chat"
		;;
		*)
			chat="/etc/chatscripts/3g.chat"
			cardinfo=$(gcom -d "$device" -s /etc/gcom/getcardinfo.gcom)
			if echo "$cardinfo" | grep -q Novatel; then
				case "$service" in
					umts_only) CODE=2;;
					gprs_only) CODE=1;;
					*) CODE=0;;
				esac
				export MODE="AT\$NWRAT=${CODE},2"
			elif echo "$cardinfo" | grep -q Option; then
				case "$service" in
					umts_only) CODE=1;;
					gprs_only) CODE=0;;
					*) CODE=3;;
				esac
				export MODE="AT_OPSYS=${CODE}"
			elif echo "$cardinfo" | grep -q "Sierra Wireless"; then
                                SIERRA=1
            elif echo "$cardinfo" | grep -qi "E327"; then
# 00000100 is EGSM900, 00000200 is primary GSM900
                BAND="3FFFFFFF"
                case "$service" in
                    umts_only) CODE="02";;
                    umts900_only) CODE="02"
                      BAND="0002000000000000";;
                    umts2100_only) CODE="02"
                      BAND="00400000";;
                    gprs_only) CODE="01";;
                    gprs900_only) CODE="01"
                      BAND="00000100";;
                    gprs1800_only) CODE="01"
                      BAND="00000080";;
                    lte_only) CODE="03";;
                    lte_b7_only) CODE="03"
                      BAND="40";;
                    lte_b20_only) CODE="03"
                      BAND="80000";;
                    *) CODE="00";;
                esac
                export MODE="AT^SYSCFGEX=\"${CODE}\",${BAND},1,4,7FFFFFFFFFFFFFFF,\"\",\"\""
            elif echo "$cardinfo" | grep -qi huawei; then
                BAND="3FFFFFFF"
                case "$service" in
                    lte_only) CODE="14,2";;
                    lte_b7_only) CODE="14,2";;
                    lte_b20_only) CODE="14,2";;
                    umts_only) CODE="14,2";;
                    umts900_only) CODE="14,2"
                    BAND="0002000000000000";;
                    umts2100_only) CODE="14,2"
                    BAND="00400000";;
                    gprs_only) CODE="13,1";;
                    gprs900_only) CODE="13,1"
                    BAND="00000100";;
                    gprs1800_only) CODE="13,1"
                    BAND="00000080";;
                    *) CODE="2,2";;
                esac
            export MODE="AT^SYSCFG=${CODE},${BAND},2,4"
        fi

			if [ -n "$pincode" ]; then
				PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
					proto_notify_error "$interface" PIN_FAILED
					proto_block_restart "$interface"
					return 1
				}
			fi
			[ -n "$MODE" ] && gcom -d "$device" -s /etc/gcom/setmode.gcom

			# wait for carrier to avoid firmware stability bugs
			[ -n "$SIERRA" ] && {
				gcom -d "$device" -s /etc/gcom/getcarrier.gcom || return 1
			}

			if [ -z "$dialnumber" ]; then
				dialnumber="*99***1#"
			fi

		;;
	esac

	connect="${apn:+USE_APN=$apn }DIALNUMBER=$dialnumber /usr/sbin/chat -t5 -v -E -f $chat"
	ppp_generic_setup "$interface" \
		noaccomp \
		nopcomp \
		novj \
		nobsdcomp \
		noauth \
		lock \
		crtscts \
		115200 "$device"
	return 0
}

proto_3g_teardown() {
	proto_kill_command "$interface"
}

[ -z "NOT_INCLUDED" ] || add_protocol 3g
