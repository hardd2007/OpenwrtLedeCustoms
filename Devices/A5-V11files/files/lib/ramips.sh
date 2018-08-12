#!/bin/sh
RAMIPS_BOARD_NAME=
RAMIPS_MODEL=
ramips_board_detect() {
	local machine
	local name
	machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)
	case "$machine" in
	*"A5-V11")
		name="a5-v11"
		;;
	*)
		name="generic"
		;;
	esac
	[ -z "$RAMIPS_BOARD_NAME" ] && RAMIPS_BOARD_NAME="$name"
	[ -z "$RAMIPS_MODEL" ] && RAMIPS_MODEL="$machine"
	[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"
	echo "$RAMIPS_BOARD_NAME" > /tmp/sysinfo/board_name
	echo "$RAMIPS_MODEL" > /tmp/sysinfo/model
}
ramips_board_name() {
	local name
	[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
	[ -z "$name" ] && name="unknown"
	echo "$name"
}