#!/bin/sh
# $Id: signal_usb_event.sh 33104 2010-01-14 05:12:17Z scross $
#
# signal_usb_event.sh - raise a USB event for flashplayer, if it's running
#
# Henry Groover
# Copyright (c) Chumby Industries, 2008
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
MOUNT_POINT=$2
MOUNT_NAME=$3
USB_PORT=$4
if [ "${EVT_TYPE}" = "" -o "${MOUNT_POINT}" = "" ]
then
  logger "$0 ERROR - required args event-type and mount-point not specified"
  exit 1
fi

if [ -f /var/run/chumbyflashplayer.pid ]
then
  echo "<event type=\"USB\" value=\"${EVT_TYPE}\" comment=\"${MOUNT_POINT}\"/>" >> /tmp/flashplayer.event
  echo "<event type=\"USB2\" value=\"${EVT_TYPE}\" comment=\"${MOUNT_POINT}:${USB_PORT}:${MOUNT_NAME}\"/>" >> /tmp/flashplayer.event
  if [ -f /tmp/flashplayer.event ]
  then
    chumbyflashplayer.x -F1
    logger "$0 $* - flashplayer signalled"
  else
    logger "$0 $* - /tmp/flashplayer.event disappeared, flashplayer must have gotten another signal"
  fi
else
  logger "$0 $* - flashplayer is not running"
fi

