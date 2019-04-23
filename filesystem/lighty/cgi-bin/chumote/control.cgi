#!/bin/sh 
echo "Content-type: text/plain"

qrystrn="${QUERY_STRING}"
cmd=$(echo $qrystrn|cut -d '&' -f1)
arg1=$(echo $qrystrn|cut -d '&' -f2)
echo $qrystrn $cmd $arg1 >cmd.log
case "$cmd" in
	cp_stop)
	 stop_control_panel ;;
	
	cd_restart)
	 stop_control_panel ;;
	
	reboot)
	 reboot ;;
	
	radiostop)
	 btplay stop ;; 

	radio1)
 	 btplay http://66.162.107.142/cpr1_lo ;;

	radio2)
	 btplay http://66.162.107.142/cpr3_lo ;;
	
	radio3)
	 btplay http://66.162.107.142/cpr2_lo ;;

	playpodcast)
	 btplay $arg1 ;;

	podscan)
	 ./bashpodder.shell
	 sleep 20 ;;
esac	
