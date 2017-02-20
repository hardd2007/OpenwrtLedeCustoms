#!/bin/sh

AR71XX_BOARD_NAME=
AR71XX_MODEL=

ar71xx_get_mtd_offset_size_format() {
	local mtd="$1"
	local offset="$2"
	local size="$3"
	local format="$4"
	local dev
	dev=$(find_mtd_part $mtd)
	[ -z "$dev" ] && return
	dd if=$dev bs=1 skip=$offset count=$size 2>/dev/null | hexdump -v -e "1/1 \"$format\""
}

ar71xx_get_mtd_part_magic() {
	local mtd="$1"
	ar71xx_get_mtd_offset_size_format "$mtd" 0 4 %02x
}

tplink_get_hwid() {
	local part
	part=$(find_mtd_part firmware)
	[ -z "$part" ] && return 1
	dd if=$part bs=4 count=1 skip=16 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}

tplink_get_mid() {
	local part
	part=$(find_mtd_part firmware)
	[ -z "$part" ] && return 1
	dd if=$part bs=4 count=1 skip=17 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}

tplink_board_detect() {
	local model="$1"
	local hwid
	local hwver

	hwid=$(tplink_get_hwid)
	mid=$(tplink_get_mid)
	hwver=${hwid:6:2}
	hwver=" v${hwver#0}"
	model="TP-Link TL-MR3420"
	AR71XX_MODEL="$model$hwver"
}

ar71xx_board_detect() {
	local machine
	local name
	name="tl-mr3420-v3"
	machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)
	[ -z "$AR71XX_MODEL" ] && [ "${machine:0:8}" = 'TP-LINK ' ] && \
		tplink_board_detect "$machine"
	[ -z "$name" ] && name="unknown"
	[ -z "$AR71XX_BOARD_NAME" ] && AR71XX_BOARD_NAME="$name"
	[ -z "$AR71XX_MODEL" ] && AR71XX_MODEL="$machine"
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
