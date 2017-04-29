. /lib/functions/system.sh
. /lib/ar71xx.sh
PART_NAME=firmware
RAMFS_COPY_DATA=/lib/ar71xx.sh
CI_BLKSZ=65536
CI_LDADR=0x80060000
PLATFORM_DO_UPGRADE_COMBINED_SEPARATE_MTD=0
platform_find_partitions() {
local first dev size erasesize name
while read dev size erasesize name; do
name=${name#'"'}; name=${name%'"'}
case "$name" in
vmlinux.bin.l7|vmlinux|kernel|linux|linux.bin|rootfs|filesystem)
if [ -z "$first" ]; then
first="$name"
else
echo "$erasesize:$first:$name"
break
fi
;;
esac
done < /proc/mtd
}
platform_find_kernelpart() {
local part
for part in "${1%:*}" "${1#*:}"; do
case "$part" in
vmlinux.bin.l7|vmlinux|kernel|linux|linux.bin)
echo "$part"
break
;;
esac
done
}
platform_find_rootfspart() {
local part
for part in "${1%:*}" "${1#*:}"; do
[ "$part" != "$2" ] && echo "$part" && break
done
}
platform_do_upgrade_combined() {
local partitions=$(platform_find_partitions)
local kernelpart=$(platform_find_kernelpart "${partitions#*:}")
local erase_size=$((0x${partitions%%:*})); partitions="${partitions#*:}"
local kern_length=0x$(dd if="$1" bs=2 skip=1 count=4 2>/dev/null)
local kern_blocks=$(($kern_length / $CI_BLKSZ))
local root_blocks=$((0x$(dd if="$1" bs=2 skip=5 count=4 2>/dev/null) / $CI_BLKSZ))
if [ -n "$partitions" ] && [ -n "$kernelpart" ] && \
[ ${kern_blocks:-0} -gt 0 ] && \
[ ${root_blocks:-0} -gt 0 ] && \
[ ${erase_size:-0} -gt 0 ];
then
local rootfspart=$(platform_find_rootfspart "$partitions" "$kernelpart")
local append=""
[ -f "$CONF_TAR" -a "$SAVE_CONFIG" -eq 1 ] && append="-j $CONF_TAR"
if [ "$PLATFORM_DO_UPGRADE_COMBINED_SEPARATE_MTD" -ne 1 ]; then
( dd if="$1" bs=$CI_BLKSZ skip=1 count=$kern_blocks 2>/dev/null; \
dd if="$1" bs=$CI_BLKSZ skip=$((1+$kern_blocks)) count=$root_blocks 2>/dev/null ) | \
mtd -r $append -F$kernelpart:$kern_length:$CI_LDADR,rootfs write - $partitions
elif [ -n "$rootfspart" ]; then
dd if="$1" bs=$CI_BLKSZ skip=1 count=$kern_blocks 2>/dev/null | \
mtd write - $kernelpart
dd if="$1" bs=$CI_BLKSZ skip=$((1+$kern_blocks)) count=$root_blocks 2>/dev/null | \
mtd -r $append write - $rootfspart
fi
fi
PLATFORM_DO_UPGRADE_COMBINED_SEPARATE_MTD=0
}
tplink_get_image_hwid() {
get_image "$@" | dd bs=4 count=1 skip=16 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}
tplink_get_image_mid() {
get_image "$@" | dd bs=4 count=1 skip=17 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}
tplink_get_image_boot_size() {
get_image "$@" | dd bs=4 count=1 skip=37 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"'
}
tplink_pharos_check_image() {
local magic_long="$(get_magic_long "$1")"
[ "$magic_long" != "7f454c46" ] && {
echo "Invalid image magic '$magic_long'"
return 1
}
local model_string="$(tplink_pharos_get_model_string)"
local line
dd if="$1" bs=1 skip=1511432 count=1024 2>/dev/null | while read line; do
[ "$line" == "$model_string" ] && break
done || {
echo "Unsupported image (model not in support-list)"
return 1
}
return 0
}
platform_check_image() {
local board=$(ar71xx_board_name)
local magic="$(get_magic_word "$1")"
local magic_long="$(get_magic_long "$1")"
[ "$#" -gt 1 ] && return 1
[ "$magic" != "0100" ] && {
echo "Invalid image type."
return 1
}
local hwid
local mid
local imagehwid
local imagemid
hwid="30200001"
mid="00000001"
imagehwid=$(tplink_get_image_hwid "$1")
imagemid=$(tplink_get_image_mid "$1")
[ "$hwid" != "$imagehwid" -o "$mid" != "$imagemid" ] && {
echo "Invalid image, hardware ID mismatch, hw:$hwid $mid image:$imagehwid $imagemid."
return 1
}
local boot_size
boot_size=$(tplink_get_image_boot_size "$1")
[ "$boot_size" != "00000000" ] && {
echo "Invalid image, it contains a bootloader."
return 1
}
return 0
echo "Sysupgrade is not yet supported on $board."
return 1
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
append sysupgrade_pre_upgrade disable_watchdog