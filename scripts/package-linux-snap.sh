#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"

if [ ! -f "${build_dir}/synthein-${SYNTHEIN_VERSION}.love" ]; then
	echo "Need to build the .love file first."
	exit 1
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
