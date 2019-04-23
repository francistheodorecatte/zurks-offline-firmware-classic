#!/bin/sh
# $Id: add.sh 18885 2010-01-15 14:18:24Z henry $
# add event script for mountmon
#
# See mountmon.conf for list of environment variables available on input
# and required output values
#

RESULT=0
MESSAGE=
MODULE_DIR=/drivers
DBGOUT=/dev/null
[ "${DAEMON_LOGDIR}" != "" ] && DBGOUT=${DAEMON_LOGDIR}/add.$$

SCRIPT_VER='$Rev: 18885 $'
echo "# Starting $0 version ${SCRIPT_VER}"

# Get MMS_PUID and other useful stuff based on DEVPATH
. mountmon_utils.sh

# If the device name begins with "/dev/sd", then it's probably a block
# device of some sort.  This becomes useful for iPods, as well as obtaining
# volume label information.
if [ `echo ${DEVNAME} | grep '/dev/sd' | wc -l` -gt 0 ]
then
  # run vol_id
  # Filter out ID_FS_LABEL, as it can have spaces that throw off
  # the eval statement.
  eval "$(/lib/udev/vol_id ${DEVNAME} | grep -v ID_FS_LABEL=)"
fi

# At this point we've collected most of the vars that are of interest for debugging.
if [ "${MM_VERBOSE}" = "1" ]
then
	set >/tmp/mountmon.add.$$
fi

# For CD/DVD, another special case
if [ "${ID_FS_TYPE}" = "" -a "${DEVNAME}" != "" -a "${ID_TYPE}" = "cd" ]
then

  # Determine module we need loaded
  NEED_MODULE=${ID_FS_TYPE}
  [ "${NEED_MODULE}" = "iso9660" ] && NEED_MODULE=isofs
  # Check to see if module is loaded
  LOAD_CHECK="$(lsmod | grep ${NEED_MODULE})"
  if [ "${LOAD_CHECK}" = "" ]
  then
  	echo "# kernel module ${NEED_MODULE} required, loading..."
  	if insmod ${MODULE_DIR}/${NEED_MODULE}.ko
  	then
  		echo "# module loaded successfully"
  		MESSAGE="${MESSAGE} ; loaded ${NEED_MODULE}"
  		sleep 1
  	else
  		RESULT=1
  		MESSAGE="Failed to load ${NEED_MODULE}"
  		ID_FS_TYPE=""
  	fi
  fi
fi

# More module loads triggered by specific vendor:modelid combos
# We put these in /etc/mountmon/*.moddef files to make it simpler
# to add new devices, but still handle matches individually here
if [ "${MMS_PUID}" != ":" ]
then

	# Check for chumbradiod
	if grep "^${MMS_PUID}" /etc/mountmon/chumbradiod.moddef >/dev/null
	then
		echo "# Starting chumbradiod for ${MMS_VENDOR_NAME} ${MMS_PRODUCT_NAME} ${MMS_VERSION}"
		MESSAGE="${MESSAGE} ; starting chumbradiod"
		service_control chumbradiod load ${DEVPATH} >>${DBGOUT} 2>&1
	fi

	# Check for USB ethernet adapters
	USBNET_DIR=/etc/mountmon
	if grep "^${MMS_PUID}" ${USBNET_DIR}/usbnet-*.moddef >/dev/null
	then
		echo "# USB ethernet ${MMS_PUID}"
		loadKernelModule /drivers/usbnet
		for USBNET_DRIVER in $(ls -1 ${USBNET_DIR}/usbnet-*.moddef | sed s/^.*usbnet-//)
		do
			USBNET_DRIVER=$(basename ${USBNET_DRIVER} .moddef)
			if grep "^${MMS_PUID}" ${USBNET_DIR}/usbnet-${USBNET_DRIVER}.moddef >/dev/null
			then
				echo "# USB ethernet chipset ${USBNET_DRIVER} ${MMS_PUID}"
				loadKernelModule /drivers/${USBNET_DRIVER}
			fi
		done
		# Determine the interface it's on
		ETH="$(ifconfig -a | awk '/^eth/ {print $1;}')"
		# If it's not visible wait
		if [ "${ETH}" = "" ]
		then
			echo "# Waiting for interface to become visible"
			sleep 2
			ETH="$(ifconfig -a | awk '/^eth/ {print $1;}')"
		fi
		# FIXME move this to start_network, which needs to handle possible manual config
		# Bring it up
		if [ "${ETH}" ]
		then
			# see if it's already up
			IFCONFIG_DATA="$(ifconfig ${ETH} | awk '/ RUNNING / {print;}' 2>/dev/null)"
			if [ "${IFCONFIG_DATA}" = "" ]
			then
				echo "# Starting network interface ${ETH}"
				ifconfig ${ETH} up
				# Start dhcp client if necessary
				DHCP_RUNNING=$(ps | awk "/[u]dhcpc .* ${ETH}/ {print 1;}")
				if [ "${DHCP_RUNNING}" != "1" ]
				then
					udhcpc -R -n -p /var/run/udhcpc.${ETH}.pid -i ${ETH}
				fi
			else
				echo "# ${ETH} is already running"
			fi
		else
			echo "# Warning - did not find interface in ifconfig -a, cannot start interface"
		fi
	fi

	# Check for USB serial adapters. We need usbserial + chipset-specific driver
	USBSER_DIR=/etc/mountmon
	if grep "^${MMS_PUID}" ${USBSER_DIR}/usbserial.moddef >/dev/null
	then
		echo "# USB serial ${MMS_PUID}"
		loadKernelModule /drivers/usbserial
		for USBSER_DRIVER in $(ls -1 ${USBSER_DIR}/usbserial-*.moddef | sed s/^.*usbserial-//)
		do
			USBSER_DRIVER=$(basename ${USBSER_DRIVER} .moddef)
			if grep "^${MMS_PUID}" ${USBSER_DIR}/usbserial-${USBSER_DRIVER}.moddef >/dev/null
			then
				echo "# USB serial chipset ${USBSER_DRIVER} ${MMS_PUID}"
				loadKernelModule /drivers/${USBSER_DRIVER}
			fi
		done
	fi

	# Check for digital cameras that use PTP
	USBCAM_DIR=/psp
	CAMERAS=`grep "^${MMS_PUID}" ${USBCAM_DIR}/cameras*.moddef 2> /dev/null`
	if [ $? -eq 0 ] && [ `echo "$CAMERAS" | wc -l` -gt 0 ]
	then
		MODEL=`echo $CAMERAS | head -n 1 | cut -d'#' -f2`
		echo "# USB camera: ${MODEL}"

		# Make sure only one camera is mounted at a time.
		if [ `mount | grep '/mnt/camera' | wc -l` -ne 0 ]
		then
			logger "$0: Only one camera is currently supported at a time"
			MESSAGE="${MESSAGE}; Camera already mounted"
			RESULT=1
		else
			mkdir -p /mnt/camera
			gphotofs /mnt/camera
			/usr/chumby/scripts/signal_usb_event.sh mount /mnt/camera
			MESSAGE="${MESSAGE}; Mounted '${MODEL}'"
			RESULT=0
		fi
	fi


	# Check for other USB devices which have a simple 1-1 correspondence with a module
	USBMISC_DIR=/etc/mountmon
	for USBMISC_DRIVER in $(cat ${USBMISC_DIR}/miscdrivers.list)
	do
		if grep "^${MMS_PUID}" ${USBMISC_DIR}/${USBMISC_DRIVER}.moddef >/dev/null
		then
			echo "# misc USB device ${USBMISC_DRIVER} ${MMS_PUID}"
			loadKernelModule /drivers/${USBMISC_DRIVER}
		fi
	done

fi

# Mount filesystems
if [ "${DEVNAME}" -a "${ID_FS_TYPE}" ]
then

  # Make sure extra mount points exist
  for d in cdrom cdrom2 cdrom3 ipod ipod2 ipod3
  do
    [ -d /mnt/$d ] || mkdir /mnt/$d
  done

  # Check for apple
  if [ "${MP}" = "" -a "${ID_VENDOR}" = "Apple" -a "${ID_MODEL}" = "iPod" ]
  then
  	# show mount points in preferred order
  	for testmp in /mnt/ipod*
  	do
  	  grep ${testmp} /proc/mounts >/dev/null 2>&1 || MP=${testmp}
  	  if [ "${MP}" ]
  	  then
  	    break
  	  fi
  	done
  fi

  # Do we need to find a mount point?
  if [ "x${MP}" = "x" -a "x${ID_FS_UUID}" != "x" -a `echo ${DEVNAME} | grep '/dev/sd' | wc -l` -gt 0 ]
  then
    echo "# using uuid ${ID_FS_UUID} as mountpoint"
    echo "# Source: ${PHYSDEVDRIVER}"
    SOURCE_TYPE="usb"
    VENDOR=$(cat /sys/${PHYSDEVPATH}/vendor)
    MODEL=$(cat /sys/${PHYSDEVPATH}/model)
#    if [ "${PPID}" = "6295" -a "${MMS_VENDOR}" = "058f" ]
    echo "${MODEL}" = "Flash Reader    " -a "${VENDOR}" = "Multi   "
    if [ "${MODEL}" = "Flash Reader    " -a "${VENDOR}" = "Multi   " ]
    then
      SOURCE_TYPE="mem"
    fi
    MP="/mnt/${SOURCE_TYPE}-${ID_FS_UUID}"
    mkdir $MP
    
    # Create a symlink to maintain backwards-compatibility
    # The next-available link is the next one that doesn't exist
    # Note that this will go to usbN, where N is any positive number,
    # rather than just to usb4.
    MP_LINK_FOUND=
    MP_LINK=
    while [ "x${MP_LINK_FOUND}" = "x" ]
    do
      # Test -L and -e separately, because -e fails if the file exists but is
      # a symlink that doesn't resolve
      if [ ! -L /mnt/usb${MP_LINK} -a ! -e /mnt/usb${MP_LINK} -a "x${MP_LINK_FOUND}" = "x" ]
      then
        MP_LINK_FOUND=1
        ln -s ${MP} /mnt/usb${MP_LINK}
      else
        if [ "x${MP_LINK}" = "x" ]
        then
          MP_LINK=2
        else
          MP_LINK=`expr ${MP_LINK} + 1`
        fi
      fi
    done
  fi

  # Check for CD/DVD
  if [ "${MP}" = "" -a "${ID_TYPE}" = "cd" ]
  then
  	for testmp in /mnt/cdrom*
  	do
  	  grep ${testmp} /proc/mounts >/dev/null 2>&1 || MP=${testmp}
  	  [ "${MP}" ] && break
  	done
  fi

  # Check for hard drives and generic USB drives
  if [ "${MP}" = "" -a "${ID_BUS}" = "usb" ]
  then
  	echo "# default mount point"
  	for testmp in /mnt/usb /mnt/usb2 /mnt/usb3 /mnt/usb4 /mnt/usb5
  	do
      [ -L ${testmp} -o -d ${testmp} ] || MP=${testmp}
  	  if [ "${MP}" ]
  	  then
 	    ID_FS_LABEL_SAFE=""
  	    mkdir ${MP}
  	    break
  	  fi
  	done
  fi

  # Mount if we have something
  if [ "${MP}" != "" ]
  then
  	echo "MOUNT=${MP}"
	# Default -osync removed - options in /psp/default_mount_options
	# must be specified WITHOUT leading -o
	MOUNT_OPTIONS=
	[ -f /psp/default_mount_options ] && MOUNT_OPTIONS="$(cat /psp/default_mount_options),"

	# For vfat systems, mount them utf8.
	if [ "${ID_FS_TYPE}" == "vfat" ]
	then
		MOUNT_OPTIONS="-o${MOUNT_OPTIONS}iocharset=iso8859-1,utf8"
	fi

  	RESULT=1
  	if mount ${DEVNAME} ${MP} -t ${ID_FS_TYPE} ${MOUNT_OPTIONS}
  	then
		MESSAGE="${MESSAGE}; Mounted ${DEVNAME} successfully"
		RESULT=0
		# Signal flashplayer
		/usr/chumby/scripts/signal_usb_event.sh mount "${MP}" "${ID_FS_LABEL_SAFE}"
	else
		logger "$0: failed to mount ${DEVNAME} on ${MP} as type ${ID_FS_TYPE} with options ${MOUNT_OPTIONS}"
	fi
  else
  	MESSAGE="Unable to find a suitable free mount point for ${DEVNAME}"
  	RESULT=1
  fi

  # Display some additional info if verbose is on
  if [ "${RESULT}" = "0" -a "${ID_VENDOR}${ID_MODEL}" != "" ]
  then
    echo "# vendor/model/puid = ${ID_VENDOR}/${ID_MODEL}/${MMS_PUID}"
  fi

  # Check for daemons we need to start after a successful mount
  if [ "${ID_VENDOR}" = "Apple" -a "${ID_MODEL}" = "iPod" -a "${RESULT}" = "0" ]
  then
	echo "# Starting chumbipodd"
	MESSAGE="${MESSAGE}; starting chumbipodd"
	service_control chumbipodd load ${DEVPATH} >>${DBGOUT} 2>&1
  fi


fi

echo "RESULT=${RESULT}"
echo "MESSAGE=${MESSAGE}"

return ${RESULT}
