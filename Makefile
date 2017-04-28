SYNTHEIN_VERSION=devel
LOVE_VERSION=0.10.2

all: love linux mac windows

love:
	scripts/package-love.sh

linux:
	scripts/package-linux-appimage.sh

mac: love
	scripts/package-mac.sh

windows: love
	scripts/package-windows.sh

clean:
	rm -rf build/

.PHONY: clean
