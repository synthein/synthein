#!/bin/sh
set -e

main () {
	root_dir=$(pwd)
	build_dir=${root_dir}/build
	build_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.AppImage
	love_file=${build_dir}/synthein-${SYNTHEIN_VERSION}.love

	if [ ! -f "$love_file" ]; then
		echo "Need to build the .love file first."
		exit 1
	fi

	echo "Getting Linux LÖVE binaries."
	if [ ! -d "${build_dir}/cache" ]; then
		mkdir "${build_dir}/cache"
	fi
	cd "${build_dir}/cache"

	love_deb="love_${LOVE_VERSION}ppa1_amd64.deb"
	if [ ! -f "$love_deb" ]; then
		curl -L -O "https://bitbucket.org/rude/love/downloads/love_${LOVE_VERSION}ppa1_amd64.deb"
	fi

	liblove_deb="liblove0_${LOVE_VERSION}ppa1_amd64.deb"
	if [ ! -f "$liblove_deb" ]; then
		curl -L -O "https://bitbucket.org/rude/love/downloads/liblove0_${LOVE_VERSION}ppa1_amd64.deb"
	fi

	dpkg --install "$love_deb" "$liblove_deb" || apt-get -yf install

	echo "Building AppImage package."
	cd "${build_dir}/cache"
	if [ ! -f "${build_dir}/cache/AppRun-x86_64" ]; then
		curl -L -O "https://github.com/probonopd/AppImageKit/releases/download/continuous/AppRun-x86_64"
	fi

	if [ -d "${build_dir}/synthein-appimage" ]; then
		rm -r "${build_dir}/synthein-appimage"
	fi
	mkdir "${build_dir}/synthein-appimage"
	cd "${build_dir}/synthein-appimage"

	# Install Synthein.
	install -D -m0755 "${build_dir}/cache/AppRun-x86_64" AppRun
	install -D -m0755 "${root_dir}/package/desktop/synthein.appimage.sh" usr/bin/synthein
	install -D "$love_file" usr/share/synthein/synthein.love
	install -D "${root_dir}/package/desktop/synthein.desktop" usr/share/applications/synthein.desktop
	install -D "${root_dir}/package/desktop/synthein.png" usr/share/pixmaps/synthein.png
	ln -s usr/share/applications/synthein.desktop synthein.desktop
	ln -s usr/share/pixmaps/synthein.png synthein.png

	# Install LOVE.
	install -D -m0755 /usr/bin/love usr/bin/love
	install -D /usr/lib/x86_64-linux-gnu/liblove.so.0 usr/lib/liblove.so.0
	install -D /usr/lib/x86_64-linux-gnu/liblove.so.0.0.0 usr/lib/liblove.so.0.0.0
	install -d usr/share/doc/love
	install -t usr/share/doc/love /usr/share/doc/love/copyright /usr/share/doc/love/readme.md

	# Install dependencies.
	install_libraries \
		libSDL2-2.0 \
		libluajit-5.1 \
		libmodplug \
		libopenal \
		libphysfs \
		libsndio

	# Package as an AppImage.
	cd "${build_dir}/cache"
	if [ ! -f appimagetool-x86_64.AppImage ]; then
		curl -L -O "https://github.com/probonopd/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
	fi
	chmod a+x appimagetool-x86_64.AppImage

	./appimagetool-x86_64.AppImage --appimage-extract 2> /dev/null
	./squashfs-root/AppRun "${build_dir}/synthein-appimage/" "${build_file}"

	echo "Built ${build_file}."
}

install_libraries () {
	libraries=''
	for libname in $@; do
		lib=$(ldconfig -p | sed -En "/$libname/"'s/.* => (.*)/\1/p')
		if [ -n "$lib" ]; then
			libraries="$libraries $lib"
		else
			echo "Warning: Couldn't find library \"$libname\""
		fi
	done
	install -d usr/lib
	install -t usr/lib/ $libraries
}

main
