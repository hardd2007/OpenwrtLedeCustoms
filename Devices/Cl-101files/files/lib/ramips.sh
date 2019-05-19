#!/bin/sh
RAMIPS_BOARD_NAME=
RAMIPS_MODEL=
ramips_board_detect() {
local machine
local name
machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)
name="cl-101"
RAMIPS_BOARD_NAME="$name"
RAMIPS_MODEL="$machine"
[ -e "/tmp/sysinfo/" ] || mkdir -p "/tmp/sysinfo/"
echo "$RAMIPS_BOARD_NAME" > /tmp/sysinfo/board_name
echo "$RAMIPS_MODEL" > /tmp/sysinfo/model
}
ramips_board_name() {
local name
[ -f /tmp/sysinfo/board_name ] && name=$(cat /tmp/sysinfo/board_name)
[ -z "$name" ] && name="unknown"
echo "${name%-[0-9]*M}"
}