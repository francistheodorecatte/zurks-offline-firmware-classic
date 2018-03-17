#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
echo "Content-type: text/html"                                                  
echo ""
echo "<html><head>"
echo "<title>Chumby Multi-Channel Widget Editor</title>"
echo "<script type=\"text/javascript\" src=\"/webtoolkit.base64.js\"></script>"
echo "</head>"
echo "<body onload=\"document.spark.params.value=Base64.decode(document.spark.params.value);\">"
echo "<h4>Zurk's Multi Channel Widget Editor</h4><form name=\"spark\">"
base=`dirname $ID`
chan=`basename $base`
root=`dirname $base`
widget=`basename $ID`
echo "Editing Chumby Widget :"

echo "<A HREF=\"widget_edit.sh?name=$base\">$root</A> /"
               
file_list=`ls $root`
echo "<select name=\"channel\" onchange=\"window.location.href='/cgi-bin/widget_edit.sh?name=$root/'+document.spark.channel.options[document.spark.channel.selectedIndex].value\">"
for f in $file_list
do
 if [ "$f" = "$chan" ]; then
  echo "<option value=\"$f\" selected>$f</option>"
 else
  echo "<option value=\"$f\">$f</option>"
 fi
done
echo "</select> /"
       
file_list=`ls $base`
echo "<select name=\"widget\" onchange=\"window.location.href='/cgi-bin/widget_editor.sh?name=$base/'+document.spark.widget.options[document.spark.widget.selectedIndex].value\">"
for f in $file_list
do
 if [ "$f" = "$widget" ]; then
  echo "<option value=\"$f\" selected>$f</option>"
 else
  echo "<option value=\"$f\">$f</option>"
 fi
done
echo "</select><P>"

tpath=`echo $ID/$x | sed -e 's/.*\/html\/zchannel/\/zchannel/g'`
echo "<img src=$tpath/thumbnail.jpg>"
echo "<P>Rename widget to : "
echo "<input type=\"text\" name=\"rename\" value=\"$widget\"></input> &nbsp;&nbsp; "
echo "<button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_rename.sh?name=$ID&newname='+document.spark.rename.value\">Rename</button>"
echo "<P>Copy $widget to channel : "
file_list=`ls $root`
echo "<select name=\"copy\">"
for f in $file_list
do
 if [ "$f" = "$chan" ]; then
  echo "<option value=\"$f\" selected>$f</option>"
 else
  echo "<option value=\"$f\">$f</option>"
 fi
done
echo "</select>"
echo "<button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_copy.sh?source=$ID&dest='+document.spark.copy.options[document.spark.copy.selectedIndex].value\">Copy</button><P>"
       
echo "<iframe id=\"yyy\" src=\"$tpath/movie.swf\" width=\"400\" height=\"300\" frameborder=\"0\" scrolling=\"no\"></iframe>"
if [ -f "$ID/template.swf" ]; then
echo "<iframe id=\"yyy\" src=\"$tpath/template.swf\" width=\"400\" height=\"300\" frameborder=\"0\" scrolling=\"yes\"></iframe>"
fi
txx=`cat $ID/timeout`
echo "<P>Enter a timeout value in seconds (e.g. 180) &nbsp; <input type=\"text\" name=\"timp\" value=\"$txx\"></input> &nbsp;&nbsp; "
echo "<button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_exec2.sh?name=echo%20%22'+document.spark.timp.value+'%22%20>%20$ID/timeout'\">Set Timeout</button>&nbsp;&nbsp; <P>"
echo "<H4>Parameters</H4>"
echo "<button type=\"button\" name=\"refresh\" onclick=\"window.location.href='/cgi-bin/widget_editor.sh?name=$ID';\">Refresh</button><BR>"
echo "<textarea name=\"params\" rows=\"40\" cols=\"80\">"
cat "$ID/parameters.txt" | /mnt/usb/python/bin/python -m base64 -e
echo "</textarea><br>"
echo "<iframe id=\"xxx\" src=\"about:blank\" width=\"300\" height=\"100\" frameborder=\"0\" scrolling=\"yes\" onload=\"document.spark.zap.disabled=false;\"></iframe><BR>Click replace and then confirm to publish the parameters to the widgets. &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"document.spark.zap.disabled=true;document.getElementById('xxx').src='/cgi-bin/widget_decode64.sh?name='+Base64.encode(document.spark.params.value);\">Replace Parameters</button>&nbsp;&nbsp; "
echo " <button type=\"button\" name=\"zap\" onclick=\"window.location.href='/cgi-bin/widget_exec.sh?name=mv%20/tmp/decode.txt%20$ID/parameters.txt';\" disabled>Confirm Replace</button>&nbsp;&nbsp; <BR><BR>"
echo " Enter a replacement thumbnail filename (e.g. if you insert a usb stick the path will be /mnt/usb/mythumb.jpg) &nbsp; <input type=\"text\" name=\"thumbnail\" value=\"mythumb.jpg\"></input> &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_exec.sh?name=cp%20'+document.spark.thumbnail.value+'%20$ID/thumbnail.jpg'\">Replace Thumbnail</button>&nbsp;&nbsp; <BR><BR>"
echo " Enter a replacement swf filename (e.g. if you insert a usb stick the path will be /mnt/usb/mymovie.swf) &nbsp; <input type=\"text\" name=\"movie\" value=\"mymovie.swf\"></input> &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_exec.sh?name=cp%20'+document.spark.movie.value+'%20$ID/movie.swf'\">Replace SWF Movie</button>&nbsp;&nbsp; <BR><BR>"
echo " Enter a replacement template filename (e.g. if you insert a usb stick the path will be /mnt/usb/mytemplate.swf) &nbsp; <input type=\"text\" name=\"template\" value=\"mytemplate.swf\"></input> &nbsp;&nbsp;"
echo " <button type=\"button\" onclick=\"window.location.href='/cgi-bin/widget_exec.sh?name=cp%20'+document.spark.template.value+'%20$ID/template.swf'\">Replace Template</button>&nbsp;&nbsp; <BR><BR>"
echo "</form></body></html>"
