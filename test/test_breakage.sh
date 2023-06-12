#!/bin/sh

input="$1"
output="$2"
extra_args="$3"

love src $extra_args --scene test-breakage < "$input" > "$output" &

exec 3>"$input"

cat >> "$input" <<EOF
return #world.objects
EOF

sleep 2

cat >> "$input" <<EOF
return #world.objects
quit()
EOF

exec 3>&-
wait

num_objects_before=$(sed -n 1p "$output")
num_objects_after=$(sed -n 2p "$output")

if ! [ "$num_objects_before" -eq 2 -a "$num_objects_after" -eq 2 ]; then
	printf "FAILED: expected 2 objects before breakage (actual: %s) " "$num_objects_before"
	printf "and 2 objects after (actual: %s)\n" "$num_objects_after"
	return 1
fi
