#!/bin/sh
find /mnt/usb/music/*.mp3 | while read x; do echo "`expr $RANDOM % 10000`:$x"; done | sort -n| sed 's/[0-9]*://'

