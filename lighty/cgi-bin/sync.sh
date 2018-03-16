#!/bin/sh                                                                       
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Sync</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "Sync completed"
sync
echo "</pre>"
echo "</body></html>"
