#!/bin/sh
AR71XX_BOARD_NAME="tl-wr1043nd"
AR71XX_MODEL="TP-Link TL-WR1043N/ND v1"

ar71xx_board_detect() {
	local machine
	local name
#	[ -z "$name" ] && name="unknown"
#	[ -z "$AR71XX_BOARD_NAME" ] && AR71XX_BOARD_NAME="$name"
#	[ -z "$AR71XX_MODEL" ] && AR71XX_MODEL="$machine"
	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"
	echo "$AR71XX_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$AR71XX_MODEL" > /tmp/sysinfo/model
}

ar71xx_board_name() {
	local name
	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"
	echo "$name"
}
