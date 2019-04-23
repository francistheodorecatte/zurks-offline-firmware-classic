#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Deleting Chumby Widget : $ID<br>"
rm -rf $ID
sync
echo "</form>"
base=`dirname $ID`
echo "<P><A HREF=\"widget_edit.sh?name=$base\">Return</A> to the editor"
</body></html>"
