#!/bin/sh

ID=`echo $QUERY_STRING|sed -e 's/^.\{1\}//'|sed -e 's/ *?.*//'`
echo "<stationlist>"
echo "<tunein base=\"/shoutcast/show\"/>"
cat ../html/shoutcast/list | grep -i "$ID"
echo "</stationlist>"
