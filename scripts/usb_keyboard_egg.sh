#!/bin/sh
source /etc/profile


# Don't do anything if the flashplayer isn't running
# (or the hackfile isn't there)
[ -e /tmp/flashplayer_started -o -e /psp/usb_fb_hack ] || exit 0

if [ "x$1" != "x" ]
then
    /usr/bin/olfade 1
	exit 0
fi

# Load the framebuffer console
/sbin/modprobe fbcon

# Restart init, because /dev/tty0 may have just appeared
sleep 1
/bin/kill -HUP 1

# Ensure the screen doesn't blank
echo -en "\033[9;0]\033[14;0]\033[13]\033[?1c" > /dev/tty0

/usr/bin/olfade 0
