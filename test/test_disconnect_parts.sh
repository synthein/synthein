#!/bin/sh

input="$1"
output="$2"
extra_args="$3"

love src $extra_args --scene test-disconnect-parts > "$output" <<EOF
return #world.objects
world.objects[2]:disconnectPart({1,-1})
return #world.objects
quit()
EOF

num_objects_before=$(sed -n 1p "$output")
num_objects_after=$(sed -n 2p "$output")

if ! [ "$num_objects_before" -eq 2 -a "$num_objects_after" -eq 4 ]; then
	printf "FAILED: expected 2 objects before disconnect (actual: %s) " "$num_objects_before"
	printf "and 4 objects after (actual: %s)\n" "$num_objects_after"
	return 1
fi
