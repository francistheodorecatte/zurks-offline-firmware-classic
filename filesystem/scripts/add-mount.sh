#!/bin/sh
# Mounts a drive.  Reports the mountpoint on stdout.  Optionally accepts a
# type as an environment variable called DEVICE_TYPE.


DEVNAME=$1


# Sleep for a variable number of seconds depending on the device name.
sleep $(echo ${DEVNAME} | tr -dc 0-9)

# Primitive shell-script-based locking.  Avert your eyes!
# Try 20 times to create the file /tmp/mount-lock
TRIES=20
while [ -e /tmp/mount-lock -a ${TRIES} -gt 0 ]
do
    sleep 1
    TRIES=$((${TRIES}-1))
done
touch /tmp/mount-lock


if [ "x${DEVNAME}" = "x" ]
then
    echo "Usage: $0 [device-name]"
    rm -f /tmp/mount-lock
    exit 1
fi


# Check to see if it's an SD Card.  SD cards are connected to USB port 4.
if echo "${DEVPATH}" | grep -q /1-1.4/1-1.4
then
    DEVICE_TYPE="sd"
fi


# Default to a device type of "usb".
if [ "x${DEVICE_TYPE}" == "x" ]
then
    DEVICE_TYPE="usb"
fi

echo "Using device ${DEVNAME} and source ${DEVICE_TYPE}"

# Bring in the environment, which might be missing if we're called from udev.
. /etc/profile


eval $(/lib/udev/vol_id ${DEVNAME})



# Create a symlink to maintain backwards-compatibility
# The next-available link is the next one that doesn't exist
# Note that this will go to usbN, where N is any positive number,
# rather than just to usb4.
MP_NUMBER=
while [ "x${MP}" = "x" ]
do
    MP_TEST=/mnt/${DEVICE_TYPE}${MP_NUMBER}
    # Test -L and -e separately, because -e fails if the file exists but is
    # a symlink that doesn't resolve
    if [ ! -L ${MP_TEST} -a ! -e ${MP_TEST} ]
    then
        MP=${MP_TEST}
        rm -f ${MP_TEST}
    else
        if [ "x${MP_NUMBER}" = "x" ]
        then
            MP_NUMBER=2
        else
            MP_NUMBER=$((${MP_NUMBER}+1))
        fi
    fi
done


# Figure out a mount point, if the UUID exists.  Symlink the
# previously-determined usb mountpoint here to maintain compatibiliy.
if [ "x${ID_FS_UUID}" != "x" ]
then
    SYMLINK=${MP}
    MP="/mnt/${DEVICE_TYPE}-${ID_FS_UUID}"
    rm -f ${MP}
    ln -sf ${MP} ${SYMLINK}
fi

echo "$$ Making directory ${MP} for mounting ${DEVNAME}" >> /tmp/mlog.txt
mkdir -p ${MP}


# Perform the actual mount.
MOUNT_OPTIONS="-onoatime"

# For vfat systems, mount them utf8.
if [ "${ID_FS_TYPE}" == "vfat" ]
then
    MOUNT_OPTIONS="${MOUNT_OPTIONS},iocharset=iso8859-1,utf8,shortname=mixed"
fi

# Do the same for NTFS.
if [ "${ID_FS_TYPE}" == "ntfs" ]
then
    MOUNT_OPTIONS="${MOUNT_OPTIONS},nls=utf8"
fi


# Perform the actual "mount".
if [ "x${MOUNT_CMD}" = "x" -a "x${DEVNAME}" != "xnone" ]
then
    mount ${DEVNAME} ${MP} -t ${ID_FS_TYPE} ${MOUNT_OPTIONS}
    MOUNT_RES=$?
    
    
    # Determine which USB port this is plugged into.
    if [ ${MOUNT_RES} == 0 ]
    then
        if echo "${DEVPATH}" | grep -q "/1-1.2/1-1.2"
        then
            USB_PORT=2
        elif echo "${DEVPATH}" | grep -q "/1-1.3/1-1.3"
        then
            USB_PORT=1
        elif echo "${DEVPATH}" | grep -q "/1-1.4/1-1.4"
        then
            USB_PORT=0
        else
            USB_PORT=?
        fi
    fi
        
elif [ "x${MOUNT_CMD}" = "x" ]
then
    false
    MOUNT_RES=1
else
    # Create the iFuse config directory.
    mkdir -p /psp/.config
    ${MOUNT_CMD} ${MP} 
    MOUNT_RES=$?
fi



# Handle the result of the mount.
if [ ${MOUNT_RES} -eq 0 ]
then

    if [ "${DEVICE_TYPE}" == "ipod" ]
    then
        /usr/chumby/scripts/service_control chumbipodd start 2> /tmp/sc-err.txt > /tmp/sc-out.txt
    else
        # If we're on a system with metadb, scan the newly-inserted drive.
        if which metadb
        then
            metadb --scan "${MP}" &
        fi
    fi
    
    # Signal flashplayer
    /usr/chumby/scripts/signal_usb_event.sh mount "${MP}" "${ID_FS_LABEL_SAFE}" "${USB_PORT}"
    echo ${MP}
    
    echo "$$ Successfully mounted ${DEVNAME} on ${MP}" >> /tmp/mlog.txt
    rm -f /tmp/mount-lock
    exit 0
else
    echo "$$ Failed to mount.  Removing ${MP}" >> /tmp/mlog.txt
    rmdir ${MP}
    if [ "x{$SYMLINK}" != "x" ]
    then
        rm -f ${SYMLINK}
    fi
    
    rm -f /tmp/mount-lock
    exit 1
fi
