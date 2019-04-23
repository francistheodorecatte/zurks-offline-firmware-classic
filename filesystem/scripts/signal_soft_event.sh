#!/bin/sh
# $Id: signal_soft_event.sh 46596 2010-04-29 23:53:21Z scross $
#
# signal_soft_event.sh - raise any soft event for flashplayer, if it's running
#
# Henry Groover
# Copyright (c) Chumby Industries, 2008-9
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA


EVT_TYPE=$1
EVT_VALUE=$2
COMMENT=$3
DESTINATION=$4
# Optional args for second event must include destination - $5 through $8 must all be set
[ "${DESTINATION}" = "" ] && DESTINATION="*"
if [ "${EVT_TYPE}" = "" -o "${EVT_VALUE}" = "" ]
then
  echo "$0 ERROR - required args event-type and event-value not specified"
  exit 1
fi

echo "<event type=\"${EVT_TYPE}\" value=\"${EVT_VALUE}\" comment=\"${COMMENT}\" destination=\"${DESTINATION}\"/>" >> /tmp/flashplayer.event
if [ "$8" != "" ]
then
  echo "<event type=\"$5\" value=\"$6\" comment=\"$7\" destination=\"$8\"/>" >> /tmp/flashplayer.event
fi

if [ -f /var/run/chumbyflashplayer.pid ]
then
  if [ -f /tmp/flashplayer.event ]
  then
    killall -HUP chumbyflashplayer.x
    echo "$0 $* - flashplayer signalled"
  else
    echo "$0 $* - /tmp/flashplayer.event disappeared, flashplayer must have gotten another signal"
  fi
else
  echo "$0 $* - flashplayer is not running"
fi

