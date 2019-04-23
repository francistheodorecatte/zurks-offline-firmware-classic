#!/bin/sh 
while read fmstations 
	do
	echo $fmstations|grep freq|cut -d= -f2|tr \" \ |tr \/ \ |tr \> \ |tr -d ' '
	done <fmstatus.xml

