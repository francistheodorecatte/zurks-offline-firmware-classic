#!/bin/sh
# $Id: temp_update_sub.sh 5236 2009-03-31 18:36:00Z henry $
#
# temp_update_sub.sh - temp script to update a single partition
# Args:
# $1 partition name, e.g. psp
# $2 USTEM name, e.g. /mnt/usb/cache
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

PART=$1
USTEM=$2
if [ "${PART}" = "" ]
then
  echo "No partition specified"
  exit 1
fi
if [ "${USTEM}" = "" ]
then
  echo "No USTEM dir specified"
  exit 1
fi
if [ ! -d ${USTEM} ]
then
  echo "${USTEM} is not a dir"
  exit 1
fi
PZIP=${USTEM}/${PART}.zip
PMD5=${USTEM}/${PART}.zip.md5
if [ ! -f ${PZIP} ]
then
  echo "${PZIP} not found"
  exit 1
fi

# Get offsets
LIST=$(sed 's/\/dev\///g' < /tmp/badblocks | sed 's/:/=/g' | sed 's/,/ /g')
eval ${LIST}
# We also have mtd0o etc. for comparisons of newly discovered bad blocks
LIST=$(sed 's/\/dev\///g' < /tmp/badblocks | sed 's/:/o=/g' | sed 's/,/ /g')
eval ${LIST}

#LIST="mtd0=0 mtd1=0 mtd2=0 mtd3=0 mtd4=0 mtd5=0 mtd6=0 mtd7=0 mtd8=0 mtd9=0"
#eval ${LIST}

# There may be no newly discovered blocks
if [ -f /tmp/new_badblocks ]
then
  NLIST=$(sed 's/\/dev\///g' < /tmp/new_badblocks | sed 's/:/=/g')
  eval ${NLIST}
  mtd0=$(expr ${mtd0} \+ ${mtd0n:-0})
  mtd1=$(expr ${mtd1} \+ ${mtd1n:-0})
  mtd2=$(expr ${mtd2} \+ ${mtd2n:-0})
  mtd3=$(expr ${mtd3} \+ ${mtd3n:-0})
  mtd4=$(expr ${mtd4} \+ ${mtd4n:-0})
  mtd5=$(expr ${mtd5} \+ ${mtd5n:-0})
  mtd6=$(expr ${mtd6} \+ ${mtd6n:-0})
  # If psp is virtualized, assume we also don't have /mnt/cache
  if /usr/chumby/scripts/is_psp_virtualized
  then
	mtd7=0
	mtd8=0
	mtd9=0
  else
	mtd7=$(expr ${mtd7} \+ ${mtd7n:-0})
	mtd8=$(expr ${mtd8} \+ ${mtd8n:-0})
	mtd9=$(expr ${mtd9} \+ ${mtd9n:-0})
  fi
fi

IGNORE_MTD=0
[ ${PART} = psp ] && /usr/chumby/scripts/is_psp_virtualized && IGNORE_MTD=1
if [ ${IGNORE_MTD} = 0 ]
then
	MTD=$(cat /proc/mtd | awk -F ':' "/\"${PART}\"/ {print \$1;}")
	if [ "${MTD}" = "" ]
	then
	  echo "${PART} not found in /proc/mtd"
	  exit 1
	fi
	#echo "Erasing ${MTD} for ${PART}"
	DEVNODE=/dev/${MTD}
	if [ ! -c ${DEVNODE} ]
	then
	  echo "char special device node ${DEVNODE} not found for ${MTD}"
	  exit 1
	fi
else
	MTD=
	DEVNODE=/dev/null
fi


/usr/chumby/scripts/blast_img updating_software.bin
fbwrite "


     $(/usr/chumby/scripts/update_part_name.sh ${PART})"

# Get erase block size
ERASEBLOCK_HEX=$(cat /proc/mtd | awk '/mtd0: / {print $3;}')

# Determine offset. Virtualized layout is different
if /usr/chumby/scripts/is_psp_virtualized
then
	case ${PART} in
	  u-boot)	OFF=0	;;
	  k2)		OFF=${mtd0}	;;
	  rfs2)		OFF=$(expr ${mtd0} \+ ${mtd1})	;;
	  k1)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2})	;;
	  rfs1)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3})	;;
	  msp)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4})	;;
	  storage)	OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4} \+ ${mtd5})	;;
	esac
else
	case ${PART} in
	  u-boot)	OFF=0	;;
	  psp)		OFF=${mtd0}	;;
	  k2)		OFF=$(expr ${mtd0} \+ ${mtd1})	;;
	  rfs2)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2})	;;
	  k1)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3})	;;
	  rfs1)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4})	;;
	  cache)	OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4} \+ ${mtd5})	;;
	  reserved)	OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4} \+ ${mtd5} \+ ${mtd6})	;;
	  msp)		OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4} \+ ${mtd5} \+ ${mtd6} \+ ${mtd7})	;;
	  storage)	OFF=$(expr ${mtd0} \+ ${mtd1} \+ ${mtd2} \+ ${mtd3} \+ ${mtd4} \+ ${mtd5} \+ ${mtd6} \+ ${mtd7} \+ ${mtd8})	;;
	esac
fi

OFFADDR=$(echo "${OFF} 0x${ERASEBLOCK_HEX}" | awk '{printf "%u\n", $1 * $2;}')
if [ ${PART} = psp ]
then
  if /usr/chumby/scripts/is_psp_virtualized
  then
	echo "Special handling for virtualized ${PART} - rm -rf and extract tarball"
	cd /mnt/storage
	rm -rf psp
	mkdir psp
	if unzip -p ${PZIP} | tar xf -
	then
		echo -e "\nSuccess"
		fbwrite "



OK"
		sync; sync
		exit 0
	else
		echo -e "\ntarball extract ${P} failed"
		fbwrite "



Failed"
	fi
  else
	echo "Special handling for ${PART} - erase, mount, extract tarball..."
	cd /
	flash_eraseall /dev/mtdparts/mtd_psp
	mount -t yaffs2 /dev/mtdparts/mtdblock_psp /psp
	if unzip -p ${PZIP} | tar xf -
	then
		echo -e "\nSuccess"
		fbwrite "



OK"
		sync; sync
		umount /psp
		exit 0
	else
		echo -e "\ntarball extract ${P} failed"
		umount /psp
		fbwrite "



Failed"
	fi
  fi
else
echo "Writing ${MTD} for ${PART} using offset ${OFFADDR} (${OFF} * 0x${ERASEBLOCK_HEX}..."
echo  "unzip -p ${PZIP} | chumbyflash -s ${OFFADDR} -e -v -m ${DEVNODE}"
if unzip -p ${PZIP} | chumbyflash -s ${OFFADDR} -e -v -m ${DEVNODE}
then
  echo -e "\nSuccess"
  fbwrite "



 OK"
  exit 0
else
  echo -e "\nchumbyflash ${P} failed"
  fbwrite "



 Failed"
fi
fi

exit 1

