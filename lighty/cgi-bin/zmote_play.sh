#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
sparky="<event type=\"UserPlayer\" value=\"play\" comment=\""
sparky="$sparky${QUERY_STRING}"
sparky="$sparky\"/>"
echo "${sparky}" > /tmp/flashplayer.event
echo "<pre>"
cat /tmp/flashplayer.event
echo " --- "
chumbyflashplayer.x -F1
echo "</pre>"
