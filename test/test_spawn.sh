#!/bin/sh

extra_args="$1"
output="$2"

love src $extra_args --scene startScene > "$output" <<EOF
return #world.objects
debugmode.on = true
debugmode.spawn = true
sleep(2)
return #world.objects
quit()
EOF

output_before=$(sed -n 1p "$output")
output_after=$(sed -n 2p "$output")

if ! [ "$output_after" -gt "$output_before" ]; then
	printf "FAILED: expected %s > %s\n" "$output_after" "$output_before"
	return 1
fi
