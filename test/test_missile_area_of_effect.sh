#!/bin/sh

extra_args="$1"
output="$2"

love src $extra_args --scene=test-missile2 > "$output" <<EOF
return #world.objects
sleep(2)
return #world.objects
quit()
EOF

output_before=$(sed -n 1p "$output")
output_after=$(sed -n 2p "$output")

if ! [ "$output_before" -eq 16 ]; then
	printf "FAILED: expected %s = 16\n" "$output_before"
	exit 1
fi
if ! [ "$output_after" -eq 11 ]; then
	printf "FAILED: expected %s = 11\n" "$output_after"
	exit 1
fi
