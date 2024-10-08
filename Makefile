synthein_version = devel
love_version = 11.4

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

# Building commands
love: rust
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

macos: love
	$(env) scripts/package-macos.sh

windows: love
	$(env) scripts/package-windows.sh

rust:
	cargo build --release
	cp target/release/libsyntheinrust.so src/syntheinrust.so

# Maintenance commands
check:
	find src -name '*.lua' -not -path 'src/vendor/*' | xargs wc -l | sort -rg
	find src -name '*.lua' -exec luac -p {} + && echo "No problems found"

clean:
	rm -rf build/
	rm -f src/*.so

dep:
	scripts/dependency-graph.lua --dot src/main.lua | dot -T png | display

map:
	dot -T png TaskMap.dot >TaskMap.png
	display TaskMap.png

analyzeDrawTimes:
	love tools/analyzeDrawTimes

luacheck:
	find src -name '*.lua' -not -path 'src/vendor/*' -exec luacheck --no-unused-args {} +

test:
	printf '\n' | love src --unit-tests
	test/init.sh

.PHONY: analyzeDrawTimes appimage check clean dep love luacheck macos rust test windows
