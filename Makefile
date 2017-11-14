synthein_version = devel
love_version = 0.10.2

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

love: build/synthein-$(synthein_version).love

build/synthein-$(synthein_version).love: src
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

mac: love
	$(env) scripts/package-mac.sh

snap: love
	$(env) scripts/package-linux-snap.sh

windows: love
	$(env) scripts/package-windows.sh

clean:
	rm -rf build/

.PHONY: all appimage clean love mac snap windows
