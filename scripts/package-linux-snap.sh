#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"
cache_dir=${build_dir}/cache

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
fi
if [ ! -d "${cache_dir}" ]; then
	mkdir "${cache_dir}"
fi

echo "Getting Linux LÖVE binaries."
cd "${cache_dir}"
love_tar="love-${LOVE_VERSION}-x86_64.tar.gz"
if [ ! -f "$love_tar" ]; then
	curl -L -O "https://bitbucket.org/rude/love/downloads/${love_tar}"
fi

echo "Building snap package."
cd "${root_dir}/package/snapcraft"
if [ ! -d snap ]; then
	mkdir snap
fi

if [ ${SYNTHEIN_VERSION} = 'devel' ]; then
	grade=devel
else
	grade=stable
fi

sed <snapcraft.yaml.template \
	-e "s/{{version}}/${SYNTHEIN_VERSION}/g" \
	-e "s/{{love_version}}/${LOVE_VERSION}/g" \
  -e "s/{{grade}}/${grade}/g" \
	> snap/snapcraft.yaml

snapcraft clean
snapcraft snap -o "${build_dir}/synthein_${SYNTHEIN_VERSION}.snap"

dlcache () {
	if [ ! -f "$(basename $1)" ]; then
		curl -L -O "$1"
	fi
}
