input=$(mktemp -u)
mkfifo "$input"
output=$(mktemp)
result=0

love src --headless --scene test-general1 < "$input" > "$output" 2>/dev/null &
exec 3>"$input"

cat >> "$input" <<EOF
players[1].ship.corePart.modules.hull.health = 1
players[1].ship.corePart.modules.heal.timer.time = 0.1
EOF

sleep 1

cat >> "$input" <<EOF
return players[1].ship.corePart.modules.hull.health
quit()
EOF

exec 3>&-
wait

actual=$(cat "$output")
if [ $actual -gt 1 ]; then
	printf .
else
	printf "FAILED: expected %s > 1\n" "$actual"
	result=1
fi

rm "$input"
rm "$output"

exit $result
