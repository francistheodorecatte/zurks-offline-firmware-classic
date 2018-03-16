#!/bin/sh
modprobe chumby_timer
mknod /dev/timerx c $(grep timerx /proc/devices | cut -d' ' -f1) 0
mknod /dev/timerm c $(grep timerx /proc/devices | cut -d' ' -f1) 1
