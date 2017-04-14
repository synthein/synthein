#!/bin/sh
set -e

ROOT_DIR=$(pwd)

if [ ! -f "${ROOT_DIR}/build/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting MacOS LÖVE binary."
cd "${ROOT_DIR}/build"
#curl -L -O "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-macosx-x64.zip"
unzip "love-${LOVE_VERSION}-macosx-x64.zip"

echo "Building MacOS package."
APP_FILE="${ROOT_DIR}/build/synthein.app"

if [ -d "${APP_FILE}" ]; then
	rm -r "${APP_FILE}"
fi
cp -aR "love.app" "${APP_FILE}"
cp "synthein-${SYNTHEIN_VERSION}.love" "${APP_FILE}/Contents/Resources/"
sed -i -e 's/<string>org.love2d.love<\/string>/<string>net.synthein.synthein<\/string>/' "${APP_FILE}/Contents/Info.plist"
sed -i -e 's/<string>LÖVE<\/string>/<string>Synthein<\/string>/' "${APP_FILE}/Contents/Info.plist"
sed -i -e '98,126d' "${APP_FILE}/Contents/Info.plist"

cd "${ROOT_DIR}/build"
zip -r "synthein-mac-${SYNTHEIN_VERSION}.zip" synthein.app

echo "Built $(find . -name synthein-mac*.zip)."
