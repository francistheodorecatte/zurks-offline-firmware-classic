#!/bin/sh 

/usr/chumby/scripts/fb_cgi.sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""

echo "<html><head><title>Chumbymote</title>"
echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
echo "<meta name='viewport' content='width=device-width, maximum-scale=1, minimum-scale=1.0'>"
echo "<style>a{font-size:18px;color:black;padding:3px; font-family:arial; border:1px solid white;background-color:#eee; -webkit-border-radius: 2px; -moz-border-radius: 2px;}"
echo "body{background-image:url('bg.png');background-color:black;color:white;padding:0px} a:hover{color:red}"
echo "fb{width:320px;height:240px} holder{align:center;}</style>"
echo "<script language='JavaScript' type='text/javascript'>"                                     
echo "function launch(url){var xmlRequest=new XMLHttpRequest(); xmlRequest.onload=function() {};xmlRequest.open('GET',url);xmlRequest.setRequestHeader('Content-Type', 'text/plain;charset=UTF-8');xmlRequest.send();}"
echo "function refreshFB() {tmp = new Date();tmp = '?'+tmp.getTime();document.getElementById('fb').src='fb0'+tmp;setTimeout('refreshFB()',4000);}"
echo "</script>"

echo "</head><body onload='refreshFB()'><div class='holder'>"
echo "Sections:<a href="admin.cgi">Admin</a> "
echo "<a href="podcasts.cgi">Podcasts</a> "
echo "<a href="radio.cgi">Radio</a><br/>"
echo "<hr/>"


echo "Screen:<a href=""javascript:launch('event.cgi?sleep');"">Sleep</a> "
echo "<a href=""javascript:launch('event.cgi?wake');"">Wake</a> "
echo "<a href=""javascript:launch('event.cgi?dim');"">Dim</a> "
echo "<a href=""javascript:launch('event.cgi?bright');"">Bright</a> "
echo "<a href=""javascript:launch('event.cgi?off');"">Off</a> "
echo "<hr/>"
 
echo "Widgets :<a href=""javascript:launch('event.cgi?prevWidget');"">&lt;</a> "
echo "<a href=""javascript:launch('event.cgi?reload');"">Reload</a> "
echo "<a href=""javascript:launch('event.cgi?shuffle');"">Shuffle</a> " 
echo "<a href=""javascript:launch('event.cgi?nextWidget');"">&gt;</a><br/>"
echo "<hr/>"

echo "Audio :<a href=""javascript:launch('event.cgi?setVolume0');"">Mute</a> "
echo "<a href=""javascript:launch('event.cgi?setVolume50');"">50%</a> "
echo "<a href=""javascript:launch('event.cgi?setVolume100');"">100%</a> "   
echo "<a href=""javascript:launch('event.cgi?stopMusic');"">Stop</a><br/>"
echo "<hr/>"
echo "<img src='fb0' id='fb' name='fb' onclick='window.location.reload(true);' />"
echo "</div></body></html>"