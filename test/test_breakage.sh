#!/bin/sh

extra_args="$1"
output="$2"

love src $extra_args --scene test-breakage > "$output" <<EOF
return #world.objects
sleep(2)
return #world.objects
quit()
EOF

num_objects_before=$(sed -n 1p "$output")
num_objects_after=$(sed -n 2p "$output")

if ! [ "$num_objects_before" -eq 2 -a "$num_objects_after" -eq 3 ]; then
	printf "FAILED: expected 2 objects before breakage (actual: %s) " "$num_objects_before"
	printf "and 3 objects after (actual: %s)\n" "$num_objects_after"
	return 1
fi
