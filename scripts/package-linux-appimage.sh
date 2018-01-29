#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"
build_file="${build_dir}/synthein-${SYNTHEIN_VERSION}.AppImage"

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting Linux LÖVE binaries."
cd "${build_dir}"
curl -L -O "https://bitbucket.org/rude/love/downloads/love_${LOVE_VERSION}ppa1_amd64.deb"
curl -L -O "https://bitbucket.org/rude/love/downloads/liblove0_${LOVE_VERSION}ppa1_amd64.deb"
dpkg --install love_*ppa1_amd64.deb liblove0_*ppa1_amd64.deb || apt-get -yf install

echo "Building AppImage package."
echo $SYNTHEIN_VERSION > SYNTHEIN_VERSION
cat /usr/bin/love synthein-${SYNTHEIN_VERSION}.love > synthein-linux.bin
chmod +x synthein-linux.bin

if [ -d "${build_dir}/synthein-appimage" ]; then
	rm -r "${build_dir}/synthein-appimage"
fi

mkdir "${build_dir}/synthein-appimage"
cd "${build_dir}/synthein-appimage"
install -D ../VERSION usr/share/doc/synthein/VERSION
install -D /usr/lib/x86_64-linux-gnu/liblove.so.0 usr/lib/liblove.so.0
install -D /usr/lib/x86_64-linux-gnu/liblove.so.0.0.0 usr/lib/liblove.so.0.0.0
install -D /usr/bin/love usr/bin/love
install -D ../synthein-linux.bin usr/bin/synthein
install -d usr/share/doc/love
install -t usr/share/doc/love /usr/share/doc/love/copyright /usr/share/doc/love/readme.md

cd "${build_dir}"
curl -L -O "https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage ./synthein-appimage/ "${build_file}"

echo "Built ${build_file}."
