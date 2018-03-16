#!/bin/sh
# $Id: check_for_update.sh 4686 2009-03-23 19:41:34Z henry $
#
# check_for_update.sh - checks URL listed in /etc/firmware_url for any available updates
#
# If build(s) found which may be newer, writes /tmp/firmware_available
# Meant to be used with engineering smoke builds for frequent local updates
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


if [ -f /psp/firmware_url ]
then
  BASE_URL=$(cat /psp/firmware_url)
else
  BASE_URL=$(cat /etc/firmware_url)
fi

rm -f /tmp/firmware_available
if [ "${BASE_URL}" = "" ]
then
  echo "No url found in /etc/firmware_url, /psp/firmware_url"
  exit 1
fi

# Handle --all option to add &upd_allstates=1
BACK=0
while [ "$1" != "" ]
do
  case $1 in
   --all)	BASE_URL="${BASE_URL}&upd_allstates=1"	;;
   --back)	BACK=1	;;
   *)		echo "Unknown option $1" ; exit 1;	;;
  esac
  shift
done

eval $(awk -F. '{printf "CUR_VER_MAJOR=%s; CUR_VER_MINOR=%s; CUR_VER_BUILD=%s", $1, $2, $3;}' /etc/firmware_build)
CUR_BUILD_TYPE=$(cat /etc/firmware_build_type)
# If current build is qa candidate, only show newer qa candidate
AWK_FILTER="/<update /"
# Create list of upgrade build types if version is identical
UPGRADE_TYPES=none
case x${CUR_BUILD_TYPE} in
	xdev/local)
		UPGRADE_TYPES="engineering/smoke engineering/regression qa/candidate qa/release production/candidate production/release"
		;;
	xengineering/smoke)
		UPGRADE_TYPES="engineering/regression qa/candidate qa/release production/candidate production/release"
		;;
	xengineering/regression)
		UPGRADE_TYPES="qa/candidate qa/release production/candidate production/release"
		;;
	xqa/candidate)
		UPGRADE_TYPES="qa/release production/candidate production/release"
		AWK_FILTER="/<update .*type='(qa|production)\/.*'/"
		;;
	xqa/release)
		UPGRADE_TYPES="production/candidate production/release"
		AWK_FILTER="/<update .*type='(qa\/release|production\/.*)'/"
		;;
	xproduction/candidate)
		UPGRADE_TYPES="production/release"
		AWK_FILTER="/<update .*type='production\/.*'/"
		;;
	xproduction/release)
		UPGRADE_TYPES=none
		AWK_FILTER="/<update .*type='production\/release'/"
		;;
esac

if [ "${CUR_VER_MAJOR}" = "" -o "${CUR_VER_MINOR}" = "" -o "${CUR_VER_BUILD}" = "" ]
then
  echo "/etc/firmware_build does not contain major.minor.build"
  exit 1
fi

TSFILE=/tmp/check_for_update.started
TSCOMPLETE=/tmp/check_for_update.exitcode
date +'%s' > ${TSFILE}
TMPXML=/tmp/check_for_update.$$.xml
if wget -O ${TMPXML} ${BASE_URL}
then
  echo "Checking for updates..."
else
  echo "Failed to get ${BASE_URL} - network down?"
  echo "1" > ${TSCOMPLETE}
  exit 1
fi


COUNT=0
for typever in $(awk "${AWK_FILTER} {
VER=\$0;
VER_OFF=index(VER,\"ver='\");
if (VER_OFF>0) VER=substr(VER,VER_OFF+5);
VER_OFF=index(VER,\"'\");
if (VER_OFF>0) VER=substr(VER,1,VER_OFF-1);
TYPE=\$0;
TYPE_OFF=index(TYPE,\"type='\");
if (TYPE_OFF>0) TYPE=substr(TYPE,TYPE_OFF+6);
TYPE_OFF=index(TYPE,\"'\");
if (TYPE_OFF>0) TYPE=substr(TYPE,1,TYPE_OFF-1);
STATE=\$0;
STATE_OFF=index(STATE,\"review_state='\");
if (STATE_OFF>0) STATE=substr(STATE,STATE_OFF+14);
STATE_OFF=index(STATE,\"'\");
if (STATE_OFF>0) STATE=substr(STATE,1,STATE_OFF-1);
printf( \"VER=%s:TYPE=%s:STATE=%s\\n\", VER, TYPE, STATE );
}" ${TMPXML})
do
  eval $(echo "${typever}" | awk -F: '{printf "%s; %s; %s\n", $1, $2, $3;}')
  echo "${typever} --> ${VER},${TYPE}"
  eval $(echo "${VER}" | awk -F. '{printf "VER_MAJOR=%s; VER_MINOR=%s; VER_BUILD=%s", $1, $2, $3;}')
  # Is it newer than current?
  NEWER=0
  if [ "${VER_MAJOR}" -gt "${CUR_VER_MAJOR}" ]
  then
    echo "Major version ${VER_MAJOR} newer than ${CUR_VER_MAJOR}"
    NEWER=1
  elif [ "${VER_MAJOR}" = "${CUR_VER_MAJOR}" -a "${VER_MINOR}" -gt "${CUR_VER_MINOR}" ]
  then
    echo "Minor version ${VER_MINOR} newer than ${CUR_VER_MINOR}"
    NEWER=1
  elif [ "${VER_MAJOR}.${VER_MINOR}" = "${CUR_VER_MAJOR}.${CUR_VER_MINOR}" -a "${VER_BUILD}" -gt "${CUR_VER_BUILD}" ]
  then
    echo "Build version ${VER_BUILD} newer than ${CUR_VER_BUILD}"
    NEWER=1
  elif [ "${VER_MAJOR}.${VER_MINOR}.${VER_BUILD}" = "${CUR_VER_MAJOR}.${CUR_VER_MINOR}.${CUR_VER_BUILD}" ]
  then
	# Check for upgrade
	for CANDIDATE_TYPE in ${UPGRADE_TYPES}
	do
		[ "${TYPE}" = "${CANDIDATE_TYPE}" ] && { echo "Candidate type ${TYPE} with equal version is eligible for upgrade"; NEWER=1; }
	done
  fi
  [ "${NEWER}" = "0" -a "${BACK}" = "1" ] && { echo "Showing older version ${VER_MAJOR}.${VER_MINOR}.${VER_BUILD} due to --back"; NEWER=1; }
  if [ "${NEWER}" = "1" ]
  then
    COUNT=$(expr ${COUNT} \+ 1)
    STYPE=$(echo "${TYPE}" | sed 's/\//\\\//g')
    awk "/type='${STYPE}'.* ver='${VER}'/ {
    URL=\$0;
    URL_OFF=index(URL,\"url='\");
    if (URL_OFF>0) URL=substr(URL,URL_OFF+5);
    URL_OFF=index(URL,\"'\");
    if (URL_OFF>0) URL=substr(URL,1,URL_OFF-1);
    printf \"${VER} ${TYPE} ${STATE:-null} %s\\n\", URL;
    }" ${TMPXML} >> /tmp/firmware_available
  fi
done

# Clean up
rm -f ${TMPXML}*

if [ "${COUNT}" -gt 0 ]
then
  echo "${COUNT} updates found"
else
  echo "No updates available"
fi

echo "0" > ${TSCOMPLETE}
