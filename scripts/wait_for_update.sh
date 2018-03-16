#!/bin/sh
# $Id: wait_for_update.sh 4686 2009-03-23 19:41:34Z henry $
#
# wait_for_update.sh - wait for completion of check_for_update.sh up to a specified number
# of seconds from its launch time.
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

MAX_WAIT=$1
if [ "${MAX_WAIT}" = "" ]
then
  echo "$0 - error: no maximum wait specified"
  exit 1
fi


TSFILE=/tmp/check_for_update.started
TSCOMPLETE=/tmp/check_for_update.exitcode
if [ ! -f ${TSFILE} ]
then
  echo "${TSFILE} does not exist - check_for_update.sh must not be running"
  exit 1
fi

TSTART=$(cat ${TSFILE})
if [ "${TSTART}" = "" ]
then
  echo "No date found in ${TSFILE}"
  exit 1
fi

DONE=0
while [ ${DONE} = 0 -a ! -f ${TSCOMPLETE} ]
do
  NOW=$(date +'%s')
  ELAPSED=$(expr ${NOW} - ${TSTART})
  if [ "${ELAPSED}" -ge "${MAX_WAIT}" ]
  then
    DONE=1
  else
    sleep 1
  fi
done

if [ -f ${TSCOMPLETE} ]
then
  echo "Exited with return code $(cat ${TSCOMPLETE})"
else
  echo "Timed out after ${ELAPSED:-??} seconds (MAX_WAIT=${MAX_WAIT})"
fi

