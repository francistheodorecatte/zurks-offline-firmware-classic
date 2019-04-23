#!/bin/sh
substring=`echo ${QUERY_STRING} | sed 's/^...//'`
cat "../html/chumcast/xshow_${substring}"

