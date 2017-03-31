#!/bin/sh
set -e

if [ ! -f build/synthein.love ]; then
	echo "Need to build the .love file first."
	exit 1
fi

curl -O https://bitbucket.org/rude/love/downloads/love-0.10.2-win64.zip
unzip love-0.10.2-win64.zip

mkdir build/synthein-windows
cat love-0.10.2-win64/love.exe build/synthein.love > build/synthein-windows/synthein.exe
cp love-0.10.2-win64/*.dll love-0.10.2-win64/licence.txt build/synthein-windows

cd build
zip -r synthein-windows.zip synthein-windows/

echo "Built $(find . -name synthein-windows.zip)."
