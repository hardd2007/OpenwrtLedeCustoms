#!/bin/sh
echo 0 >/sys/class/gpio/usbpower/value
sleep 2
echo 1 >/sys/class/gpio/usbpower/value
exit 0
