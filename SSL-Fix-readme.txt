SSL fix for Chumby - release beta 3.0.0 uni - 20 Oct 2017 - by francesco
-------------------------------------------------------------------------------
0.0 Introduction and Disclaimer

This software fixes an issue of the Chumby One which makes impossibile to connect to some
servers via a secure channel (SSL).
It has been designed and tested on the Chumby One device running FW 1.0.3454 SW 1.0.7.
(from the Settings > Info screen)

This software comes with no warranty. 
The authors, developers, packagers, distributors and anyone else cannot be held responsible 
for any damage it may cause.
Use it at your own risk.

-------------------------------------------------------------------------------
1.0 Release notes

Third release V3.0.0

This has been released in two flavours:
- normal is for the Chumby ONE (SSL-Fix-V3.zip)
- universal is for the other Chumbies (SSL-Fix-V3-uni.zip)

The universal version will work on the Chumby One too, but is meant for those 
who have a different device and still want to try out the fix.

Before installation it is recommended to run test-sslfix in order to verify 
the compatibility of the unit. 

To replace a V3 for the ONE with the universal (and back), first run restore 
then install (see below 'Installation procedure').

Ouptput from curl -V

  curl 7.46.0 (arm-none-linux-gnueabi) libcurl/7.46.0 mbedTLS/2.1.9 zlib/1.2.3
  Protocols: dict file ftp ftps http https tftp
  Features: AsynchDNS Largefile SSL libz

List of files
  README
  _debugchumby
  _restore.flg
  install.flg
  install.sh
  readme.txt

  src/curl-ca-bundle.crt
  src/curl
  src/libcurl.so.4.4.0


Second release V2.0.0
Ouptput from curl -V

  curl 7.30.0 (arm-none-linux-gnueabi) libcurl/7.30.0 OpenSSL/1.0.2l zlib/1.2.3
  Protocols: dict file ftp ftps http https tftp
  Features: AsynchDNS Largefile NTLM SSL libz

List of files
  README
  _debugchumby
  _restore.flg
  install.flg
  install.sh
  readme.txt

  src/curl-ca-bundle.crt
  src/curl
  src/libcurl.so.4.3.0


First release V0.9.0.
Output from curl -V

curl 7.16.2 (arm-none-linux-gnueabi) libcurl/7.16.2 OpenSSL/1.0.0s zlib/1.2.3 c-ares/1.3.2
Protocols: tftp ftp dict http file https ftps 
Features: AsynchDNS NTLM SSL libz 

List of files 
 README
 curl
 curl-ca-bundle.crt
 libcurl.so.4.0.0
 readme.txt

Note: readme.txt is for Windows, uppercase readme is for Unix

-------------------------------------------------------------------------------
2.0 Install procedure

This has been tested on a Chumby One. Behaviour on other devices is unknown.

There is now an automated procedure to install the update. Manual is still possible
and is briefly detailed below.


2.1 Automated procedure   -----------------------------------------------------

Expand the archive and put all the files and directories in the root of an USB key.

Rename the file _debugchumby to debugchumby (remove the underscore).

Insert the key in a switched off Chumby, start it and wait.
After a while the widgets should appear as they usually do. Let them run for a while.
Then turn the Chumby off, and take a look at the content of the key. 

There should be a file named
  install.log
where all the info on what happened during the update is available. 
If everything went right there should be something like:

  Installing V3
  Installation successfull.
  Installation of V3 successfull
  Test of V3 successfull
  curl 7.46.0 (arm-none-linux-gnueabi) libcurl/7.46.0 mbedTLS/2.1.9 zlib/1.2.3
  Protocols: dict file ftp ftps http https tftp
  Features: AsynchDNS Largefile SSL libz
  Installer finished

Alternatively it is possible to use SSH to connect to the Chumby and read the log
without having to turn off the device. The installer always starts SSHD. 
It's also important to remove the key and restart the Chumby, when the update procedure
is over.

If something goes wrong the log will contain:
  "Installation failed"
and/or 
  "Error while installing, installation incomplete. Run restore"
In these cases a restore is much needed.

When there's a need to restore the original setup, make sure these files are on the key:
  _install.flg
  restore.flg
(just rename install.flg and _restore.flg)
insert the key in the Chumby and turn it on.
The log file will tell whether the original setup is restored or not.
For instance:

  Recovering original installation
  Restore successfull
  Uninstall successfull
  Installer finished

During install, the install.flg is always renamed to _install.flg to avoid a double install 
on a rebooting device. To use the usb key again just rename it to install.flg.

If the installation fails, restore.flg is automatically activated. By restarting the Chumby, 
the original files will be restored.



2.2 Semi manual procedure -----------------------------------------------------

Much like the previous version it is possible to manually install the update, but 
there's a script to make things snappier.

First unpack the archive and store all the files on an usb key.
Turn off the chumby, insert the key and turn it on.

Connect to the chumby using SSH on linux or putty on windows.

Stop the control panel

  stop_control_panel

and remount the file system as read/write

  mount -o remount,rw /

Change directory to /usr/mnt and launch the installer

  cd /usr/mnt
  ./install.sh

This will only analyze the setup and tell whether an update is possible or not.
This will be the case only if:
* it's the original
or
* it's V1 or V2 

To actually install, run
  ./install.sh -i

To restore the original setup, run:
  ./install.sh -r

If everything went fine make the file system read only again

  mount -o remount,ro /
  
To verify whether the new library is correctly installed, print the openSSL version:

  curl -V

  curl 7.46.0 (arm-none-linux-gnueabi) libcurl/7.46.0 mbedTLS/2.1.9 zlib/1.2.3
  Protocols: dict file ftp ftps http https tftp
  Features: AsynchDNS Largefile SSL libz

OpenSSL has disappeared and mbdTLS takes its place. 
Version should be should be 2.1.9  and Curl version should be 7.46.0.
The xkcd rss feed can be used to check an https URL:

   curl https://xkcd.com/rss.xml

will print the rss feed, this time very quickly.

Restart the control panel

  start_control_panel

Before cheering and dancing and rebooting, make sure everything works fine. 
Let it run for a few minutes (even half an hour) and verify that https actually works 
(for instance by running the xkcd widget...)

Old files can be removed, but the install script will not work anymore.


-------------------------------------------------------------------------------
3.0 Brief technical description

Version 3 addresses perfomance issues associated with OpenSSL. 
Basically OpenSSL has been dropped and mbedTLS is the new SSL library for libcurl.
This library is widely used in the embedded devices, especially the ESP8266 and ESP32.
Version has been selected from a branch that is still updated and provides a more
relaxed license (Apache). As a result licurl had to be upgraded to 7.46, the first
relase that supports mbedTLS without having to patch the code.
libcurl is now lbcurl.so.4.4.0

Earlier version of the SSL library (then called PolarSSL) did work too but since
they were abandoned (1.2), very abandoned (1.1) or about to be abandoned (1.3) 
their long term safety and robustness was in doubt. 

Result is a much faster curl/curlib and smaller footprint: 700KB vs.over 2MB


In version 2 the issue of failing SSLv3 negotiations was addressed by switching to a 
newer version of curl-libcurl, namely version 7.30.0. 
OpenSSL was updated to 1.0.2l, in order to provide the latest supported version in the 
1.0.2 tree. Moving to 1.1.0 would require a version of Curl released after December 2014,
which would likely require support of libcurl.so.5, a not so simple task on the Chumby.

As in version 1,  OpenSSL it is statically linked to libcurl (hence its hefty size) 
while the new libcurl (libcurl.so.4.3.0) seems to be well supported by the system.

The other trick is the certificate store, which was updated to the lastest version. 
This ensures that all the certificates can be succesfully verified. Further information is 
available at:
https://curl.haxx.se/docs/caextract.html
This file should also be updated every year or so.

Note: cacert.pem was renamed to curl-ca-bundle.crt
 

-------------------------------------------------------------------------------
4.0 Known issues

Size of binaries did increase but getting a recent version of OpenSSL mostly fixed 
initial speed issues. Solved in V3

The "SSL3 session failed" bug has been solved.

Slow: perfomance decisively improved in V3

