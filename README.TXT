Zurk's Offline Firmware 


  v 21 . 0


License
-------

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program in the file LICENSE.TXT.  If not, see <http://www.gnu.org/licenses/>.
Copyright (C) 2012 Free Software Foundation, Inc. All rights reserved. 


Which Firmware ?
----------------

For the chumby classic : 
http://sourceforge.net/projects/zurk/files/zurk_chumby_classic.zip/download 


Usage
-----

NOTE: If you have NOT updated your Chumby using my custom firmware with fpalab's Chumby SSL Fix v3, see ssl-fix-update.txt FIRST!! 

Unzip to a blank USB thumbdrive (FAT32 formatted, 512MB or greater, root folder, make sure you keep directory structure) - power off your activated, networked, functional chumby - insert thumbdrive - power on.
You will need to change the control panel time to your correct location after bootup. Also change the brightness and sound to your preference. 
Ensure your chumby is activated, on the network and fully operational with the latest firmware (classic - v1.7.1 or c1/i3.5 - v1.0.7 or c8/i8 - v1.8.2) prior to using the offline firmware. 
Although you do not need to activate your chumby and can run this offline firmware completely without a network, for a first time installation both network and activated chumby are recommended to make life simple. For operating in network-less environments please delete the file autoreboot.on from the usb disk root. 


Help
----

Forums are available at : 

https://sourceforge.net/p/zurk/discussion/12064/

Feel free to discuss any topics as required. The chumby forums may provide more general help but they may not be available for much longer. 


Chumote!
--------

The Chumote! infrastructure has been provided in a very limited way with this release. Simply point your web browser to your chumby's ip address and you should see the new infrastructure pop up. You can now see the contents of the chumby screen and set a few parameters as well as start ssh. For insecure networks ensure you set a ssh password with "passwd root" once you ssh into the chumby. 


Music 
-----

Note that chumby music infrastructure has been **REMOVED** from the offline firmware including PANDORA. You may restore chumby infrastructure and PANDORA by completing the following procedure : After booting the chumby using the offline firmware use a web browser ( firefox/chrome/IE/safari etc ) and go to http://ip.address.of.your.chumby (You can find the IP Address in the control panel -> Settings -> Device info under ip: - The 192.168.xxx.xxx is your chumby ip address ). Your chumby is automatically converted into a webserver with a web-based control and information page loaded when you boot up the offline firmware. You will see a webpage with links. Simply click the link to select chumby.com online infrastructure and pandora will be enabled. You can also disable it and run off the offline firmware provided music infrastructure by selecting the second link. You cannot run the offline firmware music infrastructure at the same time as the chumby provided music infrastructure. 


DLNA / UPnP Infrastructure
--------------------------

The file dlna.on must be deleted to disable DLNA support. By default it is enabled and can be controlled from the web control panel. Use a javascript enabled web browser to browse http://ip.address.of.chumby/dlna to access the DLNA / UPnP control panel.
Note that on first boot DLNA will NOT be available until approximately 1 hour has passed. You can check the status of DLNA by using the web control panel. 
DLNA can be used with any UPnP or DLNA music server or device. An open source cross-platform server such as MediaTomb is recommended. 


Customization - Widgets/Weather
-------------------------------

You can customize the widgets or add more widgets by reading the FAQ/forums to get the correct weather for your location. Weather support is for the entire planet using wunderground and accuweather. 
Complete remote control command set is available at http://ip.address.of.your.chumby/

Profiles for the Infocast 3.5 / Chumby One / Chumby Classic are located in : /lighty/html/xml/profiles/profiles0 (or profiles1 for next channel)
You must type the following command on the chumby after you edit profiles on there directly : sync

Profiles for the Infocast 8 / Chumby Eight are located in : /lighty/html/xapis/profile/show/0 (or 1 for next channel)
You must type the following command on the chumby after you edit profiles on there directly : sync

You must edit the following file to set correct weather for your region : /psp/zwapi.sh and the profile file as noted above
You must type the following command on the chumby after you edit the weather zwapi.sh file or profiles on there directly : sync
Special note : For widgets which use a zipcode of ZZ, leave the zipcode field alone and modify zwapi.sh to set the correct location. Do NOT modify the zipcode of ZZ. 
For widgets which load weather directly (i.e. not relying on the built in weather the firmware provides -- such as the WUnderground graph widget or Accuweather) you have to edit the widget parameters with the name of your city/zipcode in the widget profiles as well. 

Weather updates are hourly. Wait up to 1 hour before assuming something has gone wrong with your changes. 

Delete the file autoreboot.on to stop automatic rebooting of the chumby on loss of network and to switch to pure offline mode.

If you edit these files on a PC you must eject the usb disk properly through an eject command or equivalent after saving changes. Use the web based control panel to sync by clicking the sync link instead of a command line sync if you are unfamiliar with it. 


Customization - Music
---------------------

Firmwares now have a common music infrastructure built-in. You can customize the music by editing the folder : lighty/html/chumcast/list
and create the corresponding xshow file with a list of your music. This will modify the blueocty radio

You can customize the podcasts by editing the lighty/html/podcast folder.

You must type the following command on the chumby after you edit music on there directly : sync


Note 
----

Once you have changed any settings to your liking, prior to putting the chumby into actual use, ensure you sync and reboot it at least once.


Guide
-----

An offline firmware guide has been included in this package. Please see docs/ChumbyWidgetGuide.pdf by amigafin. 
New versions will be available at : http://sourceforge.net/projects/chumby/files/


Changelog
---------
v21- Minor search engine fix for c1. Added PNG animation support for replacing GIF animation support which has transparency problems (black background) with certain animated GIFs. 
v20- Added working BBC World Vintage Edition as a temporary replacement to broken reuters news (reuters spotlight API failed). Thumbnail/profile cleanup. Lightboxes for web control panel. Chumby widgetcache bugfix for cached animated gifs.
v19- Tom Higgins Chumote (alpha) integration, dannysland podcasts. Shoutcast search engine. Cleanup of music for stub server integration. Doppler radar/animated GIF support. Remove broken LOLCats :( - replace with Flickr stream. 
v18- Preliminary fix for long term crash bug in all chumbies. Python, PHP & Perl cgi support added to built-in web server. 
v17- DLNA / UPnP Support & Perl 5.10. Random shuffler, egg timer. Zen Garden theme for the web control panel. 
v16- Cleanup, small music bugfix. 
v15- Added multiple profile infrastructure with two profiles. Can support any number of profiles. 
v14- Removed all chumby music infrastructure, restored NYT PodCasts, CBS PodCasts, fixed broken blueocty links.
v13- Added a selection of docs and customization guide to the docs folder.
v12- Bugfix for chumbies with broken network hardware.  
v11- Added periodic event recorder i.e. blackbox in case of hangs, dmesg script, better memory data, LOLcats. 
v10- Patched chumby1 fw to include the chumby classic and improved network detection updates, fixed english calendar, extra network checks/failsafes
v9 - added messaging API, now display a message on your chumby simply by going to http://ip.of.chumby/cgi-bin/message.sh?whatever
v8 - more weather api tweaks, replace c1 german cal with eng
v7 - fix images, java, speech engine, weather api (edit psp/zwapi.sh with your city and country code)
v6 - added rapidfire, long term cleanup, clock overlay on c1
v5 - removed http cache, installed adblock
v4 - add stuff 
v3 - corrected ntp drift on c8
v2 - corrected sound
v1 - init release
-
Zurk's Offline Firmware
