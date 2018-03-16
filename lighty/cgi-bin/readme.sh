#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby README</title>"
echo "</head></html>"
echo "<body>"
echo "<h4> README </h4>"
echo "<pre>"
cat /mnt/usb/README.TXT
echo "</pre>"
echo "</body></html>"

