#!/bin/sh
set -u

# Setup
output=$(mktemp)
result=0

extra_args=

! [ "${SYNTHEIN_ENABLE_TEST_GRAPHICS:-0}" = 1 ] && extra_args="$extra_args --headless"

# Run test
message=$(sh -eu "$1" "$extra_args" "$output" 2>&1)
result=$?
if [ "$result" -eq 0 ]; then
	printf .
else
	printf "%s: %s\n" "$1" "$message"
fi

# Cleanup
rm "$output"

exit $result
