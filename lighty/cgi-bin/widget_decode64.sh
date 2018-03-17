#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Decoding to /tmp/decode.txt and dumping : $ID<br>"
echo "$ID" > /tmp/decode.t
/mnt/usb/lighty/cgi-bin/widget_base64.sh -d < /tmp/decode.t > /tmp/decode.txt
rm -f /tmp/decode.t
sync
echo "</form></body></html>"
