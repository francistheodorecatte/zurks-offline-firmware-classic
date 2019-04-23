#!/bin/sh                                                                       
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Pandora</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "Pandora enabled"
cp /psp/hosts.pandora /psp/hosts
echo "</pre>"
echo "</body></html>"
