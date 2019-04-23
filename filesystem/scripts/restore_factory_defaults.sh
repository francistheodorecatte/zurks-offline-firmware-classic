#!/bin/sh
#
# restore_factory_defaults.sh - restore /psp from original install source
#
# Sean Cross
# Copyright (c) Chumby Industries, 2007-2009
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


PSP_IMAGE=/usr/share/defaults/psp.tar.gz
DISK=/dev/mmcblk0

fail() {
    echo $*
    echo $* > /tmp/restore_fail_reason.txt
    exit 1
}


# Handle options:
# --psp-only
RESET_STORAGE=1
if [ "$1" != "" ]
then
  for opt in $*
  do
    case ${opt} in
	--psp-only)
		RESET_STORAGE=0
		;;
	*)
		echo "Unrecognized option ${opt}"
		echo "Valid options:"
		echo "  --psp-only   Reset only /psp, leave /mnt/storage and /mnt/cache alone"
		exit 1
		;;
    esac
  done
fi

/usr/chumby/scripts/switch_fb.sh 0

echo "$0: Restoring factory defaults."


# We'll be unmounting /psp/, so kill the processes that we know will be
# using files located there.
killall httpd crond
sleep 1
killall -9 httpd crond


# Ensure the image we're extracting from exists.
[ -f ${PSP_IMAGE} ] || fail "Cannot restore /psp: ${PSP_IMAGE} not found"



## Unmount, format, remount, restore.  Goes the loop.
#PSP_PARTITION=$(grep /psp /etc/fstab | awk '{print $1}')
#if [ "x${PSP_PARTITION}" = "x" ]
#then
#    echo "Error: psp partition not found in /etc/fstab"
#else
#    cd /
#    umount ${PSP_PARTITION}    || fail "Unable to unmount /psp"
#    mkfs.ext3 ${PSP_PARTITION} || fail "Unable to format /psp"
#    mount ${PSP_PARTITION}     || fail "Unable to remount /psp"
#    tar xvzf ${PSP_IMAGE}      || fail "Unable to restore /psp"
#fi

# Rather than reformatting, remove everything and extract it all again.
cd /
rm -rf /psp/*           || fail "Unable to remove files from /psp"
tar xvzf ${PSP_IMAGE}   || fail "Unable to restore /psp"


# If requested, delete /mnt/storage, which will be re-created on next boot.
if [ ${RESET_STORAGE} -eq 1 ]
then
    echo "Deleting /mnt/storage..."
cat <<EOF | fdisk -u ${DISK}
d
6
w
EOF
#
#    STORAGE_PARTITION=$(grep /mnt/storage /etc/fstab | awk '{print $1}')
#    if [ "x${STORAGE_PARTITION}" = "x" ]
#    then
#        echo "Error: storage partition not found in /etc/fstab"
#    else
#        umount ${STORAGE_PARTITION}    || fail "Unable to unmount storage"
#        mkfs.ext3 ${STORAGE_PARTITION} || fail "Unable to reformat storage"
#    fi
fi

# After factory defaults are restored.
reboot
