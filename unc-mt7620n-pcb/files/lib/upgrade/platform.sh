. /lib/ramips.sh
PART_NAME=firmware
RAMFS_COPY_DATA=/lib/ramips.sh
platform_check_image() {
local board=$(ramips_board_name)
local magic="$(get_magic_long "$1")"
[ "$#" -gt 1 ] && return 1
return 0
}
platform_do_upgrade() {
local board=$(ramips_board_name)
case "$board" in
*)
default_do_upgrade "$ARGV"
;;
esac
}
disable_watchdog() {
killall watchdog
( ps | grep -v 'grep' | grep '/dev/watchdog' ) && {
echo 'Could not disable watchdog'
return 1
}
}
blink_led() {
. /etc/diag.sh; set_state upgrade
}
append disable_watchdog
append blink_led