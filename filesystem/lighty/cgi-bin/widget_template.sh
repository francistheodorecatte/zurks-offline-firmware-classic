#!/bin/sh

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`

# Get the POST string, if defined
if [ "$REQUEST_METHOD" = "POST" ]; then
	read -n $CONTENT_LENGTH QUERY_STRING_POST

	echo "$QUERY_STRING_POST" | sed -e 's/<widget_instance>//g' | sed -e 's/<widget_parameters>//g' | sed -e 's/<\/widget_parameters>//g' | sed -e 's/<\/widget_instance>//g' | sed -e 's/></>\n</g' > /mnt/usb/lighty/html/zchannel/parameters/parameters.txt

	echo "Content-type: text/html"
	echo ""
	echo "<html><head>"
	echo "<title>Chumby Parameter Uploader</title>"
	echo "</head>"
	echo "<body>"
	echo "<h4>Channel Parameter Uploader</h4>"
	echo "Dumping to : $ID<br><pre>"
	cat /mnt/usb/lighty/html/zchannel/parameters/parameters.txt
	echo "</pre></body></html>"
else
	echo "Content-type: text/plain"
	echo ""
	echo "<widget_instance>"
	echo "<widget_parameters>"
	if [ -f /mnt/usb/lighty/html/zchannel/parameters/parameters.txt ]; then
		cat /mnt/usb/lighty/html/zchannel/parameters/parameters.txt
	fi
	echo "</widget_parameters>"
	echo "</widget_instance>"
fi
