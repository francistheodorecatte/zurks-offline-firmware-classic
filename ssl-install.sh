#!/bin/sh
#------------------------------------------------------------------------------
# SSL fix installer - by fantogni
# V3.0 - Installs V3 binaries
#
# Usage:
#   ./install.sh
#     reports installation status
#
#   ./install [-i|-r]
#     -i: installs curl and libcurl
#     -r: restores original installation
#
# Notes:
# Non recoverable, non original >> nothing we can do >> install will do nothing
# Recoverable, non original >> maybe it's a broken update >> can only recover
# Original (implies non recoverable) >> we can install
# V1 (implies recoverable) >> we can upgrade
# V2 (implies recoverable) >> we can upgrade
# 
# To reapply an install, first run recover then install
#------------------------------------------------------------------------------
# Copyright Notice
# This software is free to modify and reuse.
# If you find it useful, please give credits in your code to the original author.
#
# -----------------------------------------------------------------------------

SRC="/mnt/usb/src"
LIB="/lib"
BIN="/usr/bin"
CERT="/usr/share/certs/"

INST=''
INST_1='F'
INST_2='F'
INST_3='F'
INST_R='F'
INST_P='P'          #Partially recoverable
INST_O='F'
LIBCURL=''

LIBCURL_VO="libcurl.so.4.0.0"
LIBCURL_SL="libcurl.so"
LIBCURL_SL4="libcurl.so.4"
LIBCURL_V1="${LIBCURL_VO}"
LIBCURL_V2="libcurl.so.4.3.0"
LIBCURL_V3="libcurl.so.4.4.0"
BINCURL="curl"
CERTS="curl-ca-bundle.crt"


OPENSSL_VO="OpenSSL/0.9.7p"
OPENSSL_V1="OpenSSL/1.0.0s"
OPENSSL_V2="OpenSSL/1.0.2l"
SSL_V3="mbedTLS/2.1.9"

LIBCURL_BKP="${LIBCURL_V1}_bkp"
BINCURL_BKP="${BINCURL}_bkp"
CERTS_BKP="${CERTS}_bkp"

case $1 in
  '-?'|--help)
    echo "Usage: $0 [-c|-i|-r]"
	echo "    : checks installation"
    echo "  -?|--help: this help screen"
    echo "  -c: checks installation (same as no option)"
    echo "  -i: install"
    echo "  -r: recover original installation"
    exit ;;

  -i)
#    echo "I will install!"
    INST="I"
    ;;

  -r)
#    echo "I will uninstall!"
    INST="U"
    ;;

  -c|'')
    ;;
 *)
    echo "Unrecognized option $1"
    exit                         
esac                             
                                                                  
checkSymLink() {                 
  if ( ls -l $1 | grep -q $2 ) ; then
    return 0                      
  fi                              
  return 1                        
}

echoSymLinkRef() {
  ex="s#^.+$1 [^ ]+ (.+)\$#\1# p"
  ls -l "$1"|sed -nr "$ex"
}

checkCurlSSL() {
  ossl=$( curl -V | sed -nr 's/^.+(mbedTLS\/[0-9\.]+).+$/\1/ p;')
  if [ "$ossl" == "$1" ] ; then
    return 0;
  fi
  return 1
}

# checkFSWritable() {
  # rt=$( mount |sed -nr  's#^/dev/root.+\(([a-z]+)\,.+$#\1# p' )
  # if [ "$rt" = "rw" ] ; then exit 0 ; fi
  # exit 1
# }

          
backupOri() {
  if ( mv "${LIB}/$LIBCURL_VO" "${LIB}/$LIBCURL_BKP" ) && \
     ( mv "${BIN}/$BINCURL" "${BIN}/$BINCURL_BKP" ) && \
     ( mv "${CERT}/$CERTS" "${CERT}/$CERTS_BKP" ) ; then
    return 0
  fi
  return 1
  #manca CA store 
}

installV3() { 
  if ( backupOri ) && \
     ( cp -p "${SRC}/${LIBCURL_V3}" "${LIB}" ) && \
     ( cp -p "${SRC}/${BINCURL}" "${BIN}" ) && \
     ( cp -p "${SRC}/${CERTS}" "${CERT}" ) && \
     ( rm "${LIB}/$LIBCURL_SL" ) && \
     ( rm "${LIB}/$LIBCURL_SL4" ) && \
	 ( ln -s "${LIBCURL_V3}" "${LIB}/$LIBCURL_SL" ) && \
	 ( ln -s "${LIBCURL_V3}" "${LIB}/$LIBCURL_SL4" )
  then
    echo "Installation successfull."
	return 0
  fi
  echo "Installation failed."
  return 1
}

upgradeV3fromV() {
  if ( cp -p "${SRC}/${LIBCURL_V3}" "${LIB}" ) && \
     ( cp -p "${SRC}/${BINCURL}" "${BIN}" ) && \
     ( rm "${LIB}/$LIBCURL_SL" ) && \
     ( rm "${LIB}/$LIBCURL_SL4" ) && \
	 ( ln -s "${LIBCURL_V3}" "${LIB}/$LIBCURL_SL" ) && \
	 ( ln -s "${LIBCURL_V3}" "${LIB}/$LIBCURL_SL4" )
  then
    ( rm -f "${LIB}/$LIBCURL_V1" ; rm -f "${LIB}/$LIBCURL_V2" ) 
    echo "Installation successfull."
	return 0
  fi
  echo "Installation failed. Run recover: ./install.sh -r"
  return 1
}


recoverVx() {
  if ( mv -f "${LIB}/$LIBCURL_BKP" "${LIB}/$LIBCURL_VO" ) && \
     ( mv -f "${BIN}/$BINCURL_BKP" "${BIN}/$BINCURL" ) && \
     ( rm -f "${LIB}/$LIBCURL_SL" ) && \
     ( rm -f "${LIB}/$LIBCURL_SL4" ) && \
	 ( ln -s "${LIBCURL_VO}" "${LIB}/$LIBCURL_SL" ) && \
	 ( ln -s "${LIBCURL_VO}" "${LIB}/$LIBCURL_SL4" ) && \
     ( rm -f "${LIB}/$LIBCURL_V2" ; rm -f "${LIB}/$LIBCURL_V3" ) && \
     ( mv "${CERT}/$CERTS_BKP" "${CERT}/$CERTS" )
  then
    echo "Restore successfull"
	return 0
  fi
  return 1

}

testV3() {
  if ( curl "https://www.wsj.com/xmll/rss/3_7084.xml" 1>/dev/null 2>&1 ) ; then
    echo "Test of V3 successfull"
    return 0;
  fi
  echo "Test of V3 failed: unable to load secured content"
  return 1;
}
		  
echo "Checking installation"

# Check if it's recoverable
if [ -e "${BIN}/${BINCURL_BKP}" ] && \
   [ -e "${LIB}/${LIBCURL_BKP}" ] && \
   [ -e "${CERT}/${CERTS_BKP}" ] 
then
  INST_R='T'
  INST_P='T'
  echo "Recoverable installation"
else
  if [ -e "${LIB}/$LIBCURL_BKP" ] ; then
    echo "Partially recoverable installation"
    INST_P="T"
  else
    echo "Not recoverable installation"
  fi
fi

#Check if it's the original setup 
if ( checkSymLink "${LIB}/${LIBCURL_SL}"  "${LIBCURL_VO}" ) && \
   ( checkSymLink "${LIB}/${LIBCURL_SL4}" "${LIBCURL_VO}" ) && \
   [ -e "${BIN}/${BINCURL}" ] && \
   [ -e "${LIB}/${LIBCURL_VO}" ] && \
   ! [ -e "${BIN}/${BINCURL_BKP}" ] && \
   ! [ -e "${LIB}/${LIBCURL_BKP}" ] && \
   ! [ -e "${LIB}/${LIBCURL_V2}" ] &&\
   ! [ -e "${LIB}/${LIBCURL_V3}" ]
then
  echo "Original installation"
  INST_O='T'
fi

#Check whether it's Version 1
if ( checkSymLink "${LIB}/${LIBCURL_SL}" "$LIBCURL_V1" ) && \
   ( checkSymLink "${LIB}/${LIBCURL_SL4}" "$LIBCURL_V1" ) && \
   [ -e "${BIN}/${BINCURL}" ] && \
   [ -e "${BIN}/${BINCURL_BKP}" ] && \
   [ -e "${LIB}/$LIBCURL_V1" ] && \
   [ -e "${LIB}/$LIBCURL_BKP" ] && \
   [ -e "${CERT}/${CERTS}" ]&& \
   [ -e "${CERT}/${CERTS_BKP}" ] 
then
  echo "V1 installed"
  INST_1='T'
else                             
  echo "V1 not installed"                   
fi

#Check whether it's Version 2
if ( checkSymLink "${LIB}/${LIBCURL_SL}" "$LIBCURL_V2" ) && \
   ( checkSymLink "${LIB}/${LIBCURL_SL4}" "$LIBCURL_V2" ) && \
   [ -e "${BIN}/${BINCURL}" ] && \
   [ -e "${LIB}/$LIBCURL_V2" ] && \
   [  "${INST_R}" = "T" ]
then
  echo "V2 installed"
  INST_2='T'
else                             
  echo "V2 not installed"                   
fi

#Check whether it's Version 3
if ( checkSymLink "${LIB}/${LIBCURL_SL}" "$LIBCURL_V3" ) && \
   ( checkSymLink "${LIB}/${LIBCURL_SL4}" "$LIBCURL_V3" ) && \
   [ -e "${BIN}/${BINCURL}" ] && \
   [ -e "${LIB}/$LIBCURL_V3" ] && \
   [  "${INST_R}" = "T" ]
then
  echo "V3 installed"
  INST_3='T'
else                             
  echo "V3 not installed"                   
fi

#This is confusing: was useful during beta testing now I don't know
#if [ "$INST_1$INST_2" == "TT" ] ; then
#  echo "mixed installation, recoverable"
#fi

if checkCurlSSL $SSL_V3 ; then
  echo "mbedtls (already) updated to V3"
fi

if [ "$INST" = "I" ] ; then
  res=""
  if [ "$INST_O" = "T" ] ; then
    echo "Installing V3"
    if ( installV3 ) ; then
	  res="S"
	else
	  res="F"
	fi
  elif 	[ "${INST_1}${INST_2}${INST_3}" = "TFF" ] ||\
		[ "${INST_1}${INST_2}${INST_3}" = "FTF" ]  ; then
    echo "Upgrading V1/V2 to V3"
    if ( upgradeV3fromV ) ; then
	  res="S"
	else
	  res="F"
    fi
	## Here goes any V3 Update 
	## (upgrade: changes libcurl version | update: keeps libcurl version)
  fi 
  if [ "$res" = "S" ] ; then 
    echo "Installation of V3 successfull"
    if ( testV3 ) ; then
      curl -V
	  exit 0
	else
	  echo "Test of V3 failed, running restore is strongly recommended.".
	  exit 1
	fi
  elif [ "$res" = "F" ] ; then
    echo "Error while installing, installation incomplete. Run restore"
	exit 1
  fi
fi

if [ "$INST_P" = "T" -a "$INST" = "U" ] ; then
  echo "Recovering original installation"
  if recoverVx ; then
    echo "Uninstall successfull"
	exit 0
  else
    echo "Error while recovering, original setup might not have been restored."
  fi
fi
if ! [ -z $INST ] ; then 
  echo "Unable to perform install/recover command"
fi
