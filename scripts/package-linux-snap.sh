#!/bin/sh
set -e

ROOT_DIR=$(pwd)

if [ ! -f "${ROOT_DIR}/build/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

cd "${ROOT_DIR}/build"

echo "Preparing Synthein for packaging."
install -D synthein-${SYNTHEIN_VERSION}.love synthein-system/usr/share/games/synthein/synthein.love
cat > synthein.sh <<END
#!/bin/sh
exec love /usr/share/games/synthein/synthein.love "$@"
END
install -D -m0755 synthein.sh synthein-system/bin/synthein
install -D -m0644 ../package/desktop/synthein.desktop synthein-system/usr/share/applications/synthein.desktop
install -D -m0644 ../package/desktop/synthein.png synthein-system/usr/share/pixmaps/synthein.png

echo "Building snap package."
cd "${ROOT_DIR}/package"
cp snap/snapcraft.yaml.template snap/snapcraft.yaml
sed -i "s/{{version}}/${SYNTHEIN_VERSION}/" snap/snapcraft.yaml
sed -i "s/{{love_version}}/${LOVE_VERSION}/" snap/snapcraft.yaml
if [ ${SYNTHEIN_VERSION} = 'devel' ]; then
  sed -i "s/{{grade}}/devel/" snap/snapcraft.yaml
else
  sed -i "s/{{grade}}/stable/" snap/snapcraft.yaml
fi

snapcraft clean
snapcraft snap -o "${ROOT_DIR}/build/synthein_${SYNTHEIN_VERSION}.snap"
