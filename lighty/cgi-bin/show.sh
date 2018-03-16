#!/bin/sh
ID=`echo "$QUERY_STRING" | awk -F= '{print $2}' | awk -F'&' '{print $1}' | sed -e 's/%2C//g' |  sed -e 's/%20//g'`
if [  -f "../html/xapis/profile/show/${ID}" ]
then
cat "../html/xapis/profile/show/${ID}"
else
cat "../html/xapis/profile/show/0"
fi

