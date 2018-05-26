#!/bin/sh
. /lib/functions/leds.sh
get_status_led() {
status_led="mt7620n:wlan"
}
set_state() {
get_status_led $1
case "$1" in
preinit)
status_led_blink_preinit
;;
failsafe)
status_led_blink_failsafe
;;
upgrade | \
preinit_regular)
status_led_blink_preinit_regular
;;
done)
#status_led_set_heartbeat
led_timer $status_led 1500 1500
#status_led_on
/usr/bin/core_init &
;;
esac
}