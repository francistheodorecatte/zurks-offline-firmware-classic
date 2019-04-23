#!/bin/sh

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20/ /g' | sed -e 's/%3E/>/g' | sed -e 's/%22/"/g'`
echo "Content-type: text/html"
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Executing : $ID<br>"
echo " - Executing : "
sleep 5
echo "$ID">/tmp/e2.sh
cat /tmp/e2.sh
echo "<br>"
/bin/sh /tmp/e2.sh
rm -f /tmp/e2.sh
sync
echo "</form></body></html>"
