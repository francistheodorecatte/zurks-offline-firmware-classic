#!/bin/sh
echo "Content-type: text/html"
echo ""
echo "<html><pre>"
echo " -- Black box -- "
cat /mnt/usb/blackbox.txt
echo " -- Orange box -- "
cat /mnt/usb/orangebox.txt
echo " -- Crash box -- "
cat /mnt/usb/crashbox.txt
echo "</pre></html>"
echo ""
