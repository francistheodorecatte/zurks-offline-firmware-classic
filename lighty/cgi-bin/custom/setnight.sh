#!/bin/sh
# /psp/cgi-bin/setbrightnes
# needs brightness as parameter between 0 and 100
# e.g. http://<ip.of.you.chumby/cgi-bin/custom/setbrightness.sh?30
#
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo "${QUERY_STRING}" > /mnt/usb/psp/nightmode_brightness
echo ""
echo "Brightness set to ${QUERY_STRING}"
