#!/bin/sh
set -eu

tests_dir=$(dirname "$0")

find "$tests_dir" -name 'test_*.sh' -exec "$tests_dir"/run_test.sh {} \;
