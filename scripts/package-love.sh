#!/bin/sh
set -e

build_file="${PWD}/build/synthein-${SYNTHEIN_VERSION}.love"

mkdir -p "$(dirname "$build_file")"

cd src
zip -9 -r "${build_file}" .

cd ../build
echo "return \"${SYNTHEIN_VERSION}\"" > version.lua
zip -9 "${build_file}" version.lua

echo "Built ${build_file}."
