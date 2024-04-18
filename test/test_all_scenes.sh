#!/bin/sh

extra_args="$1"

find src/res/scenes -name '*.txt' | sed -E 's|.*/([[:alnum:]_-]+).txt|\1|' | while IFS= read -r scene; do
	if ! output=$(echo "quit()" | love src $extra_args --scene "$scene" 2>&1)
	then
		printf "FAILED: scene %s crashed:\n%s\n" "$scene" "$output"
		exit 1
	fi
done
