#!/bin/sh

input="$1"
output="$2"
extra_args="$3"

love src $extra_args --scene test-missile2 < "$input" > "$output" 2>/dev/null &
exec 3>"$input"

cat >> "$input" <<EOF
return #world.objects
EOF

sleep 5

cat >> "$input" <<EOF
return #world.objects
quit()
EOF

exec 3>&-
wait

output_before=$(sed -n 1p "$output")
output_after=$(sed -n 2p "$output")

if ! [ "$output_before" -eq 16 ]; then
	printf "FAILED: expected %s = 16\n" "$output_before"
	return 1
fi
if ! [ "$output_after" -eq 9 ]; then
	printf "FAILED: expected %s = 9\n" "$output_after"
	return 1
fi
