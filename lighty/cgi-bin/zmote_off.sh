#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "${QUERY_STRING}"
echo '<event type="NightMode" value="off" comment=""/>' > /tmp/flashplayer.event
echo "<pre>"
cat /tmp/flashplayer.event
echo " --- "
chumbyflashplayer.x -F1
echo "</pre>"

