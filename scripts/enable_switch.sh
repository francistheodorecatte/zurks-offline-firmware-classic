#!/bin/sh
modprobe chumby_bend
mknod /dev/switch c $(grep switch /proc/devices | cut -d' ' -f1) 0
