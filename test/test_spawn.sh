#!/bin/sh

input="$1"
output="$2"
extra_args="$3"

love src $extra_args --scene startScene < "$input" > "$output" &

exec 3>"$input"

cat >> "$input" <<EOF
return #world.objects
debugmode.on = true
debugmode.spawn = true
EOF

sleep 2

cat >> "$input" <<EOF
return #world.objects
quit()
EOF

exec 3>&-
wait

output_before=$(sed -n 1p "$output")
output_after=$(sed -n 2p "$output")

if ! [ "$output_after" -gt "$output_before" ]; then
	printf "FAILED: expected %s > %s\n" "$output_after" "$output_before"
	return 1
fi
