#!/bin/sh
set -e

root_dir="$(pwd)"
build_dir="${root_dir}/build"
build_file="${build_dir}/synthein-${SYNTHEIN_VERSION}.love"

if [ ! -d "${build_dir}" ]; then
	mkdir "${build_dir}"
fi

cd src
zip -9 -r "${build_file}" .

cd "${root_dir}"
echo "Built ${build_file}."
