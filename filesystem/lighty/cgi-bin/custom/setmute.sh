#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo "<event type=\"MusicPlayer\" value=\"setMute\" comment=\"on\"/>" > /tmp/flashplayer.event
chumbyflashplayer.x -F1

