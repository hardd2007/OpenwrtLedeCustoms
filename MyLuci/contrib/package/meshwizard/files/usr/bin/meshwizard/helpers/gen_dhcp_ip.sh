#!/bin/sh
echo "$1" | awk 'BEGIN { FS = "." } ; { print "6."$3"."$4".1" }'