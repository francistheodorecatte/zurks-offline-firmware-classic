#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby Top Processes</title>"
echo "<meta http-equiv=\"Refresh\" content=\"5\";>"
echo "</head></html>"
echo "<body>"
echo "<h4>Top Processes (refreshes every 5 seconds) </h4>"
echo "<pre>"
top -n1
uptime
free
du -sh /tmp
/sbin/ifconfig -a
echo "</pre>"
echo "</body></html>"

