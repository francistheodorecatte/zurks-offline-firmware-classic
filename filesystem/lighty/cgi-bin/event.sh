#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "${QUERY_STRING}" | sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e > /tmp/flashplayer.event
echo "<pre>"
chumbyflashplayer.x -F1
echo "</pre>"
echo doesnt work coz ash does not support echo -e or arrays. 

