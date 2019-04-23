#!/bin/sh
# Removes the /psp partition (which is partition 5), as well
# as the "extended" partition (which is partition 4), and then
# re-creates the extended partition to fit the entire disk (minus the
# last few clusters), re-creates the psp partition, and creates a new
# storage partition.
DISK=$1

if [ "x${DISK}" = "x" ]
then
    echo "Usage: $0 [disk]"
    echo "E.g. $0 /dev/mmcblk0"
    exit
fi

EXTENDED_PARTITION=$(fdisk -u -l ${DISK} | grep "^${DISK}p4" | sed 's/ \+/ /g')
PSP_PARTITION=$(fdisk -u -l ${DISK} | grep "^${DISK}p5" | sed 's/ \+/ /g')
STORAGE_PARTITION=$(fdisk -u -l ${DISK} | grep "^${DISK}p6" | sed 's/ \+/ /g')
LAST_SECTOR=$(fdisk -u -l /dev/mmcblk0 | grep ' total ' | tr ',' '\n' | grep sectors | grep -v 'sectors/track' | tr ' ' '\n' | egrep '[0-9]+')
SAFE_SECTOR=$(expr ${LAST_SECTOR} - 8192)

# Make sure we have everything we need before going on.
if [ "x${LAST_SECTOR}" = "x" -o "x${PSP_PARTITION}" = "x" -o "x${EXTENDED_PARTITION}" = "x" ]
then
    echo "Couldn't gather required components to repartition hard drive!!!"
    echo "LAST_SECTOR: ${LAST_SECTOR}"
    echo "PSP_PARTITION: ${PSP_PARTITION}"
    echo "EXTENDED_PARTITION: ${EXTENDED_PARTITION}"
    exit
fi

if [ "x${STORAGE_PARTITION}" != "x" ]
then
    echo "Storage partition already exists!"
    exit
fi

echo "Beginning process of repartitioning"


echo "Deleting /psp and extended partitions..."
cat <<EOF | fdisk -u ${DISK}
d
5
d
4
w
EOF

echo "Creating larger extended partition..."
EXTENDED_START=
cat <<EOF | fdisk -u ${DISK}
n
e

${SAFE_SECTOR}
w
EOF

echo "Creating /psp again..."
PSP_END=$(echo ${PSP_PARTITION} | cut -d' ' -f3)
cat <<EOF | fdisk -u ${DISK}
n

${PSP_END}
w
EOF

echo "Creating /mnt/storage partition..."
cat <<EOF | fdisk -u ${DISK}
n


w
EOF

# Try to reformat the storage partition, if it exists now.  Otherwise,
# we might need to reboot.
dd if=${DISK}p6 of=/dev/null bs=512 count=1 2> /dev/null                   
if [ $? != 0 ]
then
    mount ${DISK}p5 /psp
    touch /psp/REFORMAT_STORAGE
    umount /psp
    reboot
    
    # Wait forever, so the reboot completes.
    while true
    do
        sleep 100
    done
else
    mkfs.ext3 ${DISK}p6
fi
echo "Done."

