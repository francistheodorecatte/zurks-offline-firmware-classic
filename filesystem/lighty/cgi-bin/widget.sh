#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`

# If parameter undefined, match the unit type
if [ "$ID" = "" ]; then
  if [ -f /psp/c1 ]; then
    ID=1
  else
    ID=8
  fi
fi

echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "</head>"
echo "<body>"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
if [ "$ID" -eq "1" ]; then
echo "Chumby One<br><br>"
echo " Select the channel &nbsp;&nbsp; "
file_list=`ls ../html/zchannel/channels.c1`
else
echo "Chumby Eight<br><br>"
echo " Select the channel &nbsp;&nbsp; "
file_list=`ls ../html/zchannel/channels.c8`
fi
echo '<select name="channel">'
 for f in $file_list
 do
echo "<option value=\"$f\">$f</option>"
 done
echo "</select>&nbsp;&nbsp; and "
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_edit.sh?name=../html/zchannel/channels.c$ID/'+document.spark.channel.options[document.spark.channel.selectedIndex].value\">Edit Channel</button>&nbsp;&nbsp; "
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_delchannel$ID.sh?name='+document.spark.channel.options[document.spark.channel.selectedIndex].value\">Delete Channel</button>&nbsp;&nbsp; "
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_defchannel.sh?name='+document.spark.channel.options[document.spark.channel.selectedIndex].value\">Default Channel</button><BR><BR><BR>"
echo " or enter a channel name (no spaces allowed) <input type=\"text\" name=\"new\" value=\"Default\"></input> &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_addchannel$ID.sh?name='+document.spark.new.value\">Add New Channel</button>&nbsp;&nbsp; <BR>"
echo "</form></body></html>"
