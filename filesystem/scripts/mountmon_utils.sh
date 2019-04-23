#!/bin/sh
# $Id: mountmon_utils.sh 649 2007-06-04 00:26:23Z henry $
# Utility functions used by mountmon scripts
#

# Get script locations
. script_locations.sh

# Environment-setting functions and required additional variables

idVendor()
{
  [ "${DEVPATH}" ] || return 0
  [ -f /sys${DEVPATH}/device/idVendor ] || return 0
  echo "$(cat /sys/${DEVPATH}/device/idVendor)"
  return 0
}

nameVendor()
{
  [ "${DEVPATH}" ] || return 0
  [ -f /sys${DEVPATH}/device/manufacturer ] || return 0
  echo "$(cat /sys/${DEVPATH}/device/manufacturer)"
  return 0
}

idProduct()
{
  [ "${DEVPATH}" ] || return 0
  [ -f /sys${DEVPATH}/device/idProduct ] || return 0
  echo "$(cat /sys/${DEVPATH}/device/idProduct)"
  return 0
}

nameProduct()
{
  [ "${DEVPATH}" ] || return 0
  [ -f /sys${DEVPATH}/device/product ] || return 0
  echo "$(cat /sys/${DEVPATH}/device/product)"
  return 0
}

nameVersion()
{
  [ "${DEVPATH}" ] || return 0
  [ -f /sys${DEVPATH}/device/version ] || return 0
  echo "$(cat /sys/${DEVPATH}/device/version)"
  return 0
}


export MMS_VENDOR=$(idVendor)
export MMS_PRODUCT=$(idProduct)
export MMS_VENDOR_NAME="$(nameVendor)"
export MMS_PRODUCT_NAME="$(nameProduct)"
export MMS_VERSION="$(nameVersion)"
export MMS_PUID=${MMS_VENDOR}:${MMS_PRODUCT}


# Other functions

# This is deprecated - make sure it's not referenced and remove it
# This should be called assertService
assertDaemon()
{
	DAEMON_PID=$(service_getpid $1)
	[ "${DAEMON_PID}" ] || ${ETC_INIT_DIR}/$1.sh load ${DEVPATH}
}

# This is deprecated - make sure it's not referenced and kill it
# This should be called stopService
stopDaemon()
{
	if [ -x ${ETC_INIT_DIR}/$1.sh ]
	then
		${ETC_INIT_DIR}/$1.sh stop
	else
		killall $1
	fi
}

# Load a kernel module iff not already present
loadKernelModule()
{
	LOAD_PATH=$(dirname $1)
	LOAD_MODULE=$(basename $1)
	# See if it's present
	CHECK_MODULE="$(lsmod | grep ^${LOAD_MODULE})"
	if [ "${CHECK_MODULE}" = "" ]
	then
		echo "# Loading ${LOAD_PATH}/${LOAD_MODULE}.ko"
		insmod ${LOAD_PATH}/${LOAD_MODULE}.ko && echo "# Successfully loaded ${LOAD_MODULE}"
	fi
}
