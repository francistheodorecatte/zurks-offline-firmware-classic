#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "<event type=\"WidgetPlayer\" value=\"nextWidget\" comment=\"\"/>" > /tmp/flashplayer.event
chumbyflashplayer.x -F1 > /dev/null 2>&1

