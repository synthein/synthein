#!/bin/sh
set -e

if [ ! -d build ]; then
	mkdir build
fi

cd src
zip -9 -r "../build/synthein-${SYNTHEIN_VERSION}.love" .

cd ..
echo "Built $(find . -name synthein*.love)."
