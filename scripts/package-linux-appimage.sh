#!/bin/sh
set -e

root_dir=$(pwd)
build_dir=${root_dir}/build
cache_dir=${build_dir}/cache
build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.AppImage
love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

. "${root_dir}/scripts/util.sh"

if [ ! -f "$love_file" ]; then
	echo "Need to build the .love file first."
	exit 1
fi
if [ ! -d "${cache_dir}" ]; then
	mkdir "${cache_dir}"
fi

echo "Getting Linux LÖVE binaries."
cd "${cache_dir}"

love_tar=love-${LOVE_VERSION}-linux-x86_64.tar.gz
dlcache "https://github.com/love2d/love/releases/download/${LOVE_VERSION}/${love_tar}"

extracted_love_tar=${cache_dir}/love-${LOVE_VERSION}-x86_64
[ -d "$extracted_love_tar" ] && rm -r "$extracted_love_tar"
tar -xzf "$love_tar" && mv -T dest "$extracted_love_tar"

echo "Building AppImage package."
cd "${cache_dir}"
dlcache "https://github.com/probonopd/AppImageKit/releases/download/continuous/AppRun-x86_64"

if [ -d "${build_dir}/synthein-appimage" ]; then
	rm -r "${build_dir}/synthein-appimage"
fi
mkdir "${build_dir}/synthein-appimage"
cd "${build_dir}/synthein-appimage"

# Install Synthein.
install -D -m0755 "${cache_dir}/AppRun-x86_64" AppRun
install -D -m0755 "${root_dir}/package/synthein.appimage.sh" usr/bin/synthein
install -D "$love_file" usr/share/synthein/synthein.love
install -D "${root_dir}/package/synthein.desktop" usr/share/applications/synthein.desktop
install -D "${root_dir}/package/synthein.png" usr/share/pixmaps/synthein.png
ln -s usr/share/applications/synthein.desktop synthein.desktop
ln -s usr/share/pixmaps/synthein.png synthein.png

# Install LOVE.
install -D -m0755 "${extracted_love_tar}/usr/bin/love" usr/bin/love
install -d usr/lib
cp -r "${extracted_love_tar}/usr/lib/"* usr/lib
install -D "${extracted_love_tar}/license.txt" usr/share/doc/love

# Package as an AppImage.
cd "${cache_dir}"
dlcache "https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage

./appimagetool-x86_64.AppImage --appimage-extract 2> /dev/null
./squashfs-root/AppRun "${build_dir}/synthein-appimage/" "${build_file}"

# Clean up.
rm -r "$extracted_love_tar"
rm -r "${cache_dir}/squashfs-root"
rm -r "${build_dir}/synthein-appimage"

echo "Built ${build_file}."
