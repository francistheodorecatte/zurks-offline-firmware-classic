
TARGET=PhotoFrame
VERSION=2.0
ARCHIVENAME=chumby-photoframe
ARCHIVE=$(ARCHIVENAME)-$(VERSION).tar.gz


all: $(TARGET).swf $(TARGET)Config.swf

$(TARGET)Config.swf: build/config.swf conf/config.xml data/btn_okay.png
	swfmill simple conf/config.xml $(TARGET)Config.swf

$(TARGET).swf:  build/classes.swf conf/widget.xml data/banner.png
	swfmill simple conf/widget.xml $(TARGET).swf

build/classes.swf:  $(TARGET).as
	mtasc -swf build/classes.swf -header 800:600:12 $(TARGET).as

build/config.swf: $(TARGET)Config.as
	mtasc -swf build/config.swf -header 800:600:12 $(TARGET)Config.as

$(ARCHIVE): $(TARGET).swf $(TARGET)Config.swf
	tar --exclude=.svn --exclude=$(ARCHIVE) -czvf $(ARCHIVE) ../photoframe

clean:
	rm -f build/* $(TARGET).swf $(TARGET)Config.swf $(ARCHIVE)

release: $(ARCHIVE)

prereqs:
	sudo apt-get install swfmill mtasc
