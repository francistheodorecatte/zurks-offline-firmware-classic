#!/bin/sh
# $Id: temp_update.sh 5157 2009-03-31 02:14:41Z henry $
#
# temp_update.sh - temporary update system for stormwind
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

# Process options
INIT_ONLY=0
BBSCAN_ONLY=0
FORCE_RFS2=0
if [ "$1" != "" ]
then
  for opt in $*
  do
    case ${opt} in
      init|--init)	INIT_ONLY=1;	;;
      bbscan|--bbscan)	BBSCAN_ONLY=1;	;;
      --force-rfs2)	FORCE_RFS2=1;	;;
      --help)		echo "Options are:
	--init		Boot into rfs2 to begin update
	--bbscan	Only perform a bad block scan (results in /tmp/badblocks)
	--force-rfs2	Force immediate update of rfs2 and k2
	--help		Display this message";	exit 1;	;;
      *)	echo "Unrecognized option ${opt} - use --help to view available options"; exit 1;	;;
    esac
  done
fi

if [ -f /etc/rfs1 ]
then
  PHASE=2
  # Need to go in order
  IMAGELIST="k2 rfs2"
  # Are we kicking it off?
  if [ ${INIT_ONLY} = 1 ]
  then
	  # 16 bytes including NL
	  BOOTFLAGS="RFS2UPD1RFS2   "
	  /usr/chumby/scripts/stop_control_panel
	  # Make fb0 visible
	  switch_fb.sh 0
	  /usr/chumby/scripts/blast_img rebooting.bin
	  /usr/chumby/scripts/burn_bootflag "${BOOTFLAGS}"
	  echo "Rebooting"
	  echo "$0: current version is $(chumby_version -f)" >> /psp/update.log
	  echo "$0 rebooting to rfs2" >> /psp/update.log
	  sync; sync
	  sleep 3
	  reboot
  else
	# Go back to normal booting into RFS1
	BOOTFLAGS="RFS1RFS1RFS1   "
  fi
else
  PHASE=1
  # Need to go in order. psp is a special case handled in temp_update_sub.sh
  IMAGELIST="u-boot psp k1 rfs1"
  # 16 bytes including NL
  BOOTFLAGS="RFS1UPD2RFS1   "
fi

# Make sure we have something prepared
if [ ${BBSCAN_ONLY} = 0 ]
then
	if [ -f /psp/update_prepared ]
	then
	  USTEM=$(cat /psp/update_prepared)
	  echo "Update phase ${PHASE} using ${USTEM} from /psp/update_prepared"
	  echo "Updating: ${IMAGELIST}"
	  echo "Currently in: $(ls /etc/rfs*)" >> /psp/update.log
	  echo "Current version: $(chumby_version -f)" >> /psp/update.log
	  echo "Updating phase ${PHASE} using ${USTEM} list: ${IMAGELIST}" >> /psp/update.log
	else
	  echo "/psp/update_prepared not found - prepare_updates.sh not run yet?"
	  exit 1
	fi
fi

# Make fb0 visible
switch_fb.sh 0

# Perform bad block scan
echo "Scanning for bad blocks..."
rm -f /tmp/badblocks /tmp/new_badblocks
for p in $(cat /proc/mtd | awk -F ':' '/mtd.+:/ {print $1;}')
do
  bbscan -m /dev/$p
done

echo "Scan completed: $(cat /tmp/badblocks)"

# If only doing scan, we're done
[ ${BBSCAN_ONLY} = 1 ] && exit 0

# If phase 1, stop daemons that might be keeping /psp busy
if [ "${PHASE}" = "1" ]
then
  echo "Phase ${PHASE}: stopping daemons using /psp"
  sync; sync; sync
  killall crond
  killall udhcpc
  killall mountmon
  echo "waiting for crond etc to die"
  sleep 1
  echo "Saving critical data from /psp"
  rm -rf /tmp/psp.backup
  mkdir -p /tmp/psp.backup
  PSP_SAVE="/psp/update_prepared /psp/update.log"
  sync; sync
  cp ${PSP_SAVE} /tmp/psp.backup/
  if /usr/chumby/scripts/is_psp_virtualized
  then
	echo "/psp is virtualized, no unmount needed"
	echo "virtual /psp remains mounted" >> /tmp/psp.backup/update.log
  else
	echo "Attempting unmount of /psp"
	sync; sync
	umount /psp
	echo "/psp unmounted" >> /tmp/psp.backup/update.log
  fi
fi

# Sanity check for all files present
MISSING_LIST=
for IMG in ${IMAGELIST}
do
  if [ ! \( -f ${USTEM}/${IMG}.zip -a -f ${USTEM}/${IMG}.zip.md5 \) ]
  then
    MISSING_LIST="${MISSING_LIST} ${IMG}"
  fi
done

if [ "${MISSING_LIST}" != "" ]
then
  echo "The following are missing one or more .zip and .zip.md5 files in ${USTEM}:"
  for IMG in ${IMAGELIST}
  do
    echo "${IMG}"
  done
  echo "Cannot continue"
  # Restore mounts
  if [ "${PHASE}" = "1" ]
  then
    if /usr/chumby/scripts/is_psp_virtualized
    then
	echo "No need to remount virtual /psp"
    else
	echo "Remounting /psp"
	mount -t yaffs2 /dev/mtdparts/mtdblock_psp /psp
    fi
  fi
  echo "${MISSING_LIST} missing" >> /psp/update.log
  exit 1
fi

# Now we can start burning...
FAILCOUNT=0
FAILLIST=
for IMG in ${IMAGELIST}
do
  if /usr/chumby/scripts/temp_update_sub.sh ${IMG} ${USTEM}
  then
    echo "$0: ${IMG} ok"
  else
	FAILCOUNT=$(expr ${FAILCOUNT} \+ 1)
	FAILLIST="${FAILLIST} ${IMG}"
  fi
  sleep 1
done

if [ "${FAILCOUNT}" = "0" ]
then
  echo "All succeeded"
  if [ "${PHASE}" = "1" ]
  then
	if /usr/chumby/scripts/is_psp_virtualized
	then
		echo "No need to remount virtual /psp"
		echo "virtual /psp requires no remount" >> /tmp/psp.backup/update.log
	else
		echo "Remounting /psp"
		sleep 2
		mount -t yaffs2 /dev/mtdparts/mtdblock_psp /psp
		echo "remount completed" >> /tmp/psp.backup/update.log
	fi
	echo "Restoring update files to /psp" | tee -a /tmp/psp.backup/update.log
	cp /tmp/psp.backup/* /psp/
	echo "Critical update files restored to /psp" >> /psp/update.log
	if [ -d /psp/install ]
	then
		# Previously we'd restore files from ${USTEM}/psp.backup - now we let install script(s)
		# handle that, and pass them the directory location.
		echo "Running install scripts in /psp/install; backup = ${USTEM}/psp.backup" | tee -a /psp/update.log
		for INSTALL_SCRIPT in /psp/install/*
		do
		  echo "Running ${INSTALL_SCRIPT}" | tee -a /psp/update.log
		  ${INSTALL_SCRIPT} ${USTEM}/psp.backup | tee -a /psp/update.log
		done
	else
		echo "/psp/install does not exist" | tee -a /psp/update.log
	fi
	# Signal to rfs1 that phase 1 has been completed
	touch /psp/UPDATE${PHASE}
	/usr/chumby/scripts/burn_bootflag "${BOOTFLAGS}"
	cat /tmp/chumbyflash.log >> /psp/update.log 2>&1
	echo "Rebooting"
	sync; sync
	/usr/chumby/scripts/blast_img rebooting.bin
	sync
	sleep 1
	reboot
  else
    cat /tmp/chumbyflash.log >> /psp/update.log 2>&1
	echo "completed1" >> /psp/update.log
	/usr/chumby/scripts/blast_img update_complete.bin
	if [ "${FORCE_RFS2}" = "1" ]
	then
		echo "Forced update of rfs2 completed"
		echo "Run temp_update.sh init to begin regular update"
		fbwrite "



           Forced update of RFS2 completed
           Ready to begin regular update"
		sleep 2
	else
		rm -f /psp/UPDATE1 /psp/update_prepared
		sync
		# Clear "update in progress" flag
		/usr/chumby/scripts/burn_bootflag "${BOOTFLAGS}"
		# Launch a video to create /psp/.gstreamer-0.10
		if [ -f /usr/widgets/video_initialized.avi -a ! -d /psp/.gstreamer-0.10/registry.arm.xml ]
		then
	  	  echo "Launching initial video to generate gstreamer registry..."
	  	  MAX_X_RES=800 MAX_Y_RES=600 gst-app /usr/widgets/video_initialized.avi < /dev/null > /tmp/video_init.log 2>&1 &
		fi

		# Generate a list of known camera models
		if [ ! -e /psp/cameras.moddef ]
		then
		  echo "Generating list of known camera models..."
		  ptplist > /psp/cameras.moddef
		fi

		sleep 10

	fi
  fi
  sync
else
  echo "Failure count = ${FAILCOUNT} (${FAILLIST} )"
  /usr/chumby/scripts/blast_img update_unsuccessful.bin
fi
