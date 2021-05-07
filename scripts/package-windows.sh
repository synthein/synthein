#!/bin/sh
set -e

root_dir=$(pwd)
build_dir=${root_dir}/build
cache_dir=${build_dir}/cache
build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}-windows.zip
love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

. "${root_dir}/scripts/util.sh"

if [ ! -f "$love_file" ]; then
	echo "Need to build the .love file first."
	exit 1
fi
if [ ! -d "${cache_dir}" ]; then
	mkdir "${cache_dir}"
fi

echo "Getting Windows LÖVE binary."
cd "$cache_dir"

love_zip=love-${LOVE_VERSION}-win64.zip
dlcache "https://github.com/love2d/love/releases/download/${LOVE_VERSION}/${love_zip}"
unzip "${love_zip}"

echo "Building Windows package."
windows_build_dir="${build_dir}/synthein-windows"
windows_src_dir="${cache_dir}/${love_zip%.zip}"
if [ -d "$windows_build_dir" ]; then
	rm -r "$windows_build_dir"
fi
mkdir "$windows_build_dir"
cd "$windows_build_dir"
cat "${cache_dir}/love-${LOVE_VERSION}-win64/love.exe" "$love_file" > synthein.exe
cp "${cache_dir}/love-${LOVE_VERSION}-win64/"*.dll ./
cp "${root_dir}/README.md" README.md
cp "${root_dir}/LICENSE" license.txt
cp "${cache_dir}/love-${LOVE_VERSION}-win64/license.txt" license-3rd-party.txt

cd "$build_dir"
zip -r "$build_file" synthein-windows/

# Clean up.
rm -r "${cache_dir}/love-${LOVE_VERSION}-win64"
rm -r "${build_dir}/synthein-windows"

echo "Built ${build_file}."
