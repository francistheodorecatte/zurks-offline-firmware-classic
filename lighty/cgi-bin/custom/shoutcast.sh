#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "<event type=\"UserPlayer\" value=\"play\" comment=\"http://kexp-mp3-2.cac.washington.edu:8000/\"/>" > /tmp/flashplayer.event
chumbyflashplayer.x -F1 > /dev/null 2>&1
echo ""
echo ""
echo "Now playing KEXP 128k"

