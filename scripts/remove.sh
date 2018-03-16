#!/bin/sh
# $Id: remove.sh 8275 2009-02-26 23:53:26Z scross $
# remove event script for mountmon
#
# See mountmon.conf for list of environment variables available on input
# and required output values
#

# Unmount forcibly - there's no way to be nice about it, since the device has
# already been removed... If the unmount succeeds, a umount event will be sent
RESULT=0
MESSAGE=
DBGOUT=/dev/null
[ "${DAEMON_LOGDIR}" != "" ] && DBGOUT=${DAEMON_LOGDIR}/remove.$$

SCRIPT_VER='$Rev: 8275 $'
echo "# Starting $0 version ${SCRIPT_VER}"

# Get MMS_PUID and other useful stuff based on DEVPATH
. mountmon_utils.sh

# Invoke daemon scripts with provisional unload
SVC_LIST=$(service_list)
if [ "${SVC_LIST}" != "_no_services_found_" ]
then
	for svc in ${SVC_LIST}
	do
	  # Stop daemon iff it was loaded with the same devpath
	  service_control ${svc} unload ${DEVPATH} >>${DBGOUT} 2>&1
	done
fi

USBCAM_DIR=/psp
USB_VENDOR=`echo $PRODUCT | cut -d'/' -f1`
USB_PRODUCT=`echo $PRODUCT | cut -d'/' -f2`
# zero-pad the product and vendor
while [ `echo -n $USB_VENDOR | wc -c` -lt 4 ]
do
	USB_VENDOR="0$USB_VENDOR"
done
while [ `echo -n $USB_PRODUCT | wc -c` -lt 4 ]
do
	USB_PRODUCT="0$USB_PRODUCT"
done

CAMERAS=`grep "^${USB_VENDOR}:${USB_PRODUCT}" ${USBCAM_DIR}/cameras*.moddef`
if [ $? -eq 0 ] && [ `echo "$CAMERAS" | wc -l` -gt 0 ] && [ `mount | grep '/mnt/camera' | wc -l` -gt 0 ]
then
	echo "# unmounting camera"
	/usr/chumby/scripts/signal_usb_event.sh unmount /mnt/camera
	umount /mnt/camera
fi


if [ "${MM_CURRENT_MOUNTPOINT}" != "" ]
then
  if [ "${MM_VERBOSE}" = "1" ]
  then
    set >/tmp/mountmon.remove.$$
  fi
  echo "# attempting unmount of ${MM_CURRENT_MOUNTPOINT}"
  echo "UMOUNT=${MM_CURRENT_MOUNTPOINT}"
  MESSAGE="Unmounting ${MM_CURRENT_MOUNTPOINT}: $(umount -f ${MM_CURRENT_MOUNTPOINT})" || RESULT=1
  

  # Attempt signalling flashplayer regardless of whether umount succeeded
  /usr/chumby/scripts/signal_usb_event.sh unmount ${MM_CURRENT_MOUNTPOINT}
  
# SMC 26-02-2009 - The control panel shouldn't know about the symlinked
#                  directories anymore, and this is causing a race
#                  condition in which the FP is dying, so we'll not notify
#                  the FP that the symlink is going away as well as the
#                  real mountpoint.
#  # Also see if there's a symlink, and notify FP that that symlink
#  # is going away, too.
#  SYMLINK=`ls -l /mnt | grep " ${MM_CURRENT_MOUNTPOINT}$" | cut -d'>' -f1 | tr ' ' '\n' | grep usb`
#  if [ "x${SYMLINK}" != "x" -a -L /mnt/$SYMLINK ]
#  then
#    /usr/chumby/scripts/signal_usb_event.sh unmount /mnt/${SYMLINK}
#  fi
  
  # Fire off a script to continuously attempt umount a device.
  (/usr/chumby/scripts/umount_repeated.sh "${MM_CURRENT_MOUNTPOINT}" &)
  
fi

echo "RESULT=${RESULT}"
echo "MESSAGE=${MESSAGE}"

return 0

