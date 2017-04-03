#!/bin/sh
set -e

ROOT_DIR=$(pwd)

if [ ! -f "${ROOT_DIR}/build/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting Windows LÖVE binary."
cd "${ROOT_DIR}/build"
curl -L -O "http://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win64.zip"
unzip love-${LOVE_VERSION}-win64.zip

echo "Building Windows package."
mkdir "${ROOT_DIR}/build/synthein-windows"
cd "${ROOT_DIR}/build/synthein-windows"
echo $SYNTHEIN_VERSION > VERSION
cat ../love-${LOVE_VERSION}-win64/love.exe ../synthein-${SYNTHEIN_VERSION}.love > synthein.exe
cp ../love-${LOVE_VERSION}-win64/*.dll ../love-${LOVE_VERSION}-win64/license.txt ./

cd "${ROOT_DIR}/build"
zip -r "synthein-windows-${SYNTHEIN_VERSION}.zip" synthein-windows/

echo "Built $(find . -name synthein-windows*.zip)."
