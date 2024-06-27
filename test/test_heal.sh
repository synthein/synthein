#!/bin/sh

extra_args="$1"
output="$2"

love src $extra_args --scene=test-general1 > "$output" 2>/dev/null <<EOF
players[1].ship.corePart.modules.hull.health = 1
timer = players[1].ship.corePart.modules.heal.timer
timer.time = 0.1
players[1].ship.corePart.modules.heal.timer = timer
sleep(1)
return players[1].ship.corePart.modules.hull.health
quit()
EOF

actual=$(cat "$output")
if ! [ "$actual" -gt 1 ]; then
	printf "FAILED: expected %s > 1\n" "$actual"
	exit 1
fi
