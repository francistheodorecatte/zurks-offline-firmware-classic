#!/bin/sh
# $Id: prepare_ota_update.sh 16198 2009-08-27 23:21:54Z henry $
# prepare for OTA update after running check_update.sh
#


[ "${CNPLATFORM}" ] || { logger -s "$0: CNPLATFORM not defined"; exit 1; }

# Some platforms have only one ota part containing ${CONFIGNAME}-update.tgz
case ${CNPLATFORM} in
  silvermoon|falconwing)	TWOPART=0;	;;
  *)				TWOPART=1;	;;
esac

if [ ${TWOPART} = 1 ]
then
  TESTFLAGS="-f /tmp/UPDATE1 -a -f /tmp/UPDATE2"
  PART1MSG="part 1/2 of OTA update"
  TARDIR=/mnt/storage/update
  MKTARDIR=1
else
  TESTFLAGS="-f /tmp/UPDATE1"
  PART1MSG="OTA update"
  TARDIR=/mnt/storage
  MKTARDIR=0
  UPDATE_POSSIBILITIES="${TARDIR}/update.tgz ${TARDIR}/${CONFIGNAME}-update.tgz ${TARDIR}/update.zip ${TARDIR}/${CONFIGNAME}-update.zip"
fi


# Figure out which brand to display
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


# If check_update.sh has run and we pass ${TESTFLAGS}
# but have no /psp/update_prepared, prepare for OTA update
if [ ${TESTFLAGS} -a ! -f /psp/update_prepared ]
then
	logger -s "$0 Preparing for OTA update..."
	if [ ${MKTARDIR} = 1 ]
	then
	  rm -rf ${TARDIR}
	  [ -d ${TARDIR} ] || { echo "Creating update dir..."; mkdir -p ${TARDIR}; }
	else
	  # Remove possible targets used by prepare_updates.sh
	  rm -f ${UPDATE_POSSIBILITIES}
	fi
	switch_fb.sh 0
	imgtool --mode=draw /bitmap/${VIDEO_RES}/downloading_software.bin${BRAND}.jpg
	fbwrite "\n\n\n    Downloading ${PART1MSG}..."
	wget -O - --progressbar --progress=bar:force $(cat /tmp/UPDATE1) | tar x -C ${TARDIR} || { echo "Failed"; imgtool --mode=draw /bitmap/${VIDEO_RES}/update_unsuccessful.bin${BRAND}.jpg; exit 1; }


    # Figure out which filetype we have.
    for file in ${UPDATE_POSSIBILITIES}
    do
        if [ -e ${file} ]
        then
            UPDATE_FILE=${file}
        fi
    done

#	fbwrite "
#
#
#
#	Download completed, verifying integrity of data..."

	if [ "$(cat ${UPDATE_FILE}.md5)" \
        != \
        "$(md5sum ${UPDATE_FILE} | awk '{print $1}')" ]
    then
        logger -s "$0: Data integrity failed"
        fbwrite "\n\n\n\n    Update was corrupt"
        exit 1
    fi

	fbwrite "\n\n\n\n    Starting update process part 1"

	echo "${UPDATE_FILE}" > /psp/update_prepared

	cd /
	sync
else
	logger -s "$0: No OTA update available - did you run check_update.sh ?"
fi
