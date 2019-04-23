#!/bin/sh
# Unmounts a drive.  Reports the mountpoint on stdout.  Optionally accepts a
# type via the DEVICE_TYPE environment variable, such as "ipod".  Defaults to "usb".

PATH=$PATH:/usr/chumby/scripts

DEVNAME=$1
if [ "x${DEVNAME}" = "x" ]
then
    echo "Usage: $0 [device-name]"
    exit 1
fi


if [ "x${DEVICE_TYPE}" = "x" ]
then
    DEVICE_TYPE="usb"
fi
    

. /etc/profile




if [ "x${DEVNAME}" = "xipod" ]
then
    MP=$(mount | grep "ipod" | cut -d' ' -f3)
else
    MP=$(mount | grep "^${DEVNAME} " | cut -d' ' -f3)
fi

if [ "x${MP}" = "x" ]
then
    echo "Unable to find mount point for ${DEVNAME}"
    exit 1
fi


eval $(/lib/udev/vol_id ${DEVNAME})

SYMLINK=$(ls -l /mnt/ | grep " -> ${MP}$" | awk '{print $9}')
if [ "x${SYMLINK}" != "x" ]
then
    SYMLINK=/mnt/${SYMLINK}
fi


# Signal flashplayer
/usr/chumby/scripts/signal_usb_event.sh unmount "${MP}"

# If we're on a system with metadb, scan the newly-inserted drive.
if which metadb
then
    metadb --prune "${MP}" &
fi


#echo "Going to unmount ${MP} and remove symlink ${SYMLINK}"
umount ${MP}
sleep 1
/usr/chumby/scripts/umount_repeated.sh ${MP} &
if [ "x${SYMLINK}" != "x" ]
then
    rm -f ${SYMLINK}
fi


if [ "${DEVICE_TYPE}" == "ipod" ]
then
    service_control chumbipodd stop
    killall mount.ifuse
fi
