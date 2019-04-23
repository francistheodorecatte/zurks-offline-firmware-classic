#!/bin/sh
# $Id: umount.sh 649 2007-06-04 00:26:23Z henry $
# unmount event script for mountmon
#
# See mountmon.conf for list of environment variables available on input
# and required output values
#

# Get MMS_PUID and other useful stuff based on DEVPATH
. mountmon_utils.sh

if [ "${MM_VERBOSE}" = "1" ]
then
	set >/tmp/mountmon.umount.$$
fi

# This is invoked after a successful unmount

# This is a notification - we don't try to do anything here
# $CURRENT_MOUNTPOINT is the mount point being unmounted

echo "RESULT=0"
echo "MESSAGE="

return 0
