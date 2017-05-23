env = SYNTHEIN_VERSION=devel LOVE_VERSION=0.10.2

all: love mac windows

love:
	${env} scripts/package-love.sh

appimage: love
	${env} scripts/package-linux-appimage.sh

mac: love
	${env} scripts/package-mac.sh

windows: love
	${env} scripts/package-windows.sh

clean:
	rm -rf build/

.PHONY: clean
