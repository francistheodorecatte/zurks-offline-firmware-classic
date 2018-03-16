#!/bin/sh
# $Id: signal_daemon_event.sh 39320 2010-02-27 00:10:25Z henry $
#
# signal_daemon_event.sh - send a signal in pseudo-xml snippet form
# (like signal_soft_event.sh) to an arbitrary daemon process
#
# Henry Groover
# Copyright (c) Chumby Industries, 2009-2010
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
DAEMON_NAME=$4
DAEMON_EVENT_PATH=$5

# Optional args for second event must include destination - $5 through $8 must all be set
if [ "${EVT_TYPE}" = "" -o "${EVT_VALUE}" = "" -o "${DAEMON_EVENT_PATH}" = "" -o "${DAEMON_NAME}" = "" ]
then
  echo "$0 ERROR - required args event-type, event-value, comment, daemon-name and daemon-event-path not specified"
  exit 1
fi

DAEMON_EVENT_DIR=$(dirname ${DAEMON_EVENT_PATH})
[ -d ${DAEMON_EVENT_DIR} ] || { echo "Containing dir ${DAEMON_EVENT_DIR} for ${DAEMON_EVENT_PATH} does not exist"; exit 1; }

if [ -f /var/run/${DAEMON_NAME}.pid ]
then
  DAEMON_PID=$(cat /var/run/${DAEMON_NAME}.pid)
  echo "<event type=\"${EVT_TYPE}\" value=\"${EVT_VALUE}\" comment=\"${COMMENT}\"/>" >> ${DAEMON_EVENT_PATH}
  if [ -f ${DAEMON_EVENT_PATH} ]
  then
    /bin/kill -SIGHUP ${DAEMON_PID} || { echo "kill failed to send SIGHUP to pid ${DAEMON_PID} (from /var/run/${DAEMON_NAME}.pid)"; exit 1; }
    #killall -SIGHUP ${DAEMON_NAME} || { echo "killall failed to send SIGHUP to ${DAEMON_NAME}"; exit 1; }
    echo "$0 $* - ${DAEMON_NAME} signalled"
  else
    echo "$0 $* - ${DAEMON_EVENT_PATH} disappeared, ${DAEMON_NAME} must have gotten another signal"
  fi
else
  echo "$0 $* - /var/run/${DAEMON_NAME}.pid not found, falling back to killall"
  echo "<event type=\"${EVT_TYPE}\" value=\"${EVT_VALUE}\" comment=\"${COMMENT}\"/>" >> ${DAEMON_EVENT_PATH}
  if [ -f ${DAEMON_EVENT_PATH} ]
  then
    killall -SIGHUP ${DAEMON_NAME} || { echo "killall failed to send SIGHUP to pid ${DAEMON_NAME}"; exit 1; }
    echo "$0 $* - ${DAEMON_NAME} signalled"
  else
    echo "$0 $* - ${DAEMON_EVENT_PATH} disappeared, ${DAEMON_NAME} must have gotten another signal"
  fi
fi

