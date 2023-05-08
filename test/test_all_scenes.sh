#!/bin/sh

extra_args="$3"

find src/res/scenes -name '*.txt' | sed -E 's|.*/([[:alnum:]_-]+).txt|\1|' | while IFS= read -r scene; do
	love src $extra_args --scene "$scene" <<EOF
quit()
EOF
	
	if [ $? -gt 0 ]; then
		printf "FAILED: scene %s crashed\n" "$scene"
		return 1
	fi
done
