#!/bin/sh                                                                       
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Pandora</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "Pandora enabled"
cp /mnt/usb/psp/hosts.pandora /mnt/usb/psp/hosts
echo "</pre>"
echo "</body></html>"
