#!/bin/sh
set -eu

find "$(dirname "$0")" -name 'test_*.sh' -exec sh -eu {} \;
