#!/bin/sh
#
# Persistently try to unmount a filesystem.  Eventually the filehandles will
# close, and since the filesystem has been removed, no new files will be
# opened.  Thus, /eventually/ we'll be able to unmount the device.
#
# Provided someone isn't sitting in a directory on the unmounted filesystem.

# How many times should it attempt to unmount
DEFAULT_NUMBER_OF_TRIES=10

# How long should it rest.  Greater numbers will increase the likelihood that
# the device eventually unmounts, but may leave this process executing longer.
SLEEP_BETWEEN_TRIES=5

NUMBER_OF_TRIES=${DEFAULT_NUMBER_OF_TRIES}
DEVICE_TO_UMOUNT=$1

sleep ${SLEEP_BETWEEN_TRIES}
while [ ${NUMBER_OF_TRIES} -gt 0 ] && [ `grep "${DEVICE_TO_UMOUNT} " /proc/mounts | wc -l` -eq 1 ]
do
  logger -s "Device did not unmount.  Trying again (${NUMBER_OF_TRIES} tries left)"
  sleep ${SLEEP_BETWEEN_TRIES}
  umount -f "${DEVICE_TO_UMOUNT}"
  NUMBER_OF_TRIES=`expr ${NUMBER_OF_TRIES} - 1`
done

if [ ${NUMBER_OF_TRIES} -le 0 ]
then
  logger -s "Device did not successfully unmount, even after ${DEFAULT_NUMBER_OF_TRIES} tries"
  exit 1

elif [ ${NUMBER_OF_TRIES} -lt ${DEFAULT_NUMBER_OF_TRIES} ]
then
  logger -s "Device finally unmounted after `expr ${DEFAULT_NUMBER_OF_TRIES} - ${NUMBER_OF_TRIES}` tries"
else
  logger -s "Device unmounted without any retries necessary"
fi

# Attempt to remove the directory
rmdir ${DEVICE_TO_UMOUNT}
rm ${DEVICE_TO_UMOUNT}

# Attempt to remove the symlink
# XXX This might be fragile.  It's dereferencing the symlink by doing an ls,
# which has an entry like "usb2 -> /mnt/usb-AABBCC", splitting along the '>',
# splitting items up by spaces, then taking the line containing the words "usb".
# This ought to work in all cases, but it still seems somewhat complicated.
SYMLINK=`ls -l /mnt | grep " ${DEVICE_TO_UMOUNT}$" | cut -d'>' -f1 | tr ' ' '\n' | grep usb`
if [ "x${SYMLINK}" != "x" -a -L /mnt/$SYMLINK ]
then
  rm /mnt/${SYMLINK}
fi

exit 0
