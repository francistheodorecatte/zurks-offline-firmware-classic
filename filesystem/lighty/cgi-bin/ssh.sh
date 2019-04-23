#!/bin/sh                                                                       
#doesnt work cuz webserver is non root priv
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>SSH</title>"
echo "</head></html>"
echo "<body>"
echo "<pre>"                                                                    
echo "SSH cannot be enabled"
service_control sshd stop
sleep 5
/usr/chumby/scripts/start_sshd.sh
sleep 5
echo "</pre>"
echo "</body></html>"
