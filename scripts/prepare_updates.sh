#!/bin/sh
# $Id: prepare_updates.sh 16375 2009-08-28 19:27:47Z henry $
#
# prepare_updates.sh - prepare updates in /mnt/storage
#
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

# Backup /psp to $1/psp.backup
backup_psp()
{
	BASE=$1
	[ "${BASE}" = "" ] && { echo "No base dir for psp.backup specified"; exit 1; }
	# Wipe any existing backup
	[ -d ${BASE}/psp.backup ] && rm -rf ${BASE}/psp.backup
	# Default list - we now keep an actual backup_list which the user can modify
	# Both happen to be the same for now but /psp/backup_list always overrides this
	# list and contains a reference to itself.
	BACKUP_LIST="pan mute volume network_config network_configs ts_hid_settings brightness localtime timezone timezone_city pandora_act pandora_pass pandora_stn pandora_user photobucket"
	[ -f /psp/backup_list ] && BACKUP_LIST="$(cat /psp/backup_list)"
	[ "${BACKUP_LIST}" = "" ] && { echo "Backup list is empty"; exit 1; }
	# Make sure we can write
	mkdir ${BASE}/psp.backup || { echo "Unable to create ${BASE}/psp.backup"; exit 1; }
	[ -d ${BASE}/psp.backup ] || { echo "${BASE}/psp.backup creation failed"; exit 1; }
	# Copy everything
	echo "Beginning backup to ${BASE}/psp.backup"
	CWD=$(pwd)
	cd /psp
	for f in ${BACKUP_LIST}
	do
		cp -a ${f} ${BASE}/psp.backup/
	done
	cd ${CWD}
	echo "Backup completed"
	sync
}

rm -f /psp/update_prepared
sync

# Optional syntax; specify path such as /mnt/usb or a url such as http://roxy/tftpboot/
# First arg may be - for default
# On newer microSD-based platforms, we only use - with a filter
URLBASE=$1
VERFILTER=$2
STORAGE=$3
# If downloading, optional path to store result in
[ "${TARBALL}" ] || TARBALL=/mnt/storage/update.tgz
[ "${CNPLATFORM}" ] || { logger -s "CNPLATFORM not defined"; exit 1; }

# microSD-based systems require only a single update.tgz for usb
if is_esd
then
	MICROSD=1
else
	MICROSD=0
fi

echo -n 'prepare_updates.sh $Rev: 16375 $ '
echo "CNPLATFORM=${CNPLATFORM} CONFIGNAME=${CONFIGNAME} MICROSD=${MICROSD} TARBALL=${TARBALL}"
IMAGES="u-boot psp k2 rfs2 k1 rfs1"
IMAGE2LIST="psp k1 rfs1"
MYGUID=$(guidgen.sh)
if [ "${URLBASE}" = "" -o "${URLBASE}" = "-" ]
then
	# Make sure check_for_updates.sh has been run
	if [ -f /tmp/firmware_available ]
	then
	  eval $(awk "/^${VERFILTER:-.+} / {printf \"VER=%s; TYPE=%s; STATE=%s; URLBASE=%s\\n\", \$1, \$2, \$3, \$4;}" /tmp/firmware_available)
	else
	  echo "/tmp/firmware_available is not present - did you run check_for_updates.sh ?"
	  exit 1
	fi
	# Make sure we got a hit
	if [ "${VER}" = "" -o "${URLBASE}" = "" -o "${URLBASE}" = "-" ]
	then
		echo "Unable to find version (filter=${VERFILTER}) in /tmp/firmware_available :"
		cat /tmp/firmware_available
		exit 1
	fi
else
	URLLEAD=$(echo "${URLBASE}" | awk '{print substr($1,1,5);}')
    if [ "${URLLEAD}" = "http:" ]
    then
      VER=url
      TYPE=local
    else
      VER=usb
      TYPE=local
      USTEM=${URLBASE}
      SRCMESSAGE=
      echo "Checking for required files in ${USTEM} (MICROSD=${MICROSD})"
      if [ ${MICROSD} = 1 ]
      then
	# Look for ${USTEM}/${CONFIGNAME}-update.tgz or ${USTEM}/update.tgz (in that order)
	if [ -r ${USTEM}/${CONFIGNAME}-update.tgz ]
	then
		TARBALL=${CONFIGNAME}-update.tgz
		echo "Required file ${TARBALL} found in ${USTEM}"
	else
		if [ -r ${USTEM}/update.tgz ]
		then
		  TARBALL=update.tgz
		  echo "Required file ${TARBALL} found in ${USTEM}"
		else
		  echo "Neither ${CONFIGNAME}-update.tgz nor update.tgz found in ${USTEM}"
		  exit 1
		fi
	fi
	echo "${USTEM}/${TARBALL}" > /psp/update_prepared
	echo "Continue with update_launch.sh ${USTEM}/${TARBALL}"
	exit 0
      else
         if [ -r ${USTEM}/update.zip ]
         then
       		echo "${USTEM}/update.zip found - extracting to ${USTEM}/update"
        	mkdir -p ${USTEM}/update > /dev/null 2>&1 && echo "${USTEM}/update created"
        	echo "unzip -o ${USTEM}/update.zip -d ${USTEM}/update"
        	if unzip -o ${USTEM}/update.zip -d ${USTEM}/update
        	then
			echo "Extract was successful"
			echo "${USTEM}/update" > /psp/update_prepared
			SRCMESSAGE="Files extracted from ${USTEM}/update.zip\n"
			backup_psp ${USTEM}
		else
			echo "Error: extract from ${USTEM}/update.zip failed - is there sufficient storage?"
			exit 1
		fi
	  else
		for f in ${IMAGES}
		do
			if [ ! -r ${USTEM}/${f}.zip -o ! -r ${USTEM}/${f}.zip.md5 ]
			then
				echo "Error: ${USTEM}/${f}.zip and/or ${USTEM}/${f}.zip.md5 not found, cannot continue"
				exit 1
			fi
			 MD5RAW="$(md5sum ${USTEM}/${f}.zip)"
			 MD5SUMTXT=$(echo "${MD5RAW}" | awk '{printf "%-14s %s", substr($2,length(ENVIRON["USTEM"])+2), $1;}')
			 MD5DL=$(cat ${USTEM}/${f}.zip.md5)
			 MD5SUM=$(echo "${MD5RAW}" | awk '{print $1;}')
			 if [ "${MD5SUM}" != "${MD5DL}" ]
			 then
			   echo "ERROR - MD5 mismatch for ${f} - expected ${MD5DL}, got ${MD5SUM}"
			   exit 1
			 fi
			 MD5LIST="${MD5LIST}\n${MD5RAW}"
		done
		echo "${USTEM}" > /psp/update_prepared
		backup_psp ${USTEM}
	  fi
	  echo -e "$0 started $(date) USTEM=${URLBASE} TYPE=local VER=usb\n${SRCMESSAGE}" > /psp/update.log
	  sync
	  echo "Required files found - continue with temp_update.sh"
	  echo -e "${MD5LIST}"
	  exit 0
      fi
    fi
fi

echo "${TYPE} v${VER} ${URLBASE}"
MD5LIST=""
if [ ${MICROSD} = 1 ]
then
  DLEXT=.tgz
  IMAGES=$(basename ${TARBALL} ${DLEXT})
  USTEM=$(dirname ${TARBALL})
  [ -d ${USTEM} ] || { echo "Parent directory ${USTEM} for ${IMAGES} does not exist"; exit 1; }
  echo "Downloading from ${URLBASE} to ${TARBALL}"
else
  DLEXT=.zip
# Storage may be overridden via command line
  export USTEM=${STORAGE:-/mnt/storage/update}
#if [ ! -f /mnt/storage/works.properly ]
#then
#  export USTEM=/mnt/usb/cache
#fi
  rm -rf ${USTEM}
  mkdir -p ${USTEM}
  if [ -d ${USTEM} ]
  then
    echo "Downloading from ${URLBASE} to ${USTEM}"
  else
    echo "Fatal error: cannot create ${USTEM}"
    exit 1
  fi
fi

# Make fb0 visible
switch_fb.sh 0

for f in ${IMAGES}
do
 blast_img downloading_software.bin
 fbwrite "


     $(update_part_name.sh ${f})"
 wget --progressbar --progress=bar:force -O ${USTEM}/${f}${DLEXT} "${URLBASE}${f}${DLEXT}?guid=${MYGUID}"
 sync
 MD5RAW="$(md5sum ${USTEM}/${f}${DLEXT})"
 MD5SUMTXT=$(echo "${MD5RAW}" | awk '{printf "%-14s %s", substr($2,length(ENVIRON["USTEM"])+2), $1;}')
 MD5SUM=$(echo "${MD5RAW}" | awk '{print $1;}')
 if [ ${MICROSD} = 0 ]
 then
   wget -O ${USTEM}/${f}${DLEXT}.md5 ${URLBASE}${f}${DLEXT}.md5
   MD5DL=$(cat ${USTEM}/${f}${DLEXT}.md5)
   if [ "${MD5SUM}" != "${MD5DL}" ]
   then
     echo "ERROR - MD5 mismatch for ${f} - expected ${MD5DL}, got ${MD5SUM}"
     exit 1
   fi
 fi
 MD5LIST="${MD5LIST}\n${MD5RAW}"
done

echo "${USTEM}" > /psp/update_prepared
echo "$0 started $(date) USTEM=${USTEM} URLBASE=${URLBASE} STORAGE=${STORAGE} VER=${VER}" > /psp/update.log
sync

echo "All update data fetched"
echo -e "${MD5LIST}"

backup_psp ${USTEM}
