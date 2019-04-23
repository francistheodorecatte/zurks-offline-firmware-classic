#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
echo "Adding Chumby Widget : $ID<br>"
mkdir $ID
cp ../../www/genericwidget.jpg $ID/thumbnail.jpg
cp ../../www/genericwidget.swf $ID/movie.swf
if [[ $ID = *c1* ]]; then
echo " <widget_parameter>" > $ID/parameters.txt
echo "  <name>name1</name>" >> $ID/parameters.txt
echo "  <value>value1</value>" >> $ID/parameters.txt
echo " </widget_parameter>" >> $ID/parameters.txt
echo " <widget_parameter>" >> $ID/parameters.txt
echo "  <name>name2</name>" >> $ID/parameters.txt
echo "  <value>value2</value>" >> $ID/parameters.txt
echo " </widget_parameter>" >> $ID/parameters.txt
else
echo "<parameter value=\"value1\" name=\"name1\"/>" > $ID/parameters.txt
echo "<parameter value=\"value2\" name=\"name2\"/>" >> $ID/parameters.txt
fi
sync
echo "</form></body></html>"
