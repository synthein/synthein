#!/bin/sh
set -e

ROOT_DIR=$(pwd)

if [ ! -f "${ROOT_DIR}/build/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting Linux LÖVE binaries."
if [ ! -d "${ROOT_DIR}/build/love-system" ]; then
	mkdir -p "${ROOT_DIR}/build/love-system"
fi
cd "${ROOT_DIR}/build/love-system"

lovebin_pkg="love_${LOVE_VERSION}ppa1_amd64.deb"
lovelib_pkg="liblove0_${LOVE_VERSION}ppa1_amd64.deb"
if [ ! -f "${lovebin_pkg}" ]; then
	curl -L -O "https://bitbucket.org/rude/love/downloads/${lovebin_pkg}"
fi
if [ ! -f "${lovelib_pkg}" ]; then
	curl -L -O "https://bitbucket.org/rude/love/downloads/${lovelib_pkg}"
fi

ar -p love_${LOVE_VERSION}ppa1_amd64.deb data.tar.xz | tar -xJ
ar -p liblove0_${LOVE_VERSION}ppa1_amd64.deb data.tar.xz | tar -xJ

echo "Preparing Synthein for packaging."
cd "${ROOT_DIR}/build"
install -D synthein-${SYNTHEIN_VERSION}.love synthein-system/usr/share/games/synthein/synthein.love
cat > synthein.sh <<END
#!/bin/sh
exec love /usr/share/games/synthein/synthein.love "$@"
END
install -D -m0755 synthein.sh synthein-system/bin/synthein
install -D -m0644 ../package/desktop/synthein.desktop synthein-system/usr/share/applications/synthein.desktop
install -D -m0644 ../package/desktop/icon.png synthein-system/usr/share/pixmaps/icon.png

echo "Building snap package."
cd "${ROOT_DIR}/package"
cp snap/snapcraft.yaml.template snap/snapcraft.yaml
sed -i "s/{{version}}/${SYNTHEIN_VERSION}/" snap/snapcraft.yaml
if [ ${SYNTHEIN_VERSION} = 'devel' ]; then
  sed -i "s/{{grade}}/devel/" snap/snapcraft.yaml
else
  sed -i "s/{{grade}}/stable/" snap/snapcraft.yaml
fi

snapcraft clean
snapcraft snap -o "${ROOT_DIR}/build/synthein_${SYNTHEIN_VERSION}.snap"
