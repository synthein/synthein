synthein_version = devel
love_version = 11.3

env = SYNTHEIN_VERSION=$(synthein_version) LOVE_VERSION=$(love_version)

# Building commands
love: rust build/synthein-$(synthein_version).love

build/synthein-$(synthein_version).love: $(shell find ./src/ -type f)
	$(env) scripts/package-love.sh

appimage: love
	$(env) scripts/package-linux-appimage.sh

macos: love
	$(env) scripts/package-macos.sh

windows: love
	$(env) scripts/package-windows.sh

rust:
	cd lib/sonic && cargo build
	cp lib/sonic/target/debug/libsonic.so src/sonic.so

# Maintenance commands
run: rust
	love src

check:
	find src -name '*.lua' -not -path 'src/vendor/*' | xargs wc -l | sort -rg
	find src -name '*.lua' -exec luac -p {} + && echo "No problems found"

clean:
	rm -rf build/
	rm -f src/*.so

dep:
	scripts/dependency-graph.lua --dot src/main.lua | dot -T png | display

luacheck:
	find src -name '*.lua' -not -path 'src/vendor/*' -exec luacheck --no-unused-args {} +

test:
	love src --test

.PHONY: appimage check clean dep love luacheck macos rust test windows
