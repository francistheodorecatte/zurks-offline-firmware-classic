#!/bin/sh
# $Id: update_launch.sh 15370 2009-08-21 21:01:48Z henry $
# update_launch.sh - bootstrap phase 1 of update by extracting update tarball, looking for updater.sh,
# and starting either /mnt/storage/update/updater.sh or /usr/chumby/scripts/updater.sh
# The only required arg is the tarball
# ORIGIN is passed in environment as USB or OTA

fail() {
	for arg in $(cat /proc/cmdline)
	do
		case "${arg}" in
		logo.brand\=*)
			BRAND=$(echo ${arg} | cut -d= -f2)
			;;
		esac
	done
	if [ "x${BRAND}" = "xchumby" ]
	then
		BRAND=""
	else
		BRAND=".${BRAND}"
	fi
    echo $*
    echo $* > /tmp/update_fail_reason.txt
    # Clean up here.  Unmount partitions and draw the failure screen.
    imgtool --mode=draw /bitmap/${VIDEO_RES}/update_unsuccessful.bin${BRAND}.jpg
    exit 1
}


TARBALL=$1
MOUNT_POINT=/mnt/storage

[ "${TARBALL}" ] || fail "Syntax: $0 <tarball>"
[ -f ${TARBALL} ] || fail "Tarball ${TARBALL} not found"


# Extract the "updater.sh" script from the file and run it.
if unzip -l -q ${TARBALL} 2> /dev/null > /dev/null
then
    unzip -o ${TARBALL} updater.sh -d /tmp || fail "Updater script not found"
    chmod a+x /tmp/updater.sh
else
    tar xvzf ${TARBALL} -C /tmp updater.sh || fail "Updater script not found"
fi
export ORIGIN
logger "Running ORIGIN=${ORIGIN} /tmp/update.sh $*"
exec /tmp/updater.sh $* || fail "Unable to launch update script"
