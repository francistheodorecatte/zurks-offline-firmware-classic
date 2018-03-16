#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby License</title>"
echo "</head></html>"
echo "<body>"
echo "<h4> LICENSE </h4>"
echo "<pre>"
cat /mnt/usb/LICENSE.TXT
echo "</pre>"
echo "</body></html>"

