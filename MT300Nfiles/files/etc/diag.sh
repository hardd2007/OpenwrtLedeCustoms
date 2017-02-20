#!/bin/sh

. /lib/functions/leds.sh

get_status_led() {
	status_led="gl-mt300n:wlan"
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
		status_led_off
		;;
	esac
}
