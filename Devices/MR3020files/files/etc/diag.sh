#!/bin/sh
. /lib/functions.sh
. /lib/functions/leds.sh
status_led="tp-link:green:wps"
set_state() {
case "$1" in
preinit)
status_led_blink_preinit
;;
failsafe)
status_led_blink_failsafe
;;
preinit_regular)
status_led_blink_preinit_regular
;;
done)
//status_led_set_heartbeat
led_timer $status_led 1500 1500
#status_led_on
/usr/bin/core_init &
;;
esac
}