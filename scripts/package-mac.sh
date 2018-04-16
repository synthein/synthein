#!/bin/sh
set -e

main () {
	root_dir=$(pwd)
	build_dir=${root_dir}/build
	cache_dir=${build_dir}/cache
	build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}-mac.zip
	love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

	if [ ! -f "$love_file" ]; then
		echo "Need to build the .love file first."
		exit 1
	fi

	echo "Getting MacOS LÖVE binary."
	cd "${cache_dir}"
	dlcache "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-macosx-x64.zip"
	unzip "love-${LOVE_VERSION}-macosx-x64.zip"

	echo "Building MacOS package."
	app_dir="${build_dir}/synthein.app"

	cp -R "${cache_dir}/love.app" "$app_dir"
	cd "$app_dir"

	cp "$love_file" "Contents/Resources/"
	sed -i -e 's/<string>org.love2d.love<\/string>/<string>net.synthein.synthein<\/string>/' Contents/Info.plist
	sed -i -e 's/<string>LÖVE<\/string>/<string>Synthein<\/string>/' Contents/Info.plist
	sed -i -e '98,126d' Contents/Info.plist

	cd "$build_dir"
	zip -r "$build_file" synthein.app

	# Clean up.
	rm -r "${cache_dir}/love.app"
	rm -r "$app_dir"

	echo "Built ${build_file}."
}

dlcache () {
	if [ ! -f "$(basename $1)" ]; then
		curl -L -O "$1"
	fi
}

main
