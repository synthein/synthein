#!/bin/sh
set -eu

# Setup
input=$(mktemp -u)
mkfifo "$input"
output=$(mktemp)
result=0

extra_args=

! [ "${SYNTHEIN_ENABLE_TEST_GRAPHICS:-0}" = 1 ] && extra_args="$extra_args --headless"

# Run test
sh -eu "$1" "$input" "$output" "$extra_args"
result=$?
[ "$result" -eq 0 ] && printf .

# Cleanup
rm "$input"
rm "$output"

exit $result
