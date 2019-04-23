#!/bin/sh 

echo "HTTP/1.1 200 ok"
echo "Content-type:  text/html"
echo ""
qrystrn="${QUERY_STRING}"
cmd=$(echo $qrystrn|cut -d '=' -f1)
args=$(echo $qrystrn|cut -d '=' -f2)
echo $QUERY_STRING"-"$cmd"-"$args>>event.log 
arg1=""
arg2=""
arg3=""
case $cmd in
	nextWidget)
	  arg1="WidgetPlayer" 
	  arg2="nextWidget" ;;
        prevWidget)
          arg1="WidgetPlayer"
          arg2="prevWidget" ;;
        reload)
          arg1="WidgetPlayer"
          arg2="reload" ;;
        shuffle)
          arg1="WidgetPlayer"
          arg2="shuffle" ;;
        stopMusic)
          arg1="MusicPlayer"
          arg2="stop" ;;
        setVolume100)                   
          arg1="MusicPlayer"                    
          arg2="setVolume"
          arg3="100" ;;  
	setVolume0)
	  arg1="MusicPlayer"
	  arg2="setVolume"
	  arg3="0" ;;
        setVolume50)                                                                                     
          arg1="MusicPlayer"                                                                             
          arg2="setVolume"                                                                               
          arg3="50" ;;    
	sleep)
	  arg1="NightMode"
	  arg2="on";;
	wake)
	  arg1="NightMode"
	  arg2="off" ;;
	bright)
	  arg1="ScreenManager"
	  arg2="bright";;
	dim)
	  arg1="ScreenManager"
	  arg2="dim" ;;
	off)
	  arg1="ScreenManager"
	  arg2="off" ;;
	stopAlarm)
	  arg1="AlarmPlayer"
	  arg2="stop";;
	fmradio1)
	  arg1="FMRadio"
	  arg2="preset"
	  arg3="0" ;;
	fmradio1)
	  arg1="FMRadio"
	  arg2="preset"
	  arg3="0" ;;
	fmradio2)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="1" ;; 
	fmradio3)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="2" ;; 
	fmradio4)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="3" ;; 
	fmradio5)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="4" ;;
	fmradio6)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="5" ;; 
	fmradio7)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="preset"                                                                                        
	  arg3="6" ;; 
	fmradiostop)                                                                                            
	  arg1="FMRadio"                                                                                       
	  arg2="stop" ;;
	fmradioscanup)
	  arg1="FMRadio"
	  arg2="scan"
	  arg3="up" ;;
	fmradioscandown)
	  arg1="FMRadio"
	  arg2="scan"
	  arg3="down" ;;
	freq)
	  arg1="FMRadio"
	  arg2="play"
	  arg3=$args ;; 

esac
echo "<event type=\"$arg1\" value=\"$arg2\" comment=\"$arg3\"/>" > /tmp/flashplayer.event 
echo ""                                                                                                  
cat /tmp/flashplayer.event                                                                               
chumbyflashplayer.x -F1 > /dev/null 2>&1
