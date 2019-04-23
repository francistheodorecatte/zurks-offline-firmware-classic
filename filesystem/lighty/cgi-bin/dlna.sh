#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>DLNA Status</title>"
echo "</head></html>"
echo "<body>"
echo "<h4>"
if [ -f /mnt/usb/dlna.on ]; then
if [ -f /tmp/dlna.on ]; then
echo "DLNA has NOT been started yet. It is currently in queue to be started."
else
echo "DLNA has been started and can be used normally."
fi
else
echo "DLNA has been disabled."
fi
echo "</h4>"
echo "</body></html>"

