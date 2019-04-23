#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
WIDGET=`echo "$QUERY_STRING" | awk -F= '{print $3}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`

CHANNEL=`dirname $ID`

if [ "$ID" = "" -o "$WIDGET" = "" ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Missing arguments"
elif [ ! -d $ID ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Source widget $ID does not exist"
elif [ -d $CHANNEL/$WIDGET ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Destination widget $WIDGET already exists"
else
	echo "Content-type: text/html"                                                  
	echo ""
	echo "<html><head>"
	echo "<title>Chumby Multi-Channel Widget Editor</title>"
	echo "</head><body>"
	echo "<h4>Zurk's Multi Channel Widget Editor</h4>"
	echo "Renaming $ID to $CHANNEL/$WIDGET<P>"
	mv $ID $CHANNEL/$WIDGET
	if [ $? = 0 ]; then
		echo "Rename successful"
	else
		echo "ERROR: Rename failed!"
	fi
	echo "<P><A HREF=\"widget_editor.sh?name=$ID\">Return</A> to the editor"
	echo "</BODY></HTML>"
	sync
fi

