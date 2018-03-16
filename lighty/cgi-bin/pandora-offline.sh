#!/bin/sh                                                                       
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Pandora</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "Pandora disabled"
cp /mnt/usb/psp/hosts.offline /mnt/usb/psp/hosts
echo "</pre>"
echo "</body></html>"
