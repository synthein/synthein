#!/bin/sh
set -e

root_dir=$(pwd)
build_dir=${root_dir}/build
cache_dir=${build_dir}/cache
rust_lib=${root_dir}/src/syntheinrust.so
app_dir=${build_dir}/synthein-${SYNTHEIN_VERSION}.AppDir
build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.AppImage
love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love
fused_binary_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.bin

. "${root_dir}/scripts/util.sh"

if [ ! -f "$love_file" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

mkdir -p "$cache_dir"
rm -rf "$app_dir"

echo "Getting Linux LÖVE binaries."
cd "$cache_dir"

love_appimage=love-${LOVE_VERSION}-x86_64.AppImage
dlcache "https://github.com/love2d/love/releases/download/${LOVE_VERSION}/${love_appimage}"

chmod +x "$love_appimage" && "./$love_appimage" --appimage-extract 2>/dev/null && mv -T squashfs-root "$app_dir"

dlcache "https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x appimagetool-x86_64.AppImage

echo "Building AppImage package."
cd "$app_dir"

cat "${app_dir}/bin/love" "$love_file" > "$fused_binary_file"
chmod +x "$fused_binary_file"
rm "${app_dir}/bin/love"

install -D "$fused_binary_file" bin/synthein
install -D "$rust_lib" lib/lua/5.1/syntheinrust.so
install -D "${root_dir}/package/synthein.desktop" usr/share/applications/synthein.desktop
install -D "${root_dir}/package/synthein.png" usr/share/pixmaps/synthein.png
rm love.desktop .DirIcon
ln -s usr/share/applications/synthein.desktop synthein.desktop
ln -s usr/share/pixmaps/synthein.png synthein.png
ln -s usr/share/pixmaps/synthein.png .DirIcon

"${cache_dir}/appimagetool-x86_64.AppImage" "$app_dir" "$build_file"

echo "Built ${build_file}."
