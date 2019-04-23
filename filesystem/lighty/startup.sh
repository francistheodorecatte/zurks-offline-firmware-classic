#!/bin/sh
# kill the built-in web server
killall httpd
killall lighttpd
# create the log directory
mkdir /tmp/logs
# start lighttpd
LD_LIBRARY_PATH=/mnt/usb/lighty/lib /mnt/usb/lighty/sbin/lighttpd -m /mnt/usb/lighty/lib -f /mnt/usb/lighty/lighttpd.conf
