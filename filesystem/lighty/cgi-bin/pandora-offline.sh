#!/bin/sh                                                                       
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Pandora</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "Pandora disabled"
cp /psp/hosts.offline /psp/hosts
echo "</pre>"
echo "</body></html>"
