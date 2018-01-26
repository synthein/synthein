#!/bin/sh

if command -v luacheck >/dev/null 2>&1; then
	cmd="luacheck --std=luajit+love"
else
	echo "luacheck is not installed. Falling back to 'luac -p'."
	cmd="luac -p"
fi

find src -name '*.lua' -exec $cmd {} +
