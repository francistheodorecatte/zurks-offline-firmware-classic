#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
chan=`basename $ID`
base=`dirname $ID`
echo "<form>"
echo "Editing Chumby Channel :"

case $ID in
 (*channels.c1*)
  echo "<A HREF=\"widget.sh?1=1\">$base</A> /"
  ;;
 (*channels.c8*)
  echo "<A HREF=\"widget.sh?8=8\">$base</A> /"
  ;;
 (*)
  echo "<A HREF=\"widget.sh\">$base</A> /"
  ;;
esac

file_list=`ls $base`
echo "<select name=\"channel\" onchange=\"window.location.href='/cgi-bin/widget_edit.sh?name=$base/'+document.spark.channel.options[document.spark.channel.selectedIndex].value\">"
for f in $file_list
do
 if [ "$f" = "$chan" ]; then
  echo "<option value=\"$f\" selected>$f</option>"
 else
  echo "<option value=\"$f\">$f</option>"
 fi
done
echo "</select><BR><BR>"

echo " Select the widget &nbsp;&nbsp; "
file_list=`ls $ID`
echo "<select name=\"widget\">"
 for f in $file_list
 do
echo "<option value=\"$f\">$f</option>"
 done
echo "</select>&nbsp;&nbsp; and "
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_editor.sh?name=$ID/'+document.spark.widget.options[document.spark.widget.selectedIndex].value\">Edit Widget</button>&nbsp;&nbsp; "
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_del.sh?name=$ID/'+document.spark.widget.options[document.spark.widget.selectedIndex].value\">Delete Widget</button><BR><BR><BR>"
echo " or enter a widget name (no spaces allowed - a generic widget is created and can be edited later) <input type=\"text\" name=\"new\" value=\"Default\"></input> &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_add.sh?name=$ID/'+document.spark.new.value\">Add New Widget</button>&nbsp;&nbsp; <BR><BR>"
file_listx=`ls $ID`
 for x in $file_listx
 do
tpath=`echo $ID/$x | sed -e 's/.*\/html\/zchannel/\/zchannel/g'`
echo "<A HREF=\"/cgi-bin/widget_editor.sh?name=$ID/$x\">"
echo "<img src=\"$tpath/thumbnail.jpg\">" 
echo "</A>"
 done

echo "</form></body></html>"
