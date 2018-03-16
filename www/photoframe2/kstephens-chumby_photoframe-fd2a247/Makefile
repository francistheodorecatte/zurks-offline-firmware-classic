all prereqs :
	$(MAKE) -C photoframe $@
	$(MAKE) -C photoframe_usb $@

usb=/dev/null
install-usb :
	$(MAKE) -C photoframe_usb install usb='$(usb)'
