#!/bin/sh
set -e

if [ ! -d build ]; then
	mkdir build
fi

cd src
zip -9 -r ../build/synthein.love .

cd ..
echo "Built $(find . -name synthein.love)."
