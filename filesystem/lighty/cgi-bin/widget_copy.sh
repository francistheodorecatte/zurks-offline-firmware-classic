#!/bin/sh      

ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
DEST=`echo "$QUERY_STRING" | awk -F= '{print $3}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`

WIDGET=`basename $ID`
CHANNEL=`dirname $ID`
BASE=`dirname $CHANNEL`

if [ "$ID" = "" -o "$DEST" = "" ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Missing arguments"
elif [ ! -d $ID ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Source widget $ID does not exist"
elif [ ! -d $BASE/$DEST ]; then
	echo "Content-type: text/plain"
	echo ""
	echo "ERROR: Channel $CHANNEL does not exist"
else
	for num in ' ' 1 2 3 4 5 6 7 8 9 
	do
		if [ ! -d $BASE/$DEST/$WIDGET$num ]; then
			WIDGET=$WIDGET$num
			break
		fi
	done
	echo "Content-type: text/html"                                                  
	echo ""
	echo "<html><head>"
	echo "<title>Chumby Multi-Channel Widget Editor</title>"
	echo "</head><body>"
	echo "<h4>Zurk's Multi Channel Widget Editor</h4>"
	echo "Copying $ID to $BASE/$DEST/$WIDGET<P>"
	mkdir $BASE/$DEST/$WIDGET
	cp $ID/* $BASE/$DEST/$WIDGET
	if [ $? = 0 ]; then
		echo "Copy successful"
	else
		echo "ERROR: Copy failed!"
	fi
	echo "<P><A HREF=\"widget_editor.sh?name=$ID\">Return</A> to the editor"
	echo "</BODY></HTML>"
	sync
fi

