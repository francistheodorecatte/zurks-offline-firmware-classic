#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby Web Logs</title>"
echo "</head></html>"
echo "<body>"
echo "<h4> Web Logs </h4>"
echo "<pre>"
cat /mnt/usb/tmp/error.log
echo "</PRE><BR><HR><BR><PRE>"
cat /mnt/usb/tmp/access.log
echo "</pre>"
echo "</body></html>"

