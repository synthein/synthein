#!/bin/sh

if [ "$1" != "-f" ]; then
	if command -v luacheck >/dev/null 2>&1; then
		cmd="luacheck --std=luajit+love"
	else
		echo "luacheck is not installed. Falling back to 'luac -p'."
	fi
fi

if [ -z "$cmd" ]; then
	cmd="luac -p"
fi

find src -name '*.lua' -exec $cmd {} +
