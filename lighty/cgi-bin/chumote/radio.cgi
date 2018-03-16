#!/bin/sh 

/usr/chumby/scripts/fb_cgi.sh
echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""

echo "<html><head><title>Chumbymote</title>"
echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
echo "<meta name='viewport' content='width=device-width, maximum-scale=1, minimum-scale=1.0'>"
echo "<style>a{font-size:18px;color:black;padding:1px; font-family:arial; border:3px solid white;background-color:#eee; -webkit-border-radius: 3px; -moz-border-radius: 3px;}"
echo "body{background-color:black;color:white;padding:3px} a:hover{color:red}"
echo "#fb{width:320px;height:240px} holder{align:center;}</style>"
echo "<script language='JavaScript' type='text/javascript'>"                                     
echo "function launch(url){var xmlRequest=new XMLHttpRequest(); xmlRequest.onload=function() {};xmlRequest.open('GET',url);xmlRequest.setRequestHeader('Content-Type', 'text/plain;charset=UTF-8');xmlRequest.send();}"
echo "function tuneradio(){launch('event.cgi?freq='+document.getElementById('freq').value);}"
echo "function tunerradioselect(){launch('event.cgi?freq='+document.getElementById('fmstations').value); document.getElementById('freq').value = document.getElementById('fmstations').value;}"
echo "function refreshFB() {tmp = new Date();tmp = '?'+tmp.getTime();document.getElementById('fb').src='fb0'+tmp;setTimeout('refreshFB()',4000);}"
echo "</script>"

echo "</head><body onload='refreshFB()'><div class='holder'>"
echo "Sections:<a href="index.cgi">Main</a>"
echo "<a href="admin.cgi">Admin</a> "
echo "<a href="podcasts.cgi">Podcasts</a> "
echo "<hr/>"

streamvalue="none"
echo "Volume   :<a href=""javascript:launch('event.cgi?setVolume0');"">Mute</a> "                                                                                                                      
echo "<a href=""javascript:launch('event.cgi?setVolume50');"">50%</a> "                                                                                                                                
echo "<a href=""javascript:launch('event.cgi?setVolume100');"">100%</a> "                                                                                                                              
echo "<a href=""javascript:launch('event.cgi?stopMusic');"">Stop</a><br/><hr/>"

echo "Audio Streams:<br/>"
echo "Listening to: <input type="text" id="stream" name="stream" value="$streamvalue" size="23" onchange=""javascript:tunerstream();""><br/><br/>"
echo "Presets<a href=""javascript:launch('control.cgi?radio1');"">1</a> "    
echo "<a href=""javascript:launch('control.cgi?radio2');"">2</a> "            
echo "<a href=""javascript:launch('control.cgi?radio3');"">3</a> "            
echo "<a href=""javascript:launch('control.cgi?radio4');"">4</a> "            
echo "<a href=""javascript:launch('control.cgi?radio5');"">5</a> "            
echo "<a href=""javascript:launch('control.cgi?radio6');"">6</a> "        
echo "<a href=""javascript:launch('control.cgi?radio7');"">7</a> "        
echo "<a href=""javascript:launch('control.cgi?radio8');"">8</a> "        
echo "<a href=""javascript:launch('control.cgi?radiostop');"">Stop</a>"         
echo "<br/>"                                                              
echo "<hr/>"    

echo "FM Radio:<br/>"    
currentstation=$"curl http://127.0.0.1:8081/radio/status.xml|grep tuned |cut -d '=' -f4"
freqvalue=$(wget -q http://127.0.0.1:8081/radio/status.xml -O - |grep tuned |cut -d '=' -f4|cut -d 's' -f1)
freqrds=$(wget -q http://127.0.0.1:8081/radio/status.xml -O - |grep tuned |cut -d '=' -f17| cut -d \' -f2)
echo  "Listening to: <input type="text" id="freq" name="freq" value="$freqvalue" size="6" onchange=""javascript:tuneradio();"">"
echo  "$freqrds <br/><br/>"
echo "Tune to:<select name="fmstations" id="fmstations" onchange=""javascript:tunerradioselect();"">"
while read fmstations
       do
       fmstationvalue=$(echo $fmstations|grep freq|cut -d= -f2|tr \" \ |tr \/ \ |tr \> \ |tr -d ' ')
          echo "<option value="$fmstationvalue">$fmstationvalue</option>" 
       done <fmstatus.xml
echo "</select >"                        
echo "<a href=""javascript:launch('event.cgi?fmradioscandown');"">&lt</a> "                                                     
echo "<a href=""javascript:launch('event.cgi?fmradioscanup');"">&gt</a>"                                                        
echo "<a href=""javascript:launch('event.cgi?fmradiostop');"">Stop</a><br/><br/>"
echo "Presets:<a href=""javascript:launch('event.cgi?fmradio1');"">1</a> "        
echo "<a href=""javascript:launch('event.cgi?fmradio2');"">2</a> "           
echo "<a href=""javascript:launch('event.cgi?fmradio3');"">3</a> "        
echo "<a href=""javascript:launch('event.cgi?fmradio4');"">4</a> "        
echo "<a href=""javascript:launch('event.cgi?fmradio5');"">5</a> "        
echo "<a href=""javascript:launch('event.cgi?fmradio6');"">6</a> "        
echo "<a href=""javascript:launch('event.cgi?fmradio7');"">7</a> "        
echo "<br/>"                                                               
echo "<hr/>" 

#echo "<img src='fb0' id='fb' name='fb' onclick='window.location.reload(true);' />"
echo "</div></body></html>"
