#!/bin/sh

input="$1"
output="$2"
extra_args="$3"

love src $extra_args --scene test-general1 < "$input" > "$output" 2>/dev/null &

# Hold input open until after all our writes are done.
exec 3>"$input"

cat >> "$input" <<EOF
players[1].ship.corePart.modules.hull.health = 1
timer = players[1].ship.corePart.modules.heal.timer
timer.time = 0.1
players[1].ship.corePart.modules.heal.timer = timer
EOF

sleep 1

cat >> "$input" <<EOF
return players[1].ship.corePart.modules.hull.health
quit()
EOF

# Close input.
exec 3>&-

# Wait for love to exit.
wait

actual=$(cat "$output")
if ! [ "$actual" -gt 1 ]; then
	printf "FAILED: expected %s > 1\n" "$actual"
	return 1
fi
