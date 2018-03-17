#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby Web Logs</title>"
echo "</head></html>"
echo "<body>"
echo "<h4> Web Logs </h4>"
cat /psp/zurk
echo "<pre>"
cat /tmp/zerror.log
echo "</PRE><BR><HR><BR><PRE>"
cat /tmp/zaccess.log
echo "</pre>"
echo "</body></html>"
