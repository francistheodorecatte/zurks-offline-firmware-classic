#!/bin/sh
ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g' | sed -e 's/%2F//g' | sed -e 's/%26//g'`
cat "../html/station_list/format${ID}"
#echo "../html/station_list/format${QUERY_STRING}" >/mnt/usb/args.txt

