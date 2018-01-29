#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"
build_file="${build_dir}/synthein-windows-${SYNTHEIN_VERSION}.zip"

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting Windows LÖVE binary."
cd "${build_dir}"
curl -L -O "http://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-win64.zip"
unzip "love-${LOVE_VERSION}-win64.zip"

echo "Building Windows package."
windows_build_dir="${build_dir}/synthein-windows"
if [ -d "${windows_build_dir}" ]; then
	rm -r "${windows_build_dir}"
fi
mkdir "${windows_build_dir}"
cd "${windows_build_dir}"
echo $SYNTHEIN_VERSION > SYNTHEIN_VERSION
cat ../love-${LOVE_VERSION}-win64/love.exe ../synthein-${SYNTHEIN_VERSION}.love > synthein.exe
cp ../love-${LOVE_VERSION}-win64/*.dll ../love-${LOVE_VERSION}-win64/license.txt ./

cd "${build_dir}"
zip -r "${build_file}" synthein-windows/

echo "Built ${build_file}."
