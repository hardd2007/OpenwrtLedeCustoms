. /lib/ramips.sh
PART_NAME=firmware
RAMFS_COPY_DATA=/lib/ramips.sh
platform_check_image() {
local board=$(ramips_board_name)
local magic="$(get_magic_long "$1")"
[ "$#" -gt 1 ] && return 1
[ "$magic" != "27051956" ] && {
echo "Invalid image type."
return 1
}
return 0
echo "Sysupgrade is not yet supported on $board."
return 1
}
platform_nand_pre_upgrade() {
local board=$(ramips_board_name)
case "$board" in
ubnt-erx)
platform_upgrade_ubnt_erx "$ARGV"
;;
esac
}

platform_do_upgrade() {
default_do_upgrade "$ARGV"
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
append sysupgrade_pre_upgrade disable_watchdog
append sysupgrade_pre_upgrade blink_led