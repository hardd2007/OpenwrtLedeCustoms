#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_ncm_init_config() {
	no_device=1
	available=1
	proto_config_add_string "device:device"
	proto_config_add_string apn
	proto_config_add_string auth
	proto_config_add_string username
	proto_config_add_string password
	proto_config_add_string pincode
	proto_config_add_string delay
	proto_config_add_string delayc
	proto_config_add_string mode
	proto_config_add_string intline
	proto_config_add_string startdhcp
	proto_config_add_string pdptype
	proto_config_add_boolean ipv6
	proto_config_add_int metric
    proto_config_add_int defaultroute
}

proto_ncm_setup() {
	local interface="$1"
	echo "Попытка запуска соединения $1"
	local manufacturer initialize setmode connect ifname devname devpath

	local device apn auth username password pincode delay mode delayc startdhcp pdptype ipv6 intline metric defaultroute
	json_get_vars device apn auth username password pincode delay mode delayc pdptype ipv6 intline metric defaultroute

	if [ "$ipv6" = 0 ]; then
		ipv6=""
	else
		ipv6=1
	fi
	
	[ -z "$pdptype" ] && {
		if [ -n "$ipv6" ]; then
			pdptype="IPV4V6"
		else
			pdptype="IP"
		fi
	}

	[ -n "$ctl_device" ] && device=$ctl_device

	[ -n "$device" ] || {
		echo "No control device specified"
		proto_notify_error "$interface" NO_DEVICE
		proto_set_available "$interface" 0
		return 1
	}
	[ -e "$device" ] || {
		echo "Control device not valid"
		proto_set_available "$interface" 0
		return 1
	}
	echo "Apn = $apn"
	[ -n "$apn" ] || {
		echo "No APN specified"
		proto_notify_error "$interface" NO_APN
		return 1
	}

	devname="$(basename "$device")"
	case "$devname" in
	'tty'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		ifname="$( ls "$devpath"/../../*/net )"
		;;
	*)
		devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
		ifname="$( ls "$devpath"/net )"
		;;
	esac
	[ -n "$ifname" ] || {
		echo "The interface could not be found."
		proto_notify_error "$interface" NO_IFACE
		proto_set_available "$interface" 0
		return 1
	}
	echo "Время инициализации модема $delay секунд"
	[ -n "$delay" ] && sleep "$delay"
	O=$(gcom -d $device -s /etc/gcom/modem_dev.gcom 2>/dev/null)
	manufacturer=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
	#manufacturer=`gcom -d "$device" -s /etc/gcom/getcardinfo.gcom | awk '/Model/ { print tolower($2) }'`
	#manufacturer=`gcom -d "$device" -s /etc/gcom/getcardinfo.gcom | awk 'NF && $0 !~ /AT\+CGMI/ { sub(/\+CGMI: /,""); print tolower($1); exit; }'`
	if [ "$manufacturer" == "e3372" ]; then
	manufacturer="huawei"
	else
	#manufacturer=`gcom -d "$device" -s /etc/gcom/getcardinfo.gcom | awk '/Manufacturer/ { print tolower($2) }'`
	manufacturer=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
	fi
	
	[ $? -ne 0 ] && {
		echo "Failed to get modem information"
		proto_notify_error "$interface" GETINFO_FAILED
		return 1
	}

	json_load "$(cat /etc/gcom/ncm.json)"
	json_select "$manufacturer"
	[ $? -ne 0 ] && {
		echo "Unsupported modem"
		proto_notify_error "$interface" UNSUPPORTED_MODEM
		proto_set_available "$interface" 0
		return 1
	}
	echo "Определён модем $manufacturer"
	json_get_values initialize initialize
	echo "Начальная инициализация"
	for i in $initialize; do
		eval COMMAND="$i" gcom -d "$device" -s /etc/gcom/runcommand.gcom || {
			echo "Failed to initialize modem"
			proto_notify_error "$interface" INITIALIZE_FAILED
			return 1
		}
	done
	[ -n "$pincode" ] && {
		echo "Проверка пин-кода"
		PINCODE="$pincode" gcom -d "$device" -s /etc/gcom/setpin.gcom || {
			echo "Unable to verify PIN"
			proto_notify_error "$interface" PIN_FAILED
			proto_block_restart "$interface"
			return 1
		}
	}
	if [ "$mode" == "not" ] ||  [ "$mode" == "userat" ]; then
	mode=""
	fi
	[ -n "$mode" ] && {
		echo "Установка режима сети"
		json_select modes
		json_get_var setmode "$mode"
		COMMAND="$setmode" gcom -d "$device" -s /etc/gcom/runcommand.gcom || {
			echo "Failed to set operating mode"
			proto_notify_error "$interface" SETMODE_FAILED
			return 1
		}
		json_select ..
	}
	[ -n "$intline" ] && {
		echo "Отправка пользовательской команды $intline"
		COMMAND="$intline" gcom -d "$device" -s /etc/gcom/runcommand.gcom || {
			echo "Failed to set operating mode"
			proto_notify_error "$interface" SETMODE_FAILED
			return 1
		}
	}
	
	echo "Поиск и регистрация в сети $delayc"
	[ -n "$delayc" ] && sleep "$delayc"
	
	json_get_vars connect
	echo "Посылка вызова соединения"
	eval COMMAND="$connect" gcom -d "$device" -s /etc/gcom/runcommand.gcom || {
		echo "Failed to connect"
		proto_notify_error "$interface" CONNECT_FAILED
		return 1
	}
	
	
	[ ! -n "$startdhcp" ] && {
	echo "Starting DHCP"
	
	proto_init_update "$ifname" 1
	proto_send_update "$interface"

	json_init
	json_add_string name "${interface}_4"
	json_add_string ifname "@$interface"
	json_add_string proto "dhcp"
	json_add_int metric "$metric"
	json_add_boolean "$defaultroute"
	ubus call network add_dynamic "$(json_dump)"

	[ -n "$ipv6" ] && {
		json_init
		json_add_string name "${interface}_6"
		json_add_string ifname "@$interface"
		json_add_string proto "dhcpv6"
		json_add_string extendprefix 1
		ubus call network add_dynamic "$(json_dump)"
	}
  }
}

proto_ncm_teardown() {
	local interface="$1"

	local manufacturer disconnect

	local device
	json_get_vars device

	echo "Stopping network"

	#manufacturer=`gcom -d "$device" -s /etc/gcom/getcardinfo.gcom | awk '/Model/ { print tolower($2) }'`
	O=$(gcom -d $device -s /etc/gcom/modem_dev.gcom 2>/dev/null)
	manufacturer=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
	if [ "$manufacturer" == "e3372" ]; then
	manufacturer="huawei"
	else
	manufacturer=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
	fi
	[ $? -ne 0 ] && {
		echo "Failed to get modem information"
		proto_notify_error "$interface" GETINFO_FAILED
		return 1
	}

	json_load "$(cat /etc/gcom/ncm.json)"
	json_select "$manufacturer" || {
		echo "Unsupported modem"
		proto_notify_error "$interface" UNSUPPORTED_MODEM
		return 1
	}

	json_get_vars disconnect
	COMMAND="$disconnect" gcom -d "$device" -s /etc/gcom/runcommand.gcom || {
		echo "Failed to disconnect"
		proto_notify_error "$interface" DISCONNECT_FAILED
		return 1
	}

	proto_init_update "*" 0
	proto_send_update "$interface"
}
[ -n "$INCLUDE_ONLY" ] || {
	add_protocol ncm
}
