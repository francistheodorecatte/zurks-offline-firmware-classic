#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby dmesg</title>"
echo "</head></html>"
echo "<body>"
echo "<h4> Dmesg </h4>"
echo "<pre>"
dmesg
top -n1
uptime
free
/sbin/ifconfig -a
echo "</pre>"
echo "</body></html>"

