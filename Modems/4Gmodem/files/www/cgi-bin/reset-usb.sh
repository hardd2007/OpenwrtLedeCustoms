#!/bin/sh
echo 0 >/sys/devices/virtual/gpio/gpio8/value
sleep 2
echo 1 >/sys/devices/virtual/gpio/gpio8/value
exit 0