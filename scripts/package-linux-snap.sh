#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

cd "${build_dir}"

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
cd "${root_dir}/package"
cp snap/snapcraft.yaml.template snap/snapcraft.yaml
sed -i "s/{{version}}/${SYNTHEIN_VERSION}/" snap/snapcraft.yaml
sed -i "s/{{love_version}}/${LOVE_VERSION}/" snap/snapcraft.yaml
if [ ${SYNTHEIN_VERSION} = 'devel' ]; then
  sed -i "s/{{grade}}/devel/" snap/snapcraft.yaml
else
  sed -i "s/{{grade}}/stable/" snap/snapcraft.yaml
fi

snapcraft clean
snapcraft snap -o "${build_dir}/synthein_${SYNTHEIN_VERSION}.snap"
