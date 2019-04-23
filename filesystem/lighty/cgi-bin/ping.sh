IP=`netstat -rn | grep 0.0.0.0 | awk '{print $2}' | grep -v '0.0.0.0'`; ping -c 1 $IP

