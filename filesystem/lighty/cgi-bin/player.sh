#!/bin/sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
echo "<script type='text/javascript' src='/jquery-1.7.min.js'></script>"
echo "<script type='Text/javascript' src='/chum.js'>"
echo "</script>"
echo "<h1>Chumby</h1>"
echo "<h2>Player</h2>"
echo "<button id='stop_player'>Stop</button>"
echo "<select id='volume_player'><option>Select volume</option></select>"

echo "<h2>Streams</h2>"
streams_xml=`cat /psp/url_streams`
echo "<input id='streams_xml' value='$streams_xml' type='hidden' />"
echo "<div id='streams'></div>"
echo "<button id='add_stream'>Add</button>"
echo "<button id='save_stream'>Save</button>"

