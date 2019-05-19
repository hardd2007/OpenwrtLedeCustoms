#!/bin/sh
. /lib/functions/leds.sh
. /lib/ramips.sh
get_status_led() {
status_led="cl-101:wps"
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
#status_led_on
/usr/bin/core_init &
###/usr/bin/start &
status_led_set_timer 1500 1500
;;
esac
}