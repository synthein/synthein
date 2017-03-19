#!/bin/sh

cd src

if [ ! -d build ]; then
	mkdir build
fi

zip -9 -r build/synthein.love .
