#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`

# Get the POST string, if defined
if [ "$REQUEST_METHOD" = "POST" ]; then
	if [ -z "$CONTENT_LENGTH" ]; then
		echo "Content-type: text/html"                                                  
		echo ""
		echo "<html><head>"
		echo "<title>Chumby Parameter Uploader</title>"
		echo "</head>"
		echo "<body>"
		echo "<h4>Channel Parameter Uploader</h4>"
		echo "$ID<br>"
		echo "ERROR: No parameter list<br>"
		echo "</body></html>"
	else
		read QUERY_STRING_POST

		echo "Content-type: text/html"                                                  
		echo ""
		echo "<html><head>"
		echo "<title>Chumby Parameter Uploader</title>"
		echo "</head>"
		echo "<body>"
		echo "<h4>Channel Parameter Uploader</h4>>"
		echo "Receiving parameters for $ID<br>"

		case $ID in
		  (*channels.c8*)
			# Filter for the Chumby 8
			echo "$QUERY_STRING_POST" \
				| sed -e 's/<widget_instance>//g' \
				| sed -e 's/<widget_parameters>//g' \
				| sed -e 's/<\/widget_parameters>//g' \
				| sed -e 's/<\/widget_instance>//g' \
				| sed -e 's/<widget_parameter>/<parameter/g' \
				| sed -e 's/<\/value>//g' \
				| sed -e 's/<\/widget_parameter>/\"\/>\n/g' \
				| sed -e 's/<name>/ name="/g' \
				| sed -e 's/<\/name>/\" /g' \
				| sed -e 's/<value>/ value=\"/g' \
				> /tmp/parameters.txt
			;;
		  (*channels.c1*)
			# Filter for the Chumby One
			echo "$QUERY_STRING_POST" \
				| sed -e 's/<widget_instance>//g' \
				| sed -e 's/<widget_parameters>//g' \
				| sed -e 's/<\/widget_parameters>//g' \
				| sed -e 's/<\/widget_instance>//g' \
				| sed -e 's/></>\n</g' \
				> /tmp/parameters.txt
			;;
		  (*)
		  	# Unknown, unfiltered
		  	echo "$QUERY_STRING_POST" > /tmp/parameters.txt
		  	;;
		esac
		
		echo "<PRE>"
		cat /tmp/parameters.txt
		echo "</PRE>"
	
		if [ -d /mnt/usb/lighty/html/$ID ]; then
			mv -f /tmp/parameters.txt /mnt/usb/lighty/html/$ID/parameters.txt
		else
			rm /tmp/parameters.txt
			echo "ERROR: Widget directory doesn't exist"
		fi
		sync
		echo "</form></body></html>"
	fi
else
	echo "Content-type: text/plain"
	echo ""
	echo "<widget_instance>"
	echo "<widget_parameters>"
	if [ -f /mnt/usb/lighty/html/$ID/parameters.txt ]; then
		case $ID in
		  (*channels.c8*)
			# Filter for the Chumby 8
			cat /mnt/usb/lighty/html/$ID/parameters.txt \
				| sed -e 's/<parameter/<widget_parameter>/g' \
				| sed -e 's/name=\"/<name>/g' \
				| sed -e 's/" *value="/<\/name><value>/g' \
				| sed -e 's/" *\/>/<\/value><\/widget_parameter>/g'
			;;
		  (*)
		  	# Chumby One takes the parameters as-is
			cat /mnt/usb/lighty/html/$ID/parameters.txt
			;;
		esac
	fi	
	echo "</widget_parameters>"
	echo "</widget_instance>"
fi

