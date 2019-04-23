#!/bin/sh
# $Id: mount.sh 649 2007-06-04 00:26:23Z henry $
# mount event script for mountmon
#
# See mountmon.conf for list of environment variables available on input
# and required output values
#

# Get MMS_PUID and other useful stuff based on DEVPATH
. mountmon_utils.sh

if [ "${MM_VERBOSE}" = "1" ]
then
set >/tmp/mountmon.mount.$$
fi

echo "RESULT=0"
echo "MESSAGE=OK"
echo "MOUNT="

return 0

