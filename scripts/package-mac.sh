#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"
build_file="${build_dir}/synthein-mac-${SYNTHEIN_VERSION}.zip"

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi

echo "Getting MacOS LÖVE binary."
cd "${build_dir}"
curl -L -O "https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-macosx-x64.zip"
unzip "love-${LOVE_VERSION}-macosx-x64.zip"

echo "Building MacOS package."
app_file="${build_dir}/synthein.app"

if [ -d "${app_file}" ]; then
	rm -r "${app_file}"
fi
cp -aR "love.app" "${app_file}"
cp "synthein-${SYNTHEIN_VERSION}.love" "${app_file}/Contents/Resources/"
sed -i -e 's/<string>org.love2d.love<\/string>/<string>net.synthein.synthein<\/string>/' "${app_file}/Contents/Info.plist"
sed -i -e 's/<string>LÖVE<\/string>/<string>Synthein<\/string>/' "${app_file}/Contents/Info.plist"
sed -i -e '98,126d' "${app_file}/Contents/Info.plist"

cd "${build_dir}"
zip -r "${build_file}" synthein.app

echo "Built ${build_file}."
