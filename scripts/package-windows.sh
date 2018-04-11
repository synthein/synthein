#!/bin/sh
set -e

main () {
	root_dir=$(pwd)
	build_dir=${root_dir}/build
	cache_dir=${build_dir}/cache
	build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}-windows.zip
	love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

	if [ ! -f "$love_file" ]; then
		echo "Need to build the .love file first."
		exit 1
	fi

	echo "Getting Windows LÖVE binary."
	cd "$cache_dir"
	dlcache "http://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win64.zip"
	unzip "love-${LOVE_VERSION}-win64.zip"

	echo "Building Windows package."
	windows_build_dir="${build_dir}/synthein-windows"
	if [ -d "$windows_build_dir" ]; then
		rm -r "$windows_build_dir"
	fi
	mkdir "$windows_build_dir"
	cd "$windows_build_dir"
	cat "${cache_dir}/love-${LOVE_VERSION}-win64/love.exe" "$love_file" > synthein.exe
	cp "${cache_dir}/love-${LOVE_VERSION}-win64/"*.dll "${cache_dir}/love-${LOVE_VERSION}-win64/license.txt" ./

	cd "$build_dir"
	zip -r "$build_file" synthein-windows/

	# Clean up.
	rm -r "${cache_dir}/love-${LOVE_VERSION}-win64"
	rm -r "${build_dir}/synthein-windows"

	echo "Built ${build_file}."
}

dlcache () {
	if [ ! -f "$(basename $1)" ]; then
		curl -L -O "$1"
	fi
}

main
